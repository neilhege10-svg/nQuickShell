import Quickshell
import "bar"
import "menu/RMenu"
import "menu/SessionMenu"
import "menu/SettingMenu"
import "menu"
import "services"

ShellRoot {
// Inside your main shell.qml / root element
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

        delegate: SettingPanel {
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
