// ── WIFI PASSWORD CONTROL ─────────────────────────────────────────────────────
// Shows inside CenterPanel when activePage === "wifi-password".
// Standard interactive menu layout: header, password input line, and action button.
// ─────────────────────────────────────────────────────────────────────────────

import "../../services"
import "../../state"
import QtQuick
import QtQuick.Layouts

ColumnLayout {
    id: root

    property var t

    spacing: 2

    // Automatically focus the input line when this view wakes up
    onVisibleChanged: {
        if (visible) {
            passwordInput.text = ""
            passwordInput.forceActiveFocus()
        }
    }

    // ── HEADER ─────────────────────────────────────────────────────────
    Row {
        Layout.alignment: Qt.AlignHCenter
        spacing: 10

        Text {
            text: "CONNECT TO"
            color: t.holo.text
            font.family: t.fontFamily
            font.pixelSize: 20
            font.bold: true
            font.letterSpacing: 2
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            text: PanelState.wifiTarget ? PanelState.wifiTarget.name : ""
            color: t.holo.textAccent
            font.family: t.fontFamily
            font.pixelSize: 20
            font.bold: true
            font.letterSpacing: 2
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    // ── INPUT ROW ──────────────────────────────────────────────────────
    Row {
        Layout.alignment: Qt.AlignHCenter
        spacing: 8

        // ── PASSWORD CONTAINER BOX ──
        Rectangle {
            id: inputBox

            width: 380
            height: 50
            radius: 0
            color: t.holo.holobg
            border.color: passwordInput.activeFocus ? t.holo.neonActive : t.holo.border
            border.width: 1
            
            // Hard scissoring boundary limits for font character leakage
            clip: true 

            Behavior on border.color {
                ColorAnimation { duration: 150 }
            }

            // Placeholder Label
            Text {
                anchors { fill: parent; leftMargin: 14 }
                verticalAlignment: Text.AlignVCenter
                text: "Enter password..."
                color: Qt.rgba(t.holo.text.r, t.holo.text.g, t.holo.text.b, 0.3)
                font.family: t.fontFamily
                font.pixelSize: 15
                visible: passwordInput.text.length === 0 && !passwordInput.activeFocus
            }

            // Interactive Text Element
            TextInput {
                id: passwordInput

                anchors { fill: parent; leftMargin: 14; rightMargin: 14 }
                verticalAlignment: TextInput.AlignVCenter
                echoMode: TextInput.Password
                color: t.holo.textAccent
                selectionColor: Qt.rgba(t.holo.neonActive.r, t.holo.neonActive.g, t.holo.neonActive.b, 0.35)

                font {
                    family: t.fontFamily
                    pixelSize: 15
                    letterSpacing: 2  
                }

                Keys.onReturnPressed: connectAction()
                Keys.onEscapePressed: cancelAction()
            }
        }

        // ── CONNECT ACTION BUTTON ──
        Rectangle {
            id: connectBtn

            width: 120
            height: 50
            radius: 0
            color: connectMouse.containsMouse ? t.holo.bgsel : t.holo.holobg
            border.color: connectMouse.containsMouse ? t.holo.neonActive : t.holo.border
            border.width: 1

            Behavior on color        { ColorAnimation { duration: 150 } }
            Behavior on border.color { ColorAnimation { duration: 150 } }

            Text {
                anchors.centerIn: parent
                text: "CONNECT"
                color: connectMouse.containsMouse ? t.holo.neonActive : t.holo.text
                font.family: t.fontFamily
                font.pixelSize: 14
                font.bold: true
                font.letterSpacing: 1.5

                Behavior on color { ColorAnimation { duration: 150 } }
            }

            MouseArea {
                id: connectMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: connectAction()
            }
        }
    }

    // ── LOGIC WORKFLOWS ────────────────────────────────────────────────

    function connectAction() {
        if (!PanelState.wifiTarget) return
        NetworkService.connectToNetwork(PanelState.wifiTarget, passwordInput.text)
        closePrompt()
    }

    function cancelAction() {
        closePrompt()
    }

    function closePrompt() {
        PanelState.cPanelOpen = false
        PanelState.activePage = "session"
        PanelState.wifiTarget = null
        passwordInput.text = ""
    }
}
