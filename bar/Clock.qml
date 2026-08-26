import Qt5Compat.GraphicalEffects
import QtQuick

Item {

    id: root

// ── CORE PROPERTIES ──────────────────────────────────
    property var t
    property var now: new Date()

//-----------------------------------------------------------------------------------
// Tell the Bar's RowLayout exactly how much space this module needs
//-----------------------------------------------------------------------------------
    implicitWidth: timeLabel.implicitWidth + (t ? t.widgetPadding * 2 : 16)
    implicitHeight: t ? t.pillHeight : 32

//-----------------------------------------------------------------------------------
// this is pretty much the entire clock module... SImple ahh shit
//-----------------------------------------------------------------------------------
    Rectangle {
        id: pill

        anchors.fill: parent
        radius: t ? t.widgetRadius : 8
        color: "transparent"
        border.width: 0

        Timer {
            interval: 60000
            repeat: true
            running: true
            onTriggered: root.now = new Date()
        }

        Text {
            id: timeLabel

            anchors.centerIn: parent
            text: Qt.formatDateTime(root.now, "hh:mm")
            color: root.t ? root.t.base.text : "#cdd6f4"

            font {
                pixelSize: root.t ? root.t.fontSize : 13
                family: root.t ? root.t.fontFamily : ""
            }

        }

    }

}
