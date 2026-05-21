import "../../assets"
import "../../services"
import "../../state"
import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    property var t
    property int menuWidth: 300
    property int menuHeight: 200

    width: menuWidth
    height: menuHeight

    // ── CENTRALIZED VOLUME CONTEXT CARD ─────────────────
    Rectangle {
        id: bgPanel

        anchors.fill: parent
        // Deep background layer matching your command-center setup
        color: t.base.altbg
        radius: 12
        antialiasing: true
        // Clean, valid low-opacity cyberpunk border outline using color channels
        border.color: t.base.border
        border.width: 1
    }

    // ── CONTROL LAYOUT ──────────────────────────────────
    ColumnLayout {
        spacing: 16 // Added extra breathing room between the two main slider sectors

        anchors {
            fill: parent
            margins: 16
        }

        // ─── OUTPUT BLOCK ───
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 6

            // Header Row: Separates functional tracking from device tracking
            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Text {
                    text: "OUTPUT"
                    color: t.holo.text

                    font {
                        pixelSize: t.fontSize - 1
                        family: t.fontFamily
                        bold: true
                    }

                }

                Text {
                    Layout.fillWidth: true
                    text: AudioService.outputName
                    color: t.base.textActive
                    elide: Text.ElideRight
                    opacity: 0.6 // Tucked back into visual hierarchy

                    font {
                        pixelSize: t.fontSize + 1
                        family: t.fontFamily
                    }

                }

            }

            Slider {
                t: root.t // Pass down unified context smoothly
                Layout.fillWidth: true
                height: 12
                isOutput: true
                // Tie your handle state cleanly to the active audio nodes
                value: AudioService.outputVolume
            }

        }

        // ─── INPUT BLOCK ───
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 6

            // Header Row
            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Text {
                    text: "INPUT"
                    color: t.holo.text

                    font {
                        pixelSize: t.fontSize - 1
                        family: t.fontFamily
                        bold: true
                    }

                }

                Text {
                    Layout.fillWidth: true
                    text: AudioService.inputName
                    color: t.base.textActive
                    elide: Text.ElideRight
                    opacity: 0.6

                    font {
                        pixelSize: t.fontSize + 1
                        family: t.fontFamily
                    }

                }

            }

            Slider {
                t: root.t
                Layout.fillWidth: true
                height: 12
                isOutput: false
                value: AudioService.inputVolume
            }

        }

    }

}
