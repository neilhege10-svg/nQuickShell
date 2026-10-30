import Quickshell.Io
import Quickshell
import "bar"
import "menu"
import "services"
import "state"

ShellRoot {
    // Initialize wallpaper scanning and restore before opening the panel.
    property var initWallpaper: WallpaperService

    IpcHandler {
      target: "panel"

      function toggleWallpaper(): void {
        PanelState.toggle("wallpaper")
      }

      function toggleMain(): void {
        PanelState.toggle("main")
      }

    }

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
