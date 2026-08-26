import "../state"
import Qt5Compat.GraphicalEffects
import QtQuick
import Quickshell.Io
import Quickshell.Services.Pipewire

Item {
    id: root

    // ── CORE PROPERTIES ──────────────────────────────────
    property var t

    // Icon path generator based on Pipewire default audio sink
    readonly property string volIcon: {
        var sink = Pipewire.defaultAudioSink;
        if (!sink || !sink.audio || sink.audio.muted)
            return "../svg/volume-x.svg";

        var pct = Math.round(sink.audio.volume * 100);
        if (pct > 66)
            return "../svg/volume-2.svg";
        if (pct > 33)
            return "../svg/volume-1.svg";
        
        return "../svg/volume.svg";
    }

    // Space requirements for RowLayout
    implicitHeight: t ? t.pillHeight : 32
    implicitWidth: (root.t ? root.t.fontSize + 4 : 18) + (4 * 2)

    // ── GLOW / SHADOW EFFECT ─────────────────────────────
    DropShadow {
        anchors.fill: pill
        horizontalOffset: 3
        verticalOffset: 2
        radius: 8
        samples: 17
        color: "#000000"
        source: pill
        opacity: mouseArea.pressed ? 0.6 : 0

        Behavior on opacity {
            NumberAnimation {
                duration: 150
                easing.type: Easing.InOutQuad
            }
        }
    }

    // ── MAIN PILL CONTAINER ──────────────────────────────
    Rectangle {
        id: pill

        anchors.fill: parent
        radius: t ? t.widgetRadius : 12
        color: "transparent"
        scale: mouseArea.pressed ? 0.88 : 1.0

        Behavior on scale {
            NumberAnimation {
                duration: 120
                easing.type: Easing.OutQuad
            }
        }

        // Pipewire sink tracker to keep UI reactivity instant
        PwObjectTracker {
            objects: [Pipewire.defaultAudioSink]
        }

        // Process executing mute toggle across ALL sinks on ANY machine
        Process {
            id: muteToggleProc
            command: ["bash", "-c", "for s in $(pactl list short sinks | awk '{print $1}'); do pactl set-sink-mute \"$s\" toggle; done"]
        }

        // ── ICON DISPLAY ─────────────────────────────────────
        Image {
            id: volLabel

            source: root.volIcon

            readonly property int iconDimension: root.t ? root.t.fontSize : 16
            width: iconDimension
            height: iconDimension
            sourceSize.width: iconDimension
            sourceSize.height: iconDimension

            anchors.centerIn: parent

            fillMode: Image.PreserveAspectFit
            smooth: true
            mipmap: true

            layer.enabled: true
            layer.effect: ColorOverlay {
                color: root.t ? root.t.base.text : "#cdd6f4"

                Behavior on color {
                    ColorAnimation {
                        duration: 300
                    }
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

    // ── CLICK INTERACTION ────────────────────────────────
    MouseArea {
        id: mouseArea

        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor

        onClicked: {
            muteToggleProc.running = true;
        }
    }
}
