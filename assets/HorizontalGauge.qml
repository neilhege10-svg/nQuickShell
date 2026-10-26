import QtQuick
import QtQuick.Layouts

ColumnLayout {
    id: root

    property string label: "Usage"
    property real value: 0
    property string detail: "--"
    property color accent: "#03befc"
    property var t
    property bool showDetail: true
    // Optional replacement for the default percentage label (e.g. "54°C" or "N/A").
    property string valueLabel: ""

    spacing: 5

    RowLayout {
        Layout.fillWidth: true
        spacing: 8

        Text {
            text: root.label
            color: root.t ? root.t.base.text : "#e6e6e6"
            font.family: root.t ? root.t.fontFamily : "JetBrainsMono Nerd Font"
            font.pixelSize: 10
            elide: Text.ElideRight
            Layout.fillWidth: true
        }

        Text {
            text: root.valueLabel !== "" ? root.valueLabel : Math.round(Math.max(0, Math.min(100, root.value))) + "%"
            color: root.t ? root.t.base.textInactive : "#6e6e6e"
            font.family: root.t ? root.t.fontFamily : "JetBrainsMono Nerd Font"
            font.pixelSize: 10
        }
    }

    Item {
        Layout.fillWidth: true
        Layout.preferredHeight: 5

        Rectangle {
            anchors.fill: parent
            radius: height / 2
            color: root.t ? root.t.base.border : "#454545"
        }

        Rectangle {
            width: parent.width * Math.max(0, Math.min(100, root.value)) / 100
            height: parent.height
            radius: height / 2
            color: root.accent

            Behavior on width {
                NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
            }
        }
    }

    Text {
        visible: root.showDetail && root.detail !== ""
        Layout.fillWidth: true
        text: root.detail
        color: root.t ? root.t.base.textInactive : "#6e6e6e"
        font.family: root.t ? root.t.fontFamily : "JetBrainsMono Nerd Font"
        font.pixelSize: 9
        elide: Text.ElideRight
    }
}
