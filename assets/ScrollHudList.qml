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
    // Controls how tall the menu can grow before it starts scrolling.
    property int maxHeight: 240
    // ── CALLBACKS ───────────────────────────────────────
    property var onItemClicked: function(modelData) {
    }

    width: 300
    // ── DYNAMIC HEIGHT ────────────────────────────────────────────────────────
    // FIXED: Calculate height using count directly to avoid heavy binding loops
    height: Math.min(listView.count * 40, maxHeight)

    ListView {
        id: listView

        anchors.fill: parent
        model: root.listModel
        spacing: 0
        // Essential for scrolling viewports — clips rows cleanly at the edges
        clip: true
        // Prevents the list from bouncing/stretching aggressively on desktop layouts
        boundsBehavior: Flickable.StopAtBounds

        delegate: Item {
            id: delegateItem

            // Explicitly map modelData for generic JS arrays/objects passed in
            readonly property var currentData: modelData
            property bool isActive: root.activeItem === currentData

            width: listView.width
            height: 40 // FIXED: Changed from implicitHeight to hardcoded height to stop 0-pixel layout spikes

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
                color: delegateItem.isActive ? Qt.rgba(t.holo.text.r, t.holo.text.g, t.holo.text.b, 0.05) : "transparent"
                visible: delegateItem.isActive
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                spacing: 8

                // Active Accent Bar
                Rectangle {
                    width: 3
                    height: 16
                    color: t.holo.text
                    Layout.alignment: Qt.AlignVCenter
                    opacity: delegateItem.isActive ? 1 : 0

                    Behavior on opacity {
                        NumberAnimation {
                            duration: 200
                            easing.type: Easing.OutQuad
                        }

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
                    // Injects the current row's data so the icons can read signal/secured states
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

    }

}
