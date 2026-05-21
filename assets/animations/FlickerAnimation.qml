// FlickerAnimation.qml
import QtQuick

SequentialAnimation {
    id: rootAnim

    // Expose the target item so any component can hook into it
    property Item targetItem: null
    
    // Optional: Allow tweaking overall animation speed multiplier
    property real speedMultiplier: 1.0

    NumberAnimation { 
        target: rootAnim.targetItem
        property: "opacity"
        from: 0; to: 1
        duration: 50 * rootAnim.speedMultiplier 
    }
    NumberAnimation { 
        target: rootAnim.targetItem
        property: "opacity"
        from: 1; to: 0.2
        duration: 60 * rootAnim.speedMultiplier 
    }
    NumberAnimation { 
        target: rootAnim.targetItem
        property: "opacity"
        from: 0.2; to: 0.8
        duration: 40 * rootAnim.speedMultiplier 
    }
    NumberAnimation { 
        target: rootAnim.targetItem
        property: "opacity"
        from: 0.8; to: 0.4
        duration: 50 * rootAnim.speedMultiplier 
    }
    NumberAnimation { 
        target: rootAnim.targetItem
        property: "opacity"
        from: 0.4; to: 1
        duration: 70 * rootAnim.speedMultiplier 
    }
}
