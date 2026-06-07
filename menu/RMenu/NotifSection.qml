import "../../assets"
import "../../services"
import "../../theme"
import QtQuick
import QtQuick.Layouts

Item {
    id: root
    property var t

    ColumnLayout {
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            margins: 15
        }
        spacing: 4

        HudListHeader {
            t: root.t
            title: "NOTIFS"
            accentColor: root.t.holo.text
            Layout.leftMargin: 10
            Layout.rightMargin: 10
        }

        Repeater {
            model: NotifService.notifications
            delegate: Item {
                width: parent.width
                height: 50

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 12
                    spacing: 3

                    Text {
                        text: modelData.summary
                        color: root.t.base.text
                        font.family: root.t.fontFamily
                        font.pixelSize: root.t.fontSize + 3
                        font.bold: true
                    }

                    Text {
                        text: modelData.body
                        font.family: root.t.fontFamily
                        font.pixelSize: root.t.fontSize
                        elide: Text.ElideRight
                        width: root.width - 40
                        color: root.t.base.textActive
                    }
                }

                Rectangle {
                    anchors.bottom: parent.bottom
                    width: parent.width
                    height: 1
                    color: Qt.rgba(root.t.holo.text.r, root.t.holo.text.g, root.t.holo.text.b, 0.06)
                }
            }
        }
    }
}
