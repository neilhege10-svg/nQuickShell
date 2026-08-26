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

            // Returns active connection type AND wifi radio status
            command: ["bash", "-c", "nmcli -t -f TYPE,STATE connection show --active 2>/dev/null | grep ':activated' | head -1; nmcli radio wifi"]
            running: true

            stdout: SplitParser {
                onRead: (data) => {
                    var lines = data.trim().split("\n");
                    var activeLine = lines[0] || "";
                    var wifiRadio = lines[1] ? lines[1].trim() : "enabled";

                    var parts = activeLine.split(":");

                    // 1. Ethernet Connected -> Take Priority
                    if (parts.length >= 2 && parts[0] === "802-3-ethernet") {
                        root.netIcon = "../svg/ethernet.svg";
                        root.netName = "LAN";
                        return;
                    }

                    // 2. Wi-Fi Radio Powered OFF
                    if (wifiRadio === "disabled") {
                        root.netIcon = "../svg/wifi-off.svg";
                        root.netName = "Off";
                        return;
                    }

                    // 3. Wi-Fi Powered ON & Connected
                    if (parts.length >= 2 && parts[0] === "802-11-wireless") {
                        root.netIcon = "../svg/wifi-high.svg";
                        root.netName = "WiFi";
                        return;
                    }

                    // 4. Disconnected / Unknown
                    root.netIcon = "../svg/wifi-off.svg";
                    root.netName = "Disconnected";
                }
            }
        }

        // ── PROCESS 2: Toggle Wi-Fi Power ────────────────────
        Process {
            id: wifiToggleProc

            // Turns wifi ON if currently off, or OFF if currently on
            command: ["bash", "-c", root.netIcon === "../svg/wifi-off.svg" ? "nmcli radio wifi on" : "nmcli radio wifi off"]
            
            // Re-run status check once toggle finishes
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
        
        // Show pointer cursor unless connected via Ethernet
        cursorShape: root.netName === "LAN" ? Qt.ArrowCursor : Qt.PointingHandCursor

        onClicked: {
            // Ignore click if on Ethernet, otherwise toggle Wi-Fi power
            if (root.netName !== "LAN") {
                wifiToggleProc.running = true;
            }
        }
    }
}
