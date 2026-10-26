pragma Singleton
import QtQuick

// ── PanelState ────────────────────────────────────────────────────────
// State for the shapeshifting control panel. currentPage drives both
// which content the panel's Loader shows AND (via pageSizes below) what
// target size PanelShape animates to — so adding a new page later is
// just adding one entry here, not touching the animation code at all.
// ─────────────────────────────────────────────────────────────────────
QtObject {
    id: root

    property bool panelOpen: false
    property string currentPage: "wallpaper"
    property bool cPanelOpen: false // used by the power/session button in Bar.qml

    // Each page declares its own target size. Add an entry here when a
    // new page (theme changer, control center, etc.) gets built —
    // PanelShape and ShellPanel read from this, nothing else needs to
    // change.
    readonly property var pageSizes: ({
        "wallpaper": {
            width: 745,
            height: 495
        },
        "main": {
          width: 1000,
            height: 550
        }
    })
    readonly property var defaultSize: ({
        width: 745,
        height: 495
    })

    function targetSize() {
        return pageSizes[currentPage] || defaultSize;
    }

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
