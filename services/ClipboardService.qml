import QtQuick
import Quickshell.Io
import Quickshell.Hyprland
pragma Singleton

//-----------------------------------------------------------------------------------
// THE CLIPBOARD SERVICE - The backend brain that manages clipboard history
// 
// How it works:
// - This is a singleton service that runs in the background
// - It polls `cliphist list` every 5 seconds to get the current clipboard history
// - It provides functions to paste clips back, clear history, and pause recording
// - The UI (ClipboardSection.qml) just reads from `root.clips` and displays it
//
// Why we use Timer + Process instead of events:
// - `wl-paste --watch` runs as a separate process in Hyprland autostart
// - Quickshell can't easily listen to its output in real-time
// - Polling every 5 seconds is simple and works reliably
// - We can optimize to event-driven later in the "Big cleanup pass"
//
// Why we use separate Process blocks:
// - Each operation (poll, paste, wipe, pause) gets its own Process
// - This prevents race conditions: if you click "paste" at the exact moment
//   the 5-second timer fires, they won't interrupt each other
// - Think of it like having separate chefs for different tasks in a kitchen
//-----------------------------------------------------------------------------------
Item {
    id: root

    // ── PUBLIC PROPERTIES ──────────────────────────────────────────
    // These are what the UI reads from
    property var clips: []          // The final array of clipboard items shown in UI
    property var _clipBuf: []       // Temporary buffer while parsing (private)

    visible: false                  // This is a backend service, no visual output

//-----------------------------------------------------------------------------------
// THE POLLING TIMER - The heartbeat that triggers clipboard checks
// 
// How it works:
// - Fires every 5000ms (5 seconds)
// - triggeredOnStart: true means it fires immediately when Quickshell loads
// - Each time it fires, it clears the buffer and starts the listProcess
// - uses the _clipbuf variable as a buffer 
//-----------------------------------------------------------------------------------
    Timer {
        id: pollTimer
        interval: 5000
        repeat: true
        running: true
        triggeredOnStart: true
        
        onTriggered: {
            // Clear the buffer before each poll to avoid stale data
            root._clipBuf = [];
            // Start the process that will fetch the clipboard list
            listProcess.running = true;
        }
    }

//-----------------------------------------------------------------------------------
// THE LIST PROCESS - Fetches clipboard history from cliphist
// 
// How it works:
// - Runs `cliphist list` which outputs lines like: "1234567890\tSome text here"
// - SplitParser reads each line individually
// - We parse each line into an object with "id" and "text" properties
// - We filter out binary/image entries (they show as "[[ binary data ... ]]")
// - When done, we slice the last 50 items and assign to root.clips
//
// Why we use SplitParser instead of buffering the whole output:
// - cliphist outputs one clip per line
// - Each line is a complete record (no multi-line JSON)
// - SplitParser lets us process each line as it arrives
// - This is more memory-efficient than buffering everything
//
// Why we slice(-50):
// - Limits the UI to the last 50 clips for performance and sanity
// - Scrolling through 500 clips is annoying
// - The actual cliphist database can have more, but UI only shows recent 50
//-----------------------------------------------------------------------------------
    Process {
        id: listProcess
        command: ["cliphist", "list"]
        running: false
        
        onExited: function(code, status) {
            // Only keep the last 50 items for the UI
            root.clips = root._clipBuf.slice(-50);
           //console.log("ClipboardService: loaded", root.clips.length, "clips"); //(debuggin tool)
        }

        stdout: SplitParser {
            onRead: function(line) {
                // Skip empty lines
                if (!line.trim())
                    return ;

                // Split the line by tab: "id\ttext"
                const parts = line.split("\t");
                const id = parts[0].trim();
                const text = parts[1] || "";
                
                // Filter out binary/image entries (they show as "[[ binary data ... ]]")
                if (text.includes("[["))
                    return ;

                // Add this clip to our buffer
                root._clipBuf.push({
                    "id": id,
                    "text": text
                });
            }
        }
    }

//-----------------------------------------------------------------------------------
// THE PASTE BACK PROCESS - Restores a clipboard item to the system clipboard
// 
// How it works:
// - When user clicks a clip in the UI, this function is called with the clip's ID
// - We run `cliphist decode <id> | wl-copy` to decode and copy it back
// - We use bash -c because Quickshell's Process doesn't understand shell pipes (|)
// - If we passed it directly, it would look for an executable literally named "|"
// - By wrapping in bash -c, bash interprets the pipe correctly
//-----------------------------------------------------------------------------------
    Process {
        id: pasteProcess
        running: false
    }

    function pasteClip(id) {
        // bash -c is required because Quickshell doesn't understand shell pipes
        pasteProcess.command = ["bash", "-c", "cliphist decode " + id + " | wl-copy"]
        pasteProcess.running = true
    }

//-----------------------------------------------------------------------------------
// THE WIPE PROCESS - Clears all clipboard history
// 
// How it works:
// - Runs `cliphist wipe` which deletes the entire clipboard database
// - We immediately clear root.clips so the UI updates instantly
// - Without the instant clear, the UI would still show old clips until the next poll
//-----------------------------------------------------------------------------------
    Process {
        id: wipeProcess
        running: false
    }

    function clearClips() {
        // Just wipe the database - no need to kill the watcher
        wipeProcess.command = ["bash", "-c", "cliphist wipe"]
        wipeProcess.running = true
        
        // Instantly clear the UI so the user doesn't wait for the next poll
        root.clips = [];
    }

//-----------------------------------------------------------------------------------
// THE PAUSE PROCESS - Toggles clipboard recording on/off
// 
// How it works:
// - When pausing: kills the `wl-paste --watch cliphist store` process
// - When unpausing: restarts it using Hyprland's Lua dispatcher
//
// Why we use Hyprland to restart the watcher:
// - The watcher needs proper Wayland environment variables (WAYLAND_DISPLAY, etc.)
// - If we spawn it directly from Quickshell's Process, it might not inherit them
// - Hyprland.dispatch runs it in Hyprland's environment, so it works correctly
// - It also runs completely detached from Quickshell (if Quickshell crashes, watcher keeps running)
//
// The "leak" behavior:
// - When you unpause, the watcher restarts and does an initial read of the current clipboard
// - So the very last thing you copied while paused will appear in the UI
// - But everything in between is properly ignored
// - This is acceptable behavior - the whole point is that stuff copied while paused doesn't get saved
//-----------------------------------------------------------------------------------
    Process {
        id: clipPauseProcess
        running: false
    }

    function setClipboardPaused(enabled) {
        if (enabled) {
            // Kill the watcher process
            clipPauseProcess.command = ["bash", "-c", "pkill -f 'wl-paste --watch cliphist store'"]
            clipPauseProcess.running = true
        } else {
            // Restart via Hyprland's Lua dispatcher for proper environment
            Hyprland.dispatch('hl.dsp.exec_cmd("wl-paste --watch cliphist store")')
        }
    }
}
