import Qt5Compat.GraphicalEffects
import QtQuick
import Quickshell.Io

Item {
    id: root

    // ── CORE PROPERTIES ──────────────────────────────────
    property var t
    property string netIcon: "󰤨"
    property string netName: "..."

    implicitWidth: netLabel.implicitWidth + (t ? t.widgetPadding * 2 : 16)
    implicitHeight: t ? t.pillHeight : 32 // FIXED: Changed theme.pillHeight to t.pillHeight

    Rectangle {
        id: pill

        anchors.fill: parent
        radius: t ? t.widgetRadius : 8
        color: t ? t.base.surface : "#313244" // UPGRADED: Namespaced to base.surface [cite: 5]

        Process {
            id: netProc

            command: ["bash", "-c", "nmcli -t -f NAME,TYPE,STATE connection show --active 2>/dev/null | grep ':activated' | head -1"]
            running: true

            stdout: SplitParser {
                onRead: (data) => {
                    var parts = data.trim().split(":");
                    if (parts.length < 3) {
                        root.netIcon = "󰖪"; // disconnected [cite: 7, 8]
                        root.netName = "Off";
                        return ;
                    }
                    var type = parts[1];
                    var name = parts[0];
                    if (type === "802-11-wireless") {
                        root.netIcon = "󰤨"; // wifi icon [cite: 10, 11]
                        root.netName = name.split(" "); // first word only [cite: 11, 12]
                    } else if (type === "802-3-ethernet") {
                        root.netIcon = "󰈀"; // ethernet icon [cite: 12, 13]
                        root.netName = "LAN"; // just say LAN [cite: 13, 14]
                    } else {
                        root.netIcon = "󰤨";
                        root.netName = name.split(" ");
                    }
                }
            }

        }

        Timer {
            interval: 15000
            repeat: true
            running: true
            onTriggered: netProc.running = true
        }

        Text {
            id: netLabel

            anchors.centerIn: parent
            text: root.netIcon + " " + root.netName
            color: root.t ? root.t.base.text : "#cdd6f4" // UPGRADED: Namespaced to base.text [cite: 17]

            font {
                pixelSize: root.t ? root.t.fontSize : 13
                family: root.t ? root.t.fontFamily : ""
            }

        }

    }

}
