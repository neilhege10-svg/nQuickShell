import Qt5Compat.GraphicalEffects
import QtQuick
import Quickshell.Io

Item {
    id: root

    // ── CORE PROPERTIES ──────────────────────────────────
    property var t
    property bool hasBattery: true
    property int batPct: 0
    property string batStatus: ""

    // Dynamic color: turns red at <=20% (unless charging)
    readonly property color iconColor: {
        if (root.batStatus !== "Charging" && root.batPct <= 20) {
            return t ? (t.base.red || "#f38ba8") : "#f38ba8";
        }
        return t ? t.base.text : "#cdd6f4";
    }

    // Dynamic SVG selection based on percentage & charging state
    readonly property string iconSource: {
        if (root.batStatus === "Charging") {
            return "../svg/battery-charging.svg";
        }
        if (root.batPct <= 20) {
            return "../svg/battery-low.svg";
        }
        if (root.batPct <= 60) {
            return "../svg/battery-medium.svg";
        }
        if (root.batPct <= 95) {
            return "../svg/battery.svg";
        }
        return "../svg/battery-full.svg";
    }

    // Auto-fit inside the control pill layout
    implicitWidth: hasBattery ? 16 : 0
    implicitHeight: hasBattery ? 16 : 0
    visible: hasBattery

    // ── PROCESS LOGIC ────────────────────────────────────
    Process {
        id: batProc

        command: ["sh", "-c", "cap=$(cat /sys/class/power_supply/BAT*/capacity 2>/dev/null | head -n 1); stat=$(cat /sys/class/power_supply/BAT*/status 2>/dev/null | head -n 1); [ -n \"$cap\" ] && echo \"$cap $stat\" || echo \"NONE\""]
        running: true

        stdout: SplitParser {
            onRead: (data) => {
                let reply = data.trim();
                if (reply === "NONE" || reply === "") {
                    root.hasBattery = false;
                } else {
                    root.hasBattery = true;
                    let parts = reply.split(" ");
                    root.batPct = parseInt(parts[0]) || 0;
                    root.batStatus = parts[1] || "";
                }
            }
        }
    }

    Timer {
        interval: 5000
        repeat: true
        running: root.hasBattery
        onTriggered: batProc.running = true
    }

    // ── SVG ICON & COLOR OVERLAY ─────────────────────────
    Image {
        id: batIcon
        anchors.fill: parent
        source: root.iconSource
        sourceSize.width: width
        sourceSize.height: height
        fillMode: Image.PreserveAspectFit
        smooth: true
        visible: false // Hidden because ColorOverlay handles rendering
    }

    ColorOverlay {
        anchors.fill: batIcon
        source: batIcon
        color: root.iconColor
    }
}
