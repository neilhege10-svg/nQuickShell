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
            anchors.fill: parent // Keep full size

            ShapePath {
                fillColor: theme.base.bg
                strokeColor: theme.base.border
                strokeWidth: 1
                startX: 0
                startY: 2

                // Top Line
                PathLine {
                    x: dockBg.width
                    y: 2
                }

                // Right Slope
                PathLine {
                    x: dockBg.width - 12
                    y: dockBg.height - 2 // Pushes 2 pixels up from the hard bottom edge
                }

                // Right Arc
                PathArc {
                    x: dockBg.width - 15
                    y: dockBg.height - 2 // Pushes 2 pixels up from the hard bottom edge
                    radiusX: 18
                    radiusY: 18
                }

                // Flat Bottom Line
                PathLine {
                    x: 15
                    y: dockBg.height - 2 // Pushes 2 pixels up from the hard bottom edge
                }

                // Left Arc
                PathArc {
                    x: 12
                    y: dockBg.height - 2 // Pushes 2 pixels up from the hard bottom edge
                    radiusX: 18
                    radiusY: 18
                }

                // Left Slope back to start
                PathLine {
                    x: 0
                    y: 2
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
                leftMargin: 20
                rightMargin: 20
                topMargin: 4
                bottomMargin: 4
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
