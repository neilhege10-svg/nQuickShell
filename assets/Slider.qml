import "../services"
import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Layouts

Item {
    id: control

    // ── CORE SYSTEM PROPERTIES ───────────────────────────
    property var t
    property real value: 0.5
    property bool isOutput: true

    onValueChanged: {
        if (isOutput)
            AudioService.setOutputVolume(value);
        else
            AudioService.setInputVolume(value);
    }
    Component.onCompleted: {
        value = isOutput ? AudioService.outputVolume : AudioService.inputVolume;
    }
    implicitWidth: 200
    implicitHeight: 32

    // ── INTERACTIVE MOUSE AREA ───────────────────────────
    MouseArea {
        id: trackMouse

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            value = Math.max(0, Math.min(1, mouseX / control.width));
        }
        onPositionChanged: {
            if (pressed)
                value = Math.max(0, Math.min(1, mouseX / control.width));

        }
    }

    // ── VISUAL TRACK ─────────────────────────────────────
    Rectangle {
        id: track

        width: parent.width
        height: 6
        radius: 3
        anchors.verticalCenter: parent.verticalCenter
        color: Qt.darker(control.t.base.altbg, 1.4)
        border.color: control.t.base.border // CHANGED: Now uses your clean base border
        border.width: 1

        // ── PROGRESS FILL ──
        Rectangle {
            id: fill

            width: track.width * control.value
            height: parent.height
            radius: parent.radius

            gradient: Gradient {
                orientation: Gradient.Horizontal

                GradientStop {
                    position: 0
                    color: Qt.alpha(control.t.base.accent, 0.3) // CHANGED: Tied to base.accent
                }

                GradientStop {
                    position: 1
                    color: control.t.base.accent // CHANGED: Tied to base.accent
                }

            }

        }

        // ── HOLOGRAPHIC NEON GLOW ──
        Glow {
            anchors.fill: fill
            source: fill
            radius: 8
            samples: 15
            fast: true
            // CHANGED: No opacity formulas or Qt.alpha calculations needed here anymore!
            color: trackMouse.containsMouse || trackMouse.pressed ? control.t.holo.neonActive : control.t.holo.neon

            // Smoothly transitions the glow intensity on hover/press
            Behavior on color {
                ColorAnimation {
                    duration: 150
                }

            }

        }

        // ── SMOOTH HANDLE ──
        Rectangle {
            id: handle

            width: 12
            height: 12
            radius: width / 2
            x: fill.width - width / 2
            y: (track.height - height) / 2
            color: trackMouse.containsMouse || trackMouse.pressed ? control.t.holo.text : control.t.base.textAccent
            opacity: trackMouse.containsMouse || trackMouse.pressed ? 1 : 0.85
            border.color: trackMouse.containsMouse || trackMouse.pressed ? "#ffffff" : "transparent"
            border.width: 1

            Behavior on color {
                ColorAnimation {
                    duration: 120
                }

            }

            Behavior on opacity {
                NumberAnimation {
                    duration: 120
                }

            }

        }

    }

}
