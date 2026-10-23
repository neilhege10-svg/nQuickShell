
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// -- SessionBlock.QML Services ---------------------------- 
// i hate services.
// ----------------------------------------------------------

Item {
    id: root

    visible: false
    width: 0
    height: 0

    property string pendingAction: ""
    property bool confirmationVisible: false

    signal actionFailed(string action, int exitCode)

    Process {
        id: poweroffProcess
        command: ["systemctl", "poweroff"]

        onExited: (exitCode, exitStatus) => {
            running = false
            if (exitCode !== 0)
                root.actionFailed("poweroff", exitCode)
        }
    }

    Process {
        id: rebootProcess
        command: ["systemctl", "reboot"]

        onExited: (exitCode, exitStatus) => {
            running = false
            if (exitCode !== 0)
                root.actionFailed("reboot", exitCode)
        }
    }

    Process {
        id: suspendProcess
        command: ["systemctl", "suspend"]

        onExited: (exitCode, exitStatus) => {
            running = false
            if (exitCode !== 0)
                root.actionFailed("suspend", exitCode)
        }
    }

    Process {
        id: lockProcess
        command: ["hyprlock"]

        onExited: (exitCode, exitStatus) => {
            running = false
            if (exitCode !== 0)
                root.actionFailed("lock", exitCode)
        }
    }

    function requestConfirmation(action) {
        if (poweroffProcess.running ||
            rebootProcess.running ||
            suspendProcess.running ||
            lockProcess.running)
            return

        if (action !== "poweroff" && action !== "reboot")
            return

        pendingAction = action
        confirmationVisible = true
    }

    function cancelConfirmation() {
        confirmationVisible = false
        pendingAction = ""
    }

    function confirmAction() {
        if (!confirmationVisible)
            return

        const action = pendingAction

        confirmationVisible = false
        pendingAction = ""

        if (action === "poweroff")
            poweroffProcess.running = true
        else if (action === "reboot")
            rebootProcess.running = true
    }

    function suspend() {
        if (!poweroffProcess.running &&
            !rebootProcess.running &&
            !suspendProcess.running &&
            !lockProcess.running)
            suspendProcess.running = true
    }

    function lock() {
        if (!poweroffProcess.running &&
            !rebootProcess.running &&
            !suspendProcess.running &&
            !lockProcess.running)
            lockProcess.running = true
    }
}
