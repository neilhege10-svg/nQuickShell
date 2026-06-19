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
    implicitHeight: theme.barHeight + 10
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
        height: theme.barHeight - 2
        width: contentLayout.implicitWidth + 800
//--------------------------------------------------------------------------------------
// MAIN SHAPE OF THE BAR
//--------------------------------------------------------------------------------------
        Shape {
            id: dockBg

            layer.enabled: true
            layer.samples: 8
            anchors.fill: parent

            ShapePath {
                fillColor: theme.base.bg
                strokeColor: theme.holo.border
                strokeWidth: 0
                startX: 0
                startY: 0

                PathLine {
                    x: dockBg.width
                    y: 0
                }

                PathQuad {
                    controlX: dockBg.width
                    controlY: 0
                    x: dockBg.width - 18
                    y: 2
                }

                PathLine {
                    x: dockBg.width - 24
                    y: 4
                }

                PathQuad {
                    controlX: dockBg.width - 28
                    controlY: 6
                    x: dockBg.width - 38
                    y: dockBg.height - 14
                }

                PathQuad {
                    controlX: dockBg.width - 45
                    controlY: dockBg.height - 2
                    x: dockBg.width - 58
                    y: dockBg.height - 2
                }

                PathLine {
                    x: 58
                    y: dockBg.height - 2
                }

                PathQuad {
                    controlX: 45
                    controlY: dockBg.height - 2
                    x: 38
                    y: dockBg.height - 14
                }

                PathQuad {
                    controlX: 28
                    controlY: 6
                    x: 24
                    y: 4
                }

                PathLine {
                    x: 18
                    y: 2
                }

                PathQuad {
                    controlX: 0
                    controlY: 0
                    x: 0
                    y: 0
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
//--------------------------------------------------------------------------------------
// the Clock Widget, it is seperated from contentLayout so that
// it can be anchored to the center of the bar
//--------------------------------------------------------------------------------------
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

//--------------------------------------------------------------------------------------
// This is the bar's RowLayout it contains all the Modules inside a typical bar
// like Bluetooth, systats, wifi, etc. it is specifically anchored to the lef and right
// side of the bar to create space from the middle clock module
//--------------------------------------------------------------------------------------
        RowLayout {
            id: contentLayout

            spacing: theme.spacing

            anchors {
                fill: parent
                leftMargin: 48
                rightMargin: 48
                topMargin: 2
                bottomMargin: 2
            }

            Workspaces {
                t: theme
                monitor: Hyprland.monitorFor(targetScreen)
            }

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

//--------------------------------------------------------------------------------------
// This is the SIDE BUTTONS these are 2 extra buttons that lives outside the bar
// theyre anchored to the contentLayout above but are margined to the left and right
// to live just outside the bar
//--------------------------------------------------------------------------------------
        BtnRound {
            t: theme
            icon: ""
            hasBorder: true
            showShadow: true
            scale: 0.82
            activeState: PanelState.settingPanelOpen
            onClicked: PanelState.settingPanelOpen = !PanelState.settingPanelOpen

            anchors {
                left: contentLayout.right
                top: contentLayout.top
                topMargin: 1
                leftMargin: 17
            }

        }

        BtnRound {
            t: theme
            icon: "⏻"
            hasBorder: true
            showShadow: true
            activeState: PanelState.cPanelOpen
            onClicked: PanelState.cPanelOpen = !PanelState.cPanelOpen
            scale: 0.82

            anchors {
                right: contentLayout.left
                top: contentLayout.top
                topMargin: 1
                rightMargin: 17
            }

        }

    }

}
