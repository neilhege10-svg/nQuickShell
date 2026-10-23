import QtQuick
import QtQuick.Layouts
import "../state"
import "../services"
import "../assets"

// ── NAVPILL─────────────────────────────────────
// this is the NavPill,it sits inside of the ShellPanel/PanelShape, and just under EVERY page
// it serves as an adaptive Navigation section, that changes depending on the page/pages need
// ───────────────────────────────────────────────

Rectangle {
    id: root

    property var t

// Declared Height and radius, and other properties of the universal buttons
    height: root.t ? root.t.btnHeight + 12 : 42
    radius: root.t ? root.t.widgetRadius : 12

    color: root.t ? root.t.base.surface : "#1f1f1f"
    border.width: 0
// main Row layout, sorts out the universal buttons alongside local components 
// from each page into a Row
    RowLayout {
        anchors.fill: parent
        anchors.margins: 6
        spacing: 12

// Universal Buttons, that serves as a way to switch between Pages, in the ShellPanel
        Row {
            spacing: 6
            Layout.alignment: Qt.AlignVCenter

            BtnRound {
                t: root.t
                icon: "󰕮" // Nerd Font Home/Main icon
                activeState: PanelState.currentPage === "main"
                onClicked: PanelState.currentPage = "main"
            }
            
            BtnRound {
                t: root.t
                icon: "󰸉" // Nerd Font Image/Wallpaper icon
                activeState: PanelState.currentPage === "wallpaper"
                onClicked: PanelState.currentPage = "wallpaper"
            }
        }

// ── WALLPAPER NAV 1 ─────────────────────────────────────
// DEDICATED SEARCH BAR FOR THE WALLPAPER PAGE
// ──────────────────────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: root.t ? root.t.widgetRadius - 4 : 8
            
            // Slightly darker background to inset the search field
            color: root.t ? root.t.base.bg : "#171717"
            border.width: 1
            border.color: root.t ? root.t.base.border : "#454545"
            
            // Only show the search bar when the wallpaper page is active
            visible: PanelState.currentPage === "wallpaper"

            TextInput {
                id: searchInput
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                verticalAlignment: TextInput.AlignVCenter
                
                color: root.t ? root.t.base.text : "#e6e6e6"
                font.pixelSize: 13
                font.family: root.t ? root.t.fontFamily : "JetBrainsMono Nerd Font"
                
                // Real-time filtering as you type
                onTextChanged: WallpaperService.searchQuery = text

                Text {
                    anchors.fill: parent
                    verticalAlignment: Text.AlignVCenter
                    text: "Search wallpapers..."
                    color: root.t ? root.t.base.textInactive : "#6e6e6e"
                    font: parent.font
                    // Hide placeholder when typing or focused
                    visible: parent.text.length === 0 && !parent.activeFocus
                }
            }
        }

// ── WALLPAPER NAV 2 ─────────────────────────────────────
// DEDICATED REFRESH BUTTON FOR THE WALLPAPER PAGE
// ──────────────────────────────────────────────────────
        Row {
            spacing: 6
            Layout.alignment: Qt.AlignVCenter
            
            // Contextual buttons only appear when their specific menu is open
            visible: PanelState.currentPage === "wallpaper"

            BtnRound {
                t: root.t
                icon: "󰑐" // Nerd Font Refresh icon
                onClicked: {
                    // Clear the search and rescan the directory
                    WallpaperService.searchQuery = ""
                    searchInput.text = ""
                    WallpaperService.rescan()
                }
            }
        }
    }
}
