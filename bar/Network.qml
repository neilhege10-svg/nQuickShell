import "../state"
import QtQuick
import Quickshell.Io
import Qt5Compat.GraphicalEffects

Item {
    id: root

    // ── CORE PROPERTIES ──────────────────────────────────
    property var t
    property string netIcon: "../svg/wifi-off.svg"
    property string netName: "..."

    // ── LAYOUT BOUNDS ────────────────────────────────────
    // Layout footprint targets exact icon size to preserve RowLayout spacing
    implicitHeight: t ? t.pillHeight : 32
    implicitWidth: netLabel.width

// ── MAIN PILL CONTAINER ──────────────────────────────
// Rectangle for the module,
// its set to transparent, because the actual pill lives in Bar.qml and this is crammed
// alongside other modules, such as Volume,Wifi,etc
// ─────────────────────────────────────────────────────
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

// ── PROCESS 1: Check WIFI Status ────────────────
// this is a simple Bash process that checks the status of the WIFI (wether its on/off/Ethernet)
// and changes the Icon depending on its status
// ─────────────────────────────────────────────────────
        Process {
            id: netProc

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

                        if (type === "802-3-ethernet") {
                            root.netIcon = "../svg/ethernet.svg";
                            root.netName = "LAN";
                            return;
                        }

                        if (type === "802-11-wireless") {
                            root.netIcon = "../svg/wifi.svg";
                            root.netName = "WiFi";
                            return;
                        }

                        root.netIcon = "../svg/wifi-off.svg";
                        root.netName = (wifiState === "disabled") ? "Off" : "Disconnected";
                    } catch (e) {
                        console.log("Network parsing error:", e);
                    }
                }
            }
        }

// ── PROCESS 2: Toggle Wifi Power ─────────────────
// this is another simple process that allows the toggling of the module's status
// onExited, ensures that PROCESS 1 runs once, to check the status of the bluetooth
// and changes the icon
// ─────────────────────────────────────────────────────
        Process {
            id: wifiToggleProc

            command: ["bash", "-c", root.netIcon === "../svg/wifi-off.svg" ? "nmcli radio wifi on" : "nmcli radio wifi off"]
            onExited: netProc.running = true
        }

// ── AUTO-REFRESH TIMER ──────────────────────────────
// it checks periodaclly if theres any changes, by using PROCESS 1
// ─────────────────────────────────────────────────────
        Timer {
            interval: 10000
            repeat: true
            running: true
            onTriggered: netProc.running = true
        }

// ── ICON DISPLAY ─────────────────────────────────────
// this is just the visual design, coloring of the icon
// ─────────────────────────────────────────────────────
        Image {
            id: netLabel

            source: root.netIcon
            
            readonly property int iconDimension: root.t ? root.t.fontSize - 1 : 15
            width: iconDimension
            height: iconDimension
            sourceSize.width: iconDimension
            sourceSize.height: iconDimension

            anchors.centerIn: parent

            fillMode: Image.PreserveAspectFit
            smooth: true
            mipmap: true

            layer.enabled: true
            layer.effect: ColorOverlay {
            color: root.t ? root.t.base.textAccent : "#cdd6f4"
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
// Click function, has Animations, and also runs PROCESS 2 on click
// ─────────────────────────────────────────────────────
    MouseArea {
        id: mouseArea

        // Expands touch target by 10px on each side without pushing neighbors
        anchors {
            top: parent.top
            bottom: parent.bottom
            left: parent.left
            right: parent.right
            leftMargin: -10
            rightMargin: -10
        }
        
        cursorShape: root.netName === "LAN" ? Qt.ArrowCursor : Qt.PointingHandCursor

        onClicked: {
            if (root.netName !== "LAN") {
                wifiToggleProc.running = true;
            }
        }
    }
}
