import "../../theme"
import QtQuick
import "../../assets"
import "../../services"
import QtQuick.Layouts

Item {
  id: root
    property var t
    property bool dndEnabled: false
    property bool clipboardPaused: false

    Rectangle {
        anchors.fill: parent
        radius: 14
        color: t.base.altbg
        border.color: t.base.border
        border.width: 1
    }
    ColumnLayout {
        spacing: 10

        anchors {
            fill: parent
            leftMargin: 18
            rightMargin: 18
            topMargin: 14
            bottomMargin: 14
        }

     RowLayout {
        Layout.fillWidth: true
        spacing: 16
        Text {
          text: "DND"
                font.family: t.fontFamily
                font.pixelSize: t.fontSize + 2
                font.bold: true
                font.letterSpacing: 1.5
                color: t.base.text
              }
            Item {
                Layout.fillWidth: true
            }

            ToggleSwitch {
                t: root.t
                checked: root.dndEnabled
                onToggled: root.dndEnabled = !root.dndEnabled
            }

            BtnRound {
                t: root.t; icon: "󰆴"; showShadow: true

            }
          }

        // SEPERATOR LINE
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Qt.rgba(t.holo.text.r, t.holo.text.g, t.holo.text.b, 0.06)
            Layout.topMargin: 10
            Layout.bottomMargin: 10
          }
        //SEPERATOR LINE

     RowLayout {
        Layout.fillWidth: true
        spacing: 16
        Text {
          text: "CLIPBOARD"
                font.family: t.fontFamily
                font.pixelSize: t.fontSize + 2
                font.bold: true
                font.letterSpacing: 1.5
                color: t.base.text
              }
            Item {
                Layout.fillWidth: true
            }

            ToggleSwitch {
                t: root.t
                checked: root.clipboardPaused
                onToggled: root.clipboardPaused = !root.clipboardPaused
            }

            BtnRound {
                t: root.t; icon: "󰆴"; showShadow: true
            }
          }


 }
}
