import "../../assets"
import "../../theme"
import QtQuick
import QtQuick.Layouts

ColumnLayout {
  id: root
    property var t

    spacing: 4
    anchors { 
     fill: parent
     margins: 15 }

    property var notifications: [
        { app: "Discord", message: "Someone sent a message" },
        { app: "Firefox", message: "Download complete" },
        { app: "System", message: "Update available" }
    ]

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
            height: 40
            Text {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 12
                text: modelData.app + " — " + modelData.message
                color: "white"
                font.pixelSize: 12
            }
        }
    }
}
