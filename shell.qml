import Quickshell
import "bar"
import "menu/RMenu"
import "menu/SessionMenu"
import "menu/SettingMenu"

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

        delegate: CenterPanel {
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

}
