import "../state"
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

    DropShadow {
        anchors.fill: pill
        horizontalOffset: 3
        verticalOffset: 2
        radius: 8
        samples: 17
        color: "#000000"
        source: pill
        opacity: PanelState.rPanelOpen && PanelState.rPanelPage === "network" ? 1 : 0

        Behavior on opacity {
            NumberAnimation {
                duration: 200
                easing.type: Easing.InOutQuad
            }

        }

    }

    Rectangle {
        id: pill

        anchors.fill: parent
        radius: PanelState.rPanelOpen && PanelState.rPanelPage === "network" ? 12 : (t ? t.widgetRadius : 8)
        color: PanelState.rPanelOpen && PanelState.rPanelPage === "network" ? (t ? t.base.accent : "#b4befe") : (t ? t.base.surface : "#313244")
        scale: mouseArea.pressed ? 0.9 : 1

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
            color: PanelState.rPanelOpen && PanelState.rPanelPage === "network" ? (root.t ? root.t.base.textActive : "#11111b") : (root.t ? root.t.base.text : "#cdd6f4")

            font {
                pixelSize: root.t ? root.t.fontSize : 13
                family: root.t ? root.t.fontFamily : ""
            }

            Behavior on color {
                ColorAnimation {
                    duration: 400
                }

            }

        }

        Behavior on color {
            ColorAnimation {
                duration: 330
            }

        }

        Behavior on radius {
            NumberAnimation {
                duration: 330
            }

        }

    }

    MouseArea {
        id: mouseArea

        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            if (!PanelState.rPanelOpen) {
                // If the panel is closed, open it and set the page
                PanelState.rPanelOpen = true;
                PanelState.rPanelPage = "network";
            } else {
                // If it's already open, just make sure it switches to the network page
                PanelState.rPanelPage = "network";
            }
        }
    }

}
