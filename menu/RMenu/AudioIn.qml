import "../../assets/"
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

    // Use your reusable header
    HudListHeader {
        t: theme
        title: "INPUT DEVICE"
        accentColor: t.holo.text
        Layout.leftMargin: 10
        Layout.rightMargin: 10
    }

    ScrollHudList {
        t: theme
        listModel: AudioService.inputDevices
        activeItem: AudioService.inputNode
        Layout.preferredWidth: 280
        Layout.alignment: Qt.AlignHCenter
        labelProperty: "description"
        onItemClicked: function(device) {
            AudioService.setInputDevice(device);
        }
    }

    Item {
        Layout.fillWidth: true
        Layout.fillHeight: true
    }

}
