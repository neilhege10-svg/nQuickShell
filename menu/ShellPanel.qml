import "../state"
import "../theme"
import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Shapes
import Quickshell
import Quickshell.Wayland

// ── ShellPanel ────────────────────────────────────────────────────────
// The shapeshifting control panel. Mirrors Bar.qml's own technique:
//   - own Theme instance (Bar.qml doesn't rely on being handed one either)
//   - WlrLayershell.* attached properties for windowing, matching Bar.qml
//     exactly rather than the generic PanelWindow properties
//   - a Shape/ShapePath background instead of a plain Rectangle, using
//     the same PathQuad-corner technique as the bar's dockBg
//
// IMPORTANT: the window itself is a FIXED size (openWidth x openHeight).
// The open/close morph animates an INNER Item (panelBody) that's clipped,
// not the actual Wayland surface — resizing a real layer-shell surface
// every animation frame is a heavier, potentially janky operation
// (configure/ack round-trip each time). Animating a clipped child inside
// a stable window is the safer bet for smooth motion.
// ─────────────────────────────────────────────────────────────────────
PanelWindow {
    id: root

    property var targetScreen

    readonly property int openWidth: PanelState.barWidth
    readonly property int openHeight: 480
    readonly property int topRadius: 14
    readonly property int bottomRadius: 34

    WlrLayershell.screen: targetScreen
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "shell-panel"
    WlrLayershell.exclusiveZone: 0
    color: "transparent"

    WlrLayershell.anchors {
        top: true
    }

    // fixed surface size — big enough for the fully open panel plus
    // breathing room for the drop shadow / margin gap under the bar
    implicitWidth: openWidth + 24
    implicitHeight: openHeight + (theme ? theme.pillHeight : 40) + 24

    Theme {
        id: theme
    }

//-----------------------------------------------------------------------------------
// panelBody — the part that actually animates. Anchored top-right within
// the fixed window, dropping down from just under the bar.
//-----------------------------------------------------------------------------------
    Item {
        id: panelBody

        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: theme ? theme.pillHeight + 8 : 40

        implicitWidth: PanelState.panelOpen ? root.openWidth : 1
        implicitHeight: PanelState.panelOpen ? root.openHeight : 1
        clip: true

        Behavior on implicitWidth {
            NumberAnimation {
                duration: 380
                easing.type: Easing.OutBack
                easing.overshoot: 0.6
            }
        }

        Behavior on implicitHeight {
            NumberAnimation {
                duration: 420
                easing.type: Easing.OutExpo
            }
        }

//-----------------------------------------------------------------------------------
// MAIN SHAPE OF THE PANEL — same PathQuad-corner technique as dockBg in
// Bar.qml. Small radius up top (near the gear button it drops from),
// bigger radius on the bottom corners for that flowing/dropping feel.
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
// Page content — swaps based on PanelState.currentPage.
// Only "wallpaper" exists so far; add more cases as pages get built.
//-----------------------------------------------------------------------------------
        Loader {
            anchors.fill: parent
            anchors.margins: 16
            active: PanelState.panelOpen
            sourceComponent: {
                switch (PanelState.currentPage) {
                case "wallpaper":
                    return wallpaperPlaceholder;
                default:
                    return wallpaperPlaceholder;
                }
            }
        }
    }

    Component {
        id: wallpaperPlaceholder

        Text {
            anchors.centerIn: parent
            text: "Wallpaper grid goes here"
            color: theme.base.text
        }
    }
}
