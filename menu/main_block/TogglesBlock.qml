// menu/main_block/TogglesBlock.qml
import QtQuick
import QtQuick.Layouts
import "../../assets"
import "../../services"

Rectangle {
    id: root
    property var t

    color: root.t ? root.t.base.surface : "#1f1f1f"
    radius: root.t ? root.t.widgetRadius : 10

    GridLayout {
        anchors.fill: parent
        anchors.margins: 0
        columns: 2
        columnSpacing: 8
        rowSpacing: 12

        // 1. Wi-Fi
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignCenter
            spacing: 12
            
            Image {
                source: NetworkService.wifiEnabled ? "../../svg/wifi.svg" : "../../svg/wifi-off.svg"
                sourceSize: Qt.size(20, 20)
            }
            
            ToggleSwitch {
                t: root.t
                checked: NetworkService.wifiEnabled
                onToggled: NetworkService.toggleWifiPower()
            }
        }

        // 2. Bluetooth
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignCenter
            spacing: 12
            
            Image {
                source: NetworkService.btEnabled ? "../../svg/bluetooth.svg" : "../../svg/bluetooth-off.svg"
                sourceSize: Qt.size(20, 20)
            }
            
            ToggleSwitch {
                t: root.t
                checked: NetworkService.btEnabled
                onToggled: NetworkService.toggleBtPower()
            }
        }
        
        // 3. Do Not Disturb
        RowLayout {
            property bool dndEnabled: false // Local state placeholder
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignCenter
            spacing: 12
            
            Image {
                source: parent.dndEnabled ? "../../svg/bell-off.svg" : "../../svg/bell.svg"
                sourceSize: Qt.size(20, 20)
            }
            
            ToggleSwitch {
                t: root.t
                checked: parent.dndEnabled
                onToggled: parent.dndEnabled = !parent.dndEnabled
            }
        }

        // 4. HyprIdle (Placeholder)
        RowLayout {
            property bool idleEnabled: true // Local state placeholder
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignCenter
            spacing: 12
            
            Image {
                source: "../../svg/battery-full.svg" 
                sourceSize: Qt.size(20, 20)
            }
            
            ToggleSwitch {
                t: root.t
                checked: parent.idleEnabled
                onToggled: parent.idleEnabled = !parent.idleEnabled
            }
        }
    }
}
