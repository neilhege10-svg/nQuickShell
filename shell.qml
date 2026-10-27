import Quickshell
import "bar"
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

        delegate: ShellPanel {
            required property var modelData

            targetScreen: modelData
        }
    }
}
