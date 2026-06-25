import "../../assets/"
import "../../services"
import "../../theme"
import QtQuick
import QtQuick.Effects
import QtQuick.Layouts

//---------------------------------------------------------------
// Uses the column layout to organize the Header and the content
//---------------------------------------------------------------
ColumnLayout {
    property var t

    spacing: 4

    anchors {
        fill: parent
        margins: 15
    }
//---------------------------------------------------------------
// uses the HudListHeader.qml to display the Header
//---------------------------------------------------------------
    HudListHeader {
        t: theme
        title: "OUTPUT DEVICE"
        accentColor: t.holo.text
        Layout.leftMargin: 10
        Layout.rightMargin: 10
    }
//---------------------------------------------------------------
// uses the ScrollHudList to display the Audio Output devices 
// in AudioService.qml
//---------------------------------------------------------------
    ScrollHudList {
        t: theme
        listModel: AudioService.outputDevices
        activeItem: AudioService.outputNode
        Layout.preferredWidth: 280
        Layout.alignment: Qt.AlignHCenter
        labelProperty: "description"
        onItemClicked: function(device) {
            AudioService.setOutputDevice(device);
        }
    }
//---------------------------------------------------------------
// This item is used to make sure the header doesnt fall to the
// center if there is no content in the ScrollHudList
//---------------------------------------------------------------
    Item {
        Layout.fillWidth: true
        Layout.fillHeight: true
    }

}
