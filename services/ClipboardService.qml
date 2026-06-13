import QtQuick
import Quickshell.Io
pragma Singleton

Item {
    id: root

    property var clips: []
    property var _clipBuf: []

    visible: false

    Timer {
        id: pollTimer

        interval: 5000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: {
            root._clipBuf = [];
            listProcess.running = true;
        }
    }

    Process {
        id: listProcess

        command: ["cliphist", "list"]
        running: false
        onExited: function(code, status) {
            root.clips = root._clipBuf;
            console.log("ClipboardService: loaded", root.clips.length, "clips");
        }

        stdout: SplitParser {
            onRead: function(line) {
                if (!line.trim())
                    return ;

                // skip binary/image entries
                const parts = line.split("\t");
                const id = parts[0].trim();
                const text = parts[1] || "";
                if (text.includes("[["))
                    return ;

                root._clipBuf.push({
                    "id": id,
                    "text": text
                });
            }
        }

    }

}
