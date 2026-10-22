
import QtQuick

Rectangle {
    id: root

    property var t
    property string iconText: ""
    property string label: ""

    signal clicked()

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

    color: mouseArea.containsMouse ? tileHover : tileColor

    border.color: mouseArea.containsMouse
        ? (t ? t.base.accent : "#03befc")
        : tileBorder
    border.width: 1

    Behavior on color {
        ColorAnimation {
            duration: 140
        }
    }

    Column {
        anchors.fill: parent
        anchors.margins: 5
        spacing: 2

        Text {
            width: parent.width
            height: Math.max(0, parent.height - labelText.implicitHeight - 2)

            text: root.iconText
            color: root.iconColor
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 23

            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
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

