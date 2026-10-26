import QtQuick
import QtQuick.Layouts
import "../../assets/"
import "../../services"

Rectangle {
    id: root
    property var t

    color: root.t ? root.t.base.surface : "#1f1f1f"
    radius: root.t ? root.t.widgetRadius : 10

    // Live readings from the system telemetry singleton.
    readonly property var stats: SystemStatsService
    function metricDetail(used, total, unit) {
        if (used < 0 || total < 0)
            return "N/A"
        return used.toFixed(1) + " / " + total.toFixed(1) + " " + unit
    }
    function tempDetail(temp) {
        return temp < 0 ? "N/A" : temp.toFixed(0) + "°C"
    }
    function safePercent(value) {
        return value < 0 ? 0 : Math.max(0, Math.min(100, value))
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 16

        // CPU: large utilization ring + temperature bar.
        ColumnLayout {
            Layout.preferredWidth: root.width * 0.30
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumWidth: 0
            spacing: 10

            CircularGauge {
                Layout.alignment: Qt.AlignHCenter
                Layout.fillWidth: true
                Layout.preferredHeight: Math.min(118, parent.height * 1.65)
                gaugeSize: Math.min(112, width, height - 18)
                t: root.t
                label: "CPU"
                value: root.safePercent(root.stats.cpuPercent)
                detail: "UTILIZATION"
                accent: root.t ? root.t.base.accent : "#03befc"
            }

            HorizontalGauge {
                Layout.fillWidth: true
                label: "TEMP"
                value: root.safePercent(root.stats.cpuTempC)
                detail: root.tempDetail(root.stats.cpuTempC)
                showDetail: false
                t: root.t
                accent: root.t ? root.t.base.accent : "#03befc"
            }
        }

        Rectangle {
            Layout.fillHeight: true
            width: 1
            color: root.t ? root.t.base.border : "#454545"
        }

        // GPU: same visual language as CPU, with its own accent treatment.
        ColumnLayout {
            Layout.preferredWidth: root.width * 0.30
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumWidth: 0
            spacing: 10

            CircularGauge {
                Layout.alignment: Qt.AlignHCenter
                Layout.fillWidth: true
                Layout.preferredHeight: Math.min(118, parent.height * 1.65)
                gaugeSize: Math.min(112, width, height - 18)
                t: root.t
                label: "GPU"
                value: root.safePercent(root.stats.gpuPercent)
                detail: "UTILIZATION"
                accent: root.t ? root.t.holo.text : "#9a8cff"
            }

            HorizontalGauge {
                Layout.fillWidth: true
                label: "TEMP"
                value: root.safePercent(root.stats.gpuTempC)
                detail: root.tempDetail(root.stats.gpuTempC)
                showDetail: false
                t: root.t
                accent: root.t ? root.t.holo.text : "#9a8cff"
            }
        }

        Rectangle {
            Layout.fillHeight: true
            width: 1
            color: root.t ? root.t.base.border : "#454545"
        }

        // Memory: no nested card background, only spacing and a divider.
        ColumnLayout {
            Layout.preferredWidth: root.width * 0.18
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumWidth: 0
            spacing: 5

            Text {
                Layout.fillWidth: true
                text: "MEMORY"
                color: root.t ? root.t.base.textInactive : "#6e6e6e"
                font.family: root.t ? root.t.fontFamily : "JetBrainsMono Nerd Font"
                font.pixelSize: 10
                horizontalAlignment: Text.AlignHCenter
            }

            CircularGauge {
                Layout.alignment: Qt.AlignHCenter
                Layout.fillWidth: true
                Layout.preferredHeight: 78
                Layout.maximumHeight: 78
                Layout.minimumHeight: 78
                gaugeSize: Math.min(68, width, height - 10)
                t: root.t
                label: "RAM"
                value: root.safePercent(root.stats.ramUsedPercent)
                detail: root.metricDetail(root.stats.ramUsedGiB, root.stats.ramTotalGiB, "GB")
                accent: root.t ? root.t.base.accent : "#03befc"
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: root.t ? root.t.base.border : "#454545"
            }

            CircularGauge {
                Layout.alignment: Qt.AlignHCenter
                Layout.fillWidth: true
                Layout.preferredHeight: 78
                Layout.maximumHeight: 78
                Layout.minimumHeight: 78
                gaugeSize: Math.min(68, width, height - 10)
                t: root.t
                label: "VRAM"
                value: root.safePercent(root.stats.vramUsedPercent)
                detail: root.metricDetail(root.stats.vramUsedGiB, root.stats.vramTotalGiB, "GB")
                accent: root.t ? root.t.holo.text : "#9a8cff"
            }
        }

        Rectangle {
            Layout.fillHeight: true
            width: 1
            color: root.t ? root.t.base.border : "#454545"
        }

        // Resource details: simple bars, no nested panel/card backgrounds.
        ColumnLayout {
            Layout.preferredWidth: root.width * 0.18
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumWidth: 0
            spacing: 10

            Text {
                Layout.fillWidth: true
                text: "RESOURCES"
                color: root.t ? root.t.base.textInactive : "#6e6e6e"
                font.family: root.t ? root.t.fontFamily : "JetBrainsMono Nerd Font"
                font.pixelSize: 10
            }

            HorizontalGauge {
                Layout.fillWidth: true
                label: "SWAP"
                value: root.safePercent(root.stats.swapUsedPercent)
                detail: root.stats.swapUsedPercent.toFixed(0) + "% used"
                t: root.t
                accent: root.t ? root.t.base.accent : "#03befc"
            }

            HorizontalGauge {
                Layout.fillWidth: true
                label: "DISK"
                value: root.safePercent(root.stats.diskUsedPercent)
                detail: root.stats.diskUsedPercent.toFixed(0) + "% used"
                t: root.t
                accent: root.t ? root.t.holo.text : "#9a8cff"
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: root.t ? root.t.base.border : "#454545"
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 5

                Text {
                    text: "NETWORK"
                    color: root.t ? root.t.base.textInactive : "#6e6e6e"
                    font.family: root.t ? root.t.fontFamily : "JetBrainsMono Nerd Font"
                    font.pixelSize: 10
                }

                Text {
                    Layout.fillWidth: true
                    text: "↓ " + root.stats.networkRxMiBs.toFixed(1) + " MiB/s"
                    color: root.t ? root.t.base.text : "#e6e6e6"
                    font.family: root.t ? root.t.fontFamily : "JetBrainsMono Nerd Font"
                    font.pixelSize: 11
                    elide: Text.ElideRight
                }

                Text {
                    Layout.fillWidth: true
                    text: "↑ " + root.stats.networkTxMiBs.toFixed(1) + " MiB/s"
                    color: root.t ? root.t.base.text : "#e6e6e6"
                    font.family: root.t ? root.t.fontFamily : "JetBrainsMono Nerd Font"
                    font.pixelSize: 11
                    elide: Text.ElideRight
                }
            }
        }
    }
}
