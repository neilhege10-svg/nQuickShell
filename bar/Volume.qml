import "../state"
import Qt5Compat.GraphicalEffects
import QtQuick
import Quickshell.Services.Pipewire

Item {
    id: root

    property var t

    implicitHeight: t ? t.pillHeight : 32
    implicitWidth: volLabel.implicitWidth + (t ? t.widgetPadding * 2 : 16)

    DropShadow {
        anchors.fill: pill
        horizontalOffset: 3
        verticalOffset: 2
        radius: 8
        samples: 17
        color: "#000000"
        source: pill
        opacity: PanelState.rPanelOpen && PanelState.rPanelPage === "audio" ? 1 : 0

        Behavior on opacity {
            NumberAnimation {
                duration: 200
                easing.type: Easing.InOutQuad
            }

        }

    }

    Rectangle {
        id: pill

        anchors.fill: parent
        radius: PanelState.rPanelOpen && PanelState.rPanelPage === "audio" ? 12 : (t ? t.widgetRadius : 8)
        color: PanelState.rPanelOpen && PanelState.rPanelPage === "audio" ? (t ? t.base.accent : "#b4befe") : (t ? t.base.surface : "#313244")
        scale: mouseArea.pressed ? 0.9 : 1

        PwObjectTracker {
            objects: [Pipewire.defaultAudioSink]
        }

        Text {
            id: volLabel

            anchors.centerIn: parent
            text: {
                var sink = Pipewire.defaultAudioSink;
                if (!sink || !sink.audio)
                    return "󰸈 --";

                var pct = Math.round(sink.audio.volume * 100);
                if (sink.audio.muted)
                    return "󰸈 " + pct + "%";

                if (pct > 66)
                    return "󰕾 " + pct + "%";

                if (pct > 33)
                    return "󰖀 " + pct + "%";

                return "󰕿 " + pct + "%";
            }
            color: PanelState.rPanelOpen && PanelState.rPanelPage === "audio" ? (root.t ? root.t.base.textActive : "#11111b") : (root.t ? root.t.base.text : "#cdd6f4")

            font {
                pixelSize: root.t ? root.t.fontSize : 13
                family: root.t ? root.t.fontFamily : ""
            }

            Behavior on color {
                ColorAnimation {
                    duration: 400
                  }
                }

        }

MouseArea {
    id: mouseArea
    anchors.fill: parent
    cursorShape: Qt.PointingHandCursor
    
    onClicked: {
        if (!PanelState.rPanelOpen) {
            // If the panel is closed, open it and set the page
            PanelState.rPanelOpen = true;
            PanelState.rPanelPage = "audio";
        } else {
            // If it's already open, just make sure it switches to the audio page
            PanelState.rPanelPage = "audio";
        }
    }
}

        Behavior on color {
            ColorAnimation {
                duration: 330
            }

        }

        Behavior on radius {
            NumberAnimation {
                duration: 330
            }

        }

    }

}
