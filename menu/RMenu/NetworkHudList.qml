import "../../theme"
import QtQuick
import QtQuick.Effects
import QtQuick.Layouts

// ── NETWORK HUD LIST ──────────────────────────────────────────────────────────
// Sibling of HudListMenu, designed specifically for network connections.
// Each row shows: [accent bar] [name] [lock icon?] [signal icon]
// Works for both WiFi (signal 0-100) and Ethernet (always full / shows cable icon).
// ─────────────────────────────────────────────────────────────────────────────

Item {
    id: root

    property var t
    property var listModel: []
    property var activeItem: null              // The currently active network object
    property var onItemClicked: function(network) {}

    width: 300
    implicitHeight: listContainer.implicitHeight

    // ── HELPER: signal strength → nerd font icon ───────────────────────
    // Uses Nerd Font wifi icons. Ethernet gets a cable icon.
    function signalIcon(network) {
        if (network.type === "ethernet")
            return "󰈀"; // ethernet cable icon
        const s = network.signal;
        if (s >= 80)
            return "󰤨"; // 4 bars
        if (s >= 60)
            return "󰤥"; // 3 bars
        if (s >= 40)
            return "󰤢"; // 2 bars
        if (s >= 20)
            return "󰤟"; // 1 bar
        return "󰤯";     // no signal
    }

    // ── HELPER: signal strength → color ───────────────────────────────
    function signalColor(network) {
        if (network.type === "ethernet")
            return t.holo.neonActive;
        const s = network.signal;
        if (s >= 60)
            return t.holo.neonActive;
        if (s >= 35)
            return "#f0a500"; // amber warning
        return "#e05252";    // red weak
    }

    // ── THE LIST ────────────────────────────────────────────────────────
    ColumnLayout {
        id: listContainer
        anchors.fill: parent
        spacing: 0

        Repeater {
            model: root.listModel

            delegate: Item {
                id: delegateItem

                required property var modelData
                // Active = this network's name matches the active one
                property bool isActive: root.activeItem && modelData.name === root.activeItem.name

                Layout.fillWidth: true
                implicitHeight: 40

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.onItemClicked(modelData)
                }

                // ── ACTIVE ROW HIGHLIGHT ─────────────────────────────
                Rectangle {
                    anchors.fill: parent
                    anchors.bottomMargin: 1
                    visible: delegateItem.isActive

                    gradient: Gradient {
                        orientation: Gradient.Horizontal

                        GradientStop { position: 0.0; color: "transparent" }
                        GradientStop { position: 0.6; color: Qt.rgba(t.holo.neonActive.r, t.holo.neonActive.g, t.holo.neonActive.b, 0.06) }
                        GradientStop { position: 1.0; color: "transparent" }
                    }
                }

                // ── ROW CONTENT ──────────────────────────────────────
                RowLayout {
                    spacing: 10
                    anchors {
                        fill: parent
                        leftMargin: 8
                        rightMargin: 12
                    }

                    // ── LEFT ACCENT BAR (same as HudListMenu) ────────
                    Rectangle {
                        width: 3
                        height: 18
                        radius: 1
                        color: t.holo.text
                        Layout.alignment: Qt.AlignVCenter
                        opacity: delegateItem.isActive ? 1 : 0

                        Behavior on opacity {
                            NumberAnimation { duration: 200; easing.type: Easing.OutQuad }
                        }
                    }

                    // ── NETWORK NAME ──────────────────────────────────
                    Text {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                        text: modelData.name
                        elide: Text.ElideRight
                        color: delegateItem.isActive ? t.holo.textActive : Qt.rgba(t.base.textActive.r, t.base.textActive.g, t.base.textActive.b, 0.6)

                        font {
                            family: t.fontFamily
                            pixelSize: t.fontSize
                            bold: delegateItem.isActive
                        }
                    }

                    // ── LOCK ICON (only for secured wifi) ────────────
                    Text {
                        visible: modelData.secured && modelData.type === "wifi"
                        text: "󰌾" // lock icon
                        color: Qt.rgba(t.base.textActive.r, t.base.textActive.g, t.base.textActive.b, 0.4)

                        font {
                            family: t.fontFamily
                            pixelSize: t.fontSize - 2
                        }
                    }

                    // ── SIGNAL / TYPE ICON ────────────────────────────
                    Text {
                        text: root.signalIcon(modelData)
                        color: root.signalColor(modelData)

                        font {
                            family: t.fontFamily
                            pixelSize: t.fontSize + 2
                        }

                        // Subtle glow on strong signal
                        layer.enabled: modelData.type === "ethernet" || modelData.signal >= 60
                        layer.effect: MultiEffect {
                            blurEnabled: true
                            blur: 0.3
                            colorization: 1
                            colorizationColor: root.signalColor(modelData)
                        }
                    }
                }

                // ── ROW SEPARATOR ────────────────────────────────────
                Rectangle {
                    anchors.bottom: parent.bottom
                    width: parent.width
                    height: 1
                    color: Qt.rgba(t.holo.text.r, t.holo.text.g, t.holo.text.b, 0.04)
                }
            }
        }
    }
}
