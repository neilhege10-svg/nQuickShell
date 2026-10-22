pragma Singleton
import QtQuick
import Quickshell.Io

// WallpaperService
// Scans ~/Pictures/Wallpapers, generates video thumbnails, chooses the
// correct wallpaper backend, and remembers the last successful selection.
QtObject {
    id: root

    readonly property string wallpaperDir: "/home/neil/Pictures/Wallpapers"
    readonly property string thumbDir: "/home/neil/.cache/quickshell/wallpaper-thumbs"
    readonly property string stateFile: "/home/neil/.local/state/quickshell/current-wallpaper.txt"
    readonly property string applyScript: "/home/neil/.config/quickshell-custom/services/WallpaperApply.sh"

    property string currentWallpaper: ""
    property string pendingWallpaper: ""
    property string processingWallpaper: ""
    property var wallpapers: []
    property string searchQuery: ""
    property var filteredWallpapers: []

    onSearchQueryChanged: applyFilter()
    onWallpapersChanged: applyFilter()

    function applyFilter() {
        if (searchQuery.trim() === "") {
            filteredWallpapers = wallpapers.slice()
            return
        }

        var query = searchQuery.toLowerCase()
        var result = []
        for (var i = 0; i < wallpapers.length; i++) {
            if (wallpapers[i].name.toLowerCase().indexOf(query) !== -1)
                result.push(wallpapers[i])
        }
        filteredWallpapers = result
    }

    // One shell process scans the directory and generates missing/outdated
    // thumbnails. Paths are passed as positional arguments, not shell code.
    readonly property string _scanScript:
        "mkdir -p \"$THUMB_DIR\"\n" +
        "for f in \"$WALLPAPER_DIR\"/*; do\n" +
        "  [ -f \"$f\" ] || continue\n" +
        "  base=$(basename \"$f\")\n" +
        "  ext=\"${base##*.}\"\n" +
        "  name=\"${base%.*}\"\n" +
        "  case \"${ext,,}\" in\n" +
        "    mp4|webm|mkv|mov)\n" +
        "      thumb=\"$THUMB_DIR/$name.jpg\"\n" +
        "      if [ ! -f \"$thumb\" ] || [ \"$f\" -nt \"$thumb\" ]; then\n" +
        "        ffmpeg -y -ss 00:00:01 -i \"$f\" -vframes 1 -vf scale=320:-1 \"$thumb\" >/dev/null 2>&1\n" +
        "      fi\n" +
        "      printf 'VIDEO|%s|%s\\n' \"$f\" \"$thumb\"\n" +
        "      ;;\n" +
        "    png|jpg|jpeg|webp|bmp|gif)\n" +
        "      printf 'IMAGE|%s|%s\\n' \"$f\" \"$f\"\n" +
        "      ;;\n" +
        "  esac\n" +
        "done\n"

    property var scanProc: Process {
        command: ["bash", "-c",
            "WALLPAPER_DIR=\"$1\" THUMB_DIR=\"$2\"; export WALLPAPER_DIR THUMB_DIR; " + root._scanScript,
            "wallpaper-scan", root.wallpaperDir, root.thumbDir]

        stdout: SplitParser {
            onRead: (line) => {
                var parts = line.split("|")
                if (parts.length < 3)
                    return

                var fullPath = parts[1]
                var base = fullPath.substring(fullPath.lastIndexOf("/") + 1)
                var dot = base.lastIndexOf(".")
                var name = dot > 0 ? base.substring(0, dot) : base
                var list = root.wallpapers.slice()
                list.push({
                    path: fullPath,
                    name: name,
                    thumb: parts[2],
                    isVideo: parts[0] === "VIDEO"
                })
                root.wallpapers = list
            }
        }
    }

    function rescan() {
        wallpapers = []
        scanProc.running = true
    }

    // Serialize selections: if the user clicks several items quickly, finish
    // the current switch and then apply the latest requested wallpaper.
    property var applyProc: Process {
        command: [root.applyScript, root.processingWallpaper]

        onExited: (exitCode, exitStatus) => {
            if (exitCode === 0) {
                root.currentWallpaper = root.processingWallpaper
                root._persist()
            } else {
                console.warn("WallpaperService: failed to apply wallpaper (exit code " + exitCode + "): " + root.processingWallpaper)
            }

            if (root.pendingWallpaper !== root.processingWallpaper)
                root._startNextApply()
        }
    }

    function applyWallpaper(path) {
        if (!path || path.length === 0)
            return

        pendingWallpaper = path
        if (!applyProc.running)
            _startNextApply()
    }

    function _startNextApply() {
        if (!pendingWallpaper || applyProc.running)
            return

        processingWallpaper = pendingWallpaper
        applyProc.command = ["bash", applyScript, processingWallpaper]
        applyProc.running = true
    }

    property var persistProc: Process {
        command: ["bash", "-c",
            "mkdir -p \"$(dirname \"$1\")\" && printf '%s\\n' \"$2\" > \"$1\"",
            "wallpaper-persist", root.stateFile, root.currentWallpaper]
    }

    function _persist() {
        persistProc.running = true
    }

    property var restoreProc: Process {
        command: ["bash", "-c", "cat \"$1\" 2>/dev/null", "wallpaper-restore", root.stateFile]

        stdout: SplitParser {
            onRead: (line) => {
                var path = line.trim()
                if (path.length > 0)
                    root.applyWallpaper(path)
            }
        }
    }

    Component.onCompleted: {
        rescan()
        restoreProc.running = true
    }
}
