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

//-----------------------------------------------------------------------------------
// Tell the Bar's RowLayout exactly how much space this module needs
//-----------------------------------------------------------------------------------
    implicitHeight: t ? t.pillHeight : 32
    implicitWidth: (root.t ? root.t.fontSize + 4 : 18) + (4 * 2)

//-----------------------------------------------------------------------------------
// this is the Glow effect, it activates when the module is clicked
// by using PanelState in the opacity
//-----------------------------------------------------------------------------------
    DropShadow {
        anchors.fill: pill
        horizontalOffset: 3
        verticalOffset: 2
        radius: 8
        samples: 17
        color: "#000000"
        source: pill
        opacity: PanelState.rPanelOpen && PanelState.rPanelPage === "network" ? 1 : 0

        // animation for the shadow on the module
        Behavior on opacity {
            NumberAnimation {
                duration: 200
                easing.type: Easing.InOutQuad
            }

        }

    }

//-----------------------------------------------------------------------------------
// Main shape and design of the Network module
//-----------------------------------------------------------------------------------
    Rectangle {
        id: pill

        anchors.fill: parent
        radius: PanelState.rPanelOpen && PanelState.rPanelPage === "network" ? (t ? t.widgetRadius : 12) : (t ? t.widgetRadius : 12)
        color: PanelState.rPanelOpen && PanelState.rPanelPage === "network" ? (t ? t.base.accent : "#b4befe") : ("transparent")
        scale: mouseArea.pressed ? 0.9 : 1
        
//-----------------------------------------------------------------------------------
// Main Process of the Network module
//-----------------------------------------------------------------------------------
        Process {
            id: netProc

            command: ["bash", "-c", "nmcli -t -f NAME,TYPE,STATE connection show --active 2>/dev/null | grep ':activated' | head -1"]
            running: true

            stdout: SplitParser {
                onRead: (data) => {
                    var parts = data.trim().split(":");
                    if (parts.length < 3) {
                        root.netIcon = "󰖪";
                        root.netName = "Off";
                        return ;
                    }
                    var type = parts[1];
                    var name = parts[0];
                    if (type === "802-11-wireless") {
                        root.netIcon = "󰤨";
                        root.netName = name.split(" ");
                    } else if (type === "802-3-ethernet") {
                        root.netIcon = "󰤨"; 
                        root.netName = "LAN"; 
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

//-----------------------------------------------------------------------------------
// Main Text design of the Network module
//-----------------------------------------------------------------------------------
        Image {
            id: netLabel

            //if you to display the Wifi name change the text to "text: root.netIcon + " " + root.netName"

            source: "../svg/wifi-high.svg"
            width: root.t? root.t.fontSize + 4 : 18
            height: width

            anchors.centerIn: parent
            anchors.verticalCenterOffset: -2

            layer.enabled: true
            layer.effect: ColorOverlay {
              color: PanelState.rPanelOpen && PanelState.rPanelPage === "audio" ? (root.t ? root.t.base.textAccent : "#11111b") : (root.t ? root.t.base.text : "#cdd6f4")

              Behavior on color {
                ColorAnimation {
                  duration: 400
                }

              }
            }

        }

        // animation for the color of the module
        Behavior on color {
            ColorAnimation {
                duration: 330
            }

        }

        //animation for the radius of the module
        Behavior on radius {
            NumberAnimation {
                duration: 330
            }

        }

    }

//-----------------------------------------------------------------------------------
// The mouseArea section is what makes the module CLICKABLE by using onClicked property
// it changes the panelstate and other sections of the code can use the panelstate
// to change the button's visual
//-----------------------------------------------------------------------------------
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
