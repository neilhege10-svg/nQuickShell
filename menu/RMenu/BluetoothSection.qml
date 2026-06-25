import "../../assets"
import "../../services"
import "../../theme"
import QtQuick
import QtQuick.Layouts

//---------------------------------------------------------------
// Uses the column layout to organize the Header and the content
//---------------------------------------------------------------
ColumnLayout {
    property var t

    spacing: 4

    anchors {
        fill: parent
        margins: 10
    }
//---------------------------------------------------------------
// uses the HudListHeader.qml to display the Header
//---------------------------------------------------------------
    HudListHeader {
        t: theme
        title: "BLUETOOTH"
        accentColor: t.holo.text
        Layout.leftMargin: 10
        Layout.rightMargin: 10
    }
//---------------------------------------------------------------
// uses the ScrollHudList to display the available Bluetooth 
// devices in NetworkService.qml
//---------------------------------------------------------------
    ScrollHudList {
        t: theme
        listModel: NetworkService.btDevices
        activeItem: NetworkService.btDevices.find((d) => {
            return d.connected;
        }) ?? null
        Layout.preferredWidth: 280
        Layout.alignment: Qt.AlignHCenter
        labelProperty: "name"
        onItemClicked: function(device) {
            NetworkService.toggleBluetooth(device);
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
