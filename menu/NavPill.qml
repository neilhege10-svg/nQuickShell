import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Mpris
import Qt5Compat.GraphicalEffects
import "../state"
import "../services"
import "../assets"

// ── NAVPILL ─────────────────────────────────────
// Adaptive navigation section below every page.
// ────────────────────────────────────────────────

Rectangle {
    id: root

    property var t
    property string displayedPage: PanelState.currentPage
    property real contextOpacity: 1

    readonly property var activePlayer: {
        var players = Mpris.players.values
        for (var i = 0; i < players.length; ++i) {
            if (players[i].isPlaying)
                return players[i]
        }
        for (var j = 0; j < players.length; ++j) {
            if (players[j].playbackState === MprisPlaybackState.Paused)
                return players[j]
        }
        for (var k = 0; k < players.length; ++k) {
            if (players[k].canControl)
                return players[k]
        }
        return null
    }

    height: root.t ? root.t.btnHeight + 12 : 42
    radius: root.t ? root.t.widgetRadius + 2 : 14

    color: root.t ? root.t.base.surface : "#1f1f1f"
    border.width: 1
    border.color: root.t ? root.t.base.border : "#5d6170"

    RowLayout {
        anchors.fill: parent
        anchors.margins: 6
        spacing: 10

        // ── UNIVERSAL NAVIGATION ─────────────────
        Row {
            spacing: 6
            Layout.alignment: Qt.AlignVCenter

            BtnRound {
                t: root.t
                imageSource: Qt.resolvedUrl("../svg/power.svg")
                activeState: PanelState.currentPage === "main"
                onClicked: PanelState.currentPage = "main"
            }

            BtnRound {
                t: root.t
                imageSource: Qt.resolvedUrl("../svg/picture.svg")
                activeState: PanelState.currentPage === "wallpaper"
                onClicked: PanelState.currentPage = "wallpaper"
            }
        }

        // Faint divider between universal and contextual content.
        Rectangle {
            Layout.preferredWidth: 1
            Layout.fillHeight: true
            Layout.topMargin: 5
            Layout.bottomMargin: 5
            color: root.t ? root.t.base.border : "#5d6170"
            opacity: 0.45
        }

        // ── WALLPAPER SEARCH ─────────────────────
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumWidth: 0

            radius: root.t ? root.t.widgetRadius - 4 : 8
            color: root.t ? root.t.base.bg : "#171717"
            border.width: 1
            border.color: root.t ? root.t.base.border : "#454545"

            visible: root.displayedPage === "wallpaper"
            opacity: root.contextOpacity

            Behavior on opacity {
                NumberAnimation {
                    duration: 220
                    easing.type: Easing.InOutCubic
                }
            }

            TextInput {
                id: searchInput
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                verticalAlignment: TextInput.AlignVCenter

                color: root.t ? root.t.base.text : "#e6e6e6"
                font.pixelSize: 13
                font.family: root.t
                            ? root.t.fontFamily
                            : "JetBrainsMono Nerd Font"

                onTextChanged: WallpaperService.searchQuery = text

                Text {
                    anchors.fill: parent
                    verticalAlignment: Text.AlignVCenter
                    text: "Search wallpapers..."
                    color: root.t
                           ? root.t.base.textInactive
                           : "#6e6e6e"
                    font: parent.font
                    visible: parent.text.length === 0
                             && !parent.activeFocus
                }
            }
        }

        // ── WALLPAPER REFRESH ────────────────────
        Row {
            spacing: 6
            Layout.alignment: Qt.AlignVCenter

            visible: root.displayedPage === "wallpaper"
            opacity: root.contextOpacity

            Behavior on opacity {
                NumberAnimation {
                    duration: 220
                    easing.type: Easing.InOutCubic
                }
            }

            BtnRound {
                t: root.t
                icon: "󰑐"
                onClicked: {
                    WallpaperService.searchQuery = ""
                    searchInput.text = ""
                    WallpaperService.rescan()
                }
            }
        }

        // ── MPRIS MEDIA DOCK ─────────────────────
        RowLayout {
            id: mediaDock

            // Give the media section room to shrink when needed.
            Layout.fillWidth: true
            Layout.minimumWidth: 0
            Layout.fillHeight: true
            spacing: 8

            visible: root.displayedPage === "main"
            opacity: root.contextOpacity

            Behavior on opacity {
                NumberAnimation {
                    duration: 220
                    easing.type: Easing.InOutCubic
                }
            }

            // Artwork with SVG fallback.
            Rectangle {
                Layout.preferredWidth: 30
                Layout.preferredHeight: 30
                Layout.alignment: Qt.AlignVCenter

                radius: 6
                color: root.t ? root.t.base.bg : "#171717"
                clip: true

                Image {
                    id: albumArt
                    anchors.fill: parent
                    source: root.activePlayer
                            ? root.activePlayer.trackArtUrl
                            : ""
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    cache: false
                    visible: status === Image.Ready
                }

                Image {
                    id: musicNote
                    anchors.centerIn: parent
                    width: 16
                    height: 16
                    source: Qt.resolvedUrl("../svg/music-note.svg")
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                    visible: !albumArt.visible

                    layer.enabled: true
                    layer.effect: ColorOverlay {
                        color: root.t ? root.t.base.textInactive : "#8e98ab"
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.minimumWidth: 0
                spacing: 2

                Text {
                    Layout.fillWidth: true
                    Layout.minimumWidth: 0

                    text: root.activePlayer
                          ? (root.activePlayer.trackTitle
                             || root.activePlayer.identity
                             || "Unknown track")
                          : "Nothing playing"

                    color: root.t ? root.t.base.text : "#e6e6e6"
                    font.family: root.t
                                ? root.t.fontFamily
                                : "JetBrainsMono Nerd Font"
                    font.pixelSize: 11
                    elide: Text.ElideRight
                }

                Text {
                    Layout.fillWidth: true
                    Layout.minimumWidth: 0

                    text: root.activePlayer
                          ? (root.activePlayer.trackArtist
                             || root.activePlayer.trackAlbum
                             || root.activePlayer.identity)
                          : "Start a media player"

                    color: root.t
                           ? root.t.base.textInactive
                           : "#6e6e6e"
                    font.family: root.t
                                ? root.t.fontFamily
                                : "JetBrainsMono Nerd Font"
                    font.pixelSize: 9
                    elide: Text.ElideRight
                }
            }

            Row {
                spacing: 4
                Layout.alignment: Qt.AlignVCenter

                BtnRound {
                    t: root.t
                    visualSize : 13

                    imageSource: Qt.resolvedUrl("../svg/media-backward.svg")
                    enabled: !!root.activePlayer
                             && root.activePlayer.canGoPrevious
                    onClicked: {
                        if (root.activePlayer)
                            root.activePlayer.previous()
                    }
                }

                BtnRound {
                    t: root.t
                    visualSize : 13

                    imageSource: Qt.resolvedUrl(
                        root.activePlayer && root.activePlayer.isPlaying
                            ? "../svg/media-pause.svg"
                            : "../svg/media-play.svg"
                    )

                    enabled: !!root.activePlayer
                             && root.activePlayer.canTogglePlaying
                    onClicked: {
                        if (root.activePlayer)
                            root.activePlayer.togglePlaying()
                    }
                }

                BtnRound {
                    t: root.t
                    visualSize : 13

                    imageSource: Qt.resolvedUrl("../svg/media-forward.svg")
                    enabled: !!root.activePlayer
                             && root.activePlayer.canGoNext
                    onClicked: {
                        if (root.activePlayer)
                            root.activePlayer.next()
                    }
                }
            }
        }

        // Divider between media and right-side contextual actions.
        Rectangle {
            Layout.preferredWidth: 1
            Layout.fillHeight: true
            Layout.topMargin: 5
            Layout.bottomMargin: 5
            color: root.t ? root.t.base.border : "#5d6170"
            opacity: 0.45
            visible: root.displayedPage === "main"
        }

        // ── RIGHT-SIDE PLACEHOLDER ACTIONS ───────
        Row {
            spacing: 4
            Layout.alignment: Qt.AlignVCenter

            visible: root.displayedPage === "main"

            BtnRound {
                t: root.t
                imageSource: Qt.resolvedUrl("../svg/volume-1.svg")
            }

            BtnRound {
                t: root.t
                imageSource: Qt.resolvedUrl("../svg/volume-2.svg")
            }

            BtnRound {
                t: root.t
                imageSource: Qt.resolvedUrl("../svg/volume-x.svg")
            }
        }
    }
}
