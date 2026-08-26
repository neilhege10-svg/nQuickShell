pragma Singleton
import QtQuick

// ── PanelState ────────────────────────────────────────────────────────
// State for the shapeshifting control panel. currentPage drives which
// content the panel's Loader shows.
//
// barWidth is published by Bar.qml (its dockContainer's actual width),
// so other windows (like ShellPanel) can size themselves to match the
// bar without needing direct access to it — they're separate windows,
// so this shared singleton is the only way to pass that value across.
// ─────────────────────────────────────────────────────────────────────
QtObject {
    id: root

    property bool panelOpen: false
    property string currentPage: "wallpaper"
    property real barWidth: 300 // sane fallback until Bar.qml reports its real width
    property bool cPanelOpen: false // used by the power/session button in Bar.qml

    function open(page) {
        if (page !== undefined)
            currentPage = page;
        panelOpen = true;
    }

    function close() {
        panelOpen = false;
    }

    function toggle(page) {
        if (panelOpen && (page === undefined || page === currentPage)) {
            close();
        } else {
            open(page);
        }
    }
}
