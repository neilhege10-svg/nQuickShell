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

//--------------------------------------------------------------------------------------
// BACKGROUND CARD
//--------------------------------------------------------------------------------------
    Rectangle {
        id: bgPanel
        anchors.fill: parent
        color: Qt.rgba(t.base.surface.r, t.base.surface.g, t.base.surface.b, 0.5)
        radius: 12
        antialiasing: true
        border.color: t.base.border
        border.width: 1
    }

//------------------------------------------------------ 
// The main ColumnLayout that holds the Output and Input section
//-------------------------------------------------------
    ColumnLayout {
        spacing: 16

        anchors {
            fill: parent
            margins: 16
        }

//------------------- OUTPUT SECTION --------------------
// This ColumnLayout Holds the individual components
// for the The "OUTPUT" Devices
//-------------------------------------------------------
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 6

            // The RowLayout holds the Header and Device name
            RowLayout {
                Layout.fillWidth: true
                spacing: 8

              // HEADER
              Text {
                text: "OUTPUT"
                color: t.base.text

                  font {
                    pixelSize: t.fontSize - 1
                    family: t.fontFamily
                    bold: true
                   }
               }

               // Output Device name
              Text {
                 Layout.fillWidth: true
                 text: AudioService.outputName
                 color: t.base.text
                 elide: Text.ElideRight
                 opacity: 0.6

                  font {
                      pixelSize: t.fontSize + 1
                      family: t.fontFamily
                     }

                 }

            }
            // A Simple Slider for the volumes
            Slider {
                t: root.t // Pass down unified context smoothly
                Layout.fillWidth: true
                height: 12
                isOutput: true
                // Tie your handle state cleanly to the active audio nodes
                value: AudioService.outputVolume
            }

        }

//------------------- INPUT SECTION --------------------
// This ColumnLayout Holds the individual components
// for the The "INPUT" Devices
//-------------------------------------------------------
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 6

            // The RowLayout holds the Header and Device name
            RowLayout {
                Layout.fillWidth: true
                spacing: 8

              // HEADER
              Text {
                text: "INPUT"
                color: t.base.text

                  font {
                     pixelSize: t.fontSize - 1
                     family: t.fontFamily
                     bold: true
                    }

                  }

               // Input Device name
                Text {
                    Layout.fillWidth: true
                    text: AudioService.inputName
                    color: t.base.text
                    elide: Text.ElideRight
                    opacity: 0.6

                    font {
                        pixelSize: t.fontSize + 1
                        family: t.fontFamily
                    }

                }

              }
            // A Simple Slider for the volumes
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
