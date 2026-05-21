import "../../state"
import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import Quickshell.Io

ColumnLayout {
    id: root

    property var t

    // Extra spacing to give the confirmation page breathability and weight
    spacing: 16

    // "Shutdown?" label
    Text {
        Layout.alignment: Qt.AlignHCenter
        text: PanelState.pendingAction + "?"
        color: t.holo.text

        font {
            pixelSize: 30
            family: t.holoFont
            bold: true
        }

    }

    // Yes / No row
    RowLayout {
        Layout.alignment: Qt.AlignHCenter
        spacing: 40 // Widened slightly to balance out the layout footprint

        // ==================== YES BUTTON (DESTRUCTIVE / WARNING) ====================
        Rectangle {
            id: yesButtonRoot

            property int bracketSize: 10
            property int cutSize: 4
            property int thickness: 2
            property color bracketColor: yesMouse.containsMouse ? t.holo.warningActive : t.holo.warningText

            width: 130
            height: 60
            radius: 0 // Sharp sci-fi edges
            clip: true
            color: yesMouse.containsMouse ? t.holo.warningBgSel : t.holo.warningBg

            Process {
                id: confirmProcess
            }

            // Hidden background mask layer mapping cleanly to core shadow matrix
            Rectangle {
                id: yesShadowSource

                anchors.fill: parent
                radius: 0
                color: t.shadow
                visible: false
            }

            // --- ANGLED HUD BRACKETS (YES) ---
            Shape {
                anchors.left: parent.left
                anchors.top: parent.top
                width: yesButtonRoot.bracketSize
                height: yesButtonRoot.bracketSize
                layer.enabled: true
                layer.samples: 4

                ShapePath {
                    strokeColor: yesButtonRoot.bracketColor
                    strokeWidth: yesButtonRoot.thickness
                    fillColor: "transparent"
                    startX: yesButtonRoot.bracketSize
                    startY: 0

                    PathLine {
                        x: yesButtonRoot.cutSize
                        y: 0
                    }

                    PathLine {
                        x: 0
                        y: yesButtonRoot.cutSize
                    }

                    PathLine {
                        x: 0
                        y: yesButtonRoot.bracketSize
                    }

                }

            }

            Shape {
                anchors.right: parent.right
                anchors.top: parent.top
                width: yesButtonRoot.bracketSize
                height: yesButtonRoot.bracketSize
                layer.enabled: true
                layer.samples: 4

                ShapePath {
                    strokeColor: yesButtonRoot.bracketColor
                    strokeWidth: yesButtonRoot.thickness
                    fillColor: "transparent"
                    startX: 0
                    startY: 0

                    PathLine {
                        x: yesButtonRoot.bracketSize - yesButtonRoot.cutSize
                        y: 0
                    }

                    PathLine {
                        x: yesButtonRoot.bracketSize
                        y: yesButtonRoot.cutSize
                    }

                    PathLine {
                        x: yesButtonRoot.bracketSize
                        y: yesButtonRoot.bracketSize
                    }

                }

            }

            Shape {
                anchors.left: parent.left
                anchors.bottom: parent.bottom
                width: yesButtonRoot.bracketSize
                height: yesButtonRoot.bracketSize
                layer.enabled: true
                layer.samples: 4

                ShapePath {
                    strokeColor: yesButtonRoot.bracketColor
                    strokeWidth: yesButtonRoot.thickness
                    fillColor: "transparent"
                    startX: yesButtonRoot.bracketSize
                    startY: yesButtonRoot.bracketSize

                    PathLine {
                        x: yesButtonRoot.cutSize
                        y: yesButtonRoot.bracketSize
                    }

                    PathLine {
                        x: 0
                        y: yesButtonRoot.bracketSize - yesButtonRoot.cutSize
                    }

                    PathLine {
                        x: 0
                        y: 0
                    }

                }

            }

            Shape {
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                width: yesButtonRoot.bracketSize
                height: yesButtonRoot.bracketSize
                layer.enabled: true
                layer.samples: 4

                ShapePath {
                    strokeColor: yesButtonRoot.bracketColor
                    strokeWidth: yesButtonRoot.thickness
                    fillColor: "transparent"
                    startX: 0
                    startY: yesButtonRoot.bracketSize

                    PathLine {
                        x: yesButtonRoot.bracketSize - yesButtonRoot.cutSize
                        y: yesButtonRoot.bracketSize
                    }

                    PathLine {
                        x: yesButtonRoot.bracketSize
                        y: yesButtonRoot.bracketSize - yesButtonRoot.cutSize
                    }

                    PathLine {
                        x: yesButtonRoot.bracketSize
                        y: 0
                    }

                }

            }

            Text {
                anchors.centerIn: parent
                text: "Yes"
                color: yesMouse.containsMouse ? t.holo.warningActive : t.holo.warningText

                font {
                    pixelSize: 18
                    family: t.holoFont
                    bold: true
                }

                Behavior on color {
                    ColorAnimation {
                        duration: 150
                    }

                }

            }

            MouseArea {
                id: yesMouse

                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                onClicked: {
                    confirmProcess.command = ["bash", "-c", PanelState.pendingCmd];
                    confirmProcess.running = false;
                    confirmProcess.running = true;
                    PanelState.cPanelOpen = false;
                    PanelState.activePage = "session";
                    PanelState.pendingAction = "";
                    PanelState.pendingCmd = "";
                }
            }

            Behavior on bracketColor {
                ColorAnimation {
                    duration: 150
                    easing.type: Easing.OutQuad
                }

            }

            Behavior on color {
                ColorAnimation {
                    duration: 150
                }

            }

        }

        // ==================== NO BUTTON (SAFE ESCAPE) ====================
        Rectangle {
            id: noButtonRoot

            property int bracketSize: 10
            property int cutSize: 4
            property int thickness: 2
            property color bracketColor: noMouse.containsMouse ? t.holo.textActive : t.holo.border

            width: 130
            height: 60
            radius: 0 // Sharp sci-fi edges
            clip: true
            color: noMouse.containsMouse ? t.holo.bgsel : t.holo.holobg

            Rectangle {
                id: noShadowSource

                anchors.fill: parent
                radius: 12
                color: t.shadow
                visible: false
            }

            // --- ANGLED HUD BRACKETS (NO) ---
            Shape {
                anchors.left: parent.left
                anchors.top: parent.top
                width: noButtonRoot.bracketSize
                height: noButtonRoot.bracketSize
                layer.enabled: true
                layer.samples: 4

                ShapePath {
                    strokeColor: noButtonRoot.bracketColor
                    strokeWidth: noButtonRoot.thickness
                    fillColor: "transparent"
                    startX: noButtonRoot.bracketSize
                    startY: 0

                    PathLine {
                        x: noButtonRoot.cutSize
                        y: 0
                    }

                    PathLine {
                        x: 0
                        y: noButtonRoot.cutSize
                    }

                    PathLine {
                        x: 0
                        y: noButtonRoot.bracketSize
                    }

                }

            }

            Shape {
                anchors.right: parent.right
                anchors.top: parent.top
                width: noButtonRoot.bracketSize
                height: noButtonRoot.bracketSize
                layer.enabled: true
                layer.samples: 4

                ShapePath {
                    strokeColor: noButtonRoot.bracketColor
                    strokeWidth: noButtonRoot.thickness
                    fillColor: "transparent"
                    startX: 0
                    startY: 0

                    PathLine {
                        x: noButtonRoot.bracketSize - noButtonRoot.cutSize
                        y: 0
                    }

                    PathLine {
                        x: noButtonRoot.bracketSize
                        y: noButtonRoot.cutSize
                    }

                    PathLine {
                        x: noButtonRoot.bracketSize
                        y: noButtonRoot.bracketSize
                    }

                }

            }

            Shape {
                anchors.left: parent.left
                anchors.bottom: parent.bottom
                width: noButtonRoot.bracketSize
                height: noButtonRoot.bracketSize
                layer.enabled: true
                layer.samples: 4

                ShapePath {
                    strokeColor: noButtonRoot.bracketColor
                    strokeWidth: noButtonRoot.thickness
                    fillColor: "transparent"
                    startX: noButtonRoot.bracketSize
                    startY: noButtonRoot.bracketSize

                    PathLine {
                        x: noButtonRoot.cutSize
                        y: noButtonRoot.bracketSize
                    }

                    PathLine {
                        x: 0
                        y: noButtonRoot.bracketSize - noButtonRoot.cutSize
                    }

                    PathLine {
                        x: 0
                        y: 0
                    }

                }

            }

            Shape {
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                width: noButtonRoot.bracketSize
                height: noButtonRoot.bracketSize
                layer.enabled: true
                layer.samples: 4

                ShapePath {
                    strokeColor: noButtonRoot.bracketColor
                    strokeWidth: noButtonRoot.thickness
                    fillColor: "transparent"
                    startX: 0
                    startY: noButtonRoot.bracketSize

                    PathLine {
                        x: noButtonRoot.bracketSize - noButtonRoot.cutSize
                        y: noButtonRoot.bracketSize
                    }

                    PathLine {
                        x: noButtonRoot.bracketSize
                        y: noButtonRoot.bracketSize - noButtonRoot.cutSize
                    }

                    PathLine {
                        x: noButtonRoot.bracketSize
                        y: 0
                    }

                }

            }

            Text {
                anchors.centerIn: parent
                text: "No"
                color: noMouse.containsMouse ? t.holo.textActive : t.holo.text

                font {
                    pixelSize: 18
                    family: t.holoFont
                }

                Behavior on color {
                    ColorAnimation {
                        duration: 150
                    }

                }

            }

            MouseArea {
                id: noMouse

                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                onClicked: {
                    PanelState.activePage = "session";
                    PanelState.pendingAction = "";
                    PanelState.pendingCmd = "";
                }
            }

            Behavior on bracketColor {
                ColorAnimation {
                    duration: 150
                    easing.type: Easing.OutQuad
                }

            }

            Behavior on color {
                ColorAnimation {
                    duration: 150
                }

            }

        }

    }

}
