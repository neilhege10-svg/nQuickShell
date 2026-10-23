
import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import "../../assets"
import "../../services"

//Main BG of the SessionBlock
Rectangle {
    id: root

    property var t

    readonly property color panelColor:
        t ? t.base.surface : "#1f1f1f"
    readonly property color primaryText:
        t ? t.base.text : "#e6e6e6"
    readonly property color mutedText:
        t ? t.base.textInactive : "#6e6e6e"
    readonly property color accent:
        t ? t.base.accent : "#03befc"
    readonly property string uiFont:
        t ? t.fontFamily : "JetBrainsMono Nerd Font"

    color: panelColor
    radius: t ? t.widgetRadius : 12
    clip: true

// -- HEADER -------------------- 
// this is the Header, it utilizes both column and row layouts
// to organize the Header design
// -------------------------------

    // Main ColumnLayout, organizes the Header and the Session Buttons
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 10

        // organizes the Blue line and the HEADERS
        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            // Blue line at the beginning of the header
            Rectangle {
                Layout.preferredWidth: 3
                Layout.preferredHeight: 22

                radius: 2
                color: root.accent
            }

            // Organizes the Main Header and Sub Header
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 1

                // MAIN HEADER TEXT
                Text {
                    text: "SESSION"
                    color: root.primaryText
                    font.family: root.uiFont
                    font.pixelSize: root.t ? root.t.fontSize : 13
                    font.bold: true
                    font.letterSpacing: 1.2
                }

                // SUB HEADER TEXT
                Text {
                    text: "Power and System actions"
                    color: root.mutedText
                    font.family: root.uiFont
                    font.pixelSize: 10
                }
              } 

            // Profile Picture
            Rectangle {
                Layout.preferredWidth: 38
                Layout.preferredHeight: 38

                radius: width / 2
                color: "transparent"
                border.color: root.accent
                border.width: 2

                Image {
                    anchors.fill: parent
                    anchors.margins: 2

                    source: Qt.resolvedUrl("../../img/PFP-Pixel.jpg")
                    fillMode: Image.PreserveAspectCrop
                    smooth: true
                    mipmap: true

                    sourceSize.width: 256
                    sourceSize.height: 256

                    layer.enabled: true
                    layer.effect: OpacityMask {
                        maskSource: Rectangle {
                            width: 38
                            height: 38
                            radius: width / 2
                        }
                    }
                }
             }

          }

// Seperator Line between the Header and the ActionTiles
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1

            color: root.t ? root.t.base.border : "#454545"
        }

// -- SESSION BUTTONS ----------------
// this is the main part of this QML, its the Power, restart, Suspend and Lock screen BUTTONS
// it uses ActionTile.qml from the Assets folder
// and the onClicked properties are pulled from SessionService.qml
// -----------------------------------
        GridLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true

            columns: 2
            columnSpacing: 8
            rowSpacing: 8

            ActionTile {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumHeight: 48

                t: root.t
                iconSource: Qt.resolvedUrl("../../svg/power.svg")
                label: "Power Off"

                onClicked: SessionService.requestConfirmation("poweroff")
            }

            ActionTile {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumHeight: 48

                t: root.t
                iconSource: Qt.resolvedUrl("../../svg/rotate-ccw.svg")
                label: "Restart"

                onClicked: SessionService.requestConfirmation("reboot")
            }

            ActionTile {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumHeight: 48

                t: root.t
                iconSource: Qt.resolvedUrl("../../svg/moon.svg")
                label: "Suspend"

                onClicked: SessionService.suspend()
            }

            ActionTile {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumHeight: 48

                t: root.t
                iconSource: Qt.resolvedUrl("../../svg/lock.svg")
                label: "Lock Screen"

                onClicked: SessionService.lock()
            }
        }
    }
}
