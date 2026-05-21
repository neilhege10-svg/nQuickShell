import "../state"
import Qt5Compat.GraphicalEffects
import QtQuick

Item {
    id: root

    property var t
    property string icon: ""
    property bool activeState: false
    property bool showShadow: false

    signal clicked()

    implicitHeight: 28
    implicitWidth: 28
    layer.enabled: root.showShadow

    Rectangle {
        id: btn

        anchors.fill: parent
        radius: 16
        // Solid accent when active, slightly highlighted on hover, baseline surface when idle
        color: root.activeState ? root.t.base.accent : (mouseArea.containsMouse ? Qt.alpha(root.t.base.surface, 0.85) : root.t.base.surface)
        // ── CLICK ANIMATION SCHEMA ──
        // Instantly snaps down on press, smoothly pops back up on release
        scale: mouseArea.pressed ? 0.9 : 1

        Text {
            id: menuBtn

            anchors.centerIn: parent
            text: root.icon
            color: root.activeState ? root.t.textalt : root.t.text

            font {
                pixelSize: 16
                family: root.t.fontFamily
            }

        }

        Behavior on scale {
            NumberAnimation {
                duration: 100
                easing.type: Easing.OutQuad
            }

        }

        Behavior on color {
            ColorAnimation {
                duration: 200
            }

        }

    }

    MouseArea {
        id: mouseArea

        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
        onClicked: root.clicked()
    }

    layer.effect: DropShadow {
        horizontalOffset: 3
        verticalOffset: 2
        radius: 6
        samples: 17
        color: root.t.base.shadow
    }

}
