
import "../../assets"
import "../../theme"
import QtQuick
import QtQuick.Layouts

ColumnLayout {
    id: root

    property var t
property var clips: [
    "192.168.1.14",
    "npm run dev",
    "neil@gmail.com"
]

    spacing: 4

    anchors {
        fill: parent
        margins: 15
    }

    HudListHeader {
        t: root.t
        title: "CLIPBOARD"
        accentColor: t.holo.text
        Layout.leftMargin: 10
        Layout.rightMargin: 10
    }

    Repeater {
        model: parent.clips

        delegate: Item {
            width: parent.width
            height: 50

            Column {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 12
                spacing: 3

                Text {
                    text: modelData
                    color: t.base.text
                    font.family: t.fontFamily
                    font.pixelSize: t.fontSize + 3
                    elide: Text.ElideRight
                    font.bold: true
                }
            }

        }

    }

}
