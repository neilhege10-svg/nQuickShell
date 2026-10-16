import "../state"
import "../theme"
import QtQuick
import Quickshell
import Quickshell.Wayland

// ── ShellPanel ────────────────────────────────────────────────────────
// Owns the window/click-through plumbing only. The actual shape and its
// open/close animation sequence live in PanelShape.qml — this file just
// hosts it and fades page content in once PanelShape signals it's ready.
// ─────────────────────────────────────────────────────────────────────
PanelWindow {
    id: root

    property var targetScreen

    readonly property var pageSize: PanelState.targetSize()

    WlrLayershell.screen: targetScreen
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "shell-panel"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    WlrLayershell.exclusiveZone: 0
    color: "transparent"

    // Stays mapped through the full close sequence (not just while
    // panelOpen is true) so the window only unmaps once PanelShape has
    // actually finished shrinking — same fix as before, still needed.
    visible: PanelState.panelOpen || panelShape.animating

    WlrLayershell.anchors {
        top: true
        left: true
    }

    margins.left: targetScreen ? Math.round(targetScreen.width / 2 - implicitWidth / 2) : 0

    implicitWidth: pageSize.width + 20
    implicitHeight: pageSize.height + (theme ? theme.pillHeight : 40) + 20

    Theme {
        id: theme
    }

//-----------------------------------------------------------------------------------
// The shape + its custom open/close sequence
//-----------------------------------------------------------------------------------
    PanelShape {
        id: panelShape

        t: theme
        open: PanelState.panelOpen
        targetWidth: root.pageSize.width
        targetHeight: root.pageSize.height

        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 7
    }

//-----------------------------------------------------------------------------------
// Content — fades in only once PanelShape.readyForContent flips true,
// so nothing appears mid-resize. Fades out immediately when closing
// starts (readyForContent flips false right away), overlapping with the
// shape's own collapse rather than sitting still first.
//-----------------------------------------------------------------------------------
    Item {
        anchors.fill: panelShape
        anchors.margins: 16
        opacity: panelShape.readyForContent ? 1 : 0

        Behavior on opacity {
            NumberAnimation {
                duration: 200
            }
        }

        Loader {
            id: pageLoader

            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: navPill.top
            anchors.bottomMargin: 10

            active: panelShape.readyForContent
            sourceComponent: {
                switch (PanelState.currentPage) {
                case "main":
                    return mainPage;
                case "wallpaper":
                    return wallpaperPage;
                default:
                    return mainPage;
                }
            }
        }

        NavPill {
            id: navPill

            t: theme
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
        }
    }

    Component {
        id: mainPage

        MainPage {
            t: theme
        }
    }

    Component {
        id: wallpaperPage

        WallpaperGrid {
            t: theme
        }
    }
}
