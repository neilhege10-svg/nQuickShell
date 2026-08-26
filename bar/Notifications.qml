import "../state"
import Qt5Compat.GraphicalEffects
import QtQuick
import Quickshell.Io

Item {
    id: root

    // ── CORE PROPERTIES ──────────────────────────────────
    property var t
    property string bellIcon: "../svg/bell.svg"
    property bool isDnd: false

    // Space requirements for RowLayout
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

        // ── PROCESS 1: Check Mako DND Status ─────────────────
        Process {
            id: makoCheckProc
            command: ["makoctl", "mode"]
            running: true

            stdout: SplitParser {
                onRead: (data) => {
                    var modes = data.trim().split("\n");
                    root.isDnd = modes.includes("do-not-disturb");
                    root.bellIcon = root.isDnd ? "../svg/bell-off.svg" : "../svg/bell.svg";
                }
            }
        }

        // ── PROCESS 2: Toggle Mako DND Mode ──────────────────
        Process {
            id: makoToggleProc
            command: ["bash", "-c", "if makoctl mode | grep -q 'do-not-disturb'; then makoctl mode -r do-not-disturb; else makoctl mode -a do-not-disturb; fi"]
            onExited: makoCheckProc.running = true
        }

        // ── AUTO-REFRESH TIMER ──────────────────────────────
        Timer {
            interval: 5000
            repeat: true
            running: true
            onTriggered: makoCheckProc.running = true
        }

        // ── ICON DISPLAY ─────────────────────────────────────
        Image {
            id: bellLabel

            source: root.bellIcon

            readonly property int iconDimension: root.t ? root.t.fontSize : 16
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

    // ── CLICK INTERACTION (TOGGLE DND) ───────────────────
    MouseArea {
        id: mouseArea

        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor

        onClicked: {
            makoToggleProc.running = true;
        }
    }
}
