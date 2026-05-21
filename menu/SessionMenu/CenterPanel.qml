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
    WlrLayershell.namespace: "cpanel"
    WlrLayershell.exclusiveZone: -1
    implicitHeight: theme.barHeight + menuShape.menuHeight + 20
    color: "transparent"
    visible: PanelState.cPanelOpen || menuShape.openAmount > 0
focusable: PanelState.activePage === "wifi-password"
    onVisibleChanged: {
        if (!visible) {
            PanelState.activePage = "session"
            PanelState.pendingAction = ""
            PanelState.pendingCmd = ""
            PanelState.wifiTarget = null   // ← clear wifi target on close
        }
    }

    WlrLayershell.anchors {
        top: true
        left: true
        right: true
        bottom: false
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            if (!menuShape.contains(menuShape.mapFromItem(parent, mouseX, mouseY)))
                PanelState.cPanelOpen = false
        }
    }

    Theme { id: theme }

    Item {
        id: menuShape

        property int menuWidth: 900
        property int menuHeight: 200
        property real openAmount: PanelState.cPanelOpen ? 1 : 0

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: theme.barHeight
        width: menuWidth
        height: menuHeight

        Shape {
            id: shapeBg

            anchors.fill: parent
            layer.enabled: true
            layer.samples: 4

            ShapePath {
                fillColor: theme.holo.bgtransparent
                strokeColor: theme.holo.border
                strokeWidth: 2
                startX: 0
                startY: 0

                PathLine { x: shapeBg.width; y: 0 }
                PathLine {
                    x: shapeBg.width - 50 * menuShape.openAmount
                    y: 0 + (shapeBg.height - 80) * menuShape.openAmount
                }
                PathArc {
                    x: shapeBg.width - 54 * menuShape.openAmount
                    y: 0 + (shapeBg.height - 77) * menuShape.openAmount
                    radiusX: 15 * menuShape.openAmount
                    radiusY: 15 * menuShape.openAmount
                }
                PathLine {
                    x: 54 * menuShape.openAmount
                    y: 0 + (shapeBg.height - 77) * menuShape.openAmount
                }
                PathArc {
                    x: 50 * menuShape.openAmount
                    y: 0 + (shapeBg.height - 80) * menuShape.openAmount
                    radiusX: 15 * menuShape.openAmount
                    radiusY: 15 * menuShape.openAmount
                }
                PathLine { x: 0; y: 0 }
            }

            layer.effect: DropShadow {
                horizontalOffset: 0
                verticalOffset: 0
                radius: 20
                samples: 31
                color: theme.holo.shadow
            }
        }

        SequentialAnimation {
            id: flickerAnim

            NumberAnimation { target: contentArea; property: "opacity"; from: 0;   to: 1;   duration: 40 }
            NumberAnimation { target: contentArea; property: "opacity"; from: 1;   to: 0.2; duration: 50 }
            NumberAnimation { target: contentArea; property: "opacity"; from: 0.2; to: 0.8; duration: 30 }
            NumberAnimation { target: contentArea; property: "opacity"; from: 0.8; to: 0.4; duration: 40 }
            NumberAnimation { target: contentArea; property: "opacity"; from: 0.4; to: 1;   duration: 60 }
        }

        Connections {
            target: PanelState
            function onCPanelOpenChanged() {
                if (!PanelState.cPanelOpen) {
                    flickerAnim.stop()
                    contentArea.opacity = 0
                }
            }
        }

        Connections {
            target: menuShape
            function onOpenAmountChanged() {
                if (menuShape.openAmount > 0.6 && PanelState.cPanelOpen && !flickerAnim.running) {
                    contentArea.opacity = 0
                    flickerAnim.restart()
                }
            }
        }

        Item {
            id: contentArea

            anchors.horizontalCenter: parent.horizontalCenter
            y: 6
            width: menuShape.menuWidth
            height: menuShape.menuHeight

            // ── SESSION PAGE ─────────────────────────────────────────
            SessionControl {
                t: theme
                anchors.horizontalCenter: parent.horizontalCenter
                visible: PanelState.activePage === "session" && menuShape.openAmount > 0.9
                opacity: PanelState.activePage === "session" ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: 300 } }
            }

            // ── CONFIRM PAGE ─────────────────────────────────────────
            ConfirmControl {
                t: theme
                anchors.horizontalCenter: parent.horizontalCenter
                visible: PanelState.activePage === "confirm"
                opacity: PanelState.activePage === "confirm" ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: 300 } }
            }

            // ── WIFI PASSWORD PAGE ───────────────────────────────────
            WifiPasswordControl {
                t: theme
                anchors.horizontalCenter: parent.horizontalCenter
                y : 12
                visible: PanelState.activePage === "wifi-password"
                opacity: PanelState.activePage === "wifi-password" ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: 300 } }
            }
        }

        Behavior on openAmount {
            NumberAnimation { duration: 500; easing.type: Easing.OutCubic }
        }
    }
}
