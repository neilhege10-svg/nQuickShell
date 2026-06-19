import "../../assets"
import "../../state"
import "../../theme"
import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import Quickshell
import Quickshell.Wayland

//-----------------------------------------------------------------------------------
// THE ROOT WINDOW: Centered Settings Panel
// 
// How it works:
// - PanelWindow creates a desktop overlay centered on the target screen
// - WlrLayershell.layer: Top keeps it above normal windows
// - exclusiveZone: -1 makes it float over content without reserving space
// - The window is transparent; only the Shape inside has the visible border/glow
//-----------------------------------------------------------------------------------
PanelWindow {
    id: root

    required property var targetScreen

    WlrLayershell.screen: targetScreen
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "settingpanel"
    WlrLayershell.exclusiveZone: -1
    
    // Canvas size - larger than the panel to allow shadow bloom
    implicitWidth: 900
    implicitHeight: 700
    
    color: "transparent"
    
    // Only show when panel is open OR animation is still running
    visible: PanelState.settingPanelOpen || settingsShape.openAmount > 0

WlrLayershell.anchors {
    top: true
    bottom: true
    left: true
    right: true
}

//-----------------------------------------------------------------------------------
// THE "CLICK OUTSIDE TO CLOSE" CATCHER
// 
// Covers the entire transparent canvas. If user clicks outside the visible shape,
// close the panel. This provides natural dismissal behavior.
//-----------------------------------------------------------------------------------
    MouseArea {
        anchors.fill: parent
        onClicked: {
            if (!settingsShape.contains(settingsShape.mapFromItem(parent, mouseX, mouseY)))
                PanelState.settingPanelOpen = false;
        }
    }

    Theme {
        id: theme
    }

//-----------------------------------------------------------------------------------
// THE CENTERED SETTINGS CONTAINER
// 
// This Item holds the actual panel shape and handles the open/close animation.
// 
// How the animation works:
// - openAmount goes from 0.0 (closed) to 1.0 (fully open)
// - We use scale + opacity for a "pop in" effect
// - When closed: scale 0.9, opacity 0 (smaller and invisible)
// - When open: scale 1.0, opacity 1 (full size and visible)
// - The Behavior at the bottom makes this transition smooth
//-----------------------------------------------------------------------------------
    Item {
        id: settingsShape

        property int panelWidth: 800
        property int panelHeight: 600
        
        // Animation driver: 0.0 = closed, 1.0 = open
        property real openAmount: PanelState.settingPanelOpen ? 1 : 0

        // Center this container in the parent window
        anchors.centerIn: parent
        
        width: panelWidth
        height: panelHeight
        
        // Scale and opacity based on openAmount
        scale: 0.9 + (0.1 * openAmount)  // Goes from 0.9 to 1.0
        opacity: openAmount

//-----------------------------------------------------------------------------------
// THE GLOWING BORDER SHAPE
// 
// This draws the cyan/turquoise octagonal outline with glow effect.
// 
// How it works:
// - ShapePath creates an octagon (rectangle with cut corners)
// - strokeColor creates the visible border line
// - fillColor is transparent (we only want the outline)
// - DropShadow layer effect creates the cyan glow around the border
// 
// The corner cuts:
// - Each corner uses PathLine to create 45-degree angled cuts
// - This gives it that futuristic "tech panel" aesthetic
//-----------------------------------------------------------------------------------
Shape {
    anchors.fill: parent

    ShapePath {
        fillColor: Qt.rgba(0, 0, 0, 0.75)
        strokeColor: theme.holo.text
        strokeWidth: 2
        joinStyle: ShapePath.RoundJoin

        readonly property int cut: 20

        startX: cut
        startY: 0

        PathLine { x: parent.width - cut; y: 0 }
        PathLine { x: parent.width; y: cut }

        PathLine { x: parent.width; y: parent.height - cut }
        PathLine { x: parent.width - cut; y: parent.height }

        PathLine { x: cut; y: parent.height }
        PathLine { x: 0; y: parent.height - cut }

        PathLine { x: 0; y: cut }
        PathLine { x: cut; y: 0 }
    }

            // THE GLOW EFFECT
            // Creates the cyan bloom around the border
            layer.effect: DropShadow {
                horizontalOffset: 0
                verticalOffset: 0
                radius: 20
                samples: 21
                color: Qt.rgba(theme.holo.text.r, theme.holo.text.g, theme.holo.text.b, 0.6)
            }
        }

//-----------------------------------------------------------------------------------
// THE INNER CONTENT AREA (Placeholder)
// 
// This is where actual settings content will go later.
// For now, it's just an empty container with proper margins inside the border.
//-----------------------------------------------------------------------------------
        Item {
            id: contentArea
            
            anchors.fill: parent
            anchors.margins: 60  // Space inside the border
            
            // Future content will be added here:
            // - Wallpaper page
            // - Theme page
            // - Other settings pages
        }

//-----------------------------------------------------------------------------------
// OPEN/CLOSE ANIMATION BEHAVIOR
// 
// This makes the panel "pop" in and out smoothly.
// 
// How it works:
// - Duration: 300ms (quick but not instant)
// - Easing.OutBack: Creates a slight "overshoot" effect
//   (panel scales slightly past 1.0 then settles back)
// - This gives it a bouncy, tactile feel
//-----------------------------------------------------------------------------------
        Behavior on openAmount {
            NumberAnimation {
                duration: 300
                easing.type: Easing.OutBack
                easing.overshoot: 1.2
            }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: 300
                easing.type: Easing.OutQuad
            }
        }
    }
}
