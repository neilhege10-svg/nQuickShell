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
    // ── CALLBACKS ───────────────────────────────────────
    property var onItemClicked: function(modelData) {
    }
    // 1. Set the maximum height limit before it starts scrolling
    property real maxHeight: 200

    // ── SIZING & LIMIT CONSTRAINTS ──────────────────────
    width: 300
    // 2. Dynamic height: shrink-to-fit content, but hard-cap at maxHeight
    height: Math.min(listView.contentHeight, maxHeight)
    // Layout helper to let parent ColumnLayouts inside NetworkSection/VolumeControl respect this height
    Layout.preferredWidth: width
    Layout.preferredHeight: height

    ListView {
        id: listView

        anchors.fill: parent
        model: root.listModel
        // 3. CRITICAL: Prevents text from bleeding out over your other UI sections
        clip: true
        // Stops the list from awkwardly bouncing like a mobile app when scrolling on desktop
        boundsBehavior: Flickable.StopAtBounds
        // Space out items if needed (replaces the ColumnLayout spacing)
        spacing: 0

        delegate: Item {
            id: delegateItem

            // ListView automatically passes 'modelData' to the delegate
            property bool isActive: root.activeItem === modelData || (root.activeItem && modelData && root.activeItem.name === modelData.name)

            // ListView items require an explicit width and height on their root delegate
            width: listView.width
            height: 40

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.onItemClicked(modelData)
            }

            // Selection Highlight
            Rectangle {
                anchors.fill: parent
                anchors.bottomMargin: 1
                visible: delegateItem.isActive

                gradient: Gradient {
                    orientation: Gradient.Horizontal

                    GradientStop {
                        position: 0
                        color: "transparent"
                    }

                    GradientStop {
                        position: 0.6
                        color: Qt.rgba(t.holo.neonActive.r, t.holo.neonActive.g, t.holo.neonActive.b, 0.06)
                    }

                    GradientStop {
                        position: 1
                        color: "transparent"
                    }

                }

            }

            RowLayout {
                spacing: 10

                anchors {
                    fill: parent
                    leftMargin: 8
                    rightMargin: 12
                }

                // Accent Bar
                Rectangle {
                    width: 3
                    height: 18
                    radius: 1
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
                    text: typeof modelData === "string" ? modelData : (modelData[root.labelProperty] || "")
                    elide: Text.ElideRight
                    color: delegateItem.isActive ? t.holo.textActive : Qt.rgba(t.base.textActive.r, t.base.textActive.g, t.base.textActive.b, 0.6)

                    font {
                        family: t.fontFamily
                        pixelSize: t.fontSize
                        bold: delegateItem.isActive
                    }

                }

                // Dynamic Right-Side Injection (Icons/Telemetry)
                Loader {
                    // Expose context out to the custom component block safely
                    property var modelData: modelData

                    Layout.alignment: Qt.AlignVCenter
                    active: root.rightSideItem !== null
                    sourceComponent: root.rightSideItem
                }

            }

            // Separator Line
            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width
                height: 1
                color: Qt.rgba(t.holo.text.r, t.holo.text.g, t.holo.text.b, 0.04)
            }

        }

    }

}
