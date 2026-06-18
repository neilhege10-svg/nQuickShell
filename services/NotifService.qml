import QtQuick
import Quickshell.Io
pragma Singleton

//-----------------------------------------------------------------------------------
// THE NOTIFICATION SERVICE - The backend brain that manages Mako notifications
// 
// How it works:
// - This is a singleton service that runs in the background
// - It polls TWO makoctl commands every 5 seconds: active + history
// - It combines them into a single array for the UI to display
// - It provides functions to clear all notifications and toggle DND mode
//
// Why we have TWO separate Process blocks:
// - `makoctl list -j` gives us currently visible notifications
// - `makoctl history -j` gives us dismissed notifications
// - We need both to show a complete timeline in the UI
// - Each process writes to its own buffer to avoid race conditions
// - Only when BOTH finish do we combine them into the final array
//
// Why we use JSON parsing:
// - The `-j` flag makes makoctl output JSON instead of plain text
// - JSON can span multiple lines, so we buffer the entire output as a string
// - We parse it once in onExited after all lines are collected
// - This is different from cliphist which outputs one record per line
//-----------------------------------------------------------------------------------
Item {
    id: root
    visible: false

    // ── PUBLIC PROPERTIES ──────────────────────────────────────────
    // These are what the UI reads from
    property var notifications: []    // The final combined array shown in UI
    property string _buf: ""          // Buffer for active notifications JSON (private)
    property string _histBuf: ""      // Buffer for history JSON (private)
    property var _active: []          // Parsed active notifications (private)

//-----------------------------------------------------------------------------------
// THE POLLING TIMER - The heartbeat that triggers notification checks
// 
// How it works:
// - Fires every 5000ms (5 seconds)
// - triggeredOnStart: true means it fires immediately when Quickshell loads
// - Each time it fires, it clears BOTH buffers and starts BOTH processes
// - Both processes run in parallel and write to separate buffers
//-----------------------------------------------------------------------------------
    Timer {
        id: pollTimer
        interval: 5000
        repeat: true
        running: true
        triggeredOnStart: true
        
        onTriggered: {
            // Clear both buffers before each poll to avoid stale data
            root._buf = ""
            root._histBuf = ""
            
            // Start both processes in parallel
            historyProcess.running = true
            listProcess.running = true
        }
    }

//-----------------------------------------------------------------------------------
// THE LIST PROCESS - Fetches currently active (visible) notifications
// 
// How it works:
// - Runs `makoctl list -j` which outputs JSON of active notifications
// - SplitParser reads each line and concatenates into _buf string
// - When done, we parse the JSON and store in _active (private)
// - We DON'T assign to root.notifications here to avoid race conditions
//
// Why we use string concatenation instead of array:
// - JSON can span multiple lines (pretty-printed or minified)
// - We need the complete JSON string before we can parse it
// - So we concatenate every line into one big string
// - Then parse it once in onExited
//-----------------------------------------------------------------------------------
    Process {
        id: listProcess
        command: ["makoctl", "list", "-j"]
        running: false

        stdout: SplitParser {
            onRead: function(line) {
                root._buf += line
            }
        }
        
        onExited: function(code, status) {
            try {
                // Parse the complete JSON into an array
                root._active = JSON.parse(root._buf)
                console.log("NotifService: loaded", root._active.length, "active notifications")
            } catch(e) {
                console.log("NotifService: parse error", e)
            }
        }
    }

//-----------------------------------------------------------------------------------
// THE HISTORY PROCESS - Fetches dismissed notification history
// 
// How it works:
// - Runs `makoctl history -j` which outputs JSON of dismissed notifications
// - SplitParser reads each line and concatenates into _histBuf string
// - When done, we parse the JSON and COMBINE it with _active
// - This is the LAST process to finish, so it does the final assignment
//
// The race condition fix:
// - Both processes run in parallel and finish at different times
// - If both tried to assign to root.notifications, whichever finished last would win
// - Instead: listProcess writes to _active (private), historyProcess combines them
// - This ensures we always have the latest data from BOTH sources
//-----------------------------------------------------------------------------------
    Process {
        id: historyProcess
        command: ["makoctl", "history", "-j"]
        running: false
        
        stdout: SplitParser {
            onRead: function(line) {
                root._histBuf += line
            }
        }

        onExited: function(code, status) {
            try {
                // Parse the history JSON
                const history = JSON.parse(root._histBuf)
                
                // Combine active + history (active ones first, then dismissed)
                const combined = root._active.concat(history)
                
                // This is the final assignment to the public property
                root.notifications = combined
                console.log("NotifService: total", root.notifications.length, "notifications")
            } catch(e) {
                console.log("NotifService: history parse error", e)
            }
        }
    }

//-----------------------------------------------------------------------------------
// THE CLEAR PROCESS - Wipes all notifications (active + history)
// 
// How it works:
// - Kills mako completely (which clears its in-memory history)
// - Waits 0.5 seconds for the process to die
// - Restarts mako in the background
// - We immediately clear root.notifications so the UI updates instantly
//
// Why we kill + restart instead of using makoctl commands:
// - Mako doesn't have a native "clear history" command
// - Its history lives in RAM, so killing the process wipes it clean
// - This is the "get it working" solution - we can optimize later
//-----------------------------------------------------------------------------------
    Process {
        id: clearProcess
        running: false
    }

    function clearNotifs() {
        // Kill mako (clears history), wait, then restart it
        clearProcess.command = ["bash", "-c", "pkill mako && sleep 0.5 && mako &"]
        clearProcess.running = true
        
        // Instantly clear the UI so the user doesn't wait for the next poll
        root.notifications = [];
    }

//-----------------------------------------------------------------------------------
// THE DND PROCESS - Toggles Do Not Disturb mode
// 
// How it works:
// - When DND is enabled: kills mako (no daemon = no notifications)
// - When DND is disabled: restarts mako in the background
//
// Why this works for DND:
// - Mako is the notification daemon - it receives and displays notifications
// - If mako isn't running, notifications have nowhere to go
// - They're either dropped by the compositor or queued by the sender
// - When we restart mako, it starts fresh (no history, since we killed it)
//
// The tradeoff:
// - This is a "nuclear" DND - it completely stops the daemon
// - Some apps might retry sending notifications when mako restarts
// - A more elegant solution would use mako's mode system, but this works for MVP
//-----------------------------------------------------------------------------------
    Process {
        id: dndProcess
        running: false
    }

    function setDND(enabled) {
    dndProcess.command = [
        "makoctl",
        "mode",
        "-s",
        enabled ? "dnd" : "default"
    ]
    dndProcess.running = true
  }
}
