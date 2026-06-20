import "../../theme"
import QtQuick

Item {
    property var t

    Text {
        anchors.centerIn: parent
        text: "THEMES PAGE"
        color: t.base.text
    }
}
