import QtQuick
import Qt5Compat.GraphicalEffects

Rectangle {
    id: root

    property var t
// These 2 properties are what allows the Icon and Label to be customizeable
    property string iconSource: ""
    property string label: ""

    signal clicked()
// Color properties of each component in the ActionTile
    readonly property color tileColor:
        t ? t.holo.holobg : "#1a3e78d6"
    readonly property color tileHover:
        t ? t.holo.neonActive : "#a603cffc"
    readonly property color tileBorder:
        t ? t.holo.neon : "#5903cffc"
    readonly property color iconColor:
        t ? t.holo.text : "#03cffc"
    readonly property color labelColor:
        t ? t.base.text : "#e6e6e6"
    readonly property string uiFont:
        t ? t.fontFamily : "JetBrainsMono Nerd Font"

    radius: 9

    // Subtle physical feedback shared by SessionBlock and other ActionTile users.
    y: mouseArea.pressed ? 1 : 0
    scale: mouseArea.pressed ? 0.975 : 1.0

    Behavior on y {
        NumberAnimation { duration: 70; easing.type: Easing.OutQuad }
    }
    Behavior on scale {
        NumberAnimation { duration: 70; easing.type: Easing.OutQuad }
    }

// Behaviour for when the mouse hovers over the button
    color: mouseArea.pressed ? (t ? t.base.surface : "#151922") : (mouseArea.containsMouse ? tileHover : tileColor)

    border.color: mouseArea.containsMouse
        ? (t ? t.base.accent : "#03befc")
        : tileBorder
    border.width: 1

    Behavior on color {
        ColorAnimation {
            duration: 140
        }
    }
// Column for text and label, this stacks the Icon on top of the Text
    Column {
        anchors.fill: parent
        anchors.margins: 5
        spacing: 2

        Item {
            width: parent.width
            height: Math.max(0, parent.height - labelText.implicitHeight - 2)

            Image {
                id: iconImage

                anchors.centerIn: parent

                width: 24
                height: 24
                source: root.iconSource
                sourceSize.width: 24
                sourceSize.height: 24

                fillMode: Image.PreserveAspectFit
                smooth: true
                mipmap: true

                layer.enabled: true
                layer.effect: ColorOverlay {
                    color: root.iconColor
                }
            }
        }

        Text {
            id: labelText

            width: parent.width
            text: root.label

            color: root.labelColor
            font.family: root.uiFont
            font.pixelSize: 10

            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
        }
    }

    MouseArea {
        id: mouseArea

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onClicked: root.clicked()
    }
}
