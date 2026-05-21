import "../theme"
import QtQuick
import QtQuick.Effects
import QtQuick.Layouts

RowLayout {
    id: root

    // ── INTERFACE PROPERTIES ──
    property var t
    property string title: "SECTION TITLE"
    property color accentColor: t.holo.text // Default to holo.text

    Layout.fillWidth: true
    Layout.preferredHeight: 28
    spacing: 8

    // Left Line
    Rectangle {
        Layout.fillWidth: true
        height: 1
        color: Qt.rgba(t.base.accent.r, t.base.accent.g, t.base.accent.b, 0.15)
    }

    // Left Decorative Bar
    Rectangle {
        width: 2
        height: 14
        radius: 1
        color: root.accentColor
        layer.enabled: true

        layer.effect: MultiEffect {
            blurEnabled: true
            blur: 0.4
            colorization: 1
            colorizationColor: root.accentColor
        }

    }

    // Main Title Text
    Text {
        text: root.title
        color: t.holo.text

        font {
            family: t.holoFont
            pixelSize: t.fontSize + 8
            bold: true
            letterSpacing: 1.5
        }

    }

    // Right Decorative Bar
    Rectangle {
        width: 2
        height: 14
        radius: 1
        color: root.accentColor
        layer.enabled: true

        layer.effect: MultiEffect {
            blurEnabled: true
            blur: 0.4
            colorization: 1
            colorizationColor: root.accentColor
        }

    }

    // Right Line
    Rectangle {
        Layout.fillWidth: true
        height: 1
        color: Qt.rgba(t.base.accent.r, t.base.accent.g, t.base.accent.b, 0.15)
    }

}
