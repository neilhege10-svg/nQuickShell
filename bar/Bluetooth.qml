import "../state"
import QtQuick
import Quickshell.Io
import Qt5Compat.GraphicalEffects

Item {
    id: root

    // ── CORE PROPERTIES ──────────────────────────────────
    property var t
    property string btIcon: "../svg/bluetooth-off.svg"
    property string btState: "off"

    // ── LAYOUT BOUNDS ────────────────────────────────────
    // Keeps layout footprint tight to preserve RowLayout spacing
    implicitHeight: t ? t.pillHeight : 32
    implicitWidth: btLabel.width

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

        // ── PROCESS 1: Check Bluetooth Status ────────────────
        Process {
            id: btProc

            command: ["bash", "-c", "POWERED=$(bluetoothctl show | grep 'Powered:' | awk '{print $2}'); [ -z \"$POWERED\" ] && POWERED=\"no\"; CONNECTED=$(bluetoothctl info 2>/dev/null | grep 'Connected:' | grep -q 'yes' && echo 'yes' || echo 'no'); echo \"{\\\"powered\\\":\\\"$POWERED\\\",\\\"connected\\\":\\\"$CONNECTED\\\"}\""]
            running: true

            stdout: SplitParser {
                onRead: (data) => {
                    var str = data.trim();
                    if (!str.startsWith("{")) return;

                    try {
                        var res = JSON.parse(str);
                        var isPowered = res.powered === "yes";
                        var isConnected = res.connected === "yes";

                        if (!isPowered) {
                            root.btIcon = "../svg/bluetooth-off.svg";
                            root.btState = "off";
                        } else if (isConnected) {
                            root.btIcon = "../svg/bluetooth-connected.svg";
                            root.btState = "connected";
                        } else {
                            root.btIcon = "../svg/bluetooth.svg";
                            root.btState = "on";
                        }
                    } catch (e) {
                        console.log("Bluetooth parsing error:", e);
                    }
                }
            }
        }

        // ── PROCESS 2: Toggle Bluetooth Power ─────────────────
        Process {
            id: btToggleProc

            command: ["bash", "-c", root.btState === "off" ? "bluetoothctl power on" : "bluetoothctl power off"]
            onExited: btProc.running = true
        }

        // ── AUTO-REFRESH TIMER ──────────────────────────────
        Timer {
            interval: 10000
            repeat: true
            running: true
            onTriggered: btProc.running = true
        }

        // ── ICON DISPLAY ─────────────────────────────────────
        Image {
            id: btLabel

            source: root.btIcon

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
    MouseArea {
        id: mouseArea

        // Expands touch target by 10px on each side into RowLayout spacing
        anchors {
            top: parent.top
            bottom: parent.bottom
            left: parent.left
            right: parent.right
            leftMargin: -10
            rightMargin: -10
        }

        cursorShape: Qt.PointingHandCursor

        onClicked: {
            btToggleProc.running = true;
        }
    }
}
