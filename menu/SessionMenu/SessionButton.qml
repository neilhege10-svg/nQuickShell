import "../../state"
import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import Quickshell.Io

Rectangle {
    id: buttonRoot

    property var t
    property string icon: ""
    property string label: ""
    property string cmd: ""
    // --- HUD Bracket Properties ---
    property int bracketSize: 14
    // How far the bracket extends along the edge
    property int cutSize: 6
    // How large the chamfer/angle cut is
    property int thickness: 2
    // Line thickness
    property color bracketColor: btnMouse.containsMouse ? t.holo.textActive : t.holo.border

    implicitWidth: 110
    implicitHeight: 110
    radius: 12
    color: btnMouse.containsMouse ? t.holo.bgsel : t.holo.holobg
    clip: true

    Process {
        id: btnProcess
    }

    // --- ANGLED HUD BRACKETS ---
    // Top-Left Corner
    Shape {
        anchors.left: parent.left
        anchors.top: parent.top
        width: buttonRoot.bracketSize
        height: buttonRoot.bracketSize
        layer.enabled: true
        layer.samples: 4 // Keeps the diagonal line perfectly crisp

        ShapePath {
            strokeColor: buttonRoot.bracketColor
            strokeWidth: buttonRoot.thickness
            fillColor: "transparent"
            startX: buttonRoot.bracketSize
            startY: 0

            PathLine {
                x: buttonRoot.cutSize
                y: 0
            }

            PathLine {
                x: 0
                y: buttonRoot.cutSize
            }

            PathLine {
                x: 0
                y: buttonRoot.bracketSize
            }

        }

        layer.effect: DropShadow {
            horizontalOffset: 0
            verticalOffset: 0
            radius: 20
            samples: 31
            color: t.holo.shadow
        }

    }

    // Top-Right Corner
    Shape {
        anchors.right: parent.right
        anchors.top: parent.top
        width: buttonRoot.bracketSize
        height: buttonRoot.bracketSize
        layer.enabled: true
        layer.samples: 4

        ShapePath {
            strokeColor: buttonRoot.bracketColor
            strokeWidth: buttonRoot.thickness
            fillColor: "transparent"
            startX: 0
            startY: 0

            PathLine {
                x: buttonRoot.bracketSize - buttonRoot.cutSize
                y: 0
            }

            PathLine {
                x: buttonRoot.bracketSize
                y: buttonRoot.cutSize
            }

            PathLine {
                x: buttonRoot.bracketSize
                y: buttonRoot.bracketSize
            }

        }

    }

    // Bottom-Left Corner
    Shape {
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        width: buttonRoot.bracketSize
        height: buttonRoot.bracketSize
        layer.enabled: true
        layer.samples: 4

        ShapePath {
            strokeColor: buttonRoot.bracketColor
            strokeWidth: buttonRoot.thickness
            fillColor: "transparent"
            startX: buttonRoot.bracketSize
            startY: buttonRoot.bracketSize

            PathLine {
                x: buttonRoot.cutSize
                y: buttonRoot.bracketSize
            }

            PathLine {
                x: 0
                y: buttonRoot.bracketSize - buttonRoot.cutSize
            }

            PathLine {
                x: 0
                y: 0
            }

        }

    }

    // Bottom-Right Corner
    Shape {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        width: buttonRoot.bracketSize
        height: buttonRoot.bracketSize
        layer.enabled: true
        layer.samples: 4

        ShapePath {
            strokeColor: buttonRoot.bracketColor
            strokeWidth: buttonRoot.thickness
            fillColor: "transparent"
            startX: 0
            startY: buttonRoot.bracketSize

            PathLine {
                x: buttonRoot.bracketSize - buttonRoot.cutSize
                y: buttonRoot.bracketSize
            }

            PathLine {
                x: buttonRoot.bracketSize
                y: buttonRoot.bracketSize - buttonRoot.cutSize
            }

            PathLine {
                x: buttonRoot.bracketSize
                y: 0
            }

        }

    }

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 8

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: icon
            color: btnMouse.containsMouse ? t.holo.textActive : t.holo.text

            font {
                pixelSize: 40
                family: t.fontFamily
            }

        }

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: label
            color: btnMouse.containsMouse ? t.holo.textActive : t.holo.text

            font {
                pixelSize: 15
                family: t.holoFont
            }

        }

    }

    MouseArea {
        id: btnMouse

        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
        onClicked: {
            PanelState.pendingAction = label;
            PanelState.pendingCmd = cmd;
            PanelState.activePage = "confirm";
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
            duration: 500
        }

    }

}
