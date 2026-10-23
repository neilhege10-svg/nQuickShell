import "../state"
import QtQuick.Effects
import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import Quickshell.Services.Pipewire

Item {
    id: root

    // ── CORE PROPERTIES ──────────────────────────────────
    property var t

// ── MAIN PROCESS ──────────────────────────────
// this is what makes the icon reactive and changes its icon
// based on its volume/status (muted/or not)
// ─────────────────────────────────────────────────────
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

    // ── LAYOUT BOUNDS ────────────────────────────────────
    // Keeps layout tight based strictly on the icon size
    implicitHeight: t ? t.pillHeight : 32
    implicitWidth: volLabel.width

// ── MAIN PILL CONTAINER ──────────────────────────────
// Rectangle for the module,
// its set to transparent, because the actual pill lives in Bar.qml and this is crammed
// alongside other modules, such as Volume,Wifi,etc
// ─────────────────────────────────────────────────────
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
        // (part of Main Process)
        PwObjectTracker {
            objects: [Pipewire.defaultAudioSink]
        }

// ── PROCESS 2: Toggle Wifi Power ─────────────────
// this is another simple process that allows the toggling of the module's status
// and changes the icon
// ─────────────────────────────────────────────────────
        Process {
            id: muteToggleProc
            command: ["bash", "-c", "for s in $(pactl list short sinks | awk '{print $1}'); do pactl set-sink-mute \"$s\" toggle; done"]
        }

// ── ICON DISPLAY ─────────────────────────────────────
// this is just the visual design, coloring of the icon
// ─────────────────────────────────────────────────────
        Image {
            id: volLabel

            source: root.volIcon

            readonly property int iconDimension: root.t ? root.t.fontSize - 1 : 15
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
            color: root.t ? root.t.base.textAccent : "#cdd6f4"
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
// Click function, has Animations, and also runs muteToggleProc on click
// ─────────────────────────────────────────────────────
    MouseArea {
        id: mouseArea

        // Expands hit box by 10px on left/right into empty RowLayout spacing
        anchors {
            top: parent.top
            bottom: parent.bottom
            left: parent.left
            right: parent.right
            leftMargin: -10
            rightMargin: -10
        }

        cursorShape: Qt.PointingHandCursor

        onClicked: {
            muteToggleProc.running = true;
        }
    }
}
