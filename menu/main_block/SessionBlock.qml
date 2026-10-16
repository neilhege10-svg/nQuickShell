// menu/main_block/SessionBlock.qml
import QtQuick
import QtQuick.Layouts
import "../../assets"

Rectangle {
    id: root
    property var t

    color: root.t ? root.t.base.surface : "#1f1f1f"
    radius: root.t ? root.t.widgetRadius : 10

    GridLayout {
        anchors.fill: parent
        anchors.margins: 12
        columns: 2
        columnSpacing: 8
        rowSpacing: 8

        BtnRound { 
            t: root.t; icon: "󰐥"
            Layout.fillWidth: true; Layout.fillHeight: true; Layout.alignment: Qt.AlignCenter 
            onClicked: console.log("Power") 
        }
        BtnRound { 
            t: root.t; icon: "󰑐"
            Layout.fillWidth: true; Layout.fillHeight: true; Layout.alignment: Qt.AlignCenter 
            onClicked: console.log("Reboot") 
        }
        BtnRound { 
            t: root.t; icon: "󰤄"
            Layout.fillWidth: true; Layout.fillHeight: true; Layout.alignment: Qt.AlignCenter 
            onClicked: console.log("Suspend") 
        }
        BtnRound { 
            t: root.t; icon: "󰌾"
            Layout.fillWidth: true; Layout.fillHeight: true; Layout.alignment: Qt.AlignCenter 
            onClicked: console.log("Lock") 
        }
    }
}
