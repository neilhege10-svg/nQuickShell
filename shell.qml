import Quickshell
import "bar"
import "menu/RMenu"
import "menu/SessionMenu"
import "menu/SettingMenu"
import "menu"
import "services"

ShellRoot {

// Launches wallpaper on launch
property var initWallpaper: WallpaperService

    Variants {
        model: Quickshell.screens

        delegate: Bar {
            required property var modelData

            targetScreen: modelData
        }

    }
   

    Variants {
        model: Quickshell.screens

        delegate: ShellPanel {
            required property var modelData

            targetScreen: modelData
        }

    }

}
