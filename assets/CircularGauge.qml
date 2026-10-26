import QtQuick
import QtQuick.Layouts

Item {
    id: root

    property string label: "CPU"
    property real value: 0
    property string detail: "--"
    property color accent: "#03befc"
    property var t
    property int gaugeSize: 104

    implicitWidth: gaugeSize
    implicitHeight: gaugeSize + 24

    ColumnLayout {
        anchors.fill: parent
        spacing: 4

        Item {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: Math.min(root.gaugeSize, root.width)
            Layout.preferredHeight: Layout.preferredWidth

            Canvas {
                id: ring
                anchors.fill: parent
                antialiasing: true
                onWidthChanged: requestPaint()
                onHeightChanged: requestPaint()
                onPaint: {
                    var ctx = getContext("2d")
                    ctx.reset()
                    var line = Math.max(5, width * 0.075)
                    var r = Math.min(width, height) / 2 - line
                    var cx = width / 2
                    var cy = height / 2
                    var start = -Math.PI / 2
                    var end = start + (Math.PI * 2 * Math.max(0, Math.min(100, root.value)) / 100)

                    ctx.beginPath()
                    ctx.arc(cx, cy, r, 0, Math.PI * 2)
                    ctx.strokeStyle = root.t ? root.t.base.border : "#454545"
                    ctx.lineWidth = line
                    ctx.stroke()

                    if (root.value > 0) {
                        ctx.beginPath()
                        ctx.arc(cx, cy, r, start, end)
                        ctx.strokeStyle = root.accent
                        ctx.lineWidth = line
                        ctx.lineCap = "round"
                        ctx.stroke()
                    }
                }
            }

            Column {
                anchors.centerIn: parent
                spacing: 1
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: Math.round(root.value) + "%"
                    color: root.t ? root.t.base.text : "#e6e6e6"
                    font.family: root.t ? root.t.fontFamily : "JetBrainsMono Nerd Font"
                    font.pixelSize: Math.max(15, Math.min(23, root.gaugeSize * 0.21))
                    font.bold: true
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: root.label
                    color: root.t ? root.t.base.textInactive : "#6e6e6e"
                    font.family: root.t ? root.t.fontFamily : "JetBrainsMono Nerd Font"
                    font.pixelSize: 9
                }
            }
        }

        Text {
            Layout.fillWidth: true
            text: root.detail
            color: root.t ? root.t.base.textInactive : "#6e6e6e"
            font.family: root.t ? root.t.fontFamily : "JetBrainsMono Nerd Font"
            font.pixelSize: 10
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
        }
    }

    onValueChanged: ring.requestPaint()
    onAccentChanged: ring.requestPaint()
    onTChanged: ring.requestPaint()
}
