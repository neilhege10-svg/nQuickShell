import "../../assets"
import "../../assets/animations"
import "../../state"
import "../../theme"
import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: root

    required property var targetScreen

    WlrLayershell.screen: targetScreen
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "rpanel"
    WlrLayershell.exclusiveZone: -1
    implicitWidth: 450
    // FIX 1: Add a 40px padding buffer to the window canvas height (20px top, 20px bottom)
    // This provides structural canvas pixels so the shadows can bloom without slicing
    implicitHeight: 840
    color: "transparent"
    visible: PanelState.rPanelOpen || menuShape.openAmount > 0

    WlrLayershell.anchors {
        right: true
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            if (!menuShape.contains(menuShape.mapFromItem(parent, mouseX, mouseY)))
                PanelState.rPanelOpen = false;

        }
    }

    Theme {
        id: theme
    }

    Item {
        id: menuShape

        property int menuWidth: 320
        property int menuHeight: 800
        property real openAmount: PanelState.rPanelOpen ? 1 : 0

        // FIX 2: Vertically center the menu inside the expanded window space,
        // which leaves a safe 20px margin at the top and bottom of the display
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: 0 - (menuWidth * (1 - openAmount))
        width: menuWidth
        height: menuHeight

        // ── HOLOGRAPHIC BACKGROUND TAB OUTLINE ──
        Shape {
            id: notchTab

            layer.enabled: true
            layer.samples: 6
            anchors.fill: parent

            ShapePath {
                fillColor: theme.holo.bgtransparent
                strokeColor: theme.holo.border
                strokeWidth: 2
                joinStyle: ShapePath.MiterJoin
                // Pushed 30px down from the top to give the upper shadow breathing room
                startX: 45
                startY: 30

                // Top Line
                PathLine {
                    x: notchTab.width
                    y: 30
                }

                // Straight down the right side, but stopping 25px short of the bottom
                PathLine {
                    x: notchTab.width
                    y: notchTab.height - 25
                }

                // Bottom Line (lifted up to y: height - 25)
                PathLine {
                    x: 45
                    y: notchTab.height - 25
                }

                // Left Bottom Corner Curves (All shifted up by 20-25 pixels)
                PathArc {
                    x: 35
                    y: notchTab.height - 30
                    radiusX: 33
                    radiusY: 30
                }

                PathLine {
                    x: 15
                    y: notchTab.height - 50
                }

                PathArc {
                    x: 10
                    y: notchTab.height - 60
                    radiusX: 33
                    radiusY: 30
                }

                // Straight line tracking up the left edge
                PathLine {
                    x: 10
                    y: 65
                }

                // Left Top Corner Curves (All pushed down by 20-25 pixels)
                PathArc {
                    x: 15
                    y: 55
                    radiusX: 33
                    radiusY: 30
                }

                PathLine {
                    x: 40
                    y: 35
                }

                PathArc {
                    x: 45
                    y: 30
                    radiusX: 33
                    radiusY: 30
                }

            }

            layer.effect: DropShadow {
                horizontalOffset: 0
                verticalOffset: 0
                radius: 10
                samples: 17
                color: theme.holo.shadow
            }

        }

        // ── SOLID FOREGROUND MAIN PANEL ──
        Shape {
            id: mainPanel

            layer.enabled: true
            layer.samples: 6
            anchors.fill: parent

            ShapePath {
                fillColor: theme.base.bg
                strokeColor: theme.base.border
                strokeWidth: 1
                // FIX 5: Mirror pixel alignment logic across components
                joinStyle: ShapePath.MiterJoin
                // FIX 6: Uniform 2px safety padding inside the component boundaries
                startX: 34
                startY: 2

                PathLine {
                    x: mainPanel.width
                    y: 2
                }

                PathLine {
                    x: mainPanel.width
                    y: mainPanel.height - 2
                }

                PathLine {
                    x: 34
                    y: mainPanel.height - 2
                }

                PathArc {
                    x: 27
                    y: mainPanel.height - 5
                    radiusX: 33
                    radiusY: 30
                }

                PathLine {
                    x: 3
                    y: mainPanel.height - 29
                }

                PathArc {
                    x: 0
                    y: mainPanel.height - 36
                    radiusX: 33
                    radiusY: 30
                }

                PathLine {
                    x: 0
                    y: mainPanel.height - 293
                }

                PathArc {
                    x: 4
                    y: mainPanel.height - 299
                    radiusX: 33
                    radiusY: 30
                }

                PathLine {
                    x: 46
                    y: mainPanel.height - 320
                }

                PathArc {
                    x: 50
                    y: mainPanel.height - 326
                    radiusX: 90
                    radiusY: 90
                }

                PathLine {
                    x: 50
                    y: 326
                }

                PathArc {
                    x: 46
                    y: 320
                    radiusX: 90
                    radiusY: 90
                }

                PathLine {
                    x: 4
                    y: 299
                }

                PathArc {
                    x: 0
                    y: 293
                    radiusX: 33
                    radiusY: 30
                }

                PathLine {
                    x: 0
                    y: 36
                }

                PathArc {
                    x: 3
                    y: 29
                    radiusX: 33
                    radiusY: 30
                }

                PathLine {
                    x: 27
                    y: 5
                }

                PathArc {
                    x: 34
                    y: 2
                    radiusX: 33
                    radiusY: 30
                }

            }

            layer.effect: DropShadow {
                horizontalOffset: -4
                verticalOffset: 3
                radius: 8
                samples: 17
                color: theme.base.shadow
            }

        }

        // ── TARGETED FLICKER ANIMATIONS ──────────────────────────────────
        FlickerAnimation {
            id: audioBootGlitch

            targetItem: audioGlitchGroup
        }

        FlickerAnimation {
            id: networkBootGlitch

            targetItem: networkGlitchGroup
        }

        // ── STATE ORCHESTRATION ──────────────────────────────────────────
        Connections {
            function onRPanelPageChanged() {
                if (!PanelState.rPanelOpen)
                    return ;

                if (PanelState.rPanelPage === "audio") {
                    networkBootGlitch.stop();
                    audioGlitchGroup.opacity = 0;
                    audioBootGlitch.restart();
                } else if (PanelState.rPanelPage === "network") {
                    audioBootGlitch.stop();
                    networkGlitchGroup.opacity = 0;
                    networkBootGlitch.restart();
                }
            }

            function onRPanelOpenChanged() {
                if (!PanelState.rPanelOpen) {
                    audioBootGlitch.stop();
                    networkBootGlitch.stop();
                    audioGlitchGroup.opacity = 0;
                    networkGlitchGroup.opacity = 0;
                }
            }

            target: PanelState
        }

        Connections {
            function onOpenAmountChanged() {
                if (menuShape.openAmount > 0.6 && PanelState.rPanelOpen) {
                    if (PanelState.rPanelPage === "audio" && !audioBootGlitch.running) {
                        audioGlitchGroup.opacity = 0;
                        audioBootGlitch.restart();
                    } else if (PanelState.rPanelPage === "network" && !networkBootGlitch.running) {
                        networkGlitchGroup.opacity = 0;
                        networkBootGlitch.restart();
                    }
                }
            }

            target: menuShape
        }

        // ── AUDIO PAGE ───────────────────────────────────────────────────
        Item {
            id: audioPage

            anchors.fill: parent
            visible: PanelState.rPanelPage === "audio"

            Item {
                id: audioGlitchGroup

                anchors.fill: parent

                AudioOut {
                    id: audioOut

                    t: theme

                    anchors {
                        top: parent.top
                        bottom: parent.bottom
                        left: parent.left
                        right: parent.right
                        leftMargin: 10
                        rightMargin: 10
                        topMargin: 10
                        bottomMargin: 495
                    }

                }

                AudioIn {
                    id: audioIn

                    t: theme

                    anchors {
                        top: parent.top
                        bottom: parent.bottom
                        left: parent.left
                        right: parent.right
                        leftMargin: 10
                        rightMargin: 10
                        topMargin: 495
                        bottomMargin: 10
                    }

                }

            }

            VolumeControl {
                id: volumeControl

                t: theme
                opacity: (PanelState.rPanelOpen && PanelState.rPanelPage === "audio") ? 1 : 0

                anchors {
                    top: parent.top
                    bottom: parent.bottom
                    left: parent.left
                    right: parent.right
                    leftMargin: 60
                    rightMargin: 10
                    topMargin: 320
                    bottomMargin: 320
                }

                Behavior on opacity {
                    NumberAnimation {
                        duration: 350
                        easing.type: Easing.OutQuad
                    }

                }

            }

        }

        // ── NETWORK PAGE ─────────────────────────────────────────────────
        Item {
            id: networkPage

            anchors.fill: parent
            visible: PanelState.rPanelPage === "network"

            Item {
                id: networkGlitchGroup

                anchors.fill: parent

                NetworkSection {
                    id: networkSection

                    t: theme

                    anchors {
                        top: parent.top
                        bottom: parent.bottom
                        left: parent.left
                        right: parent.right
                        leftMargin: 10
                        rightMargin: 10
                        topMargin: 10
                        bottomMargin: 495
                    }

                }

                BluetoothSection {
                    id: bluetoothSection

                    t: theme

                    anchors {
                        top: parent.top
                        bottom: parent.bottom
                        left: parent.left
                        right: parent.right
                        leftMargin: 10
                        rightMargin: 10
                        topMargin: 495
                        bottomMargin: 10
                    }

                }

            }

            NetworkControl {
                id: networkControl

                t: theme
                opacity: (PanelState.rPanelOpen && PanelState.rPanelPage === "network") ? 1 : 0

                anchors {
                    top: parent.top
                    bottom: parent.bottom
                    left: parent.left
                    right: parent.right
                    leftMargin: 60
                    rightMargin: 10
                    topMargin: 320
                    bottomMargin: 320
                }

                Behavior on opacity {
                    NumberAnimation {
                        duration: 500
                        easing.type: Easing.OutQuad
                    }

                }

            }

        }

        Item {
            id: notifPage

            anchors.fill: parent
            visible: PanelState.rPanelPage === "notif"

            NotifControl {
                t: theme

                anchors {
                    top: parent.top
                    bottom: parent.bottom
                    left: parent.left
                    right: parent.right
                    leftMargin: 60
                    rightMargin: 10
                    topMargin: 320
                    bottomMargin: 320
                }

            }

        }

        // ── SIDE ACCENT ACTION BUTTONS ───────────────────────────────────
        ColumnLayout {
            spacing: 10

            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                topMargin: 330
                leftMargin: 15
                rightMargin: 12
            }

            BtnRound {
                t: theme
                icon: ""
                showShadow: true
                onClicked: PanelState.rPanelOpen = false
            }

            BtnRound {
                t: theme
                icon: "󰕾"
                showShadow: true
                activeState: PanelState.rPanelOpen && PanelState.rPanelPage === "audio"
                onClicked: {
                    PanelState.rPanelPage = "audio";
                    PanelState.rPanelOpen = true;
                }
            }

            BtnRound {
                t: theme
                icon: "󰖩"
                showShadow: true
                activeState: PanelState.rPanelOpen && PanelState.rPanelPage === "network"
                onClicked: {
                    PanelState.rPanelPage = "network";
                    PanelState.rPanelOpen = true;
                }
            }

            BtnRound {
                t: theme
                icon: "󰂚"
                showShadow: true
                activeState: PanelState.rPanelOpen && PanelState.rPanelPage === "notif"
                onClicked: {
                    PanelState.rPanelPage = "notif";
                    PanelState.rPanelOpen = true;
                }
            }

        }

        Behavior on openAmount {
            NumberAnimation {
                duration: 400
                easing.type: Easing.OutCubic
            }

        }

    }

}
