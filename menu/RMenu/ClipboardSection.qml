import "../../assets"
import "../../services"
import "../../theme"
import QtQuick
import QtQuick.Layouts

ColumnLayout {
    id: root

    property var t

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

    ListView {
        model: ClipboardService.clips
        Layout.fillWidth: true
        Layout.preferredHeight: Math.min(contentHeight, 250)
        clip: true
        spacing: 4

        delegate: Item {
            width: parent.width
            height: Math.max(65, clipContentLayout.implicitHeight + 20)

            ColumnLayout {
                id: clipContentLayout

                spacing: 3

                anchors {
                    verticalCenter: parent.verticalCenter
                    left: parent.left
                    right: parent.right
                    leftMargin: 12
                }

                Text {
                    text: modelData.text
                    font.family: root.t.fontFamily
                    font.pixelSize: root.t.fontSize
                    elide: Text.ElideRight
                    width: root.width - 40
                    color: root.t.base.textActive
                    Layout.fillWidth: true
                    wrapMode: Text.Wrap
                    maximumLineCount: 3
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
