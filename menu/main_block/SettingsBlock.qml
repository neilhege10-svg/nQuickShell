
import QtQuick
import QtQuick.Layouts

// ── SETTINGS BLOCK ─────────────────────────────
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

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 16

        // ── HEADER ─────────────────────────────
        RowLayout {
            Layout.fillWidth: true

            Text {
                text: "Quick Settings"
                color: primaryText
                font.family: uiFont
                font.pixelSize: 16
                font.bold: true
            }

            Item {
                Layout.fillWidth: true
            }
        }

        // ── MAIN CONTROLS ──────────────────────
        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            Item {
                Layout.fillWidth: true
            }

            // Wi-Fi
            Rectangle {
                Layout.preferredWidth: 170
                Layout.preferredHeight: 76

                radius: 16
                color: "#ffffff"

                Text {
                    anchors.centerIn: parent
                    text: "Wi-Fi"
                    color: "#202636"
                    font.family: uiFont
                    font.pixelSize: 14
                }
            }

            // Bluetooth
            Rectangle {
                Layout.preferredWidth: 170
                Layout.preferredHeight: 76

                radius: 16
                color: "#ffffff"

                Text {
                    anchors.centerIn: parent
                    text: "Bluetooth"
                    color: "#202636"
                    font.family: uiFont
                    font.pixelSize: 14
                }
            }

            Item {
                Layout.fillWidth: true
            }
        }

        // ── SMALL CONTROLS ─────────────────────
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Item {
                Layout.fillWidth: true
            }

            // DND
            Rectangle {
                Layout.preferredWidth: 76
                Layout.preferredHeight: 68

                radius: 12
                color: insetColor

                Text {
                    anchors.centerIn: parent
                    text: "DND"
                    color: primaryText
                    font.family: uiFont
                    font.pixelSize: 12
                }
            }

            // Idle
            Rectangle {
                Layout.preferredWidth: 76
                Layout.preferredHeight: 68

                radius: 12
                color: insetColor

                Text {
                    anchors.centerIn: parent
                    text: "Idle"
                    color: primaryText
                    font.family: uiFont
                    font.pixelSize: 12
                }
            }

            // Placeholder 1
            Rectangle {
                Layout.preferredWidth: 76
                Layout.preferredHeight: 68

                radius: 12
                color: insetColor

                Text {
                    anchors.centerIn: parent
                    text: "—"
                    color: primaryText
                    font.family: uiFont
                    font.pixelSize: 12
                }
            }

            // Placeholder 2
            Rectangle {
                Layout.preferredWidth: 76
                Layout.preferredHeight: 68

                radius: 12
                color: insetColor

                Text {
                    anchors.centerIn: parent
                    text: "—"
                    color: primaryText
                    font.family: uiFont
                    font.pixelSize: 12
                }
            }

            Item {
                Layout.fillWidth: true
            }
        }

        Item {
            Layout.fillHeight: true
        }
    }
}
