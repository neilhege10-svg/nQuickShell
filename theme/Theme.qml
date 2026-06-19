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
    readonly property int barHeight: 36
    readonly property int barPadding: 6
    readonly property int pillHeight: 20
    readonly property int btnHeight: 30
    readonly property int widgetPadding: 10
    readonly property int widgetRadius: 8
    readonly property string holoFont: "Share Tech Mono"
    // ─────────────────────────────────────────────────────────────
    // 2. YOUR NEW DESIGN SYSTEMS (Inline to lock them from formatters)
    // ─────────────────────────────────────────────────────────────
    readonly property QtObject
    base: QtObject {
        readonly property color bg: "#1c1c1c"
        readonly property color surface: "#141414"
        readonly property color text: "#e6e6e6"
        readonly property color textAccent: "#1c1c1c"
        readonly property color textInactive: "#6e6e6e"
        readonly property color accent: "#03befc"
        readonly property color border: "#BF454545"
        readonly property color shadow: "#4d010101"
    }

    readonly property QtObject
    holo: QtObject {
        readonly property color bgtransparent: "#4d3e78d6"
        readonly property color text: "#03cffc"
        readonly property color textAccent: "#7ae7ff"
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
      // ==========================================
// TRANSPARENCY CHEAT SHEET
// ==========================================

// 1. BASE COLOR (MUST be 'color' type, NEVER 'string')
readonly property color baseSurface: "#1e1e2e"

// 2. DYNAMIC METHOD: Qt.rgba()
// Extracts RGB from baseSurface, applies alpha (0.0 to 1.0)
readonly property color surface_40pct: Qt.rgba(baseSurface.r, baseSurface.g, baseSurface.b, 0.4)
readonly property color surface_80pct: Qt.rgba(baseSurface.r, baseSurface.g, baseSurface.b, 0.8)

// 3. STATIC METHOD: Hex Alpha #AARRGGBB (5% increments)
// Format: # + AA (Alpha) + RRGGBB (Your base color)
readonly property color alpha_00: "#001e1e2e"  // 0% (Invisible)
readonly property color alpha_05: "#0D1e1e2e"  // 5%
readonly property color alpha_10: "#1A1e1e2e"  // 10%
readonly property color alpha_15: "#261e1e2e"  // 15%
readonly property color alpha_20: "#331e1e2e"  // 20%
readonly property color alpha_25: "#401e1e2e"  // 25%
readonly property color alpha_30: "#4D1e1e2e"  // 30%
readonly property color alpha_35: "#591e1e2e"  // 35%
readonly property color alpha_40: "#661e1e2e"  // 40%
readonly property color alpha_45: "#731e1e2e"  // 45%
readonly property color alpha_50: "#801e1e2e"  // 50%
readonly property color alpha_55: "#8C1e1e2e"  // 55%
readonly property color alpha_60: "#991e1e2e"  // 60%
readonly property color alpha_65: "#A61e1e2e"  // 65%
readonly property color alpha_70: "#B31e1e2e"  // 70%
readonly property color alpha_75: "#BF1e1e2e"  // 75%
readonly property color alpha_80: "#CC1e1e2e"  // 80%
readonly property color alpha_85: "#D91e1e2e"  // 85%
readonly property color alpha_90: "#E61e1e2e"  // 90%
readonly property color alpha_95: "#F21e1e2e"  // 95%
readonly property color alpha_100:"#FF1e1e2e"  // 100% (Solid)
}
