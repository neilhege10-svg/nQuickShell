pragma Singleton

import QtQuick
import Quickshell.Io

Item {
    id: root
    visible: false

    // ── PUBLIC PROPERTIES ──────────────────────────────────────────────
    property var networks: []
    property var btDevices: []
    property string activeConnectionName: ""
    property string activeConnectionType: ""
    property string activeIp: ""
    property bool wifiEnabled: false
    property bool btEnabled: false

    // ── INTERNAL ───────────────────────────────────────────────────────
    property var _netBuf: []
    property var _btBuf: []
    // Tracks how many of the two network processes (active + wifi) have
    // finished so we only commit root.networks once both are done
    property int _netDone: 0

    Component.onCompleted: {
        console.log("NetworkService loaded ✓")
        wifiStateProcess.running = true
        btStateProcess.running = true
    }

    // ── POLL TIMER ─────────────────────────────────────────────────────
    // 10s for network, 15s for bluetooth — reasonable refresh without hammering
    Timer {
        id: pollTimer
        interval: 10000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: {
            root._netBuf   = []
            root._netDone  = 0
            root.activeConnectionName = ""
            root.activeConnectionType = ""
            root.activeIp  = ""
            activeProcess.running = true
            // Only scan WiFi if the adapter is on — avoids the 30-60s hardware scan
            if (root.wifiEnabled)
                wifiProcess.running = true
            else
                root._netDone++ // count wifi as "done" so ethernet still commits
            ipProcess.running = true
        }
    }

    // ── ACTIVE CONNECTIONS (ethernet / vpn / known wifi) ───────────────
    Process {
        id: activeProcess
        command: ["nmcli", "-t", "-f", "NAME,TYPE,DEVICE,STATE", "con", "show", "--active"]
        running: false

        stdout: SplitParser {
            onRead: function(line) {
                if (!line.trim()) return
                const parts = line.split(":")
                if (parts.length < 4) return
                const name  = parts[0].trim()
                const type  = parts[1].trim()
                const state = parts[3].trim()
                if (state !== "activated") return

                const isEthernet = type.includes("ethernet")
                if (!root.activeConnectionName) {
                    root.activeConnectionName = name
                    root.activeConnectionType = isEthernet ? "ethernet" : "wifi"
                }
                if (isEthernet) {
                    root._netBuf.push({ name: name, signal: 100, secured: true, active: true, type: "ethernet" })
                }
            }
        }

        onExited: function() {
            root._netDone++
            // If both processes are done (or wifi was skipped), commit
            if (root._netDone >= 2)
                root.networks = root._netBuf.slice()
        }
    }

    // ── WIFI SCAN ──────────────────────────────────────────────────────
    // --rescan no  →  returns cached results IMMEDIATELY instead of
    //                 triggering a 30-60s hardware scan every poll
    Process {
        id: wifiProcess
        command: ["nmcli", "-t", "-f", "IN-USE,SSID,SIGNAL,SECURITY", "dev", "wifi", "list", "--rescan", "no"]
        running: false

        stdout: SplitParser {
            onRead: function(line) {
                if (!line.trim()) return
                const parts = line.split(":")
                if (parts.length < 4) return
                const inUse   = parts[0].trim() === "*"
                const ssid    = parts[1].trim()
                if (!ssid) return
                const signal  = parseInt(parts[2]) || 0
                const secured = parts[3].trim() !== "--" && parts[3].trim() !== ""
                root._netBuf.push({ name: ssid, signal: signal, secured: secured, active: inUse, type: "wifi" })
            }
        }

        onExited: function() {
            root._netDone++
            if (root._netDone >= 2)
                root.networks = root._netBuf.slice()
        }
    }

    // ── IP ADDRESS ─────────────────────────────────────────────────────
    Process {
        id: ipProcess
        command: ["bash", "-c", "ip -4 addr show | grep 'inet ' | grep -v '127.0.0.1' | head -1 | awk '{print $2}' | cut -d/ -f1"]
        running: false

        stdout: SplitParser {
            onRead: function(line) {
                const ip = line.trim()
                if (ip) root.activeIp = ip
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
            root._btBuf = []
            btProcess.running = true
        }
    }

    Process {
        id: btProcess
        command: ["bluetoothctl", "devices", "Paired"]
        running: false

        stdout: SplitParser {
            onRead: function(line) {
                const match = line.match(/^Device\s+([0-9A-Fa-f:]+)\s+(.+)$/)
                if (!match) return
                root._btBuf.push({ mac: match[1], name: match[2].trim(), connected: false })
            }
        }

        onExited: function() {
            root.btDevices = root._btBuf.slice()
            if (root._btBuf.length > 0)
                btStatusProcess.running = true
        }
    }

    Process {
        id: btStatusProcess
        command: ["bash", "-c", "for mac in $(bluetoothctl devices Paired | awk '{print $2}'); do echo \"$mac $(bluetoothctl info $mac | grep 'Connected:' | awk '{print $2}')\"; done"]
        running: false

        stdout: SplitParser {
            onRead: function(line) {
                const parts = line.trim().split(" ")
                if (parts.length < 2) return
                const mac = parts[0]
                const connected = parts[1] === "yes"
                root.btDevices = root.btDevices.map(d =>
                    d.mac === mac ? Object.assign({}, d, { connected: connected }) : d
                )
            }
        }
    }

    // ── WIFI/BT POWER STATE ────────────────────────────────────────────
    Process {
        id: wifiStateProcess
        command: ["nmcli", "radio", "wifi"]
        running: false
        stdout: SplitParser {
            onRead: function(line) { root.wifiEnabled = line.trim() === "enabled" }
        }
    }

    Process {
        id: btStateProcess
        command: ["bash", "-c", "bluetoothctl show | grep 'Powered:' | awk '{print $2}'"]
        running: false
        stdout: SplitParser {
            onRead: function(line) { root.btEnabled = line.trim() === "yes" }
        }
    }

    // ── POWER TOGGLES ──────────────────────────────────────────────────
    Process {
        id: wifiPowerProcess
        running: false
        onExited: function() {
            wifiStateProcess.running = true
            wifiRefreshTimer.start()
        }
    }

    Timer {
        id: wifiRefreshTimer
        interval: 1500
        repeat: false
        onTriggered: { pollTimer.triggered() }
    }

    Process {
        id: btPowerProcess
        running: false
        onExited: function() { btStateProcess.running = true }
    }

    Process { id: connectProcess;  running: false }
    Process { id: btToggleProcess; running: false }

    Timer {
        id: btRefreshTimer
        interval: 2000
        repeat: false
        onTriggered: {
            root._btBuf = []
            btProcess.running = true
        }
    }

    // ── PUBLIC ACTIONS ─────────────────────────────────────────────────
    function connectToNetwork(network, password) {
        if (network.type === "wifi") {
            connectProcess.command = (password && password.length > 0)
                ? ["nmcli", "dev", "wifi", "connect", network.name, "password", password]
                : ["nmcli", "dev", "wifi", "connect", network.name]
            connectProcess.running = true
        }
    }

    function toggleWifiPower() {
        root.wifiEnabled = !root.wifiEnabled
        wifiPowerProcess.command = ["nmcli", "radio", "wifi", root.wifiEnabled ? "on" : "off"]
        wifiPowerProcess.running = true
    }

    function toggleBtPower() {
        root.btEnabled = !root.btEnabled
        btPowerProcess.command = ["bash", "-c", "bluetoothctl power " + (root.btEnabled ? "on" : "off")]
        btPowerProcess.running = true
    }

    function toggleBluetooth(device) {
        btToggleProcess.command = device.connected
            ? ["bluetoothctl", "disconnect", device.mac]
            : ["bluetoothctl", "connect", device.mac]
        btToggleProcess.running = true
        btRefreshTimer.start()
    }
}
