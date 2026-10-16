// menu/main_block/AudioBlock.qml
import QtQuick
import QtQuick.Layouts
import "../../assets"
import "../../services"

Rectangle {
    id: root
    property var t

    color: root.t ? root.t.base.surface : "#1f1f1f"
    radius: root.t ? root.t.widgetRadius : 10

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 16

        // Master Volume (Output)
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true // Let the section breathe vertically
            spacing: 8
            
            RowLayout {
                Layout.fillWidth: true
                Text { text: "󰕾"; color: root.t ? root.t.base.accent : "cyan"; font.pixelSize: 16; font.family: "JetBrainsMono Nerd Font" }
                Text { 
                    text: "Master Volume"
                    color: root.t ? root.t.base.text : "white"
                    font.pixelSize: root.t ? root.t.fontSize : 13
                    font.bold: true
                    Layout.fillWidth: true 
                    elide: Text.ElideRight // Prevents overlap by adding "..." if squeezed
                }
                Text { text: Math.round(AudioService.outputVolume * 100) + "%"; color: root.t ? root.t.base.textInactive : "#6e6e6e"; font.pixelSize: 12 }
            }
            
            Slider {
                t: root.t
                Layout.fillWidth: true
                isOutput: true
                value: AudioService.outputVolume
            }
        }

        // Microphone (Input)
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 8
            
            RowLayout {
                Layout.fillWidth: true
                Text { text: "󰍬"; color: root.t ? root.t.base.accent : "cyan"; font.pixelSize: 16; font.family: "JetBrainsMono Nerd Font" }
                Text { 
                    text: "Microphone"
                    color: root.t ? root.t.base.text : "white"
                    font.pixelSize: root.t ? root.t.fontSize : 13
                    font.bold: true
                    Layout.fillWidth: true 
                    elide: Text.ElideRight
                }
                Text { text: Math.round(AudioService.inputVolume * 100) + "%"; color: root.t ? root.t.base.textInactive : "#6e6e6e"; font.pixelSize: 12 }
            }
            
            Slider {
                t: root.t
                Layout.fillWidth: true
                isOutput: false
                value: AudioService.inputVolume
            }
        }
    }
}
