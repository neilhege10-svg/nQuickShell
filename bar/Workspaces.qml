import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland

RowLayout {
    id: root

    property var monitor
    property var t

    spacing: 4

    Repeater {
        model: Hyprland.workspaces

        delegate: Item {
            required property var modelData
            property bool isActive: Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id === modelData.id : false
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

                width: isActive ? 50 : 20
                height: isActive ? t.pillHeight : 18
                radius: 14
                color: isActive ? (root.t ? root.t.base.accent : "#cba6f7") : (root.t ? root.t.base.surface : "#191926")

                Text {
                    anchors.centerIn: parent
                    text: modelData.id
                    color: isActive ? (root.t ? root.t.base.textActive : "#cdd6f4") : ("transparent")

                    font {
                        pixelSize: root.t ? root.t.fontSize - 2 : 11
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
                        duration: 600 // Slowed down from 400ms for a smoother stretch
                        easing.type: Easing.OutElastic
                        easing.amplitude: 0.25 // Lowered from 0.4 so the bounce is very subtle
                        easing.period: 0.4 // Widened the wave period to make the settling motion feel heavier
                    }

                }

            }

        }

    }

}
