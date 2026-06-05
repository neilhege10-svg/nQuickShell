import "../../assets"
import "../../theme"
import QtQuick
import QtQuick.Layouts

ColumnLayout {
    id: root

    property var t
    property var notifications: [{
        "app": "Discord",
        "message": "Someone sent a message"
    }, {
        "app": "Firefox",
        "message": "Download complete"
    }, {
        "app": "System",
        "message": "Update available"
    }]

    spacing: 4

    anchors {
        fill: parent
        margins: 15
    }

    HudListHeader {
        t: root.t
        title: "NOTIFS"
        accentColor: t.holo.text
        Layout.leftMargin: 10
        Layout.rightMargin: 10
    }

    Repeater {
        model: parent.notifications

        delegate: Item {
            width: parent.width
            height: 50

            Column {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 12
                spacing: 3

                Text {
                    text: modelData.app
                    color: t.base.text
                    font.family: t.fontFamily
                    font.pixelSize: t.fontSize + 3
                    font.bold: true
                }

                Text {
                    text: modelData.message
                    font.family: t.fontFamily
                    font.pixelSize: t.fontSize
                    color: t.base.textActive
                }

            }

        }

    }

}
