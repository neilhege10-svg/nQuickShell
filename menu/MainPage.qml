
import QtQuick
import QtQuick.Layouts
import "main_block"
import "../services"

// -- MAIN PAGE -------------------------------------
// This qml is the MainPage of the main control panel UI 
// it seperates each of the Control panels into its own dedicated block
// and organizes them
// --------------------------------------------------

Item {
    id: root

    property var t
// --------------------------------------------------
// Main ColumnLayout, that organizes the blocks,
// it nests a column and rowlayout inside of a column layout,
// seperating into a top half and a bottom half
// --------------------------------------------------
    ColumnLayout {
        anchors.fill: parent
        spacing: 12

        // Top half
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumHeight: 0
            spacing: 12


            SessionBlock {
                t: root.t
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumHeight: 0
                Layout.preferredWidth: 1.15
            }

            QuickToggleBlock {
              t: root.t
              Layout.fillWidth: true
              Layout.fillHeight: true
              Layout.minimumHeight: 0
              Layout.preferredWidth: 2
            }
        }

      // Bottom half
      RowLayout {
          Layout.fillWidth: true
          Layout.fillHeight: true
          Layout.minimumHeight: 0
          spacing: 12

        StatsBlock {
            t: root.t
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumHeight: 0
            Layout.preferredHeight: 1
          }

        AudioBlock {
          t: root.t
          Layout.fillWidth: true
          Layout.fillHeight: true
          Layout.minimumWidth: 0
          Layout.minimumHeight: 0
          Layout.preferredWidth: 0.5
        }

      }

    }

// --OVERLAY for SessionBlock.qml------------------------------------------------
// this shit... is a pain in the ass that i dont understand
// its an overlay specifically for the SessionBlock.qml
// when you click on the power/restart buttom, it dimns the entire page's bg and summons an overlay
// a confirmation button, so that we dont accidentally shutdown the entire f'ing PC
// --------------------------------------------------
    Rectangle {
        id: confirmationOverlay

        property bool overlayShown: false

        anchors.fill: parent
        z: 100
        visible: overlayShown

        opacity: SessionService.confirmationVisible ? 1 : 0

        color: root.t
            ? Qt.rgba(
                root.t.base.bg.r,
                root.t.base.bg.g,
                root.t.base.bg.b,
                0.62
            )
            : "#9e171717"

        Behavior on opacity {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutCubic
            }
        }

        // Keep the overlay alive until the fade-out finishes.
        onOpacityChanged: {
            if (opacity === 0 && !SessionService.confirmationVisible)
                overlayShown = false
        }

        Connections {
            target: SessionService

            function onConfirmationVisibleChanged() {
                if (SessionService.confirmationVisible)
                    confirmationOverlay.overlayShown = true
            }
        }

        Component.onCompleted: {
            overlayShown = SessionService.confirmationVisible
        }

        // Consume clicks so the underlying page cannot be used.
        MouseArea {
            anchors.fill: parent
            onClicked: {}
        }

        // Confirmation dialog
        Rectangle {
            id: dialog

            anchors.centerIn: parent
            width: Math.min(parent.width - 32, 310)
            height: content.implicitHeight + 32

            radius: root.t ? root.t.widgetRadius : 12
            color: root.t ? root.t.base.surface : "#1f1f1f"
            border.width: 1
            border.color: root.t
                ? root.t.holo.neon
                : "#5903cffc"

            opacity: SessionService.confirmationVisible ? 1 : 0
            scale: SessionService.confirmationVisible ? 1 : 0.96

            Behavior on opacity {
                NumberAnimation {
                    duration: 180
                    easing.type: Easing.OutCubic
                }
            }

            Behavior on scale {
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.OutCubic
                }
            }

            ColumnLayout {
                id: content

                anchors.fill: parent
                anchors.margins: 16
                spacing: 10

                Text {
                    Layout.fillWidth: true

                    text: SessionService.pendingAction === "poweroff"
                        ? "Shut down this computer?"
                        : "Restart this computer?"

                    color: root.t ? root.t.base.text : "#e6e6e6"
                    font.family: root.t
                        ? root.t.fontFamily : "JetBrainsMono Nerd Font"
                    font.pixelSize: 13
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                }

                Text {
                    Layout.fillWidth: true

                    text: SessionService.pendingAction === "poweroff"
                        ? "Your current session will end."
                        : "Your current session will close."

                    color: root.t
                        ? root.t.base.textInactive : "#6e6e6e"
                    font.family: root.t
                        ? root.t.fontFamily : "JetBrainsMono Nerd Font"
                    font.pixelSize: 10
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    // Cancel button
                    Rectangle {
                        id: cancelButton

                        Layout.fillWidth: true
                        Layout.preferredHeight: 32

                        radius: 7

                        color: cancelMouse.containsMouse
                            ? (root.t
                                ? root.t.holo.neonActive : "#a603cffc")
                            : (root.t
                                ? root.t.holo.holobg : "#1a3e78d6")

                        border.width: 1
                        border.color: cancelMouse.containsMouse
                            ? (root.t
                                ? root.t.holo.neonActive : "#a603cffc")
                            : (root.t
                                ? root.t.holo.neon : "#5903cffc")

                        Behavior on color {
                            ColorAnimation {
                                duration: 140
                                easing.type: Easing.OutCubic
                            }
                        }

                        Behavior on border.color {
                            ColorAnimation {
                                duration: 140
                                easing.type: Easing.OutCubic
                            }
                        }

                        Text {
                            anchors.centerIn: parent

                            text: "Cancel"
                            color: root.t
                                ? root.t.base.text : "#e6e6e6"
                            font.family: root.t
                                ? root.t.fontFamily
                                : "JetBrainsMono Nerd Font"
                            font.pixelSize: 11
                        }

                        MouseArea {
                            id: cancelMouse

                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor

                            onClicked: {
                                SessionService.cancelConfirmation()
                            }
                        }
                    }

                    // Confirm button
                    Rectangle {
                        id: confirmButton

                        Layout.fillWidth: true
                        Layout.preferredHeight: 32

                        radius: 7

                        color: confirmMouse.containsMouse
                            ? (root.t
                                ? root.t.holo.warningActive : "#ffff5555")
                            : (root.t
                                ? root.t.holo.warningBgSel : "#4dff5555")

                        border.width: 1
                        border.color: confirmMouse.containsMouse
                            ? (root.t
                                ? root.t.holo.warningText : "#ff7777")
                            : (root.t
                                ? root.t.holo.warningText : "#ff5555")

                        Behavior on color {
                            ColorAnimation {
                                duration: 140
                                easing.type: Easing.OutCubic
                            }
                        }

                        Behavior on border.color {
                            ColorAnimation {
                                duration: 140
                                easing.type: Easing.OutCubic
                            }
                        }

                        Text {
                            anchors.centerIn: parent

                            text: SessionService.pendingAction === "poweroff"
                                ? "Shut down" : "Restart"

                            color: root.t
                                ? root.t.base.text : "#e6e6e6"
                            font.family: root.t
                                ? root.t.fontFamily
                                : "JetBrainsMono Nerd Font"
                            font.pixelSize: 11
                            font.bold: true
                        }

                        MouseArea {
                            id: confirmMouse

                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor

                            onClicked: {
                                SessionService.confirmAction()
                            }
                        }
                    }
                }
            }
        }
    }
}
