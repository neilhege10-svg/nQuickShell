import Qt5Compat.GraphicalEffects
import QtQuick
import Quickshell.Io

Item {
    id: root

// ── CORE PROPERTIES ──────────────────────────────────
    property var t
    property bool hasBattery: false
    property string batPct: "0"
    property string batStatus: ""

//-----------------------------------------------------------------------------------
// this Section makes it so that the BATTERY module collapses if the system detects
// that there is no battery in the system.
//-----------------------------------------------------------------------------------
    implicitWidth: hasBattery ? (statsLabel.implicitWidth + (t ? t.widgetPadding * 2 : 16)) : 0
    implicitHeight: hasBattery ? (t ? t.pillHeight : 32) : 0
    visible: hasBattery

//-----------------------------------------------------------------------------------
// Main Shape and design of the battery pill
//-----------------------------------------------------------------------------------
    Rectangle {
        id: pill

        anchors.fill: parent
        radius: t ? t.widgetRadius : 8
        color: t ? t.base.surface : "#313244"

//-----------------------------------------------------------------------------------
// Main processes and core logic
//-----------------------------------------------------------------------------------
        Process {
            id: batProc

            // Looks for any BAT* directory. Outputs "Percentage Status" (e.g. "85 Charging") or "NONE"
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
                        root.batPct = parts[0] || "0";
                        root.batStatus = parts[1] || "";
                    }
                }
            }
        }

        Timer {
            interval: 5000 // Battery doesn't change as fast as CPU, 5s is plenty
            repeat: true
            running: root.hasBattery // Only keep looping the timer if we actually have a battery!
            onTriggered: {
                batProc.running = true;
            }
        }

//-----------------------------------------------------------------------------------
// Text Design and stuff
//-----------------------------------------------------------------------------------
        Text {
            id: statsLabel

            anchors.centerIn: parent
            color: root.t ? root.t.base.text : "#cdd6f4"

            // Dynamic Nerd Font icon handling based on charging status
            text: {
                let icon = "󰁹"; // Default battery icon
                if (root.batStatus === "Charging") {
                    icon = "󰂄"; // Charging icon
                }
                return icon + " " + root.batPct + "%";
            }

            font {
                pixelSize: root.t ? root.t.fontSize : 13
                family: root.t ? root.t.fontFamily : ""
            }
        }
    }
}
