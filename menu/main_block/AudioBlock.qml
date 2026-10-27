// menu/main_block/AudioBlock.qml
// EVO-inspired single-knob audio control surface.
import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import "../../services"

Rectangle {
    id: root

    property var t
    property string selectedChannel: "audio"
    readonly property real activeVolume: selectedChannel === "audio"
        ? AudioService.outputVolume : AudioService.inputVolume
    readonly property bool activeMuted: selectedChannel === "audio"
        ? AudioService.outputMuted : AudioService.inputMuted
    readonly property color textColor: root.t ? root.t.base.text : "#e6e6e6"
    readonly property color inactiveColor: root.t ? root.t.base.textInactive : "#737b88"
    readonly property color accentColor: root.t ? root.t.base.accent : "#03cffc"
    readonly property color panelColor: root.t ? root.t.base.surface : "#1f1f1f"
    readonly property color ringColor: activeMuted ? "#59343a" : "#424852"
    readonly property color ledColor: activeMuted ? "#f04452" : accentColor

    color: panelColor
    radius: root.t ? root.t.widgetRadius : 10
    clip: true

    Behavior on color {
        ColorAnimation { duration: 160; easing.type: Easing.OutCubic }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 5

        // Small status line keeps the selected channel and its real level visible.
        RowLayout {
            Layout.fillWidth: true
            spacing: 6

            Rectangle {
                width: 6
                height: 6
                radius: 3
                color: root.activeMuted ? "#f04452" : root.accentColor
            }

            Text {
                Layout.fillWidth: true
                text: root.selectedChannel === "audio" ? "AUDIO CONTROL" : "MIC CONTROL"
                color: root.textColor
                font.family: root.t ? root.t.fontFamily : "JetBrainsMono Nerd Font"
                font.pixelSize: 10
                font.bold: true
                font.letterSpacing: 1.0
                elide: Text.ElideRight
            }

            Text {
                text: Math.round(root.activeVolume * 100) + "%"
                color: root.inactiveColor
                font.family: root.t ? root.t.fontFamily : "JetBrainsMono Nerd Font"
                font.pixelSize: 11
            }
        }

        Item {
            id: dialArea
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumHeight: 100
            Layout.preferredHeight: 180

            // The dial scales with the available block height, with a compact minimum.
            Item {
                id: dial
                width: Math.min(176, Math.max(104, Math.min(dialArea.width - 8, dialArea.height - 4)))
                height: width
                anchors.centerIn: parent

                readonly property real center: width / 2
                readonly property real outerRadius: width * 0.455
                readonly property real knobRadius: width * 0.345
                readonly property real dotRadius: width * 0.014
                readonly property int ledCount: 27
                readonly property real startAngle: 135
                readonly property real sweepAngle: 270

                // Unlit LED track.
                Repeater {
                    model: dial.ledCount
                    delegate: Rectangle {
                        required property int index
                        readonly property real angle: (dial.startAngle + index * dial.sweepAngle / (dial.ledCount - 1)) * Math.PI / 180
                        width: Math.max(2, dial.dotRadius * 2)
                        height: width
                        radius: width / 2
                        x: dial.center + Math.cos(angle) * dial.outerRadius - width / 2
                        y: dial.center + Math.sin(angle) * dial.outerRadius - height / 2
                        color: {
                            const fraction = index / (dial.ledCount - 1)
                            const lit = fraction <= root.activeVolume + 0.0001
                            if (lit)
                                return root.activeMuted ? "#f04452" : root.accentColor
                            return root.ringColor
                        }
                        opacity: {
                            const lit = index / (dial.ledCount - 1) <= root.activeVolume + 0.0001
                            return lit ? 1.0 : 0.82
                        }
                        Behavior on color { ColorAnimation { duration: 140 } }
                    }
                }

                // Subtle shadow gives the dial depth without a glossy, over-rendered look.
                Rectangle {
                    width: dial.knobRadius * 2 + 4
                    height: width
                    radius: width / 2
                    anchors.centerIn: parent
                    anchors.verticalCenterOffset: 2
                    color: "#0d1016"
                }

                // Outer metal-like rim.
                Rectangle {
                    id: knobRim
                    width: dial.knobRadius * 2 + 2
                    height: width
                    radius: width / 2
                    anchors.centerIn: parent
                    color: root.activeMuted ? "#25252c" : "#303641"
                    border.width: 1.2
                    border.color: root.activeMuted ? "#4b353b" : "#59616e"

                    Behavior on color { ColorAnimation { duration: 180 } }
                    Behavior on border.color { ColorAnimation { duration: 180 } }
                }

                // Face: matte and understated, with a soft inner bevel.
                Rectangle {
                    id: knobFace
                    width: dial.knobRadius * 2 - 7
                    height: width
                    radius: width / 2
                    anchors.centerIn: parent
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: root.activeMuted ? "#27242a" : "#343a45" }
                        GradientStop { position: 1.0; color: root.activeMuted ? "#1c1c22" : "#222832" }
                    }
                    border.width: 1
                    border.color: root.activeMuted ? "#342c32" : "#414956"

                    Behavior on border.color { ColorAnimation { duration: 180 } }
                }

                // Pointer is the physical-looking position indicator.
                Item {
                    id: pointerAssembly
                    anchors.fill: parent
                    rotation: 225 + root.activeVolume * 270
                    Behavior on rotation {
                        NumberAnimation { duration: 230; easing.type: Easing.OutCubic }
                    }

                    Rectangle {
                        width: Math.max(2, dial.width * 0.018)
                        height: dial.width * 0.105
                        radius: width / 2
                        anchors.horizontalCenter: parent.horizontalCenter
                        y: dial.center - dial.knobRadius * 0.73 - height / 2
                        color: root.activeMuted ? "#7b454c" : "#dce4ef"
                        opacity: root.activeMuted ? 0.65 : 0.96
                    }
                }

                // Center cap adds a little hardware-like weight.
                Rectangle {
                    width: dial.width * 0.075
                    height: width
                    radius: width / 2
                    anchors.centerIn: parent
                    color: root.activeMuted ? "#373039" : "#46505f"
                    border.width: 1
                    border.color: root.activeMuted ? "#49373e" : "#626c7a"
                }

                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton
                    hoverEnabled: true
                    cursorShape: pressed ? Qt.ClosedHandCursor : Qt.PointingHandCursor

                    // Track relative angular movement rather than mapping each pointer
                    // position directly onto the arc. This prevents the 0/100% wrap seam
                    // from snapping the value to the opposite end of the range.
                    property real lastPointerAngle: 0

                    function pointerAngle(mouseX, mouseY) {
                        return Math.atan2(mouseY - dial.center, mouseX - dial.center) * 180 / Math.PI
                    }

                    function setActiveVolume(value) {
                        const nextValue = Math.max(0, Math.min(1, value))
                        if (root.selectedChannel === "audio")
                            AudioService.setOutputVolume(nextValue)
                        else
                            AudioService.setInputVolume(nextValue)
                    }

                    onPressed: mouse => {
                        lastPointerAngle = pointerAngle(mouse.x, mouse.y)
                    }
                    onPositionChanged: mouse => {
                        if (!pressed)
                            return
                        const currentAngle = pointerAngle(mouse.x, mouse.y)
                        let delta = currentAngle - lastPointerAngle
                        // Normalize the angular delta across the -180/180 boundary.
                        if (delta > 180)
                            delta -= 360
                        else if (delta < -180)
                            delta += 360
                        lastPointerAngle = currentAngle
                        setActiveVolume(root.activeVolume + delta / dial.sweepAngle)
                    }
                    onWheel: wheel => {
                        const delta = wheel.angleDelta.y / 120 * 0.025
                        const nextValue = Math.max(0, Math.min(1, root.activeVolume + delta))
                        if (root.selectedChannel === "audio")
                            AudioService.setOutputVolume(nextValue)
                        else
                            AudioService.setInputVolume(nextValue)
                        wheel.accepted = true
                    }
                }
            }
        }

        // Compact selector row: source buttons flank a small red mute key.
        RowLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            spacing: 7

            Rectangle {
                id: audioButton
                Layout.preferredWidth: 58
                Layout.preferredHeight: 32
                radius: 5
                y: audioMouse.pressed ? 1 : 0
                scale: audioMouse.pressed ? 0.96 : 1.0
                color: audioMouse.pressed ? "#151a22" : (root.selectedChannel === "audio" ? "#293541" : "#20242c")
                border.width: 1
                border.color: root.selectedChannel === "audio" ? root.accentColor : "#414752"

                Behavior on y { NumberAnimation { duration: 75; easing.type: Easing.OutQuad } }
                Behavior on scale { NumberAnimation { duration: 75; easing.type: Easing.OutQuad } }
                Behavior on color { ColorAnimation { duration: 120 } }
                Behavior on border.color { ColorAnimation { duration: 120 } }

                Image {
                    id: headphoneIcon
                    anchors.centerIn: parent
                    source: Qt.resolvedUrl("../../svg/headphone.svg")
                    sourceSize.width: 22
                    sourceSize.height: 22
                    width: 15
                    height: 15
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                    visible: status === Image.Ready
                    layer.enabled: status === Image.Ready
                    layer.effect: ColorOverlay {
                        color: root.selectedChannel === "audio" ? root.accentColor : root.inactiveColor
                    }
                }

                Text {
                    anchors.centerIn: parent
                    text: "♫"
                    color: root.selectedChannel === "audio" ? root.accentColor : root.inactiveColor
                    font.pixelSize: 15
                    visible: headphoneIcon.status !== Image.Ready
                }

                MouseArea {
                    id: audioMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: pressed ? Qt.ClosedHandCursor : Qt.PointingHandCursor
                    onClicked: root.selectedChannel = "audio"
                }
            }

            Rectangle {
                id: muteButton
                Layout.preferredWidth: 32
                Layout.preferredHeight: 32
                radius: 4
                y: muteMouse.pressed ? 1 : 0
                scale: muteMouse.pressed ? 0.93 : 1.0
                color: muteMouse.pressed ? "#3c1c22" : (root.activeMuted ? "#a52f3b" : "#54262d")
                border.width: 1
                border.color: root.activeMuted ? "#f05b68" : "#85404a"
                Behavior on y { NumberAnimation { duration: 65; easing.type: Easing.OutQuad } }
                Behavior on scale { NumberAnimation { duration: 65; easing.type: Easing.OutQuad } }

                // Slight top-edge highlight and bottom shadow imply a tactile button.
                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: 1
                    height: 1
                    color: root.activeMuted ? "#ff9aa2" : "#9b5059"
                    opacity: 0.7
                }
                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.margins: 1
                    height: 2
                    color: "#35181d"
                    opacity: 0.65
                }

                Text {
                    anchors.centerIn: parent
                    text: "M"
                    color: "#ffe7e9"
                    font.family: "JetBrainsMono Nerd Font Mono"
                    font.pixelSize: 13
                    font.weight: Font.Black
                    font.letterSpacing: 0.4
                }

                Behavior on color { ColorAnimation { duration: 140 } }
                Behavior on border.color { ColorAnimation { duration: 140 } }

                MouseArea {
                    id: muteMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: pressed ? Qt.ClosedHandCursor : Qt.PointingHandCursor
                    onClicked: {
                        if (root.selectedChannel === "audio")
                            AudioService.toggleOutputMute()
                        else
                            AudioService.toggleInputMute()
                    }
                }
            }

            Rectangle {
                id: micButton
                Layout.preferredWidth: 58
                Layout.preferredHeight: 32
                radius: 5
                y: micMouse.pressed ? 1 : 0
                scale: micMouse.pressed ? 0.96 : 1.0
                color: micMouse.pressed ? "#151a22" : (root.selectedChannel === "mic" ? "#293541" : "#20242c")
                border.width: 1
                border.color: root.selectedChannel === "mic" ? root.accentColor : "#414752"

                Behavior on y { NumberAnimation { duration: 75; easing.type: Easing.OutQuad } }
                Behavior on scale { NumberAnimation { duration: 75; easing.type: Easing.OutQuad } }
                Behavior on color { ColorAnimation { duration: 120 } }
                Behavior on border.color { ColorAnimation { duration: 120 } }

                Image {
                    id: micIcon
                    anchors.centerIn: parent
                    source: Qt.resolvedUrl("../../svg/mic.svg")
                    sourceSize.width: 21
                    sourceSize.height: 21
                    width: 15
                    height: 15
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                    visible: status === Image.Ready
                    layer.enabled: status === Image.Ready
                    layer.effect: ColorOverlay {
                        color: root.selectedChannel === "mic" ? root.accentColor : root.inactiveColor
                    }
                }

                Text {
                    anchors.centerIn: parent
                    text: "♩"
                    color: root.selectedChannel === "mic" ? root.accentColor : root.inactiveColor
                    font.pixelSize: 19
                    visible: micIcon.status !== Image.Ready
                }

                MouseArea {
                    id: micMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: pressed ? Qt.ClosedHandCursor : Qt.PointingHandCursor
                    onClicked: root.selectedChannel = "mic"
                }
            }
        }
    }
}
