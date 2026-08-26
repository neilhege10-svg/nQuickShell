import "../state"
import QtQuick
import Quickshell.Io

Item {
    id: root

    // ── CORE PROPERTIES ──────────────────────────────────
    property var t
    property string bellIcon: "../svg/bell.svg"
    property bool isDnd: false

    // ── LAYOUT BOUNDS ────────────────────────────────────
    // Keeps layout footprint tight to preserve RowLayout spacing
    implicitHeight: t ? t.pillHeight : 32
    implicitWidth: bellLabel.width

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

            readonly property int iconDimension: root.t ? root.t.fontSize - 1 : 15
            width: iconDimension
            height: iconDimension
            sourceSize.width: iconDimension
            sourceSize.height: iconDimension

            anchors.centerIn: parent

            fillMode: Image.PreserveAspectFit
            smooth: true
            mipmap: true
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
            makoToggleProc.running = true;
        }
    }
}
