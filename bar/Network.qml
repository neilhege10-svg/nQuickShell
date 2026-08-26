import "../state"
import Qt5Compat.GraphicalEffects
import QtQuick
import Quickshell.Io

Item {
    id: root

    // ── CORE PROPERTIES ──────────────────────────────────
    property var t
    property string netIcon: "../svg/wifi-off.svg"
    property string netName: "..."

    // Tell the Bar's RowLayout how much space this module needs
    implicitHeight: t ? t.pillHeight : 32
    implicitWidth: (root.t ? root.t.fontSize + 4 : 18) + (4 * 2)

    // ── GLOW / SHADOW EFFECT ─────────────────────────────
    DropShadow {
        anchors.fill: pill
        horizontalOffset: 3
        verticalOffset: 2
        radius: 8
        samples: 17
        color: "#000000"
        source: pill
        opacity: mouseArea.pressed ? 0.6 : 0

        Behavior on opacity {
            NumberAnimation {
                duration: 150
                easing.type: Easing.InOutQuad
            }
        }
    }

    // ── MAIN PILL CONTAINER ──────────────────────────────
    Rectangle {
        id: pill

        anchors.fill: parent
        radius: t ? t.widgetRadius : 12
        color: "transparent"
        scale: mouseArea.pressed ? 0.88 : 1.0

        Behavior on scale {
            NumberAnimation {
                duration: 120
                easing.type: Easing.OutQuad
            }
        }

        // ── PROCESS 1: Check Network & Wi-Fi Radio Status ──────
        Process {
            id: netProc

            // Outputs single-line JSON: {"type":"802-3-ethernet|802-11-wireless|none", "wifi":"enabled|disabled"}
            command: ["bash", "-c", "TYPE=$(nmcli -t -f TYPE,STATE connection show --active 2>/dev/null | grep ':activated' | head -1 | cut -d: -f1); [ -z \"$TYPE\" ] && TYPE=\"none\"; WIFI=$(nmcli radio wifi 2>/dev/null); echo \"{\\\"type\\\":\\\"$TYPE\\\",\\\"wifi\\\":\\\"$WIFI\\\"}\""]
            running: true

            stdout: SplitParser {
                onRead: (data) => {
                    var str = data.trim();
                    if (!str.startsWith("{")) return;

                    try {
                        var res = JSON.parse(str);
                        var type = res.type || "none";
                        var wifiState = res.wifi || "disabled";

                        // 1. Ethernet Connected -> Highest Priority
                        if (type === "802-3-ethernet") {
                            root.netIcon = "../svg/ethernet.svg";
                            root.netName = "LAN";
                            return;
                        }

                        // 2. Wi-Fi Connected
                        if (type === "802-11-wireless") {
                            root.netIcon = "../svg/wifi-high.svg";
                            root.netName = "WiFi";
                            return;
                        }

                        // 3. Wi-Fi Radio Powered Off or Disconnected
                        root.netIcon = "../svg/wifi-off.svg";
                        root.netName = (wifiState === "disabled") ? "Off" : "Disconnected";
                    } catch (e) {
                        console.log("Network parsing error:", e);
                    }
                }
            }
        }

        // ── PROCESS 2: Toggle Wi-Fi Power ────────────────────
        Process {
            id: wifiToggleProc

            command: ["bash", "-c", root.netIcon === "../svg/wifi-off.svg" ? "nmcli radio wifi on" : "nmcli radio wifi off"]
            
            // Re-run status check once toggle completes
            onExited: netProc.running = true
        }

        // ── AUTO-REFRESH TIMER ──────────────────────────────
        Timer {
            interval: 10000
            repeat: true
            running: true
            onTriggered: netProc.running = true
        }

        // ── ICON DISPLAY ─────────────────────────────────────
        Image {
            id: netLabel

            source: root.netIcon
            width: root.t ? root.t.fontSize + 4 : 18
            height: width

            anchors.centerIn: parent
            anchors.verticalCenterOffset: -2

            layer.enabled: true
            layer.effect: ColorOverlay {
                color: root.t ? root.t.base.text : "#cdd6f4"

                Behavior on color {
                    ColorAnimation {
                        duration: 300
                    }
                }
            }
        }

        Behavior on color {
            ColorAnimation {
                duration: 330
            }
        }

        Behavior on radius {
            NumberAnimation {
                duration: 330
            }
        }
    }

    // ── CLICK INTERACTION ────────────────────────────────
    MouseArea {
        id: mouseArea

        anchors.fill: parent
        
        // Pointer cursor for Wi-Fi / Disconnected, Arrow cursor for Ethernet
        cursorShape: root.netName === "LAN" ? Qt.ArrowCursor : Qt.PointingHandCursor

        onClicked: {
            if (root.netName !== "LAN") {
                wifiToggleProc.running = true;
            }
        }
    }
}
