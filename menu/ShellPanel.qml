import "../state"
import "../theme"
import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Shapes
import Quickshell
import Quickshell.Wayland

// ── ShellPanel ────────────────────────────────────────────────────────
// The shapeshifting control panel window.
// Hosts active sub-pages (via Loader) anchored to the top and a floating 
// NavPill component anchored to the bottom.
// ─────────────────────────────────────────────────────────────────────
PanelWindow {
    id: root

    property var targetScreen

    readonly property int openWidth: PanelState.barWidth
    readonly property int openHeight: 480
    readonly property int topRadius: 34
    readonly property int bottomRadius: 34

    WlrLayershell.screen: targetScreen
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "shell-panel"
    WlrLayershell.exclusiveZone: 0
    color: "transparent"

    // Unmaps window when collapsed to prevent intercepting mouse clicks
    property real openAmount: PanelState.panelOpen ? 1 : 0
    visible: PanelState.panelOpen || openAmount > 0.001

    Behavior on openAmount {
        NumberAnimation {
            duration: 420
        }
    }

    WlrLayershell.anchors {
        top: true
        left: true
    }

    // Explicit horizontal centering alignment relative to output
    margins.left: targetScreen ? Math.round(targetScreen.width / 2 - implicitWidth / 2) : 0

    implicitWidth: openWidth + 24
    implicitHeight: openHeight + (theme ? theme.pillHeight : 40) + 24

    Theme {
        id: theme
    }

//-----------------------------------------------------------------------------------
// panelBody — Top-anchored morphing panel surface container
//-----------------------------------------------------------------------------------
    Item {
        id: panelBody

        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: theme ? theme.pillHeight - 4 : 32

        implicitWidth: PanelState.panelOpen ? root.openWidth : 1
        implicitHeight: PanelState.panelOpen ? root.openHeight : 1
        clip: true

        Behavior on implicitWidth {
            NumberAnimation {
                duration: 100
                easing.type: Easing.OutBack
                easing.overshoot: 0.6
            }
        }

        Behavior on implicitHeight {
            NumberAnimation {
                duration: 1000
                easing.type: Easing.OutExpo
            }
        }

//-----------------------------------------------------------------------------------
// Background Path Shape
//-----------------------------------------------------------------------------------
        Shape {
            id: panelBg

            anchors.fill: parent
            layer.enabled: true
            layer.samples: 8

            ShapePath {
                fillColor: theme.base.bg
                strokeWidth: 0

                startX: 0
                startY: root.topRadius

                PathQuad {
                    controlX: 0
                    controlY: 0
                    x: root.topRadius
                    y: 0
                }

                PathLine {
                    x: panelBg.width - root.topRadius
                    y: 0
                }

                PathQuad {
                    controlX: panelBg.width
                    controlY: 0
                    x: panelBg.width
                    y: root.topRadius
                }

                PathLine {
                    x: panelBg.width
                    y: panelBg.height - root.bottomRadius
                }

                PathQuad {
                    controlX: panelBg.width
                    controlY: panelBg.height
                    x: panelBg.width - root.bottomRadius
                    y: panelBg.height
                }

                PathLine {
                    x: root.bottomRadius
                    y: panelBg.height
                }

                PathQuad {
                    controlX: 0
                    controlY: panelBg.height
                    x: 0
                    y: panelBg.height - root.bottomRadius
                }

                PathLine {
                    x: 0
                    y: root.topRadius
                }
            }

            layer.effect: DropShadow {
                horizontalOffset: 0
                verticalOffset: 4
                radius: 12
                samples: 17
                color: theme.base.shadow
            }
        }

//-----------------------------------------------------------------------------------
// Content Layout Structure (Top-Aligned Loader + Bottom NavPill)
//-----------------------------------------------------------------------------------
// Inside ShellPanel.qml -> Content Layout Structure

        Item {
            anchors.fill: parent
            anchors.margins: 16

            // Page Content Grid Container
            Loader {
                id: pageLoader

                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: navPill.top
                anchors.bottomMargin: 10

                active: PanelState.panelOpen
                sourceComponent: {
                    switch (PanelState.currentPage) {
                    case "wallpaper":
                        return wallpaperPage;
                    default:
                        return wallpaperPage;
                    }
                }
            }

            // Dedicated Navigation Pill — Stretches horizontally to match parent width
            NavPill {
                id: navPill

                t: theme
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
            }
        }
      }
    Component {
        id: wallpaperPage

        WallpaperGrid {
            t: theme
        }
    }
}
