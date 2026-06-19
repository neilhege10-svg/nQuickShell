import "../state"
import Qt5Compat.GraphicalEffects
import QtQuick

Item {
    // ─────────────────────────────────────────────────────────────────
    // 2. STYLING STATES
    // ─────────────────────────────────────────────────────────────────

    id: root

    // ─────────────────────────────────────────────────────────────────
    // 1. EXPOSED COMPONENT INTERFACE
    // ─────────────────────────────────────────────────────────────────
    property var t
    property string icon: ""
    property bool activeState: false
    property bool showShadow: false
    property bool hasBorder: false
    // Background track
    readonly property color finalBgColor: {
        if (root.activeState)
            return root.t.base.accent;
        else
            return mouseArea.containsMouse ? Qt.alpha(root.t.base.bg, 0.85) : root.t.base.bg;
    }
    // Border track
    readonly property color finalBorderColor: root.t.base.border
    // Text & Glyph track
    readonly property color finalTextColor: {
        return root.activeState ? root.t.base.textAccent : root.t.base.text;
    }
    // Shadow Radius track
    readonly property int finalGlowRadius: {
        if (root.activeState)
            return 8;

        // Expands nicely when active and centered
        return root.showShadow ? 6 : 0;
    }
    // Shadow Color track
    readonly property color finalGlowColor: {
        // Force the solid holographic glow when active, fall back to base shadow otherwise
        return root.activeState ? root.t.holo.glowSolid : root.t.base.shadow;
    }
    // Shadow Offsets (Slammed to 0 when active for a fully centered bloom effect)
    readonly property int finalXOffset: root.activeState ? 0 : 3
    readonly property int finalYOffset: root.activeState ? 0 : 2

    signal clicked()

    implicitHeight: root.t ? root.t.btnHeight : 30
    implicitWidth: root.t ? root.t.btnHeight : 30
    layer.enabled: root.showShadow || root.activeState

    // ─────────────────────────────────────────────────────────────────
    // 3. VISUAL LAYOUT & RENDERING PIPELINE
    // ─────────────────────────────────────────────────────────────────
    Rectangle {
        id: btn

        anchors.fill: parent
        radius: 16
        scale: mouseArea.pressed ? 0.9 : 1
        color: root.finalBgColor
        border.width: root.hasBorder ? 1 : 0
        border.color: root.finalBorderColor

        Text {
            id: menuBtn

            anchors.centerIn: parent
            text: root.icon
            color: root.finalTextColor

            font {
                pixelSize: 16
                family: root.t ? root.t.fontFamily : "JetBrainsMono Nerd Font"
            }

        }

        Behavior on scale {
            NumberAnimation {
                duration: 100
                easing.type: Easing.OutQuad
            }

        }

        Behavior on color {
            ColorAnimation {
                duration: 200
            }

        }

    }

    MouseArea {
        id: mouseArea

        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
        onClicked: root.clicked()
    }

    layer.effect: DropShadow {
        horizontalOffset: root.finalXOffset
        verticalOffset: root.finalYOffset
        radius: root.finalGlowRadius
        color: root.finalGlowColor
        samples: 17

        Behavior on radius {
            NumberAnimation {
                duration: 250
                easing.type: Easing.OutQuad
            }

        }

    }

}
