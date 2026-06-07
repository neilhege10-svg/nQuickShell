pragma Singleton

import QtQuick
import Quickshell.Io

Item {
    id: root
    visible: false

    property var notifications: []
    property string _buf: ""
    property string _histBuf: ""
    property var _active: []

    Timer {
      id: pollTimer
        interval: 5000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered:{
         root._buf = ""
         root._histBuf = ""
         historyProcess.running = true
         listProcess.running = true
       }
     }
    Process {
      id:listProcess
       command: ["makoctl", "list", "-j"]
       running: false

       stdout: SplitParser {
         onRead: function(line) {
           root._buf += line
         }
       }
      onExited: function(code, status) {
       try {
           root._active = JSON.parse(root._buf)
           console.log("NotifService: loaded", root.notifications.length, "notifications")
         } catch(e) {
           console.log("NotifService: parse error", e)
      }
    }
  }
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
            const history = JSON.parse(root._histBuf)
            // combine active + history, active ones first
            const active = root.notifications
            const combined = root._active.concat(history)
            root.notifications = combined
            console.log("NotifService: total", root.notifications.length, "notifications")
        } catch(e) {
            console.log("NotifService: history parse error", e)
        }
    }
}
}
