import "../../assets"
import "../../services"
import "../../theme"
import QtQuick
import QtQuick.Layouts

//--------------------------------------------------------------------------------------
// ROOT ITEM & PROPERTIES
//--------------------------------------------------------------------------------------
Item {
    id: root
    anchors.fill: parent
    property var t

//--------------------------------------------------------------------------------------
// MAIN CONTENT CONTAINER
// Wraps the header and the list, pinned to the top so it doesn't center when empty.
//--------------------------------------------------------------------------------------
    ColumnLayout {
        spacing: 4
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            margins: 15
        }

//--------------------------------------------------------------------------------------
// LIST HEADER
//--------------------------------------------------------------------------------------
        HudListHeader {
            t: root.t
            title: "CLIPBOARD"
            accentColor: t.holo.text
            Layout.leftMargin: 10
            Layout.rightMargin: 10
        }

//--------------------------------------------------------------------------------------
// CLIPBOARD LISTVIEW
// Binds to ClipboardService.clips. Limits height to 250px so it scrolls internally
// instead of expanding infinitely and breaking the panel layout.
//--------------------------------------------------------------------------------------
        ListView {
            model: ClipboardService.clips
            Layout.fillWidth: true
            Layout.preferredHeight: Math.min(contentHeight, 250)
            clip: true
            spacing: 4

//--------------------------------------------------------------------------------------
// CLIP DELEGATE (INDIVIDUAL ROW)
// Each item in the list gets this layout. 
//--------------------------------------------------------------------------------------
            delegate: Item {
                width: parent.width
                // Dynamic height: at least 65px, or grows if the text wraps to multiple lines
                height: Math.max(65, clipContentLayout.implicitHeight + 20)
                
                // ── TACTILE PRESS EFFECT ──────────────────────────────────
                // Shrinks the row slightly when clicked for physical feedback
                scale: mouseArea.pressed ? 0.97 : 1

                Behavior on scale {
                    NumberAnimation { 
                        duration: 100
                        easing.type: Easing.OutQuad 
                    }
                }

                // ── CLICK CATCHER ─────────────────────────────────────────
                // Covers the whole row. Triggers the paste-back function in the service.
                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: ClipboardService.pasteClip(modelData.id)
                }

                // ── ROW CONTENT ───────────────────────────────────────────
                ColumnLayout {
                    id: clipContentLayout
                    spacing: 3
                    anchors {
                        verticalCenter: parent.verticalCenter
                        left: parent.left
                        right: parent.right
                        leftMargin: 12
                    }

                    // The actual clipboard text. Wraps up to 3 lines before eliding.
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

                    // Subtle separator line between clips
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
}
