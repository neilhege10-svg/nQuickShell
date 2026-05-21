import "../theme"
import QtQuick
import QtQuick.Effects
import QtQuick.Layouts

Item {
    id: root

    // ── DESIGN SYSTEM & SIZING ──────────────────────────
    property var t
    
    // ── GENERIC INTERFACE PROPERTIES ────────────────────
    property var listModel: null
    property var activeItem: null
    property string labelProperty: "description"
    property Component rightSideItem: null
    
    // ── SCROLL BOUNDARY LIMIT ───────────────────────────
    property int maxHeight: 240
    
    // ── CALLBACKS ───────────────────────────────────────
    property var onItemClicked: function(modelData) {}

    width: 300
    height: Math.min(listView.count * 40, maxHeight)

    ListView {
        id: listView
        anchors.fill: parent
        model: root.listModel
        spacing: 0
        clip: true
        
        // DESKTOP FIX: Disables the smartphone click-and-drag panning behavior
        interactive: false 
        boundsBehavior: Flickable.StopAtBounds

        // DESKTOP FIX: Restores native mouse wheel scrolling over the list
        WheelHandler {
            id: wheelHandler
            target: listView
            orientation: Qt.Vertical
        }

        delegate: Item {
            id: delegateItem

            readonly property var currentData: modelData
            property bool isActive: root.activeItem === currentData

            width: listView.width
            height: 40

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.onItemClicked(currentData)
            }

            // Selection Highlight Background
            Rectangle {
                anchors.fill: parent
                anchors.bottomMargin: 1
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0; color: "transparent" }
                    GradientStop { position: 0.6; color: Qt.rgba(t.holo.neonActive.r, t.holo.neonActive.g, t.holo.neonActive.b, 0.06) }
                    GradientStop { position: 1; color: "transparent" }
                }
                visible: delegateItem.isActive
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 18 // Padded to clear the wider interactive scroll track
                spacing: 8

                // Active Accent Bar
                Rectangle {
                    width: 3
                    height: 16
                    color: t.holo.text
                    Layout.alignment: Qt.AlignVCenter
                    opacity: delegateItem.isActive ? 1 : 0

                    Behavior on opacity {
                        NumberAnimation { duration: 200; easing.type: Easing.OutQuad }
                    }
                }

                // Dynamic Label
                Text {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    text: typeof currentData === "string" ? currentData : (currentData[root.labelProperty] || "")
                    elide: Text.ElideRight
                    color: delegateItem.isActive ? t.holo.textActive : Qt.rgba(t.base.textActive.r, t.base.textActive.g, t.base.textActive.b, 0.6)

                    font {
                        family: t.fontFamily
                        pixelSize: t.fontSize
                        bold: delegateItem.isActive
                    }
                }

                Loader {
                    property var modelData: delegateItem.currentData
                    Layout.alignment: Qt.AlignVCenter
                    sourceComponent: root.rightSideItem
                    visible: status === Loader.Ready
                }
            }

            // Row Separator Line
            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width
                height: 1
                color: Qt.rgba(t.holo.text.r, t.holo.text.g, t.holo.text.b, 0.04)
            }
        }

        // ── INTERACTIVE DESKTOP SCROLLBAR ───────────────────────────────────
        Rectangle {
            id: scrollTrack
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.rightMargin: 2
            anchors.topMargin: 4
            anchors.bottomMargin: 4
            width: 4 
            color: "transparent" 
            visible: listView.visibleArea.heightRatio < 1.0

            // Scroll Handle
            Rectangle {
                id: scrollThumb
                width: parent.width
                height: Math.max(20, parent.height * listView.visibleArea.heightRatio)
                
                // Dynamically tracks list position when not dragging
                y: parent.height * listView.visibleArea.yPosition
                radius: 2
                
                // Darkens color on hover or grab
                color: scrollMouseArea.containsPress 
                       ? t.holo.text 
                       : (scrollMouseArea.containsMouse ? Qt.rgba(t.holo.text.r, t.holo.text.g, t.holo.text.b, 0.6) : Qt.rgba(t.holo.text.r, t.holo.text.g, t.holo.text.b, 0.3))

                Behavior on color { ColorAnimation { duration: 100 } }
            }

            // Click and Drag Controller
            MouseArea {
                id: scrollMouseArea
                anchors.fill: parent
                
                // Negative margin widens the mouse target area so you don't have to aim precisely at a 4px line
                anchors.leftMargin: -12 
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                function dragScroll(mouseY) {
                    let availableTrackHeight = scrollTrack.height - scrollThumb.height;
                    if (availableTrackHeight <= 0) return;

                    // Calculates position ratio relative to thumb center point
                    let relativeY = mouseY - (scrollThumb.height / 2);
                    let percentage = Math.max(0, Math.min(1, relativeY / availableTrackHeight));

                    // Direct mapping back to the list's viewport coordinate
                    listView.contentY = percentage * (listView.contentHeight - listView.height);
                }

                onPositionChanged: (mouse) => { if (pressed) dragScroll(mouse.y) }
                onPressed: (mouse) => dragScroll(mouse.y)
            }
        }
    }
}
