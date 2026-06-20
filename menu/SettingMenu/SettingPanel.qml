import "../../assets/animations"
import "../../state"
import "../../theme"
import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Shapes
import Quickshell
import Quickshell.Wayland
import QtQuick.Layouts

PanelWindow {
    id: root

    required property var targetScreen
    property var t: theme

    WlrLayershell.screen: targetScreen
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "settingpanel"
    WlrLayershell.exclusiveZone: -1

    WlrLayershell.anchors {
        left: true
        right: true
        top: true
        bottom: true
    }

    color: "transparent"
    visible: PanelState.settingPanelOpen || panel.openAmount > 0

    Theme { id: theme }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            if (!panel.contains(panel.mapFromItem(parent, mouseX, mouseY)))
                PanelState.settingPanelOpen = false
        }
    }

    Item {
        id: panel
        property string settingsPage: "themes"

        width: 1000
        height: 700

        // Horizontally centered, top pinned to where it sits when fully open
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: (parent.height - 700) / 2

        property real openAmount: PanelState.settingPanelOpen ? 1 : 0
        property real o: openAmount
        property int  cut: 16

        Behavior on openAmount {
            NumberAnimation {
                duration: 500
                easing.type: Easing.OutCubic
            }
        }

        // ── THE SHAPE ─────────────────────────────────────────────────
        // X coordinates are always at their final positions — full width from frame 1.
        // Y coordinates multiply by openAmount — grows downward from a flat line.
        //
        // At o=0: flat horizontal line spanning full width at y=0
        // At o=1: full 700x500 shape with all 4 corners cut
        Shape {
            id: panelShape
            layer.enabled: true
            layer.samples: 6
            anchors.fill: parent

            ShapePath {
                fillColor: theme.base.bg
                strokeColor: theme.base.border
                strokeWidth: 1
                joinStyle: ShapePath.MiterJoin

                // Top-left cut — y is always 0 (the fixed top edge)
                startX: panel.cut
                startY: 0

                // Top edge end
                PathLine { x: panel.width - panel.cut; y: 0 }

                // Top-right cut grows downward
                PathLine {
                    x: panel.width
                    y: panel.cut * panel.o
                }
                // Right edge bottom grows downward
                PathLine {
                    x: panel.width
                    y: (panel.height - panel.cut) * panel.o
                }
                // Bottom-right cut
                PathLine {
                    x: panel.width - panel.cut
                    y: panel.height * panel.o
                }
                // Bottom edge
                PathLine {
                    x: panel.cut
                    y: panel.height * panel.o
                }
                // Bottom-left cut
                PathLine {
                    x: 0
                    y: (panel.height - panel.cut) * panel.o
                }
                // Left edge top grows downward
                PathLine {
                    x: 0
                    y: panel.cut * panel.o
                }
                // Close back to top-left
                PathLine {
                    x: panel.cut
                    y: 0
                }
            }

            layer.effect: DropShadow {
                horizontalOffset: 0
                verticalOffset: 0
                radius: 24
                samples: 32
                color: theme.base.shadow
            }
        }

        // ── CONTENT CLIP ──────────────────────────────────────────────
        // Clips content to the currently drawn height so it doesn't
        // bleed outside the shape while it's still growing
        Item {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: panel.height * panel.o
            clip: true

            Item {
                id: contentArea
                width: parent.width
                height: panel.height
                opacity: 0

                // ── PLACEHOLDER ── replace with real content
              RowLayout {
                spacing: 10

                anchors {
                  top: parent.top
                  left: parent.left
                  right: parent.right
                  bottom: parent.bottom
                  margins: 10
                }

                ListView {
                 id: sidebar
                 Layout.preferredWidth: 110     // fixed width for the sidebar
                 Layout.fillHeight: true        // stretches to fill available height
                 Layout.topMargin: 10
                 model: ["Themes", "Wallpapers"]  

                 delegate: Item {
                   id: delegateItem
                   width: sidebar.width
                   height: 40

                   property bool isActive: panel.settingsPage === modelData.toLowerCase()

                   Rectangle {
                     anchors.fill: parent
                     color: delegateItem.isActive ? Qt.rgba(t.holo.neonActive.r, t.holo.neonActive.g, t.holo.neonActive.b, 0.2) : "transparent"
                   }


                   Text {
                     anchors.verticalCenter: parent.verticalCenter
                     anchors.left: parent.left
                     anchors.leftMargin: 12
                     text: modelData
                     color: t.base.text
                   }

                   MouseArea {
                     anchors.fill: parent
                     onClicked: panel.settingsPage = modelData.toLowerCase()
                   }
                 }
               }
             

                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.topMargin: 10
                    Layout.bottomMargin: 10
                    Layout.rightMargin: 5

                    Rectangle {
                        anchors.fill: parent
                        radius: 8
                        color: t.base.surface
                    }

                    ThemeSwitcher {
                        t: panel.t
                        anchors.fill: parent
                        visible: panel.settingsPage === "themes"
                    }

                    WallpaperSwitcher {
                        t: panel.t
                        anchors.fill: parent
                        visible: panel.settingsPage === "wallpapers"
                    }
                }
            }
       }
  }

        // ── CONTENT FLICKER ───────────────────────────────────────────
        FlickerAnimation {
            id: flickerAnim
            targetItem: contentArea
            speedMultiplier: 1
        }

        Connections {
            target: PanelState
            function onSettingPanelOpenChanged() {
                if (!PanelState.settingPanelOpen) {
                    flickerAnim.stop()
                    contentArea.opacity = 0
                }
            }
        }

        Connections {
            target: panel
            function onOpenAmountChanged() {
                if (panel.openAmount > 0.6 && PanelState.settingPanelOpen && !flickerAnim.running) {
                    contentArea.opacity = 0
                    flickerAnim.restart()
                }
            }
        }
    }
}
