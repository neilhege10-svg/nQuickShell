import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland

RowLayout {
    id: root

    property var monitor
    property var t
    // =========================================================================
    // THE FRONTEND ABSTRACTION DICTIONARY
    // Maps messy backend IDs (1-10) to beautiful, consecutive UI elements
    // =========================================================================
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

    spacing: 4

    Repeater {
        model: Hyprland.workspaces

        delegate: Item {
            required property var modelData
            // -----------------------------------------------------------------
            // THE MULTI-MONITOR MULTI-LIGHT FIX:
            // Checks if this specific workspace is the active one on its assigned monitor.
            // This ensures both monitors show their active workspace status at all times!
            // -----------------------------------------------------------------
            property bool isActive: modelData.monitor && modelData.monitor.activeWorkspace ? modelData.monitor.activeWorkspace.id === modelData.id : false
            property bool belongsHere: root.monitor ? modelData.monitor.id === root.monitor.id : true

            implicitWidth: belongsHere ? button.width : 0
            implicitHeight: button.height
            visible: belongsHere
            width: belongsHere ? button.width : 0
            height: button.height

            DropShadow {
                anchors.fill: button
                horizontalOffset: isActive ? 3 : 0
                verticalOffset: isActive ? 2 : 0
                radius: isActive ? 8 : 0
                samples: 17
                color: "#000000"
                source: button
                visible: isActive

                Behavior on horizontalOffset {
                    NumberAnimation {
                        duration: 400
                    }

                }

                Behavior on verticalOffset {
                    NumberAnimation {
                        duration: 400
                    }

                }

                Behavior on radius {
                    NumberAnimation {
                        duration: 400
                    }

                }

            }

            Rectangle {
                id: button

                width: isActive ? 56 : 28
                height: isActive ? t.pillHeight : 18
                radius: 14
                color: isActive ? (root.t ? root.t.base.accent : "#cba6f7") : (root.t ? root.t.base.surface : "#191926")

                Text {
                    anchors.centerIn: parent
                    text: root.workspaceIcons[modelData.id] || modelData.id
                    // Fixed: Replaced "transparent" fallback with a visible dim color
                    // so you can actually read the icons/numbers when inactive
                    color: isActive ? (root.t ? root.t.base.textActive : "#cdd6f4") : "transparent"

                    font {
                        pixelSize: 16
                        family: root.t ? root.t.fontFamily : ""
                        bold: isActive
                    }

                    Behavior on color {
                        ColorAnimation {
                            duration: 400
                        }

                    }

                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        Hyprland.dispatch("hl.dsp.focus({ workspace = \"" + modelData.id + "\" })");
                    }
                }

                Behavior on color {
                    ColorAnimation {
                        duration: 400
                    }

                }

                Behavior on width {
                    NumberAnimation {
                        duration: 600
                        easing.type: Easing.OutElastic
                        easing.amplitude: 0.25
                        easing.period: 0.4
                    }

                }

            }

        }

    }

}
