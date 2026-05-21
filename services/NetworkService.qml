import QtQuick
import Quickshell.Io
pragma Singleton

Item {
    id: root

    // ── PUBLIC PROPERTIES ──────────────────────────────────────────────
    property var networks: []
    property var btDevices: []
    property string activeConnectionName: ""
    property string activeConnectionType: ""
    property string activeIp: ""
    // Power states — used by NetworkControl toggle card
    property bool wifiEnabled: false
    property bool btEnabled: false
    // ── INTERNAL BUFFERS ───────────────────────────────────────────────
    property var _netBuf: []
    property var _btBuf: []

    // ── ACTIONS ────────────────────────────────────────────────────────
    function connectToNetwork(network, password) {
        if (network.type === "wifi") {
            // If a password was provided use it, otherwise nmcli uses stored credentials
            if (password && password.length > 0)
                connectProcess.command = ["nmcli", "dev", "wifi", "connect", network.name, "password", password];
            else
                connectProcess.command = ["nmcli", "dev", "wifi", "connect", network.name];
            connectProcess.running = true;
        }
    }

    // Toggle WiFi radio on/off — nmcli radio wifi on/off
    function toggleWifiPower() {
        root.wifiEnabled = !root.wifiEnabled; // optimistic update feels snappier
        wifiPowerProcess.command = ["nmcli", "radio", "wifi", root.wifiEnabled ? "on" : "off"];
        wifiPowerProcess.running = true;
    }

    // Toggle Bluetooth adapter power — bluetoothctl power on/off
    function toggleBtPower() {
        root.btEnabled = !root.btEnabled;
        btPowerProcess.command = ["bash", "-c", "bluetoothctl power " + (root.btEnabled ? "on" : "off")];
        btPowerProcess.running = true;
    }

    function toggleBluetooth(device) {
        btToggleProcess.command = device.connected ? ["bluetoothctl", "disconnect", device.mac] : ["bluetoothctl", "connect", device.mac];
        btToggleProcess.running = true;
        btRefreshTimer.start();
    }

    visible: false
    Component.onCompleted: {
        console.log("NetworkService loaded ✓");
        // Read real power states on startup
        wifiStateProcess.running = true;
        btStateProcess.running = true;
    }

    // ── NETWORK POLL TIMER ─────────────────────────────────────────────
    Timer {
        id: pollTimer

        interval: 10000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: {
            console.log("NetworkService: poll fired");
            root._netBuf = [];
            root.activeConnectionName = "";
            root.activeConnectionType = "";
            root.activeIp = "";
            activeProcess.running = true;
            wifiProcess.running = true;
            ipProcess.running = true;
        }
    }

    // ── ACTIVE CONNECTIONS ─────────────────────────────────────────────
    // Fixed: removed IP4.ADDRESS — not supported here
    // Fields: NAME, TYPE, DEVICE, STATE
    Process {
        id: activeProcess

        command: ["nmcli", "-t", "-f", "NAME,TYPE,DEVICE,STATE", "con", "show", "--active"]
        running: false
        onExited: function(code, status) {
            root.networks = root._netBuf.slice();
            console.log("NetworkService: networks updated →", JSON.stringify(root.networks));
        }

        stdout: SplitParser {
            onRead: function(line) {
                if (!line.trim())
                    return ;

                const parts = line.split(":");
                if (parts.length < 4)
                    return ;

                const name = parts[0].trim();
                const type = parts[1].trim();
                const state = parts[3].trim();
                if (state !== "activated")
                    return ;

                const isEthernet = type.includes("ethernet");
                const isWifi = type.includes("wireless");
                console.log("NetworkService: active connection →", name, type, state);
                // First activated connection sets the status info
                if (!root.activeConnectionName) {
                    root.activeConnectionName = name;
                    root.activeConnectionType = isEthernet ? "ethernet" : "wifi";
                }
                // Ethernet goes into the network list
                if (isEthernet)
                    root._netBuf.push({
                        "name": name,
                        "signal": 100,
                        "secured": true,
                        "active": true,
                        "type": "ethernet"
                    });

            }
        }

    }

    // ── IP ADDRESS ─────────────────────────────────────────────────────
    // Gets the primary IPv4 address via `ip` instead of nmcli
    Process {
        id: ipProcess

        command: ["bash", "-c", "ip -4 addr show | grep 'inet ' | grep -v '127.0.0.1' | head -1 | awk '{print $2}' | cut -d/ -f1"]
        running: false

        stdout: SplitParser {
            onRead: function(line) {
                const ip = line.trim();
                if (ip) {
                    root.activeIp = ip;
                    console.log("NetworkService: IP →", ip);
                }
            }
        }

    }

    // ── WIFI SCAN ──────────────────────────────────────────────────────
    // Only populates if WiFi adapter is active — silent if not
    Process {
        id: wifiProcess

        command: ["nmcli", "-t", "-f", "IN-USE,SSID,SIGNAL,SECURITY", "dev", "wifi", "list"]
        running: false
        onExited: function(code, status) {
            root.networks = root._netBuf.slice();
        }

        stdout: SplitParser {
            onRead: function(line) {
                if (!line.trim())
                    return ;

                const parts = line.split(":");
                if (parts.length < 4)
                    return ;

                const inUse = parts[0].trim() === "*";
                const ssid = parts[1].trim();
                if (!ssid)
                    return ;

                const signal = parseInt(parts[2]) || 0;
                const secured = parts[3].trim() !== "--" && parts[3].trim() !== "";
                console.log("NetworkService: wifi →", ssid, signal);
                root._netBuf.push({
                    "name": ssid,
                    "signal": signal,
                    "secured": secured,
                    "active": inUse,
                    "type": "wifi"
                });
            }
        }

    }

    // ── BLUETOOTH ──────────────────────────────────────────────────────
    Timer {
        id: btPollTimer

        interval: 15000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: {
            root._btBuf = [];
            btProcess.running = true;
        }
    }

    Process {
        id: btProcess

        command: ["bluetoothctl", "devices", "Paired"]
        running: false
        onExited: function(code, status) {
            root.btDevices = root._btBuf.slice();
            if (root._btBuf.length > 0)
                btStatusProcess.running = true;

        }

        stdout: SplitParser {
            onRead: function(line) {
                const match = line.match(/^Device\s+([0-9A-Fa-f:]+)\s+(.+)$/);
                if (!match)
                    return ;

                console.log("NetworkService: bt device →", match[2].trim());
                root._btBuf.push({
                    "mac": match[1],
                    "name": match[2].trim(),
                    "connected": false
                });
            }
        }

    }

    Process {
        id: btStatusProcess

        command: ["bash", "-c", "for mac in $(bluetoothctl devices Paired | awk '{print $2}'); do echo \"$mac $(bluetoothctl info $mac | grep 'Connected:' | awk '{print $2}')\"; done"]
        running: false

        stdout: SplitParser {
            onRead: function(line) {
                const parts = line.trim().split(" ");
                if (parts.length < 2)
                    return ;

                const mac = parts[0];
                const connected = parts[1] === "yes";
                root.btDevices = root.btDevices.map((d) => {
                    return d.mac === mac ? Object.assign({
                    }, d, {
                        "connected": connected
                    }) : d;
                });
            }
        }

    }

    // ── WIFI POWER STATE ───────────────────────────────────────────────
    // "nmcli radio wifi" outputs "enabled" or "disabled"
    Process {
        id: wifiStateProcess

        command: ["nmcli", "radio", "wifi"]
        running: false

        stdout: SplitParser {
            onRead: function(line) {
                root.wifiEnabled = line.trim() === "enabled";
            }
        }

    }

    // ── BLUETOOTH POWER STATE ──────────────────────────────────────────
    // bluetoothctl show | grep Powered → "yes" or "no"
    Process {
        id: btStateProcess

        command: ["bash", "-c", "bluetoothctl show | grep 'Powered:' | awk '{print $2}'"]
        running: false

        stdout: SplitParser {
            onRead: function(line) {
                root.btEnabled = line.trim() === "yes";
            }
        }

    }

    // ── WIFI POWER TOGGLE ──────────────────────────────────────────────
    Process {
        id: wifiPowerProcess

        running: false
        onExited: function() {
            // Re-read actual state after toggling
            wifiStateProcess.running = true;
            // Also re-poll networks after short delay
            wifiRefreshTimer.start();
        }
    }

    Timer {
        id: wifiRefreshTimer

        interval: 1500
        repeat: false
        onTriggered: {
            pollTimer.triggered();
        }
    }

    // ── BLUETOOTH POWER TOGGLE ─────────────────────────────────────────
    Process {
        id: btPowerProcess

        running: false
        onExited: function() {
            btStateProcess.running = true;
        }
    }

    Process {
        id: connectProcess

        running: false
    }

    Process {
        id: btToggleProcess

        running: false
    }

    Timer {
        id: btRefreshTimer

        interval: 2000
        repeat: false
        onTriggered: {
            root._btBuf = [];
            btProcess.running = true;
        }
    }

}
