import QtQuick

QtObject {
    // Directed to your new custom home for it

    id: root

    // ─────────────────────────────────────────────────────────────
    // 1. GLOBAL CORE METRICS
    // ─────────────────────────────────────────────────────────────
    readonly property string fontFamily: "JetBrainsMono Nerd Font"
    readonly property int fontSize: 13
    readonly property int spacing: 7
    readonly property color shadow: "#40000000"
    readonly property int barHeight: 35
    readonly property int barPadding: 6
    readonly property int pillHeight: 25
    readonly property int btnHeight: 30
    readonly property int widgetPadding: 10
    readonly property int widgetRadius: 8
    readonly property string holoFont: "Share Tech Mono"
    // ─────────────────────────────────────────────────────────────
    // 2. YOUR NEW DESIGN SYSTEMS (Inline to lock them from formatters)
    // ─────────────────────────────────────────────────────────────
    readonly property QtObject
    base: QtObject {
        readonly property color bg: "#202636"
        readonly property color surface: "#1a1e2b"
        readonly property color text: "#03cffc"
        readonly property color textActive: "#e6e6e6"
        readonly property color accent: "#03cffc"
        readonly property color border: "#4096bfff"
        readonly property color shadow: "#4d000000"
        readonly property color altbg: "#4d171b26" // Your moved RightPanel BG
    }

    readonly property QtObject
    holo: QtObject {
        readonly property color bgtransparent: "#4d3e78d6"
        readonly property color text: "#03cffc"
        readonly property color textActive: "#7ae7ff"
        readonly property color holobg: "#1a3e78d6"
        readonly property color bgsel: "#994381e6"
        readonly property color border: "#ff96bfff"
        readonly property color shadow: "#ff96bfff"
        readonly property color neon: "#5903cffc" // 35% Opacity built-in
        readonly property color neonActive: "#a603cffc" // 65% Opacity built-in
        readonly property color glowSolid: "#ff96bfff" // despite the name glow and neon are completely different
        readonly property color warningText: "#ff5555"
        readonly property color warningActive: "#ff7777"
        readonly property color warningBg: "#1aff5555"
        readonly property color warningBgSel: "#4dff5555"
    }

    // ─────────────────────────────────────────────────────────────
    // 3. BACKWARD COMPATIBILITY PROXY LAYER
    // ─────────────────────────────────────────────────────────────
    // Normal UI Proxies
    readonly property color bg: root.base.bg
    readonly property color surface: root.base.surface
    readonly property color text: root.base.text
    readonly property color textalt: root.base.textActive // Aligned to your new name
    readonly property color accent: root.base.accent
    readonly property color border: root.base.border
    // Holographic UI Proxies
    readonly property color bgTransparent: root.holo.bgtransparent
    // Fixed lowercase casing
    readonly property color holoText: root.holo.text
    readonly property color holoTextsel: root.holo.textActive // Aligned to your new name
    readonly property color holoBG: root.holo.holobg // Fixed lowercase casing
    readonly property color holoBGsel: root.holo.bgsel
    readonly property color holoBorder: root.holo.border
    readonly property color holoShadow: root.holo.shadow
    // Right Panel Proxies
    readonly property color rpBG: root.base.altbg
}
