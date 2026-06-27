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

//------------------------------------------
//The Main Background for this component
//------------------------------------------
    Rectangle {
        anchors.fill: parent
        radius: 14
        color: Qt.rgba(t.base.surface.r, t.base.surface.g, t.base.surface.b, 0.5)
        border.color: t.base.border
        border.width: 1
    }

    // a simple ColumnLayout
    ColumnLayout {
        spacing: 0

        anchors {
            fill: parent
            leftMargin: 18
            rightMargin: 18
            topMargin: 14
            bottomMargin: 14
        }

//------------------------------------------
// The Wifi text + on/off toggle for Wifi
// all placed in uisng a RowLayout
//------------------------------------------
        RowLayout {
            Layout.fillWidth: true
            spacing: 0

            // the WIFI Header 
            Text {
                text: "WIFI"
                font.family: t.fontFamily
                font.pixelSize: t.fontSize + 2
                font.bold: true
                font.letterSpacing: 1.5
                color: t.base.text

                Behavior on color {
                    ColorAnimation {
                        duration: 200
                    }

                }

            }
            // this creates a gap between the Header and ToggleSwitch,
            // pinning the Header to the left and the ToggleSwitch to the right
            Item {
                Layout.fillWidth: true
            }
            // the on/off switch
            ToggleSwitch {
                t: root.t
                checked: NetworkService.wifiEnabled
                onToggled: NetworkService.toggleWifiPower()
            }

        }

//------------------------------------------
// a Separator line between the Bluetooth
// and Wifi RowLayout
//------------------------------------------
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: t.base.border
            Layout.topMargin: 10
            Layout.bottomMargin: 10
        }

//------------------------------------------
// The Bluetooth text + on/off toggle for
// bluetooth
// all placed in uisng a RowLayout
//------------------------------------------
        RowLayout {
            Layout.fillWidth: true
            spacing: 0

            // the Bluetooth Header 
            Text {
                text: "BLUETOOTH"
                font.family: t.fontFamily
                font.pixelSize: t.fontSize + 2
                font.bold: true
                font.letterSpacing: 1.5
                color: t.base.text

                Behavior on color {
                    ColorAnimation {
                        duration: 200
                    }

                }

            }
            // this creates a gap between the Header and ToggleSwitch,
            // pinning the Header to the left and the ToggleSwitch to the right
            Item {
                Layout.fillWidth: true
            }
            // the on/off switch
            ToggleSwitch {
                t: root.t
                checked: NetworkService.btEnabled
                onToggled: NetworkService.toggleBtPower()
            }

        }

    }

}
