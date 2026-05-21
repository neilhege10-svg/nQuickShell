// ── TOGGLE SWITCH ─────────────────────────────────────────────────────────────
// Reusable iOS-style toggle. Drop it anywhere, bind `checked` and `onToggled`.
// Styled to match the holographic theme — glows cyan when on, dims when off.
// Usage:
//   ToggleSwitch { t: theme; checked: someState; onToggled: someState = !someState }
// ─────────────────────────────────────────────────────────────────────────────

import "../../theme"
import QtQuick
import QtQuick.Effects

Item {
    id: root

    property var t
    property bool checked: false

    signal toggled()

    implicitWidth: 52
    implicitHeight: 28

    // ── TRACK (the pill background) ────────────────────────────────────
    Rectangle {
        id: track

        anchors.fill: parent
        radius: height / 2
        color: root.checked ? root.t.base.text : Qt.rgba(root.t.base.textActive.r, root.t.base.textActive.g, root.t.base.textActive.b, 0.08)
        border.color: root.checked ? root.t.base.border : Qt.rgba(root.t.base.textActive.r, root.t.base.textActive.g, root.t.base.textActive.b, 0.2)
        border.width: 1
        // Optional glow on the track when active
        layer.enabled: root.checked

        Behavior on color {
            ColorAnimation {
                duration: 200
            }

        }

        Behavior on border.color {
            ColorAnimation {
                duration: 200
            }

        }

        layer.effect: MultiEffect {
            blurEnabled: true
            blur: 0.2
            colorization: 1
            colorizationColor: Qt.rgba(root.t.holo.neonActive.r, root.t.holo.neonActive.g, root.t.holo.neonActive.b, 0.4)
        }

    }

    // ── THUMB (the sliding circle) ─────────────────────────────────────
    Rectangle {
        id: thumb

        width: 20
        height: 20
        radius: 10
        anchors.verticalCenter: parent.verticalCenter
        x: root.checked ? parent.width - width - 4 : 4
        color: root.checked ? root.t.holo.textActive : root.t.base.textActive
        // Subtle inner shadow to make it look raised
        layer.enabled: true

        Behavior on x {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutCubic
            }

        }

        Behavior on color {
            ColorAnimation {
                duration: 200
            }

        }

        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowBlur: 0.4
            shadowColor: Qt.rgba(0, 0, 0, 0.35)
            shadowVerticalOffset: 1
        }

    }

    // ── CLICK AREA ─────────────────────────────────────────────────────
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.toggled()
    }

}
