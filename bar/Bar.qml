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
    implicitHeight: theme.barHeight + 12
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

        DropShadow {
            anchors.fill: dockBg
            horizontalOffset: 0
            verticalOffset: 0
            radius: 9
            samples: 17
            color: "#000000"
            source: dockBg
        }

        Shape {
            id: dockBg

            layer.enabled: true
            layer.samples: 6
            anchors.fill: parent

            ShapePath {
                fillColor: theme.base.bg // UPGRADED: Explicitly uses namespaced base UI background
                strokeColor: "transparent"
                strokeWidth: 1
                startX: 0
                startY: 0

                PathLine {
                    x: dockBg.width
                    y: 0
                }

                PathLine {
                    x: dockBg.width - 12
                    y: dockBg.height - 3
                }

                PathArc {
                    x: dockBg.width - 15
                    y: dockBg.height
                    radiusX: 33
                    radiusY: 30
                }

                PathLine {
                    x: 15
                    y: dockBg.height
                }

                PathArc {
                    x: 12
                    y: dockBg.height - 3
                    radiusX: 33
                    radiusY: 30
                }

                PathLine {
                    x: 0
                    y: 0
                }

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
