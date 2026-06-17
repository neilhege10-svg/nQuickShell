import Qt5Compat.GraphicalEffects
import QtQuick
import Quickshell.Io

Item {
    id: root

// ── CORE PROPERTIES ──────────────────────────────────
    property var t
    property string cpuPct: "0"
    property string ramPct: "0"

//-----------------------------------------------------------------------------------
// Tell the Bar's RowLayout exactly how much space this module needs
//-----------------------------------------------------------------------------------
    implicitWidth: statsLabel.implicitWidth + (t ? t.widgetPadding * 2 : 16)
    implicitHeight: t ? t.pillHeight : 32 

//-----------------------------------------------------------------------------------
// Main shape and design of the SysStat module
//-----------------------------------------------------------------------------------
    Rectangle {
        id: pill

        anchors.fill: parent
        radius: t ? t.widgetRadius : 8
        color: t ? t.base.surface : "#313244" 

//-----------------------------------------------------------------------------------
// Main Process of the SysStat module seperated into 2, cpuProc and ramProc
//-----------------------------------------------------------------------------------
        Process {
            id: cpuProc

            // runs some bash commands to check the cpu stat
            command: ["bash", "-c", "awk '/^cpu /{u=$2+$4; t=$2+$3+$4+$5+$6+$7+$8; print int(u/t*100)}' /proc/stat"]
            running: true

            stdout: SplitParser {
                onRead: (data) => {
                    root.cpuPct = data.trim() || "0";
                }
            }

        }

        Process {
            id: ramProc

            // runs some bash commands to check the ram stat
            command: ["bash", "-c", "awk '/MemTotal/{t=$2} /MemAvailable/{a=$2} END{printf \"%d\", (t-a)/t*100}' /proc/meminfo"]
            running: true

            stdout: SplitParser {
                onRead: (data) => {
                    root.ramPct = data.trim() || "0";
                }
            }

        }

        Timer {
            interval: 3000
            repeat: true
            running: true
            onTriggered: {
                cpuProc.running = true;
                ramProc.running = true;
            }
        }

//-----------------------------------------------------------------------------------
// Main Text design of the SystemStats module
//-----------------------------------------------------------------------------------
        Text {
            id: statsLabel

            anchors.centerIn: parent
            text: "󰻠 " + root.cpuPct + "% 󰍛 " + root.ramPct + "%"
            color: root.t ? root.t.base.text : "#cdd6f4" // UPGRADED: Namespaced to base.text [cite: 30]

            font {
                pixelSize: root.t ? root.t.fontSize : 13
                family: root.t ? root.t.fontFamily : ""
            }

        }

    }

}
