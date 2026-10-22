
import QtQuick
import QtQuick.Layouts
import "../../assets"
import "../../services"

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

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 10

        // Header
        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Rectangle {
                Layout.preferredWidth: 3
                Layout.preferredHeight: 22

                radius: 2
                color: root.accent
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 1

                Text {
                    text: "SESSION"
                    color: root.primaryText
                    font.family: root.uiFont
                    font.pixelSize: root.t ? root.t.fontSize : 13
                    font.bold: true
                    font.letterSpacing: 1.2
                }

                Text {
                    text: "Power and System actions"
                    color: root.mutedText
                    font.family: root.uiFont
                    font.pixelSize: 10
                }
            }

        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1

            color: root.t ? root.t.base.border : "#454545"
        }

        // Reusable action tiles
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
                iconText: "󰐥"
                label: "power off"

                onClicked: SessionService.requestConfirmation("poweroff")
            }

            ActionTile {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumHeight: 48

                t: root.t
                iconText: "󰑐"
                label: "restart"

                onClicked: SessionService.requestConfirmation("reboot")
            }

            ActionTile {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumHeight: 48

                t: root.t
                iconText: "󰤄"
                label: "suspend"

                onClicked: SessionService.suspend()
            }

            ActionTile {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumHeight: 48

                t: root.t
                iconText: "󰌾"
                label: "lock screen"

                onClicked: SessionService.lock()
            }
        }
    }
}
