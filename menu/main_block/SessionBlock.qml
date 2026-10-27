
import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import "../../assets"
import "../../services"

//Main BG of the SessionBlock
Rectangle {
    id: root

    property var t

    readonly property color panelColor:
        t ? t.base.surface : "#1f1f1f"
    readonly property color primaryText:
        t ? t.base.text : "#e6e6e6"
    readonly property color mutedText:
        t ? t.base.textInactive : "#6e6e6e"
    readonly property color accent:
        t ? t.base.accent : "#03befc"
    readonly property string uiFont:
        t ? t.fontFamily : "JetBrainsMono Nerd Font"

    color: panelColor
    radius: t ? t.widgetRadius : 12
    clip: true

// -- HEADER -------------------- 
// this is the Header, it utilizes both column and row layouts
// to organize the Header design
// -------------------------------

    // Main ColumnLayout, organizes the Header and the Session Buttons
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 10

        // ── HEADER ──────────────────────────────
        Item {
            id: sessionHeader
            Layout.fillWidth: true
            Layout.preferredHeight: 38

            // Blue accent line
            Rectangle {
                id: headerAccent
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter

                width: 3
                height: 22
                radius: 2
                color: root.accent
            }

            // Header and subtitle
            Column {
                anchors.left: headerAccent.right
                anchors.leftMargin: 8
                anchors.right: profilePicture.left
                anchors.rightMargin: 12
                anchors.verticalCenter: parent.verticalCenter

                spacing: 1

                Text {
                    text: "SESSION"
                    color: root.primaryText
                    font.family: root.uiFont
                    font.pixelSize: root.t ? root.t.fontSize : 13
                    font.bold: true
                    font.letterSpacing: 1.2
                }

                Text {
                    text: "Power and System actions"
                    color: root.mutedText
                    font.family: root.uiFont
                    font.pixelSize: 10
                }
            }

            // Profile picture: explicitly anchored to the far right
            Rectangle {
                id: profilePicture
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter

                width: 42
                height: 42
                radius: width / 2
                color: "transparent"
                border.color: root.accent
                border.width: 2

                Image {
                    anchors.fill: parent
                    anchors.margins: 2

                    source: Qt.resolvedUrl("../../img/PFP-Pixel.jpg")
                    fillMode: Image.PreserveAspectCrop
                    smooth: true
                    mipmap: true
                    sourceSize.width: 256
                    sourceSize.height: 256

                    layer.enabled: true
                    layer.effect: OpacityMask {
                        maskSource: Rectangle {
                            width: 34
                            height: 34
                            radius: width / 2
                        }
                    }
                }
            }
        }

// Seperator Line between the Header and the ActionTiles
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1

            color: root.t ? root.t.base.border : "#454545"
        }

// -- SESSION BUTTONS ----------------
// this is the main part of this QML, its the Power, restart, Suspend and Lock screen BUTTONS
// it uses ActionTile.qml from the Assets folder
// and the onClicked properties are pulled from SessionService.qml
// -----------------------------------
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 8

            // Existing four actions keep their familiar 2x2 arrangement.
            GridLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumWidth: 0

                columns: 2
                columnSpacing: 8
                rowSpacing: 8

                ActionTile {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.minimumHeight: 48
                    t: root.t
                    iconSource: Qt.resolvedUrl("../../svg/power.svg")
                    label: "Power Off"
                    onClicked: SessionService.requestConfirmation("poweroff")
                }

                ActionTile {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.minimumHeight: 48
                    t: root.t
                    iconSource: Qt.resolvedUrl("../../svg/rotate-ccw.svg")
                    label: "Restart"
                    onClicked: SessionService.requestConfirmation("reboot")
                }

                ActionTile {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.minimumHeight: 48
                    t: root.t
                    iconSource: Qt.resolvedUrl("../../svg/moon.svg")
                    label: "Suspend"
                    onClicked: SessionService.suspend()
                }

                ActionTile {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.minimumHeight: 48
                    t: root.t
                    iconSource: Qt.resolvedUrl("../../svg/lock.svg")
                    label: "Lock Screen"
                    onClicked: SessionService.lock()
                }
            }

            // Dedicated logout tile: wider than the old ActionTile version,
            // with a quieter treatment so it feels distinct from the four main actions.
            Rectangle {
                id: logoutTile
                Layout.preferredWidth: 86
                Layout.minimumWidth: 86
                Layout.maximumWidth: 112
                Layout.fillHeight: true
                Layout.minimumHeight: 48

                radius: 9
                readonly property color tileColor:
                    root.t ? root.t.holo.holobg : "#1a3e78d6"
                readonly property color tileHover:
                    root.t ? root.t.holo.neonActive : "#a603cffc"
                readonly property color tileBorder:
                    root.t ? root.t.holo.neon : "#5903cffc"

                color: logoutMouse.containsMouse ? tileHover : tileColor
                border.color: logoutMouse.containsMouse
                    ? (root.t ? root.t.base.accent : "#03befc")
                    : tileBorder
                border.width: 1

                Behavior on color {
                    ColorAnimation { duration: 140 }
                }
                Behavior on border.color {
                    ColorAnimation { duration: 140 }
                }

                Column {
                    anchors.centerIn: parent
                    width: parent.width - 12
                    spacing: 8

                    Image {
                        id: logoutIcon
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: 28
                        height: 28
                        source: Qt.resolvedUrl("../../svg/square-arrow-right-exit.svg")
                        sourceSize.width: 28
                        sourceSize.height: 28
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                        mipmap: true

                        layer.enabled: true
                        layer.effect: ColorOverlay {
                            color: root.accent
                        }
                    }

                    Text {
                        width: parent.width
                        text: "Log Out"
                        color: root.primaryText
                        font.family: root.uiFont
                        font.pixelSize: 10
                        horizontalAlignment: Text.AlignHCenter
                        elide: Text.ElideRight
                    }
                }

                MouseArea {
                    id: logoutMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: SessionService.logout()
                }
            }
        }
    }
}
