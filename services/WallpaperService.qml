pragma Singleton
import QtQuick
import Quickshell.Io

// ── WallpaperService ─────────────────────────────────────────────────
// Owns everything backend-related for the wallpaper switcher:
//   - scans ~/wallpapers for media files
//   - generates + caches video thumbnails via ffmpeg (skips regen if
//     the thumbnail is already newer than its source file)
//   - manages the mpvpaper process (start/stop/switch)
//   - persists + restores the last-applied wallpaper across restarts
//
// UI (WallpaperGrid.qml) just binds to `wallpapers` and calls
// applyWallpaper(path). Everything else is internal.
//
// NOTE: paths below are hardcoded to /home/neil — adjust if you ever
// move this config to another machine/user.
// ────────────────────────────────────────────────────────────────────
QtObject {
    id: root

    readonly property string wallpaperDir: "/home/neil/Pictures/Wallpapers"
    readonly property string thumbDir: "/home/neil/.cache/quickshell/wallpaper-thumbs"
    readonly property string stateFile: "/home/neil/.local/state/quickshell/current-wallpaper.txt"

    property string currentWallpaper: ""   // full path of the applied wallpaper
    property string pendingWallpaper: ""   // used to sequence stop -> restart
    property var wallpapers: []            // [{ path, name, thumb, isVideo }, ...]

//-----------------------------------------------------------------------------------
// Scan + thumbnail generation. One combined script so we're not spawning a
// Process per file — it loops internally and prints one line per wallpaper
// so QML only has to parse the output once.
//-----------------------------------------------------------------------------------
    readonly property string _scanScript:
        "mkdir -p '" + thumbDir + "'\n" +
        "for f in '" + wallpaperDir + "'/*; do\n" +
        "  [ -f \"$f\" ] || continue\n" +
        "  base=$(basename \"$f\")\n" +
        "  ext=\"${base##*.}\"\n" +
        "  name=\"${base%.*}\"\n" +
        "  case \"${ext,,}\" in\n" +
        "    mp4|webm|mkv|mov)\n" +
        "      thumb=\"" + thumbDir + "/$name.jpg\"\n" +
        "      if [ ! -f \"$thumb\" ] || [ \"$f\" -nt \"$thumb\" ]; then\n" +
        "        ffmpeg -y -ss 00:00:01 -i \"$f\" -vframes 1 -vf scale=320:-1 \"$thumb\" >/dev/null 2>&1\n" +
        "      fi\n" +
        "      echo \"VIDEO|$f|$thumb\"\n" +
        "      ;;\n" +
        "    png|jpg|jpeg|gif)\n" +
        "      echo \"IMAGE|$f|$f\"\n" +
        "      ;;\n" +
        "  esac\n" +
        "done\n"

    property var scanProc: Process {
        command: ["bash", "-c", root._scanScript]

        stdout: SplitParser {
            onRead: (line) => {
                var parts = line.split("|");
                if (parts.length < 3)
                    return;
                var list = root.wallpapers.slice();
                var fullPath = parts[1];
                var base = fullPath.substring(fullPath.lastIndexOf("/") + 1);
                var name = base.substring(0, base.lastIndexOf("."));
                list.push({
                    path: fullPath,
                    name: name,
                    thumb: parts[2],
                    isVideo: parts[0] === "VIDEO"
                });
                root.wallpapers = list;
            }
        }
    }

    function rescan() {
        wallpapers = [];
        scanProc.running = true;
    }

//-----------------------------------------------------------------------------------
// mpvpaper process management. Applying a new wallpaper stops the running
// instance first (if any), waits for it to actually exit, then relaunches
// with the new path. Also kills swww/AWWW since they conflict over the
// wlr-layer-shell background layer.
//-----------------------------------------------------------------------------------
    property var killConflictProc: Process {
        command: ["pkill", "-x", "awww-daemon"]
    }

    property var mpvProc: Process {
        id: mpvProcInner
        command: root.pendingWallpaper ? ["mpvpaper", "-o", "loop hwdec=auto panscan=1.0", "*", root.pendingWallpaper] : []

        onExited: {
            // if a new wallpaper is queued and differs from what just stopped, start it now
            if (root.pendingWallpaper && root.pendingWallpaper !== root.currentWallpaper) {
                root.currentWallpaper = root.pendingWallpaper;
                root._persist();
                running = true;
            }
        }
    }

    function applyWallpaper(path) {
        killConflictProc.running = true;
        pendingWallpaper = path;

        if (mpvProc.running) {
            mpvProc.running = false; // onExited will relaunch with the new path
        } else {
            currentWallpaper = path;
            _persist();
            mpvProc.running = true;
        }
    }

//-----------------------------------------------------------------------------------
// Persistence — remember the active wallpaper across quickshell restarts
//-----------------------------------------------------------------------------------
    property var persistProc: Process {
        command: root.currentWallpaper
            ? ["bash", "-c", "mkdir -p \"$(dirname '" + root.stateFile + "')\" && echo '" + root.currentWallpaper + "' > '" + root.stateFile + "'"]
            : []
    }

    function _persist() {
        persistProc.running = true;
    }

    property var restoreProc: Process {
        command: ["bash", "-c", "cat '" + root.stateFile + "' 2>/dev/null"]

        stdout: SplitParser {
            onRead: (line) => {
                if (line.trim().length > 0)
                    root.applyWallpaper(line.trim());
            }
        }
    }

    Component.onCompleted: {
        rescan();
        restoreProc.running = true;
    }
}
