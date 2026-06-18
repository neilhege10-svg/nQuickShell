# Quickshell Custom Config — Project Context

> **Last updated:** 2026-06-18 (after Notifs + Clipboard feature)
> **Maintenance rule for whichever AI is reading this:** when you finish a feature or fix a bug, update this doc *immediately* — move the file out of "Active / in-progress" into "Stable / Done," delete the matching line from "Known issues," and update the timestamp above. Don't just append to the bottom. A stale doc is worse than no doc, because it actively misleads the next session.

## Who I am / how I work
I'm new to development. I'm using AI as a teacher, not just a code generator — I want to understand *why* things work, not just copy-paste. Sometimes I ask for full files (early project, established patterns), sometimes I ask to be guided step-by-step so I write the code myself. When guiding me: give skeletons, hints, and targeted one-line fixes rather than full files. Explain *why* something broke, not just the fix — analogies help (e.g. "Layout.preferredHeight is a communication wire to the parent layout", "`--rescan no` is reading cached notes instead of going outside to scan again").

## Stack
- **Hyprland** (Wayland compositor) on Arch/CachyOS — running a build on the new **Lua config** (Hyprland 0.55+, see pattern #10 below). This is a recent, breaking change worth keeping in mind for anything that talks to Hyprland.
- **Quickshell 0.3.0** — QML-based shell framework (bar, panels, widgets)
- Testing on both a desktop (ethernet only, no wifi adapter) and a laptop (has wifi)
- Notification daemon: **Mako** (switched from SwayNC/Dunst — both uninstalled)
- Clipboard: **cliphist** + `wl-paste --watch cliphist store` (added to Hyprland autostart)

## File structure
```
quickshell-custom/
  assets/           BtnRound, HudListHeader, HudListMenu, Slider, ScrollHudList, ToggleSwitch, qmldir
  bar/              Bar, Battery, Clock, Network, SystemStats, Volume, Workspaces, qmldir
  menu/
    RMenu/          AudioIn, AudioOut, BluetoothSection, NetworkControl, NetworkSection,
                     NetworkHudList, RightPanel, VolumeControl, NotifSection, ClipboardSection,
                     NotifControl, qmldir
    SessionMenu/    CenterPanel, ConfirmControl, SessionButton, SessionControl,
                     WifiPasswordControl, qmldir
  services/         AudioService, NetworkService, NotifService, ClipboardService, qmldir
  state/            PanelState, qmldir
  theme/            Theme, qmldir
  shell.qml
```

## Core architecture patterns (learned the hard way — don't repeat these mistakes)

**1. Singleton services pattern**
```qml
pragma Singleton
import QtQuick
import Quickshell.Io

Item {
    id: root
    visible: false
    // properties + Timer + Process children
}
```
Use `Item` (not `QtObject`, not Quickshell's `Singleton{}` type) — `Item` can hold `Process`/`Timer` children, `QtObject` can't easily. Must register in qmldir with the `singleton` keyword prefix:
```
singleton ServiceName 1.0 ServiceName.qml
```
**Critical gotcha:** a singleton only initializes if something in the UI tree actually references it. If nothing imports/uses it, it silently never loads — no errors, just dead silence. Always verify with a `Component.onCompleted: console.log(...)`.

**2. Process + SplitParser polling pattern**
```qml
Timer {
    interval: 5000; repeat: true; running: true; triggeredOnStart: true
    onTriggered: { root._buf = ""; myProcess.running = true }
}
Process {
    id: myProcess
    command: ["some", "cli", "command"]
    running: false
    stdout: SplitParser {
        onRead: function(line) { root._buf += line }  // or push to array if line-based
    }
    onExited: function(code, status) {
        root.publicProperty = JSON.parse(root._buf)  // or just assign array buffer
    }
}
```
- For JSON-across-multiple-lines output: buffer is a **string**, concatenate every line, `JSON.parse` once in `onExited`.
- For line-per-item output (each line is one complete record): buffer is an **array**, push parsed objects in `onRead`, assign directly in `onExited`. No JSON parsing needed.
- **Race condition gotcha:** if two Processes both write to the same public property independently, whichever finishes last wins and can overwrite the other's correct data. Fix: have each process write to a private intermediate property, and only the LAST process to finish does the final combine + assignment to the public property.

**3. Layout sizing gotcha (caused multiple "ghost" bugs)**
Any custom component with dynamic height (e.g. a list that grows from 0 items to N items) MUST expose `Layout.preferredHeight` wired to its `implicitHeight`, when used inside a `ColumnLayout`/`RowLayout`. Without it, the parent layout measures the child ONCE at creation (often 0 height because data hasn't loaded yet) and never re-measures — even after the child's actual height changes. This looked like "slow loading" (actually instant data, invisible due to locked 0px height) and "doesn't show at all" (Bluetooth list) bugs that took a while to diagnose. Always wire:
```qml
Layout.preferredWidth: width
Layout.preferredHeight: implicitHeight
```

**4. ColumnLayout-as-root-of-file gotcha**
When a `ColumnLayout` is the root element of a `.qml` file and anchored with `anchors.fill: parent`, it vertically centers its children when they don't fill all available space — so an empty list makes the header jump to the middle. Fix: wrap in `Item`, anchor only `top/left/right` (not `fill`) on the inner ColumnLayout, so content is pinned to the top and grows downward regardless of child count.

**5. List component pattern**
`HudListMenu` / `ScrollHudList` / `NetworkHudList` all share the same shape: take `t` (theme object), `listModel`, `activeItem`, `labelProperty`, `onItemClicked` callback. Active row gets a left accent bar + subtle horizontal gradient highlight + bold text. `isActive` comparison needs a fallback to `.name` matching (not just reference equality `===`) because data objects from polling are recreated each poll, so reference equality always fails for them — only works for true singleton object references like Pipewire nodes.

**6. nmcli gotcha**
`nmcli dev wifi list` without `--rescan no` triggers a real 30-60 second hardware radio scan on every single poll. Always append `--rescan no` to read cached results instantly instead.

**7. PanelState.qml** (pragma Singleton, QtObject — simple flat state, no Process children needed)
```qml
property bool rPanelOpen / lPanelOpen / cPanelOpen
property string activePage      // "session" | "confirm" | "wifi-password"
property string rPanelPage      // "audio" | "network" | "notifs"
property string pendingAction / pendingCmd
property var wifiTarget         // network object passed to WifiPasswordControl
```

**8. RightPanel.qml structure**
`PanelWindow` (WlrLayershell) containing: a holographic outline `Shape` (background glow), a solid `Shape` (foreground panel body), 3 stacked `Item` pages (`audioPage`/`networkPage`/`notifsPage`) toggled via `visible: PanelState.rPanelPage === "x"`, and a side `ColumnLayout` of `BtnRound` buttons (close / audio / network / notifs) that set `PanelState.rPanelPage` + `rPanelOpen = true`.

Each page follows the same 3-zone layout: top section (list, anchored top, `bottomMargin: 495`), middle control card (anchored center-ish with `leftMargin: 60` to clear the side buttons), bottom section (list, anchored bottom, `topMargin: 495`).

**9. CenterPanel.qml** (top dropdown) switches between `SessionControl` / `ConfirmControl` / `WifiPasswordControl` via `PanelState.activePage`, with a flicker-in animation triggered on open.

**10. Hyprland Lua dispatchers (0.55+) — verified, this is real and current**
Since Hyprland 0.55, the old `hyprlang` config syntax is deprecated in favor of Lua. Dispatchers now live under the `hl.dsp.*` namespace and are invoked via `hl.dispatch(...)` or bound directly with `hl.bind(keys, hl.dsp.exec_cmd("command"))`.

**Important nuance beyond "deprecated":** legacy `hyprctl dispatch <action> <args>` syntax doesn't just still-work-but-discouraged — it's **fully broken** on Lua-config builds. `hyprctl dispatch exec ghostty` throws a Lua parse error now. You must wrap it: `hyprctl dispatch 'hl.dsp.exec_cmd("ghostty")'`. This has already broken other tools in the wild (e.g. Waybar's workspace click handler stopped working until it switched to the new `hl.dsp.*` form).

In Quickshell, use `Hyprland.dispatch('hl.dsp.exec_cmd("appname")')` to spawn processes — never call raw `hyprctl` with old-style syntax from Quickshell. **If any other file in this project still issues old-style hyprctl dispatch calls, it is now silently broken, not just outdated.** Worth auditing existing bar/panel files for this when convenient (see Known issues — `Workspaces.qml` null error may be connected, not unrelated).

**11. Quickshell Process shell operators**
Quickshell's `Process` doesn't understand shell pipes (`|`), background (`&`), or conditionals. Wrap commands in `["bash", "-c", "command1 | command2"]` to let bash interpret them.

## Backend choices per feature
- **Audio** → `Quickshell.Services.Pipewire` (native QML module) — pre-existing, not built by us
- **Network/Ethernet** → `nmcli` via Process polling (NetworkService.qml)
- **Bluetooth** → `bluetoothctl` via Process polling (inside NetworkService.qml)
- **Notifications** → switched SwayNC→Mako. `makoctl list -j` (active) + `makoctl history -j` (dismissed), both real JSON via the `-j` flag. Chose this over Quickshell's native `Quickshell.Services.Notifications` because native only sees live notifications, not history.
- **Clipboard** → `cliphist list` (line-based, `<id>\t<text>` format, no JSON). Images appear as `[[ binary data ... ]]` and get filtered. Paste-back via `cliphist decode <id> | wl-copy`.

## Stable / Done
Flat list — these work, don't re-explain them, just use them.
- `AudioService.qml` — Pipewire native, pre-existing
- `NetworkService.qml` — nmcli + bluetoothctl polling
- `NetworkSection.qml` / `NetworkHudList.qml` / `NetworkControl.qml`
- `BluetoothSection.qml` — plain `HudListMenu`, no custom connection-dot (tried, rejected as clutter)
- `WifiPasswordControl.qml` — flat-square aesthetic, reads `PanelState.wifiTarget`
- `NotifService.qml` — combines active+history, has `clearNotifs()` (DND mode is the one open caveat, see below)
- `NotifSection.qml` — `ListView` bound to `NotifService.notifications`, scrollable
- `NotifControl.qml` — DND + clipboard-pause toggles wired to real service functions, trash buttons wired
- `ClipboardService.qml` — polls `cliphist list`, filters binary, caps UI at last 50 via `.slice(-50)`, has `pasteClip(id)`, `clearClips()`, `setClipboardPaused(enabled)`
- `ClipboardSection.qml` — `ListView` with tactile press effect (scale 0.97), click pastes via `ClipboardService.pasteClip()`
- `ToggleSwitch.qml` (assets/) — reusable iOS-style toggle

## Active / in-progress
- **DND mode fix.** `NotifService.setDND(true)` currently uses `pkill mako`, which wipes notification history as a side effect (mako restarts with a clean slate). Correct fix: use mako's mode system instead — `makoctl set-mode dnd` / `makoctl set-mode default`, paired with a `[mode=dnd]` section in `~/.config/mako/config` setting `invisible=1`. This preserves history while hiding notifications. Not yet implemented.

## Known issues
- DND toggle kills mako history — see "Active / in-progress" above for the fix plan
- Clipboard pause "leak": unpausing restarts `wl-paste --watch`, which does an initial read of the current clipboard — so the last item copied *while paused* appears once on unpause. Everything copied in between stays properly hidden. Accepted as reasonable for MVP, not chasing further.
- Notification click-to-dismiss not implemented (need `makoctl dismiss -i <id>` wired to a MouseArea in `NotifSection`)
- WiFi password prompt has no wrong-password error feedback
- Bluetooth section could use a "scan for new devices" button (nice-to-have, not urgent)
- `Bar.qml:137` — `ReferenceError: o is not defined`
- `Workspaces.qml:42` — `TypeError: Cannot read property 'id' of null` — previously filed as "pre-existing, unrelated." **Reconsider this**: if this file does any IPC call to Hyprland for workspace/window data, the Lua dispatcher transition (pattern #10) is a plausible root cause, not noise. Worth a real look, not just a shrug.
- Quickshell built against Qt 6.11.0, system has 6.11.1 — should rebuild the package at some point
- No unified reusable list component yet (`HudListMenu`/`ScrollHudList`/`NetworkHudList` are near-duplicates) — intentionally deferred to the cleanup pass, not a bug

## Roadmap (agreed order, don't reorder without reason)
1. Finish RightPanel — audio ✅, network+bluetooth ✅, notifs+clipboard ✅ (DND mode fix still open, see above)
2. App Launcher (next major feature)
3. Wallpaper Switcher
4. Theme Switcher
5. Big cleanup/refactor pass — only after all 4 features have a working MVP. Compact code, extract reusable components, fill in missing features noticed along the way. Explicitly decided NOT to polish mid-build since patterns from later features often reveal better abstractions for earlier code.
