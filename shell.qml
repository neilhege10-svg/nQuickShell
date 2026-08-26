import Quickshell
import "bar"
import "menu/RMenu"
import "menu/SessionMenu"
import "menu/SettingMenu"
import "menu"

ShellRoot {
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

        delegate: RightPanel {
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
