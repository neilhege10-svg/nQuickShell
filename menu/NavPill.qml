// NavPill.qml
import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root

    property var t

    // Match theme button height or fall back gracefully
    height: root.t ? root.t.btnHeight : 30
    radius: root.t ? root.t.widgetRadius : 12

    // Use surface background color dynamically
    color: root.t ? root.t.base.surface : "#1f1f1f"
    border.width: 0

    // Inner interactive area filling the entire pill container
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: PanelState.currentPage = "wallpaper"
    }
}
