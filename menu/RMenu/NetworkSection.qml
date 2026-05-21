// ── NETWORK SECTION ───────────────────────────────────────────────────────────
// Top section of the network panel page.
// Clicking a secured WiFi network opens the CenterPanel password prompt.
// Clicking an unsecured network connects directly.
// Ethernet entries are display-only (already connected).
// Updated to use ScrollableHudListMenu to handle long lists smoothly.
// ─────────────────────────────────────────────────────────────────────────────

import "../../assets"
import "../../services"
import "../../state"
import "../../theme"
import QtQuick
import QtQuick.Effects
import QtQuick.Layouts

ColumnLayout {
    id: root

    property var t

    spacing: 4

    anchors {
        fill: parent
        margins: 15
    }

    HudListHeader {
        t: root.t
        title: "NETWORK"
        accentColor: root.t.holo.text
        Layout.leftMargin: 10
        Layout.rightMargin: 10
    }

    // ── SWAPPED TO SCROLLABLE MENU ───────────────────────────────────────────
    ScrollHudList {
        id: networkList

        t: root.t
        listModel: NetworkService.networks
        labelProperty: "name"
        
        // Sets how tall the network list can grow before turning on the scroll wheel
        maxHeight: 260 

        // Highlights the item where network.active === true
        activeItem: NetworkService.networks.find((n) => {
            return n.active;
        }) ?? null

        Layout.preferredWidth: 280
        Layout.alignment: Qt.AlignHCenter

        // ── INTERNAL MODULE LOGIC HELPERS ──
        function getSignalIcon(network) {
            if (network.type === "ethernet")
                return "󰈀";

            const s = network.signal;
            if (s >= 80)
                return "󰤨";
            if (s >= 60)
                return "󰤥";
            if (s >= 40)
                return "󰤢";
            if (s >= 20)
                return "󰤟";
            return "󰤯";
        }

        function getSignalColor(network) {
            if (network.type === "ethernet")
                return root.t.holo.neonActive;

            const s = network.signal;
            if (s >= 60)
                return root.t.holo.neonActive;
            if (s >= 35)
                return "#f0a500"; // Warning color for weaker signals
            return "#e05252"; // Alert color for critical signals
        }

        onItemClicked: function(network) {
            // Ethernet is already connected — nothing to do
            if (network.type === "ethernet")
                return;

            // Already the active network — nothing to do
            if (network.active)
                return;

            if (network.secured) {
                // Secured WiFi — open the password prompt in CenterPanel
                PanelState.wifiTarget = network;
                PanelState.activePage = "wifi-password";
                PanelState.cPanelOpen = true;
            } else {
                // Open network — connect directly, no password needed
                NetworkService.connectToNetwork(network, "");
            }
        }

        // ── INJECT VISUAL ICONS INTO THE HUD LIST ROWS ──
        rightSideItem: Component {
            Row {
                spacing: 8

                // ── LOCK ICON ──
                Text {
                    visible: modelData.secured && modelData.type === "wifi"
                    text: "󰌾"
                    color: Qt.rgba(root.t.base.textActive.r, root.t.base.textActive.g, root.t.base.textActive.b, 0.4)

                    font {
                        family: root.t.fontFamily
                        pixelSize: root.t.fontSize - 2
                    }
                }

                // ── SIGNAL / TYPE ICON ──
                Text {
                    id: signalIconText

                    text: networkList.getSignalIcon(modelData)
                    color: networkList.getSignalColor(modelData)
                    
                    // Subtle neon glow effect on strong signal or wired connections
                    layer.enabled: modelData.type === "ethernet" || modelData.signal >= 60

                    font {
                        family: root.t.fontFamily
                        pixelSize: root.t.fontSize + 2
                    }

                    layer.effect: MultiEffect {
                        blurEnabled: true
                        blur: 0.3
                        colorization: 1
                        colorizationColor: signalIconText.color
                    }
                }
            }
        }
    }

    Item {
        Layout.fillWidth: true
        Layout.fillHeight: true
    }
}
