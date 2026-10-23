
import "../state"
import "../theme"
import QtQuick
import Quickshell
import Quickshell.Wayland

// ── ShellPanel ────────────────────────────────────────────────────────
// Owns the window/click-through plumbing only. The actual shape and its
// open/close animation sequence live in PanelShape.qml — this file just
// hosts it and coordinates the page-switch resize and fade sequence.
// ─────────────────────────────────────────────────────────────────────
PanelWindow {
    id: root

    property var targetScreen

    // Keep the displayed page separate from the requested page.
    // This prevents the window and shape from resizing before the
    // outgoing page has finished fading out.
    property string displayedPage: PanelState.currentPage

    readonly property var pageSize: PanelState.pageSizes[displayedPage]
                                   || PanelState.defaultSize

    // Keep the outer window fixed so Wayland doesn't reposition it
    // while PanelShape animates between page sizes.
    readonly property real windowWidth: Math.max(
        PanelState.pageSizes.main.width,
        PanelState.pageSizes.wallpaper.width
    ) + 20

    readonly property real windowHeight: Math.max(
        PanelState.pageSizes.main.height,
        PanelState.pageSizes.wallpaper.height
    ) + (theme ? theme.pillHeight : 40) + 20

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

    // Recalculate the left margin as the window width changes so the
    // panel stays centered throughout the resize animation.
    // The window remains centered at a stable size during page switches.
    margins.left: targetScreen
                  ? Math.round(targetScreen.width / 2 - windowWidth / 2)
                  : 0

    implicitWidth: windowWidth
    implicitHeight: windowHeight


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
// so nothing appears mid-resize. Page switching has a separate sequence:
// fade out, resize the window and shape together, then reveal the new page.
//-----------------------------------------------------------------------------------
    Item {
        anchors.fill: panelShape
        anchors.margins: 16
        opacity: panelShape.readyForContent && !pageSwitching ? 1 : 0

        Behavior on opacity {
            NumberAnimation {
                duration: 250
                easing.type: Easing.InOutCubic
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

            sourceComponent: root.displayedPage === "wallpaper"
                             ? wallpaperPage : mainPage

            opacity: 1

            Behavior on opacity {
                NumberAnimation {
                    duration: 250
                    easing.type: Easing.InOutCubic
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

    // Tracks the independent page-switch sequence.
    property bool pageSwitching: false

    // Fade out the old page before changing its dimensions.
    Timer {
        id: pageSwitchTimer

        interval: 260
        repeat: false

          onTriggered: {
              root.displayedPage = PanelState.currentPage
              panelShape.resizeForPage()
          }
    }

    Connections {
        target: PanelState

        function onCurrentPageChanged() {
            if (!PanelState.panelOpen || !panelShape.readyForContent)
                return

            root.pageSwitching = true
            pageLoader.opacity = 0
            pageSwitchTimer.restart()
        }
    }

    Connections {
        target: panelShape

        function onPageResizeFinished() {
            // Allow the new page to appear only after the shape has
            // reached its target dimensions and had a moment to settle.
            pageSettleTimer.restart()
        }
    }

    Timer {
        id: pageSettleTimer

        interval: 100
        repeat: false

        onTriggered: {
            root.pageSwitching = false
            pageLoader.opacity = 1
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
