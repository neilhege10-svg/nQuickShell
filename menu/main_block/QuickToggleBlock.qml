import QtQuick
import QtQuick.Layouts

// ── QUICK TOGGLE BLOCK ─────────────────────────
// Visual placeholder for future system controls.
// ───────────────────────────────────────────────

Rectangle {
    id: root

    property var t

    readonly property color panelColor:
        t ? t.base.surface : "#1f1f1f"
    readonly property color primaryText:
        t ? t.base.text : "#e6e6e6"
    readonly property color accent:
        t ? t.base.accent : "#03befc"
    readonly property color insetColor:
        t ? t.base.bg : "#171717"
    readonly property color borderColor:
        t ? t.base.border : "#454545"
    readonly property string uiFont:
        t ? t.fontFamily : "JetBrainsMono Nerd Font"

    color: panelColor
    radius: t ? t.widgetRadius : 12
    clip: true

    GridLayout {
        anchors.fill: parent
        anchors.margins: 10

        columns: 2
        rowSpacing: 7
        columnSpacing: 7

        // ── WI-FI ───────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumHeight: 0

            radius: root.t ? root.t.widgetRadius - 4 : 8
            color: root.insetColor
            border.width: 1
            border.color: root.borderColor

            Column {
                anchors.centerIn: parent
                spacing: 4

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "󰖩"
                    color: root.accent
                    font.family: root.uiFont
                    font.pixelSize: 20
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Wi-Fi"
                    color: root.primaryText
                    font.family: root.uiFont
                    font.pixelSize: 10
                }
            }
        }

        // ── BLUETOOTH ───────────────────────────
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumHeight: 0

            radius: root.t ? root.t.widgetRadius - 4 : 8
            color: root.insetColor
            border.width: 1
            border.color: root.borderColor

            Column {
                anchors.centerIn: parent
                spacing: 4

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "󰂯"
                    color: root.accent
                    font.family: root.uiFont
                    font.pixelSize: 20
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Bluetooth"
                    color: root.primaryText
                    font.family: root.uiFont
                    font.pixelSize: 10
                }
            }
        }

        // ── DO NOT DISTURB ──────────────────────
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumHeight: 0

            radius: root.t ? root.t.widgetRadius - 4 : 8
            color: root.insetColor
            border.width: 1
            border.color: root.borderColor

            Column {
                anchors.centerIn: parent
                spacing: 4

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "󰂛"
                    color: root.accent
                    font.family: root.uiFont
                    font.pixelSize: 20
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "DND"
                    color: root.primaryText
                    font.family: root.uiFont
                    font.pixelSize: 10
                }
            }
        }

        // ── IDLE INHIBITION ─────────────────────
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumHeight: 0

            radius: root.t ? root.t.widgetRadius - 4 : 8
            color: root.insetColor
            border.width: 1
            border.color: root.borderColor

            Column {
                anchors.centerIn: parent
                spacing: 4

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "󰅶"
                    color: root.accent
                    font.family: root.uiFont
                    font.pixelSize: 20
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Idle"
                    color: root.primaryText
                    font.family: root.uiFont
                    font.pixelSize: 10
                }
            }
        }

        // ── NIGHT LIGHT ─────────────────────────
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumHeight: 0

            radius: root.t ? root.t.widgetRadius - 4 : 8
            color: root.insetColor
            border.width: 1
            border.color: root.borderColor

            Column {
                anchors.centerIn: parent
                spacing: 4

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "󰖔"
                    color: root.accent
                    font.family: root.uiFont
                    font.pixelSize: 20
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Night Light"
                    color: root.primaryText
                    font.family: root.uiFont
                    font.pixelSize: 10
                }
            }
        }

        // ── FUTURE ACTION ───────────────────────
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumHeight: 0

            radius: root.t ? root.t.widgetRadius - 4 : 8
            color: root.insetColor
            border.width: 1
            border.color: root.borderColor

            Column {
                anchors.centerIn: parent
                spacing: 4

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "󰒓"
                    color: root.accent
                    font.family: root.uiFont
                    font.pixelSize: 20
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "More"
                    color: root.primaryText
                    font.family: root.uiFont
                    font.pixelSize: 10
                }
            }
        }
    }
}
