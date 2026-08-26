import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland

RowLayout {
    id: root

    // ── CORE PROPERTIES ──────────────────────────────────
    property var monitor
    property var t

    // Signal emitted when clicking the pill (prepped for your future WP Overview overlay)
    signal overviewRequested()

    // ── WORKSPACE NAMES / ICONS MAP ──────────────────────
    // Add full strings anytime (e.g., "1": "1 • Main", "8": "󰺷 Gaming")
    readonly property var workspaceIcons: ({
        "1": "1",
        "2": "2",
        "3": "3",
        "4": "4",
        "5": "5",
        "6": "6",
        "7": "󰨜",
        "8": "󰺷 ",
        "9": "󰉏",
        "10": "󰺷 "
    })

    spacing: 0

    // ── WORKSPACE REPEATER ───────────────────────────────
    Repeater {
        model: Hyprland.workspaces

        delegate: Item {
            id: delegateRoot

            required property var modelData

            // Is this workspace active on its monitor?
            property bool isActive: modelData.monitor && modelData.monitor.activeWorkspace ? modelData.monitor.activeWorkspace.id === modelData.id : false

            // Does this workspace belong to the monitor this bar is on?
            property bool belongsHere: root.monitor ? modelData.monitor.id === root.monitor.id : true

            // STRICT VISIBILITY: Show ONLY if it belongs to this monitor AND is active
            property bool shouldShow: belongsHere && isActive

            visible: shouldShow
            implicitWidth: shouldShow ? button.width : 0
            implicitHeight: shouldShow ? button.height : 0
            width: shouldShow ? button.width : 0
            height: shouldShow ? button.height : 0

            // ── DROP SHADOW ──────────────────────────────────
            DropShadow {
                anchors.fill: button
                horizontalOffset: 2
                verticalOffset: 2
                radius: 8
                samples: 17
                color: "#60000000"
                source: button
                visible: delegateRoot.shouldShow
            }

            // ── ACTIVE WORKSPACE PILL ────────────────────────
            Rectangle {
                id: button

                // Dynamic width: Fits label + padding, with a 56px minimum floor
                width: Math.max(56, label.implicitWidth + 24)
                height: root.t ? root.t.pillHeight : 28
                radius: 16

                color: root.t ? root.t.base.accent : "#00b4ff"

                // Animate width expansion smoothly when switching to workspaces with longer names
                Behavior on width {
                    NumberAnimation {
                        duration: 250
                        easing.type: Easing.OutCubic
                    }
                }

                // ── DISPLAY TEXT ─────────────────────────────
                Text {
                    id: label

                    anchors.centerIn: parent
                    text: root.workspaceIcons[modelData.id] || modelData.id
                    color: root.t ? root.t.base.textAccent : "#11111b"

                    font {
                        pixelSize: 15
                        family: root.t ? root.t.fontFamily : ""
                        bold: true
                    }
                }

                // ── CLICK INTERACTION ────────────────────────
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        root.overviewRequested();
                    }
                }
            }
        }
    }
}
