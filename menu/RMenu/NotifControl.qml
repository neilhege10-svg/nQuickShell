import "../../theme"
import QtQuick
import "../../assets"
import "../../services"
import QtQuick.Layouts

//--------------------------------------------------------------------------------------
// ROOT ITEM & LOCAL STATE
//--------------------------------------------------------------------------------------
Item {
    id: root
    property var t

    // Local state to track the visual toggle position.
    // The actual backend logic is handled by the service calls in the onToggled blocks.
    property bool dndProcess: false
    property bool clipboardPaused: false

//--------------------------------------------------------------------------------------
// BACKGROUND CARD
//--------------------------------------------------------------------------------------
    Rectangle {
        anchors.fill: parent
        radius: 14
        color: Qt.rgba(t.base.surface.r, t.base.surface.g, t.base.surface.b, 0.5)
        border.color: t.base.border
        border.width: 1
    }

//--------------------------------------------------------------------------------------
// MAIN CONTENT LAYOUT
//--------------------------------------------------------------------------------------
    ColumnLayout {
        spacing: 10

        anchors {
            fill: parent
            leftMargin: 18
            rightMargin: 18
            topMargin: 14
            bottomMargin: 14
        }

//--------------------------------------------------------------------------------------
// DND (DO NOT DISTURB) ROW
// this section has the UI for the Notifications DND toggle and clearNotifs button
//--------------------------------------------------------------------------------------
        RowLayout {
            Layout.fillWidth: true
            spacing: 16
            // HEADER
            Text {
                text: "DND"
                font.family: t.fontFamily
                font.pixelSize: t.fontSize + 2
                font.bold: true
                font.letterSpacing: 1.5
                color: t.base.text
            }
            // Spacer to push the toggle and button to the right edge
            Item {
                Layout.fillWidth: true
            }
            // DND ToggleSwitch
            ToggleSwitch {
                t: root.t
                checked: root.dndProcess
                onToggled: {
                    root.dndProcess = !root.dndProcess;
                    NotifService.setDND(root.dndProcess);
                }
            }
            // Clear Button 
            BtnRound {
                t: root.t
                icon: "󰆴"
                showShadow: true
                onClicked: NotifService.clearNotifs()
            }
        }

//--------------------------------------------------------------------------------------
// SEPARATOR between the Notifs and Clipboard controls
//--------------------------------------------------------------------------------------
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: t.base.border
            Layout.topMargin: 10
            Layout.bottomMargin: 10
        }

//--------------------------------------------------------------------------------------
// CLIPBOARD PAUSE ROW
// this section has the UI for the ClipHistory pause toggle and clearClipHistory button
//--------------------------------------------------------------------------------------
        RowLayout {
            Layout.fillWidth: true
            spacing: 16
            // HEADER
            Text {
                text: "CLIPBOARD"
                font.family: t.fontFamily
                font.pixelSize: t.fontSize + 2
                font.bold: true
                font.letterSpacing: 1.5
                color: t.base.text
            }
            // Spacer to push the toggle and button to the right edge
            Item {
                Layout.fillWidth: true
            }
            // the switch to turn off the clipboard
            ToggleSwitch {
                t: root.t
                checked: root.clipboardPaused
                onToggled: {
                    root.clipboardPaused = !root.clipboardPaused;
                    ClipboardService.setClipboardPaused(root.clipboardPaused);
                }
            }
            // Clear Button 
            BtnRound {
                t: root.t
                icon: "󰆴"
                showShadow: true
                onClicked: ClipboardService.clearClips()
            }
        }
    }
}
