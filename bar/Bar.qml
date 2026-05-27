import "../assets"
import "../state"
import "../theme"
import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland

PanelWindow {
    id: root

    property var targetScreen

    WlrLayershell.screen: targetScreen
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "bar" // Tells Hyprland this is a bar, preventing dimaround quirks
    WlrLayershell.exclusiveZone: theme.barHeight
    implicitHeight: theme.barHeight + 40
    color: "transparent"

    WlrLayershell.anchors {
        top: true
        left: true
        right: true
        bottom: false
    }

    Theme {
        id: theme
    }

    Item {
        id: dockContainer

        anchors.horizontalCenter: parent.horizontalCenter
        height: theme.barHeight
        width: contentLayout.implicitWidth + 700

        Shape {
            id: dockBg

            layer.enabled: true
            layer.samples: 6
            anchors.fill: parent

            ShapePath {
                fillColor: theme.base.bg
                strokeColor: theme.base.border
                strokeWidth: 0
                startX: 0
                startY: 0

                // 1. Top Line
                PathLine {
                    x: dockBg.width
                    y: 0
                }

                // 2. Right Slope (Stops just above the turn)
                PathLine {
                    x: dockBg.width - 10
                    y: dockBg.height - 10
                }

                // 3. Seamless Right Curve (Bézier Curve)
                // Uses the theoretical "sharp" corner as a magnet to pull the curve smoothly
                PathQuad {
                    controlX: dockBg.width - 14
                    controlY: dockBg.height - 2
                    x: dockBg.width - 22
                    y: dockBg.height - 2
                }

                // 4. Flat Bottom Line
                PathLine {
                    x: 22
                    y: dockBg.height - 2
                }

                // 5. Seamless Left Curve (Bézier Curve)
                PathQuad {
                    controlX: 14
                    controlY: dockBg.height - 2
                    x: 10
                    y: dockBg.height - 10
                }

                // 6. Left Slope back to start
                PathLine {
                    x: 0
                    y: 0
                }

            }

            layer.effect: DropShadow {
                horizontalOffset: 3
                verticalOffset: 2
                radius: 10
                samples: 17
                color: theme.base.shadow
            }

        }

        Clock {
            id: clockWidget

            t: theme

            anchors {
                horizontalCenter: parent.horizontalCenter
                verticalCenter: contentLayout.verticalCenter
                topMargin: 2
                bottomMargin: 2
            }

        }

        RowLayout {
            id: contentLayout

            spacing: theme.spacing

            anchors {
                fill: parent
                leftMargin: 18
                rightMargin: 18
                topMargin: 2
                bottomMargin: 2
            }

            Workspaces {
                t: theme
                monitor: Hyprland.monitorFor(targetScreen)
            }

            // CLEANUP: Consolidated the two identical spacers into one layout-efficient stretch element
            Item {
                Layout.fillWidth: true
            }

            SystemStats {
                t: theme
            }

            Battery {
                t: theme
            }

            Volume {
                t: theme
            }

            Network {
                t: theme
            }

        }

        BtnRound {
            t: theme
            icon: ""
            hasBorder: true
            showShadow: true

            anchors {
                left: contentLayout.right
                verticalCenter: contentLayout.verticalCenter
                leftMargin: 23
            }

        }

        BtnRound {
            t: theme
            icon: "⏻"
            hasBorder: true
            showShadow: true
            activeState: PanelState.cPanelOpen
            onClicked: PanelState.cPanelOpen = !PanelState.cPanelOpen

            anchors {
                right: contentLayout.left
                verticalCenter: contentLayout.verticalCenter
                rightMargin: 23
            }

        }

    }

}
