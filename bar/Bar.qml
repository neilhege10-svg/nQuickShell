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
        height: theme.barHeight - 2
        width: contentLayout.implicitWidth + 700

        Shape {
            id: dockBg

            layer.enabled: true
            layer.samples: 8
            anchors.fill: parent

            ShapePath {
                // === RIGHT WING EXTRA ===
                // === SMOOTH S-CURVE TRANSITION (RIGHT SIDE) ===
                // === MAIN BAR BOTTOM ===
                // === SMOOTH S-CURVE TRANSITION (LEFT SIDE - PERFECTLY MIRRORED) ===
                // === LEFT WING EXTRA (PERFECTLY MIRRORED) ===

                fillColor: theme.base.bg
                strokeColor: theme.holo.border
                strokeWidth: 0
                startX: 0
                startY: 0

                // 1. Top Line - Spans completely flat across the top edge
                PathLine {
                    x: dockBg.width
                    y: 0
                }

                // 2. Your tweaked initial curve down
                PathQuad {
                    controlX: dockBg.width
                    controlY: 0
                    x: dockBg.width - 18
                    y: 2
                }

                // 3. Your tweaked brief runway slope
                PathLine {
                    x: dockBg.width - 24
                    y: 4
                }

                // 4. Your custom wide curved connector down to the slope
                PathQuad {
                    controlX: dockBg.width - 28
                    controlY: 6
                    x: dockBg.width - 38
                    y: dockBg.height - 14
                }

                // 5. Your custom Seamless Right Curve (Main bottom corner)
                PathQuad {
                    controlX: dockBg.width - 45
                    controlY: dockBg.height - 2
                    x: dockBg.width - 58
                    y: dockBg.height - 2
                }

                // 6. Flat Bottom Line (Perfect seamless link: right lands at width-54, left starts at 54)
                PathLine {
                    x: 58
                    y: dockBg.height - 2
                }

                // 7. Mirrored Main bottom corner (Mirrors step 5 perfectly)
                PathQuad {
                    controlX: 45
                    controlY: dockBg.height - 2
                    x: 38
                    y: dockBg.height - 14
                }

                // 8. Mirrored custom upper curved connector (Mirrors step 4 perfectly)
                PathQuad {
                    controlX: 28
                    controlY: 6
                    x: 24
                    y: 4
                }

                // 9. Mirrored runway slope segment (Mirrors step 3 perfectly)
                PathLine {
                    x: 18
                    y: 2
                }

                // 10. Mirrored initial curve back up to meet (0,0) (Mirrors step 2 perfectly)
                PathQuad {
                    controlX: 0
                    controlY: 0
                    x: 0
                    y: 0
                }

            }

            layer.effect: DropShadow {
                horizontalOffset: o
                verticalOffset: 4
                radius: 12
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
                leftMargin: 48
                rightMargin: 48
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
            scale: 0.82

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
