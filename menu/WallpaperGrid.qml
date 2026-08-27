import "../services"
import QtQuick

// ── WallpaperGrid ─────────────────────────────────────────────────────
// The wallpaper switcher's actual content. Binds directly to
// WallpaperService.wallpapers (populated by its scan) and calls
// WallpaperService.applyWallpaper(path) on click.
//
// Usage: WallpaperGrid { t: theme }
// ─────────────────────────────────────────────────────────────────────
Rectangle {
    id: root

    property var t

    // Grid container background using theme surface
    color: root.t ? root.t.base.surface : "#1f1f1f"
    radius: root.t ? root.t.widgetRadius : 8
    clip: true

    Component.onCompleted: WallpaperService.rescan()

//-----------------------------------------------------------------------------------
// Empty state — shown while nothing's been found yet
//-----------------------------------------------------------------------------------
    Text {
        anchors.centerIn: parent
        visible: WallpaperService.wallpapers.length === 0
        text: "No wallpapers found in " + WallpaperService.wallpaperDir
        color: root.t ? root.t.base.text : "#cdd6f4"
        opacity: 0.6
        wrapMode: Text.WordWrap
        width: parent.width * 0.8
        horizontalAlignment: Text.AlignHCenter
    }

//-----------------------------------------------------------------------------------
// The grid itself
//-----------------------------------------------------------------------------------
    GridView {
        id: grid

        anchors.fill: parent
        anchors.margins: 8 // Clean inset padding around the whole grid
        visible: WallpaperService.wallpapers.length > 0
        clip: true

        flow: GridView.FlowTopToBottom

        // 16:9 Aspect ratio card dimensions
        cellWidth: width / 4
        cellHeight: cellWidth * (9 / 16)

        model: WallpaperService.wallpapers

        WheelHandler {
            onWheel: event => {
                grid.contentX = Math.max(0, Math.min(grid.contentWidth - grid.width, grid.contentX - event.angleDelta.y));
            }
        }

        delegate: Item {
            width: grid.cellWidth
            height: grid.cellHeight

            Rectangle {
                id: card

                anchors.fill: parent
                anchors.margins: 4
                radius: root.t ? root.t.widgetRadius - 4 : 6
                color: "#111111"
                clip: true

                border.width: modelData.path === WallpaperService.currentWallpaper ? 2 : 0
                border.color: root.t ? root.t.base.accent : "#89b4fa"

                Behavior on border.width {
                    NumberAnimation {
                        duration: 150
                    }
                }

                Image {
                    anchors.fill: parent
                    source: "file://" + modelData.thumb
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    cache: true
                }

//-----------------------------------------------------------------------------------
// Name label, bottom overlay strip
//-----------------------------------------------------------------------------------
                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    height: 22
                    color: "#000000aa"

                    Text {
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                        text: modelData.name
                        color: "white"
                        font.pixelSize: 11
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: WallpaperService.applyWallpaper(modelData.path)
                }
            }
        }
    }
}
