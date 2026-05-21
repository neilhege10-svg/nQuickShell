// ── NETWORK CONTROL CARD ──────────────────────────────────────────────────────
// Middle card on the network page — same slot as VolumeControl on audio page.
// Two rows: WIFI [toggle] and BLUETOOTH [toggle].
// Flat horizontal layout, bigger labels, no icons.
// ─────────────────────────────────────────────────────────────────────────────

import "../../assets"
import "../../services"
import "../../theme"
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    property var t

    // ── BACKGROUND CARD ────────────────────────────────────────────────
    Rectangle {
        anchors.fill: parent
        radius: 14
        color: t.base.altbg
        border.color: t.base.border
        border.width: 1
    }

    // ── ROWS ───────────────────────────────────────────────────────────
    ColumnLayout {
        spacing: 0

        anchors {
            fill: parent
            leftMargin: 18
            rightMargin: 18
            topMargin: 14
            bottomMargin: 14
        }

        // ── WIFI ROW ──────────────────────────────────────────────────
        RowLayout {
            Layout.fillWidth: true
            spacing: 0

            Text {
                text: "WIFI"
                font.family: t.fontFamily
                font.pixelSize: t.fontSize + 2
                font.bold: true
                font.letterSpacing: 1.5
                color: NetworkService.wifiEnabled ? t.base.text : Qt.rgba(t.base.textActive.r, t.base.textActive.g, t.base.textActive.b, 0.4)

                Behavior on color {
                    ColorAnimation {
                        duration: 200
                    }

                }

            }

            Item {
                Layout.fillWidth: true
            }

            ToggleSwitch {
                t: root.t
                checked: NetworkService.wifiEnabled
                onToggled: NetworkService.toggleWifiPower()
            }

        }

        // ── SEPARATOR ─────────────────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Qt.rgba(t.holo.text.r, t.holo.text.g, t.holo.text.b, 0.06)
            Layout.topMargin: 10
            Layout.bottomMargin: 10
        }

        // ── BLUETOOTH ROW ─────────────────────────────────────────────
        RowLayout {
            Layout.fillWidth: true
            spacing: 0

            Text {
                text: "BLUETOOTH"
                font.family: t.fontFamily
                font.pixelSize: t.fontSize + 2
                font.bold: true
                font.letterSpacing: 1.5
                color: NetworkService.btEnabled ? t.base.text : Qt.rgba(t.base.textActive.r, t.base.textActive.g, t.base.textActive.b, 0.4)

                Behavior on color {
                    ColorAnimation {
                        duration: 200
                    }

                }

            }

            Item {
                Layout.fillWidth: true
            }

            ToggleSwitch {
                t: root.t
                checked: NetworkService.btEnabled
                onToggled: NetworkService.toggleBtPower()
            }

        }

    }

}
