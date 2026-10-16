// menu/main_block/StatsBlock.qml
import QtQuick

Rectangle {
    id: root
    property var t

    color: root.t ? root.t.base.surface : "#1f1f1f"
    radius: root.t ? root.t.widgetRadius : 10

    Text {
        anchors.centerIn: parent
        text: "System Stats Gauges Pending..."
        color: root.t ? root.t.base.textInactive : "#6e6e6e"
    }
}
