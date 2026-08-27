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

    // Full visual span of the bar. dockContainer already includes generous
    // built-in padding (+500), and the side buttons land INSIDE its edge
    // (not past it), so dockContainer.width alone is the correct match.
    // The dock's right-side ShapePath tapers inward via a chain of PathQuad
    // curves (see dockBg's ShapePath below) — there's no clean analytical
    // way to derive the exact rendered edge from those bezier curves, so
    // this is an eyeballed, tuned-by-hand offset. Kept HERE (next to the
    // shape that causes it) rather than buried in another file, so future
    // edits to the taper curves have an obvious place to also update this.
    readonly property int edgeTaper: 85

    property real barFootprintWidth: dockContainer.width - edgeTaper

    onBarFootprintWidthChanged: PanelState.barWidth = barFootprintWidth
    Component.onCompleted: PanelState.barWidth = barFootprintWidth

    // this determines the height and width of the bar
    Item {
        id: dockContainer

        anchors.horizontalCenter: parent.horizontalCenter
        height: theme.barHeight - 1
        width: contentLayout.implicitWidth + 700
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
RowLayout {
  id: centerLayout
  spacing : 0

  anchors {
    horizontalCenter: parent.horizontalCenter
    verticalCenter: contentLayout.verticalCenter
    topMargin: 2
    bottomMargin: 2
  }
        Notifications {
          id: notifBell
          t: theme
        }
        Clock {
            id: clockWidget
            t: theme
        }

      }
//--------------------------------------------------------------------------------------
// This is the bar's RowLayout it contains all the Modules inside a typical bar
// like Bluetooth, systats, wifi, etc. it is specifically anchored to the lef and right
// side of the bar to create space from the middle clock module
//--------------------------------------------------------------------------------------
        RowLayout {
            id: contentLayout

            spacing: 2

            anchors {
                fill: parent
                leftMargin: 48
                rightMargin: 48
                topMargin: 3
                bottomMargin: 3
            }

            Workspaces {
                t: theme
                monitor: Hyprland.monitorFor(targetScreen)
            }

            Item {
                Layout.fillWidth: true
            }

// ── CONTROL STATUS TRAIL PILL ────────────────────────

            Item {
                Layout.alignment: Qt.AlignVCenter
                implicitWidth: controlPill.implicitWidth
                implicitHeight: controlPill.implicitHeight

                // Subtle shadow effect to lift the pill

            DropShadow {
                anchors.fill: controlPill
                horizontalOffset: 2
                verticalOffset: 2
                radius: 8
                samples: 17
                color: "#60000000"
                source: controlPill
                visible: true
            }
                Rectangle {
                    id: controlPill

                    anchors.fill: parent
                    implicitWidth: controlLayout.implicitWidth + 19
                    implicitHeight: theme ? theme.pillHeight : 28

                    radius: theme ? theme.widgetRadius : 10
                    color: theme ? theme.base.accent : "#313244"

                    RowLayout {
                        id: controlLayout

                        anchors.centerIn: parent
                        spacing: 6 // Tight padding between status icons inside this group

                        Volume {
                            t: theme
                        }

                        Network {
                            t: theme
                        }

                        Bluetooth {
                            t: theme
                        }
                    }
                }
            }
        }
//--------------------------------------------------------------------------------------
// This is the SIDE BUTTONS these are 2 extra buttons that lives outside the bar
// theyre anchored to the contentLayout above but are margined to the left and right
// to live just outside the bar
//--------------------------------------------------------------------------------------
BtnRound {
    id: wallpaperBtn
    t: theme
    icon: ""
    hasBorder: true
    showShadow: true
    scale: 0.82
    activeState: PanelState.panelOpen && PanelState.currentPage === "wallpaper"
    onClicked: PanelState.toggle("wallpaper")

    anchors {
        left: contentLayout.right
        top: contentLayout.top
        topMargin: 1
        leftMargin: 17
    }
  }

  BtnRound {
            id: powerBtn
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
