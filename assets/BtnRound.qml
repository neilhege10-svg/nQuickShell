import "../state"
import Qt5Compat.GraphicalEffects
import QtQuick

Item {
    id: root

    // ─────────────────────────────────────────────────────────────────
    // 1. EXPOSED COMPONENT INTERFACE
    // ─────────────────────────────────────────────────────────────────
    property var t
    property string icon: ""
    property bool activeState: false
    property bool showShadow: false

    property bool hasBorder: false     // Draws a thin outer ring line
    property bool isHolo: false        // Switches color mapping to the holo sub-object
    property bool isWarning: false     // Switches palette maps to critical warning variants

    signal clicked()

    implicitHeight: root.t ? root.t.btnHeight : 30
    implicitWidth: root.t ? root.t.btnHeight : 30
    
    layer.enabled: root.showShadow || root.isHolo

    // ─────────────────────────────────────────────────────────────────
    // 2. DESIGN STATE MAPPINGS (THE COMPLETE 6-WAY CONTROL MATRIX)
    // ─────────────────────────────────────────────────────────────────
    
    // ── BACKGROUND COLORS ──
    readonly property color finalBgColor: {
        // [MODE 1] STANDARD BASE UI
        if (!root.isHolo && !root.isWarning) {
            if (root.activeState) return root.t.base.accent
            else return mouseArea.containsMouse ? Qt.alpha(root.t.base.surface, 0.85) : root.t.base.surface
        }

        // [MODE 2] HOLO WARNING UI
        if (root.isHolo && root.isWarning) {
            if (root.activeState) return root.t.holo.warningBgSel
            else return mouseArea.containsMouse ? root.t.holo.warningBgSel : root.t.holo.warningBg
        }

        // [MODE 3] NORMAL HOLO UI
        if (root.activeState) return root.t.holo.bgsel
        else return mouseArea.containsMouse ? root.t.holo.bgsel : root.t.holo.bgsel
    }

    // ── BORDER COLORS ──
    readonly property color finalBorderColor: {
        // [MODE 1] STANDARD BASE UI
        if (!root.isHolo && !root.isWarning) {
            return root.t.base.border
        }

        // [MODE 2] HOLO WARNING UI
        if (root.isHolo && root.isWarning) {
            if (root.activeState) return root.t.holo.warningActive
            else return "transparent"
        }

        // [MODE 3] NORMAL HOLO UI
        if (root.activeState) return root.t.holo.border
        else return root.t.holo.border
    }

    // ── TEXT / ICON COLORS ──
    readonly property color finalTextColor: {
        // [MODE 1] STANDARD BASE UI
        if (!root.isHolo && !root.isWarning) {
            if (root.activeState) return root.t.base.textActive
            else return root.t.base.text
        }

        // [MODE 2] HOLO WARNING UI
        if (root.isHolo && root.isWarning) {
            if (root.activeState) return root.t.holo.warningActive
            else return root.t.holo.warningText
        }

        // [MODE 3] NORMAL HOLO UI
        if (root.activeState) return root.t.holo.textActive
        else return root.t.holo.textActive
    }

    // ── GLOW AND SHADOW RADIUS ──
    readonly property int finalGlowRadius: {
        // [MODE 1] STANDARD BASE UI
        if (!root.isHolo && !root.isWarning) {
            return root.showShadow ? 6 : 0
        }

        // [MODE 2] HOLO WARNING UI
        if (root.isHolo && root.isWarning) {
            if (root.activeState) return 12
            else return 5
        }

        // [MODE 3] NORMAL HOLO UI
        if (root.activeState) return 12
        else return 5
    }

    // ── GLOW AND SHADOW COLORS ──
    readonly property color finalGlowColor: {
        // [MODE 1] STANDARD BASE UI
        if (!root.isHolo && !root.isWarning) {
            return root.t.base.shadow
        }

        // [MODE 2] HOLO WARNING UI
        if (root.isHolo && root.isWarning) {
            if (root.activeState) return root.t.holo.warningActive
            else return root.t.holo.warningBg // Dims down when inactive
        }

        // [MODE 3] NORMAL HOLO UI
        if (root.activeState) return root.t.holo.glowSolid
        else return root.t.holo.glowSolid
    }


    // ─────────────────────────────────────────────────────────────────
    // 3. VISUAL LAYOUT & RENDERING PIPELINE
    // ─────────────────────────────────────────────────────────────────
    Rectangle {
        id: btn

        anchors.fill: parent
        radius: 16
        scale: mouseArea.pressed ? 0.9 : 1

        color: root.finalBgColor
        border.width: root.hasBorder || root.isHolo ? 1 : 0
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

        Behavior on scale { NumberAnimation { duration: 100; easing.type: Easing.OutQuad } }
        Behavior on color { ColorAnimation { duration: 200 } }
    }

    MouseArea {
        id: mouseArea

        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
        onClicked: root.clicked()
    }

    layer.effect: DropShadow {
        horizontalOffset: root.isHolo ? 0 : 3
        verticalOffset: root.isHolo ? 0 : 2
        radius: root.finalGlowRadius
        color: root.finalGlowColor
        samples: 17

        Behavior on radius { 
            NumberAnimation { 
                duration: 250; 
                easing.type: Easing.OutQuad 
            } 
        }
    }
}
