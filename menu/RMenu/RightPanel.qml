import "../../assets"
import "../../state"
import "../../theme"
import "../../assets/animations"
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
    implicitHeight: 800
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

    Theme { id: theme }

    Item {
        id: menuShape

        property int menuWidth: 320
        property int menuHeight: 800
        property real openAmount: PanelState.rPanelOpen ? 1 : 0

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
                startX: 45; startY: 5
                PathLine { x: notchTab.width; y: 5 }
                PathLine { x: notchTab.width; y: notchTab.height }
                PathLine { x: 45; y: notchTab.height - 5 }
                PathArc { x: 35; y: notchTab.height - 10; radiusX: 33; radiusY: 30 }
                PathLine { x: 15; y: notchTab.height - 30 }
                PathArc { x: 10; y: notchTab.height - 40; radiusX: 33; radiusY: 30 }
                PathLine { x: 10; y: 40 }
                PathArc { x: 15; y: 30; radiusX: 33; radiusY: 30 }
                PathLine { x: 40; y: 10 }
                PathArc { x: 45; y: 5; radiusX: 33; radiusY: 30 }
            }
            layer.effect: DropShadow {
                horizontalOffset: 0; verticalOffset: 0; radius: 10; samples: 17
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
                strokeWidth: 0
                startX: 34; startY: 0
                PathLine { x: mainPanel.width; y: 0 }
                PathLine { x: mainPanel.width; y: mainPanel.height }
                PathLine { x: 34; y: mainPanel.height }
                PathArc { x: 27; y: mainPanel.height - 3; radiusX: 33; radiusY: 30 }
                PathLine { x: 3; y: mainPanel.height - 27 }
                PathArc { x: 0; y: mainPanel.height - 34; radiusX: 33; radiusY: 30 }
                PathLine { x: 0; y: mainPanel.height - 291 }
                PathArc { x: 4; y: mainPanel.height - 297; radiusX: 33; radiusY: 30 }
                PathLine { x: 46; y: mainPanel.height - 318 }
                PathArc { x: 50; y: mainPanel.height - 324; radiusX: -33; radiusY: -30 }
                PathLine { x: 50; y: 324 }
                PathArc { x: 46; y: 318; radiusX: -33; radiusY: -30 }
                PathLine { x: 4; y: 297 }
                PathArc { x: 0; y: 291; radiusX: 33; radiusY: 30 }
                PathLine { x: 0; y: 34 }
                PathArc { x: 3; y: 27; radiusX: 33; radiusY: 30 }
                PathLine { x: 27; y: 3 }
                PathArc { x: 34; y: 0; radiusX: 33; radiusY: 30 }
            }
            layer.effect: DropShadow {
                horizontalOffset: -4; verticalOffset: 3; radius: 8; samples: 17
                color: theme.base.shadow
            }
        }

        // ── TARGETED FLICKER ANIMATIONS ──────────────────────────────────
        // Now targeting isolated layout groups instead of the whole page
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
            target: PanelState

            function onRPanelPageChanged() {
                if (!PanelState.rPanelOpen) return;

                if (PanelState.rPanelPage === "audio") {
                    networkBootGlitch.stop()
                    audioGlitchGroup.opacity = 0
                    audioBootGlitch.restart()
                } else if (PanelState.rPanelPage === "network") {
                    audioBootGlitch.stop()
                    networkGlitchGroup.opacity = 0
                    networkBootGlitch.restart()
                }
            }

            function onRPanelOpenChanged() {
                if (!PanelState.rPanelOpen) {
                    audioBootGlitch.stop()
                    networkBootGlitch.stop()
                    audioGlitchGroup.opacity = 0
                    networkGlitchGroup.opacity = 0
                }
            }
        }

        Connections {
            target: menuShape
            function onOpenAmountChanged() {
                if (menuShape.openAmount > 0.6 && PanelState.rPanelOpen) {
                    if (PanelState.rPanelPage === "audio" && !audioBootGlitch.running) {
                        audioGlitchGroup.opacity = 0
                        audioBootGlitch.restart()
                    } else if (PanelState.rPanelPage === "network" && !networkBootGlitch.running) {
                        networkGlitchGroup.opacity = 0
                        networkBootGlitch.restart()
                    }
                }
            }
        }

        // ── AUDIO PAGE ───────────────────────────────────────────────────
        Item {
            id: audioPage
            anchors.fill: parent
            visible: PanelState.rPanelPage === "audio"

            // GLITCH GROUP: Audio lists glitch in together
            Item {
                id: audioGlitchGroup
                anchors.fill: parent

                AudioOut {
                    id: audioOut
                    t: theme
                    anchors {
                        top: parent.top; bottom: parent.bottom; left: parent.left; right: parent.right
                        leftMargin: 10; rightMargin: 10; topMargin: 10; bottomMargin: 495
                    }
                }

                AudioIn {
                    id: audioIn
                    t: theme
                    anchors {
                        top: parent.top; bottom: parent.bottom; left: parent.left; right: parent.right
                        leftMargin: 10; rightMargin: 10; topMargin: 495; bottomMargin: 10
                    }
                }
            }

            // CLEAN SMOOTH FADE: Sits outside the glitch container
            VolumeControl {
                id: volumeControl
                t: theme
                
                // Triggers automatically whenever the panel opens or switches to this page
                opacity: (PanelState.rPanelOpen && PanelState.rPanelPage === "audio") ? 1 : 0
                
                Behavior on opacity {
                    NumberAnimation {
                        duration: 350
                        easing.type: Easing.OutQuad
                    }
                }

                anchors {
                    top: parent.top; bottom: parent.bottom; left: parent.left; right: parent.right
                    leftMargin: 60; rightMargin: 10; topMargin: 320; bottomMargin: 320
                }
            }
        }

        // ── NETWORK PAGE ─────────────────────────────────────────────────
        Item {
            id: networkPage
            anchors.fill: parent
            visible: PanelState.rPanelPage === "network"

            // GLITCH GROUP: Network lists glitch in together
            Item {
                id: networkGlitchGroup
                anchors.fill: parent

                NetworkSection {
                    id: networkSection
                    t: theme
                    anchors {
                        top: parent.top; bottom: parent.bottom; left: parent.left; right: parent.right
                        leftMargin: 10; rightMargin: 10; topMargin: 10; bottomMargin: 495
                    }
                }

                BluetoothSection {
                    id: bluetoothSection
                    t: theme
                    anchors {
                        top: parent.top; bottom: parent.bottom; left: parent.left; right: parent.right
                        leftMargin: 10; rightMargin: 10; topMargin: 495; bottomMargin: 10
                    }
                }
            }

            // CLEAN SMOOTH FADE: Sits outside the glitch container
            NetworkControl {
                id: networkControl
                t: theme
                
                // Triggers automatically whenever the panel opens or switches to this page
                opacity: (PanelState.rPanelOpen && PanelState.rPanelPage === "network") ? 1 : 0
                
                Behavior on opacity {
                    NumberAnimation {
                        duration: 500
                        easing.type: Easing.OutQuad
                    }
                }

                anchors {
                    top: parent.top; bottom: parent.bottom; left: parent.left; right: parent.right
                    leftMargin: 60; rightMargin: 10; topMargin: 320; bottomMargin: 320
                }
            }
        }

        // ── SIDE ACCENT ACTION BUTTONS ───────────────────────────────────
        ColumnLayout {
            spacing: 10
            anchors {
                top: parent.top; left: parent.left; right: parent.right
                topMargin: 330; leftMargin: 15; rightMargin: 12
            }

            BtnRound {
                t: theme; icon: ""; showShadow: true
                onClicked: PanelState.rPanelOpen = false
            }

            BtnRound {
                t: theme; icon: "󰕾"; showShadow: true
                activeState: PanelState.rPanelOpen && PanelState.rPanelPage === "audio"
                onClicked: {
                    PanelState.rPanelPage = "audio";
                    PanelState.rPanelOpen = true;
                }
            }

            BtnRound {
                t: theme; icon: "󰖩"; showShadow: true
                activeState: PanelState.rPanelOpen && PanelState.rPanelPage === "network"
                onClicked: {
                    PanelState.rPanelPage = "network";
                    PanelState.rPanelOpen = true;
                }
            }

            BtnRound {
                t: theme; icon: "󰂚"; showShadow: true
              
            }
        }

        Behavior on openAmount {
            NumberAnimation { duration: 400; easing.type: Easing.OutCubic }
        }
    }
}
