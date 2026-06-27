import "../../assets"
import "../../services"
import "../../theme"
import QtQuick
import QtQuick.Layouts

Item {
    id: root
    property var t

//------------------------------------------------------ 
// ColumnLayout to sort the Header and Listview
// ------------------------------------------------------
    ColumnLayout {
      spacing: 4

        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            margins: 15
        }
//------------------------------------------------------ 
// MAIN HEADER FOR THE NotifSection
// ------------------------------------------------------
        HudListHeader {
            t: root.t
            title: "NOTIFS"
            accentColor: t.holo.text
            Layout.leftMargin: 10
            Layout.rightMargin: 10
        }

//------------------------------------------------------ 
// a Listview to list all the Notifications in a
// scrollable column list
// ------------------------------------------------------
        ListView {
            model: NotifService.notifications
            Layout.fillWidth: true
            Layout.preferredHeight: Math.min(contentHeight, 250)
            clip: true
            spacing: 4

            delegate: Item {
                width: parent.width
                height: Math.max(65, notifContentLayout.implicitHeight + 20)

                ColumnLayout {
                    id: notifContentLayout

                    spacing: 3

                    anchors {
                        verticalCenter: parent.verticalCenter
                        left: parent.left
                        right: parent.right
                        leftMargin: 12
                    }

                    //Summary Text, usually for the App title or the Header for the notification
                    Text {
                        text: modelData.summary
                        color: t.base.text
                        font.family: t.fontFamily
                        font.pixelSize: t.fontSize + 3
                        font.bold: true
                        Layout.fillWidth: true
                    }

                    //the actual Notification
                    Text {
                        text: modelData.body
                        font.family: root.t.fontFamily
                        font.pixelSize: root.t.fontSize
                        elide: Text.ElideRight
                        width: root.width - 40
                        color: root.t.base.text
                        Layout.fillWidth: true
                        wrapMode: Text.Wrap
                        maximumLineCount: 3
                    }

                }

//------------------------------------------------------ 
// a Simple Separator to seperate each items
// it lives inside the Listview and outside the ColumnLayout
// ------------------------------------------------------
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
