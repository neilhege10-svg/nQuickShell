import QtQuick
import Qt5Compat.GraphicalEffects
import QtQuick.Shapes

// ── PanelShape ───────────────────────────────────────────────────────
// Experimental animation pass.
//
// This QML is the SHAPE of the Main UI page,
// aswell as having its Animations Declared here
//
// OPEN
//   1. Seed fades + pops into existence
//   2. Short pause
//   3. Horizontal sweep
//   4. Short pause
//   5. Vertical bloom with a restrained overshoot
//   6. Settle
//
// CLOSE
//   1. Vertical collapse
//   2. Short pause
//   3. Horizontal collapse
//   4. Seed contracts + fades out
//
// ShellPanel should continue to center this component.
// This file only changes the component's own visual properties.
// ───────────────────────────────────────────────────────────────────
Item {
    id: root

    property bool open: false
    property real targetWidth: 480
    property real targetHeight: 220
    property int seedSize: 20
    property int stageDuration: 330
    property var t

    readonly property int cornerRadius: 10
    readonly property bool animating: openSeq.running || closeSeq.running

    property bool readyForContent: false


    // Emitted when the dedicated page-switch resize has finished.
    signal pageResizeFinished()

    // Resize the panel for a page change without replaying the
    // opening or closing sequence.
    function resizeForPage() {
        pageResizeSeq.stop()
        pageResizeSeq.start()
    }
    clip: true

    Component.onCompleted: {
        width = seedSize
        height = seedSize
        opacity = 0
    }

    onOpenChanged: {
        readyForContent = false

        if (open) {
            closeSeq.stop()
            openSeq.start()
        } else {
            openSeq.stop()
            closeSeq.start()
        }
    }

//-----------------------------------------------------------------------------------
// OPEN sequence — "HUD deployment"
//-----------------------------------------------------------------------------------
    SequentialAnimation {
        id: openSeq

        // 1. Materialize + pop.
        //
        // The seed starts invisible, then appears with a tiny overshoot.
            NumberAnimation {
                target: root
                property: "opacity"
                from: 0
                to: 0
                duration: 340
                easing.type: Easing.OutCubic
            }
            ParallelAnimation {

            NumberAnimation {
                target: root
                property: "opacity"
                from: 0
                to: 1
                duration: 180
                easing.type: Easing.OutCubic
              }

            NumberAnimation {
                target: root
                property: "width"
                to: root.seedSize 
                duration: 180
                easing.type: Easing.OutBack
                easing.overshoot: 1.8
            }

            NumberAnimation {
                target: root
                property: "height"
                to: root.seedSize
                duration: 180
                easing.type: Easing.OutBack
                easing.overshoot: 1.8
            }
        }

        // Let the little seed "sit" for a moment.
        PauseAnimation {
            duration: 10
        }

        // 2. Return to the actual seed size.
        //
        // This creates a tiny compression before the main deployment.
        ParallelAnimation {
            NumberAnimation {
                target: root
                property: "width"
                to: root.seedSize
                duration: 90
                easing.type: Easing.InOutQuad
            }

            NumberAnimation {
                target: root
                property: "height"
                to: root.seedSize
                duration: 90
                easing.type: Easing.InOutQuad
            }
        }

        PauseAnimation {
            duration: 10
        }

        // 3. Horizontal sweep.
        //
        // The panel stays shallow while it rapidly establishes its width.
        NumberAnimation {
            target: root
            property: "width"
            to: root.targetWidth
            duration: 300
            easing.type: Easing.OutExpo
        }

        PauseAnimation {
            duration: 80
        }

        // 4. Vertical bloom.
        //
        // OutBack gives the final panel a small "landing" overshoot.
        NumberAnimation {
            target: root
            property: "height"
            to: root.targetHeight
            duration: 390
            easing.type: Easing.OutBack
            easing.overshoot: 0.8
        }

        // Tiny final settle before content is allowed in.
        PauseAnimation {
            duration: 70
        }

        ScriptAction {
            script: root.readyForContent = true
        }
    }

//-----------------------------------------------------------------------------------
// CLOSE sequence — deliberately faster and slightly sharper
//-----------------------------------------------------------------------------------
    SequentialAnimation {
        id: closeSeq

        // Hide content first in ShellPanel, then collapse vertically.
        NumberAnimation {
            target: root
            property: "height"
            to: root.seedSize
            duration: 270
            easing.type: Easing.InCubic
        }

        PauseAnimation {
            duration: 70
        }

        // Horizontal retraction.
        NumberAnimation {
            target: root
            property: "width"
            to: root.seedSize
            duration: 240
            easing.type: Easing.InCubic
        }

        PauseAnimation {
            duration: 80
        }

        // Final little contraction + fade.
        ParallelAnimation {
            NumberAnimation {
                target: root
                property: "width"
                to: 1
                duration: 150
                easing.type: Easing.InBack
                easing.overshoot: 1.1
            }

            NumberAnimation {
                target: root
                property: "height"
                to: 1
                duration: 150
                easing.type: Easing.InBack
                easing.overshoot: 1.1
            }

            NumberAnimation {
                target: root
                property: "opacity"
                to: 0
                duration: 150
                easing.type: Easing.InCubic
            }
        }
    }


//-----------------------------------------------------------------------------------
// PAGE SWITCH — smoother, slightly faster resize sequence
//-----------------------------------------------------------------------------------
    ParallelAnimation {
        id: pageResizeSeq

        NumberAnimation {
            target: root
            property: "width"
            to: root.targetWidth
            duration: 600
            easing.type: Easing.InOutCubic
        }

        NumberAnimation {
            target: root
            property: "height"
            to: root.targetHeight
            duration: 600
            easing.type: Easing.InOutCubic
        }

        onFinished: root.pageResizeFinished()
    }
//-----------------------------------------------------------------------------------
// Background shape
//-----------------------------------------------------------------------------------
    Shape {
        id: panelBg

        anchors.fill: parent
        layer.enabled: true
        layer.samples: 8

        ShapePath {
            fillColor: root.t ? root.t.base.bg : "#1e1e2e"
            strokeWidth: 0

            startX: 0
            startY: root.cornerRadius

            PathQuad {
                controlX: 0
                controlY: 0
                x: root.cornerRadius
                y: 0
            }

            PathLine {
                x: panelBg.width - root.cornerRadius
                y: 0
            }

            PathQuad {
                controlX: panelBg.width
                controlY: 0
                x: panelBg.width
                y: root.cornerRadius
            }

            PathLine {
                x: panelBg.width
                y: panelBg.height - root.cornerRadius
            }

            PathQuad {
                controlX: panelBg.width
                controlY: panelBg.height
                x: panelBg.width - root.cornerRadius
                y: panelBg.height
            }

            PathLine {
                x: root.cornerRadius
                y: panelBg.height
            }

            PathQuad {
                controlX: 0
                controlY: panelBg.height
                x: 0
                y: panelBg.height - root.cornerRadius
            }

            PathLine {
                x: 0
                y: root.cornerRadius
            }
        }

        layer.effect: DropShadow {
            horizontalOffset: 6
            verticalOffset: 2
            radius: 16
            samples: 17
            color: root.t ? root.t.base.shadow : "#000000"
        }
    }
}
