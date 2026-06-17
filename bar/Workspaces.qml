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

//-----------------------------------------------------------------------------------
// This section changes the corresponding workspace to a title of icon 
// eg. [ "8": "󰺷 ", ] this makes it so that workspace 8
// is indicated by a game controller icon instead of just the number 8
//-----------------------------------------------------------------------------------
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

//-----------------------------------------------------------------------------------
// this is the Repeater. its responsible for displaying all the workspaces
// (this section probably needs a rework on the description lol)
//-----------------------------------------------------------------------------------
    Repeater {
        model: Hyprland.workspaces

        // -----------------------------------------------------------------
        // THE MULTI-MONITOR MULTI-LIGHT FIX:
        // Checks if this specific workspace is the active one on its assigned monitor.
        // This ensures both monitors show their active workspace status at all times!
        // -----------------------------------------------------------------
        delegate: Item {
            required property var modelData
            property bool isActive: modelData.monitor && modelData.monitor.activeWorkspace ? modelData.monitor.activeWorkspace.id === modelData.id : false
            property bool belongsHere: root.monitor ? modelData.monitor.id === root.monitor.id : true

            implicitWidth: belongsHere ? button.width : 0
            implicitHeight: button.height
            visible: belongsHere
            width: belongsHere ? button.width : 0
            height: button.height

//-----------------------------------------------------------------------------------
// this is the shadow effect, it activates for the current active workspace
// by using [ visible: isActive ]
//-----------------------------------------------------------------------------------
            DropShadow {
                anchors.fill: button
                horizontalOffset: isActive ? 3 : 0
                verticalOffset: isActive ? 2 : 0
                radius: isActive ? 8 : 0
                samples: 17
                color: "#000000"
                source: button
                visible: isActive

                // animates the shadow's horizontalOffset
                Behavior on horizontalOffset {
                    NumberAnimation {
                        duration: 400
                    }

                }

                // animates the shadow's verticalOffset
                Behavior on verticalOffset {
                    NumberAnimation {
                        duration: 400
                    }

                }

                // animates the shadow's Radius
                Behavior on radius {
                    NumberAnimation {
                        duration: 400
                    }

                }

            }

//-----------------------------------------------------------------------------------
// Main shape and design of the Workspace module
//-----------------------------------------------------------------------------------
            Rectangle {
                id: button

                width: isActive ? 56 : 28
                height: isActive ? t.pillHeight : 18
                radius: 14
                color: isActive ? (root.t ? root.t.base.accent : "#cba6f7") : (root.t ? root.t.base.surface : "#191926")

//-----------------------------------------------------------------------------------
// Main Text design of the Workspace module
//-----------------------------------------------------------------------------------
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

//-----------------------------------------------------------------------------------
// The mouseArea section is what makes the module CLICKABLE by using onClicked property
// it uses Hyperland's dispatcher to switch to the corresponding workspace id
// upon clicking one it turns into an Active state, changing the colors and design
// of the active workspace and applying animations to it
//-----------------------------------------------------------------------------------
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        Hyprland.dispatch("hl.dsp.focus({ workspace = \"" + modelData.id + "\" })");
                    }
                }

                // animation for the color of the module's Pill
                Behavior on color {
                    ColorAnimation {
                        duration: 400
                    }

                }

                // animates the WIDTH of the pill, making the pill of active workspaces wider
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
