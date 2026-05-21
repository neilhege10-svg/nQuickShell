import QtQuick
import QtQuick.Layouts

RowLayout {
    id: root

    property var t

    spacing: 55

    SessionButton {
        icon: "󰐥"
        label: "Shutdown"
        cmd: "systemctl poweroff"
        t: root.t
    }

    SessionButton {
        icon: "󰑓"
        label: "Reboot"
        cmd: "systemctl reboot"
        t: root.t
    }

    SessionButton {
        icon: "󰌾"
        label: "Lock"
        cmd: "hyprlock"
        t: root.t
    }

    SessionButton {
        icon: "󰍃"
        label: "Logout"
        cmd: "hyprctl dispatch 'hl.dsp.exit()'"
        t: root.t
    }

}
