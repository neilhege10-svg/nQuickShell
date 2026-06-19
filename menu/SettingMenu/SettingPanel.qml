import "../../assets/animations"
import "../../state"
import "../../theme"
import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Shapes
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: root

    required property var targetScreen

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
                Text {
                    anchors.centerIn: parent
                    text: "SETTINGS"
                    color: Qt.rgba(1, 1, 1, 0.15)
                    font.pixelSize: 32
                    font.letterSpacing: 8
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
