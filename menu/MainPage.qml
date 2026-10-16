// menu/MainPage.qml
import QtQuick
import QtQuick.Layouts
import "main_block" 

Item { 
    id: root
    property var t

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 0
        spacing: 16 

        // ── TOP ROW (50% of total height) ────────────────────────────
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true 
            Layout.preferredHeight: 1 // Acts as a 1:1 ratio with the bottom row
            spacing: 16

            // LEFT COLUMN: Session & Toggles (1/3 of top row width)
            ColumnLayout {
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.preferredWidth: 1 // 1 part width
                spacing: 16

                SessionBlock { 
                    t: root.t
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.preferredHeight: 1 // 50% of the left column
                }
                
                TogglesBlock { 
                    t: root.t
                    Layout.fillWidth: true
                    Layout.fillHeight: true 
                    Layout.preferredHeight: 1 // 50% of the left column
                }
            }

            // RIGHT COLUMN: Audio (2/3 of top row width)
            AudioBlock {
                t: root.t
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredWidth: 2 // 2 parts width (Double the left column)
            }
        }

        // ── BOTTOM ROW (50% of total height) ─────────────────────────
        StatsBlock {
            t: root.t
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredHeight: 1 // Acts as a 1:1 ratio with the top row
        }
    }
}
