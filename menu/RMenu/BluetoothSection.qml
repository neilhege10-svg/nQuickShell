import "../../assets"
import "../../services"
import "../../theme"
import QtQuick
import QtQuick.Layouts

ColumnLayout {
    property var t

    spacing: 4

    anchors {
        fill: parent
        margins: 10
    }

    HudListHeader {
        t: theme
        title: "BLUETOOTH"
        accentColor: t.holo.text
        Layout.leftMargin: 10
        Layout.rightMargin: 10
    }

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

    Item {
        Layout.fillWidth: true
        Layout.fillHeight: true
    }

}
