import "../../assets"
import "../../assets/animations"
import "../../state"
import "../../theme"
import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import Quickshell
import Quickshell.Wayland

//-----------------------------------------------------------------------------------
// THE ROOT WINDOW: PanelWindow & Wayland Layer Shell Setup
// 
// How it works:
// - PanelWindow is Quickshell's way of creating a desktop overlay/panel.
// - WlrLayershell tells the Wayland compositor (Hyprland) how to treat this window.
// - layer: Top puts it above normal windows but below lockscreens.
// - exclusiveZone: -1 makes it an "overlay" that doesn't reserve screen space 
//   (it floats over content rather than pushing it aside).
//-----------------------------------------------------------------------------------
PanelWindow {
    id: root

    required property var targetScreen

    // Tells the Layer Shell which monitor to draw on
    WlrLayershell.screen: targetScreen
    // Places the panel above standard application windows
    WlrLayershell.layer: WlrLayer.Top
    // A unique identifier for the compositor to track this specific panel
    WlrLayershell.namespace: "rpanel"
    // -1 means "overlay mode" - don't reserve exclusive space for this panel
    WlrLayershell.exclusiveZone: -1
    
    // The physical size of the window canvas
    implicitWidth: 450
    
    // FIX 1: Add a 40px padding buffer to the window canvas height (20px top, 20px bottom)
    // Why this matters: DropShadows need "breathing room" outside the visible shape.
    // If the canvas is exactly the size of the shape, the shadow gets cut off (sliced).
    // By making the canvas taller than the menu, the shadow can bloom beautifully.
    implicitHeight: 840
    
    // The window itself is transparent; only the shapes inside have colors
    color: "transparent"
    
    // Only render this window if the panel is supposed to be open, 
    // OR if the slide-out animation hasn't finished yet (openAmount > 0)
    visible: PanelState.rPanelOpen || menuShape.openAmount > 0

    // Pin this window to the right edge of the screen
    WlrLayershell.anchors {
        right: true
    }

//-----------------------------------------------------------------------------------
// THE "CLICK OUTSIDE TO CLOSE" CATCHER
// 
// How it works:
// - This MouseArea covers the ENTIRE transparent window canvas.
// - When clicked, it checks if the mouse coordinates (mouseX, mouseY) 
//   are actually inside the visible menuShape.
// - If the click is OUTSIDE the menu shape, it closes the panel.
// - This gives the user a natural way to dismiss the panel by clicking the desktop.
//-----------------------------------------------------------------------------------
    MouseArea {
        anchors.fill: parent
        onClicked: {
            // mapFromItem converts the global mouse coordinates to local menu coordinates
            // contains() checks if those local coordinates fall inside the menu's geometry
            if (!menuShape.contains(menuShape.mapFromItem(parent, mouseX, mouseY)))
                PanelState.rPanelOpen = false;
        }
    }

    // Instantiate our global theme so we can use its colors/fonts everywhere
    Theme {
        id: theme
    }

//-----------------------------------------------------------------------------------
// THE SLIDING MENU CONTAINER
// 
// This is the master container that actually slides in and out of the screen.
// 
// How the sliding works:
// - openAmount is a real number from 0.0 (fully closed) to 1.0 (fully open).
// - We bind anchors.rightMargin to a math formula based on openAmount.
// - When openAmount is 0, the margin pushes the menu completely off-screen to the right.
// - When openAmount is 1, the margin is 0, pulling the menu flush against the right edge.
// - The Behavior on openAmount (at the bottom of this file) makes this smooth.
//-----------------------------------------------------------------------------------
    Item {
        id: menuShape

        property int menuWidth: 320
        property int menuHeight: 800
        
        // The magic variable that drives the slide animation (0.0 to 1.0)
        property real openAmount: PanelState.rPanelOpen ? 1 : 0

        // FIX 2: Vertically center the menu inside the expanded window space.
        // Because we added extra height in FIX 1, centering it leaves a safe 
        // 20px margin at the top and bottom, ensuring shadows don't clip.
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        
        // THE SLIDE MATH: 
        // If openAmount is 0, margin is -320 (pushed off screen).
        // If openAmount is 1, margin is 0 (fully visible).
        anchors.rightMargin: 0 - (menuWidth * (1 - openAmount))
        
        width: menuWidth
        height: menuHeight

//-----------------------------------------------------------------------------------
// NOTCHTAB 
// this shape is the the little glowing inward notch that holds the 4 Buttons, 
// it draws a shape that is slightly smaller than the main panel
//-----------------------------------------------------------------------------------
        Shape {
            id: notchTab

            layer.enabled: true
            layer.samples: 6
            anchors.fill: parent

            ShapePath {
                fillColor: theme.holo.bgtransparent
                strokeColor: theme.holo.border
                strokeWidth: 2
                joinStyle: ShapePath.MiterJoin // Keeps corners sharp, not rounded
                
                startX: 45
                startY: 30

                PathLine {
                    x: notchTab.width
                    y: 30
                }

                PathLine {
                    x: notchTab.width
                    y: notchTab.height - 25
                }

                PathLine {
                    x: 45
                    y: notchTab.height - 25
                }

                PathArc {
                    x: 35
                    y: notchTab.height - 30
                    radiusX: 33
                    radiusY: 30
                }

                PathLine {
                    x: 15
                    y: notchTab.height - 50
                }

                PathArc {
                    x: 10
                    y: notchTab.height - 60
                    radiusX: 33
                    radiusY: 30
                }

                PathLine {
                    x: 10
                    y: 65
                }

                PathArc {
                    x: 15
                    y: 55
                    radiusX: 33
                    radiusY: 30
                }

                PathLine {
                    x: 40
                    y: 35
                }

                PathArc {
                    x: 45
                    y: 30
                    radiusX: 33
                    radiusY: 30
                }
            }

            // THE GLOW EFFECT: makes that holographic glowing effect
            layer.effect: DropShadow {
                horizontalOffset: 0
                verticalOffset: 0
                radius: 10
                samples: 17
                color: theme.holo.shadow
            }
        }

//-----------------------------------------------------------------------------------
// THE SOLID FOREGROUND MAIN PANEL (mainPanel)
// 
// This draws the opaque, solid background that sits ON TOP of notchtab.
// it is the main panel itself.
//-----------------------------------------------------------------------------------
        Shape {
            id: mainPanel

            layer.enabled: true
            layer.samples: 6
            anchors.fill: parent

            ShapePath {
                fillColor: theme.base.bg
                strokeColor: theme.base.border
                strokeWidth: 1
                joinStyle: ShapePath.MiterJoin
                
                startX: 34
                startY: 2

                PathLine {
                    x: mainPanel.width
                    y: 2
                }

                PathLine {
                    x: mainPanel.width
                    y: mainPanel.height - 2
                }

                PathLine {
                    x: 34
                    y: mainPanel.height - 2
                }

                // ── DRAWING THE COMPLEX LEFT NOTCHES ──
                // This traces the intricate cutout geometry for the solid panel.
                // It mirrors the background tab but with tighter radii and different offsets.
                
                PathArc {
                    x: 27
                    y: mainPanel.height - 5
                    radiusX: 33
                    radiusY: 30
                }

                PathLine {
                    x: 3
                    y: mainPanel.height - 29
                }

                PathArc {
                    x: 0
                    y: mainPanel.height - 36
                    radiusX: 33
                    radiusY: 30
                }

                PathLine {
                    x: 0
                    y: mainPanel.height - 293
                }

                PathArc {
                    x: 4
                    y: mainPanel.height - 299
                    radiusX: 33
                    radiusY: 30
                }

                PathLine {
                    x: 46
                    y: mainPanel.height - 320
                }

                // The large sweeping curve for the middle notch
                PathArc {
                    x: 50
                    y: mainPanel.height - 326
                    radiusX: 90
                    radiusY: 90
                }

                PathLine {
                    x: 50
                    y: 326
                }

                PathArc {
                    x: 46
                    y: 320
                    radiusX: 90
                    radiusY: 90
                }

                PathLine {
                    x: 4
                    y: 299
                }

                PathArc {
                    x: 0
                    y: 293
                    radiusX: 33
                    radiusY: 30
                }

                PathLine {
                    x: 0
                    y: 36
                }

                PathArc {
                    x: 3
                    y: 29
                    radiusX: 33
                    radiusY: 30
                }

                PathLine {
                    x: 27
                    y: 5
                }

                PathArc {
                    x: 34
                    y: 2
                    radiusX: 33
                    radiusY: 30
                }
            }

            // THE DEPTH SHADOW: just basic offset shadows
            layer.effect: DropShadow {
                horizontalOffset: -4
                verticalOffset: 3
                radius: 8
                samples: 17
                color: theme.base.shadow
            }
        }

//-----------------------------------------------------------------------------------
// TARGETED FLICKER ANIMATIONS
// 
// These instantiate the "boot glitch" animations. 
// They don't run automatically; they are triggered by the state orchestrator below.
// Each one targets a specific "GlitchGroup" item to make its children flicker.
//-----------------------------------------------------------------------------------
        FlickerAnimation {
            id: audioBootGlitch
            targetItem: audioGlitchGroup
        }

        FlickerAnimation {
            id: networkBootGlitch
            targetItem: networkGlitchGroup
        }
        
        // Added: The notification page was missing its glitch animation instance
        FlickerAnimation {
            id: notifBootGlitch
            targetItem: notifGlitchGroup
        }

//-----------------------------------------------------------------------------------
// STATE ORCHESTRATION: LISTENING FOR CHANGES
// 
// This section connects our UI to the global PanelState.
// It ensures that animations play at the right time (e.g., when the panel opens 
// or when the user switches between Audio/Network/Notif pages).
//-----------------------------------------------------------------------------------
        Connections {
            // Triggered when the user switches pages (Audio <-> Network <-> Notif)
            function onRPanelPageChanged() {
                // Don't play animations if the panel is currently closed
                if (!PanelState.rPanelOpen)
                    return ;

                if (PanelState.rPanelPage === "audio") {
                    networkBootGlitch.stop();
                    notifBootGlitch.stop(); 
                    audioGlitchGroup.opacity = 0;
                    audioBootGlitch.restart();
                } else if (PanelState.rPanelPage === "network") {
                    audioBootGlitch.stop();
                    notifBootGlitch.stop(); 
                    networkGlitchGroup.opacity = 0;
                    networkBootGlitch.restart();
                } else if (PanelState.rPanelPage === "notif") {
                    audioBootGlitch.stop();
                    networkBootGlitch.stop();
                    notifGlitchGroup.opacity = 0;
                    notifBootGlitch.restart();
                }
            }

            // Triggered when the panel is opened or closed
            function onRPanelOpenChanged() {
                if (!PanelState.rPanelOpen) {
                    // If closing, immediately stop all glitch animations and hide them
                    audioBootGlitch.stop();
                    networkBootGlitch.stop();
                    notifBootGlitch.stop();
                    audioGlitchGroup.opacity = 0;
                    networkGlitchGroup.opacity = 0;
                    notifGlitchGroup.opacity = 0;
                }
            }

            target: PanelState
        }

        Connections {
            // Triggered continuously as the menu slides in (openAmount changes from 0 to 1)
            function onOpenAmountChanged() {
                // Wait until the menu is mostly open (60% slid out) before triggering the glitch
                if (menuShape.openAmount > 0.6 && PanelState.rPanelOpen) {
                    if (PanelState.rPanelPage === "audio" && !audioBootGlitch.running) {
                        audioGlitchGroup.opacity = 0;
                        audioBootGlitch.restart();
                    } else if (PanelState.rPanelPage === "network" && !networkBootGlitch.running) {
                        networkGlitchGroup.opacity = 0;
                        networkBootGlitch.restart();
                    } else if (PanelState.rPanelPage === "notif" && !notifBootGlitch.running) {
                        notifGlitchGroup.opacity = 0;
                        notifBootGlitch.restart();
                    }
                }
            }

            target: menuShape
        }

//-----------------------------------------------------------------------------------
// THE AUDIO PAGE
// 
// This is the UI for the Audio controls. 
// It follows a standard pattern:
// 1. An Item that becomes visible ONLY when rPanelPage is "audio".
// 2. A "GlitchGroup" containing the top/bottom sections (these get the flicker effect).
// 3. A central Control element (VolumeControl) that fades in via opacity.
//-----------------------------------------------------------------------------------
        Item {
            id: audioPage

            anchors.fill: parent
            // Only show this page if the state says we are on the audio page
            visible: PanelState.rPanelPage === "audio"

            // The Glitch Group: Everything inside here will flicker when audioBootGlitch runs
            Item {
                id: audioGlitchGroup
                anchors.fill: parent

                // Top section (Output)
                AudioOut {
                    id: audioOut
                    t: theme
                    // Anchored to the top half of the screen, leaving space at the bottom
                    anchors {
                        top: parent.top
                        bottom: parent.bottom
                        left: parent.left
                        right: parent.right
                        leftMargin: 10
                        rightMargin: 10
                        topMargin: 10
                        bottomMargin: 495 // Pushes the bottom edge up to make room for AudioIn
                    }
                }

                // Bottom section (Input)
                AudioIn {
                    id: audioIn
                    t: theme
                    // Anchored to the bottom half, leaving space at the top
                    anchors {
                        top: parent.top
                        bottom: parent.bottom
                        left: parent.left
                        right: parent.right
                        leftMargin: 10
                        rightMargin: 10
                        topMargin: 495 // Pushes the top edge down to make room for AudioOut
                        bottomMargin: 10
                    }
                }
            }

            // The central slider/control area.
            // It doesn't glitch; instead, it smoothly fades in when the page is active.
            VolumeControl {
                id: volumeControl
                t: theme
                
                // Fades to 1 when open and on audio page, otherwise 0
                opacity: (PanelState.rPanelOpen && PanelState.rPanelPage === "audio") ? 1 : 0

                // Positioned in the middle vertical space between the top/bottom sections
                anchors {
                    top: parent.top
                    bottom: parent.bottom
                    left: parent.left
                    right: parent.right
                    leftMargin: 60 // Indented to sit inside the panel's left notch
                    rightMargin: 10
                    topMargin: 320
                    bottomMargin: 320
                }

                // Smooth fade-in/out animation for the opacity change
                Behavior on opacity {
                    NumberAnimation {
                        duration: 350
                        easing.type: Easing.OutQuad
                    }
                }
            }
        }

//-----------------------------------------------------------------------------------
// THE NETWORK PAGE
// 
// Follows the exact same structural pattern as the Audio Page, 
// but displays Network and Bluetooth sections instead.
//-----------------------------------------------------------------------------------
        Item {
            id: networkPage

            anchors.fill: parent
            visible: PanelState.rPanelPage === "network"

            Item {
                id: networkGlitchGroup
                anchors.fill: parent

                NetworkSection {
                    id: networkSection
                    t: theme
                    anchors {
                        top: parent.top
                        bottom: parent.bottom
                        left: parent.left
                        right: parent.right
                        leftMargin: 10
                        rightMargin: 10
                        topMargin: 10
                        bottomMargin: 495
                    }
                }

                BluetoothSection {
                    id: bluetoothSection
                    t: theme
                    anchors {
                        top: parent.top
                        bottom: parent.bottom
                        left: parent.left
                        right: parent.right
                        leftMargin: 10
                        rightMargin: 10
                        topMargin: 495
                        bottomMargin: 10
                    }
                }
            }

            NetworkControl {
                id: networkControl
                t: theme
                opacity: (PanelState.rPanelOpen && PanelState.rPanelPage === "network") ? 1 : 0

                anchors {
                    top: parent.top
                    bottom: parent.bottom
                    left: parent.left
                    right: parent.right
                    leftMargin: 60
                    rightMargin: 10
                    topMargin: 320
                    bottomMargin: 320
                }

                Behavior on opacity {
                    NumberAnimation {
                        duration: 500
                        easing.type: Easing.OutQuad
                    }
                }
            }
        }

//-----------------------------------------------------------------------------------
// THE NOTIFICATION PAGE
// 
// Follows the same pattern, displaying Notifications and Clipboard history.
//-----------------------------------------------------------------------------------
        Item {
            id: notifPage

            anchors.fill: parent
            visible: PanelState.rPanelPage === "notif"

            Item {
                id: notifGlitchGroup
                anchors.fill: parent

                NotifSection {
                    id: notifSection
                    t: theme
                    anchors {
                        top: parent.top
                        bottom: parent.bottom
                        left: parent.left
                        right: parent.right
                        leftMargin: 10
                        rightMargin: 10
                        topMargin: 10
                        bottomMargin: 495
                    }
                }
            }

            NotifControl {
                t: theme
                opacity: (PanelState.rPanelOpen && PanelState.rPanelPage === "notif") ? 1 : 0

                anchors {
                    top: parent.top
                    bottom: parent.bottom
                    left: parent.left
                    right: parent.right
                    leftMargin: 60
                    rightMargin: 10
                    topMargin: 320
                    bottomMargin: 320
                }
                
                // Added: Smooth fade-in/out to match the behavior of the other pages
                Behavior on opacity {
                    NumberAnimation {
                        duration: 350
                        easing.type: Easing.OutQuad
                    }
                }
            }

            ClipboardSection {
                t: theme
                anchors {
                    top: parent.top
                    bottom: parent.bottom
                    left: parent.left
                    right: parent.right
                    leftMargin: 10
                    rightMargin: 10
                    topMargin: 495
                    bottomMargin: 10
                }
            }
        }

//-----------------------------------------------------------------------------------
// SIDE ACCENT ACTION BUTTONS (Navigation)
// 
// This ColumnLayout holds the vertical stack of round buttons on the left side.
// These buttons act as the navigation tabs for the panel.
// and Visually they are Held by the Notchtab Shape
// 
// How they work:
// - They update PanelState.rPanelPage to switch the visible content.
// - They use activeState to visually highlight which page is currently open.
// - The first button is a "Close" button that sets rPanelOpen to false.
//-----------------------------------------------------------------------------------
        ColumnLayout {
            spacing: 10

            // Positioned vertically on the left side, aligned with the middle notch
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                topMargin: 330
                leftMargin: 15
                rightMargin: 12
            }

            // CLOSE BUTTON
            BtnRound {
                t: theme
                icon: "" // 'X' icon
                showShadow: true
                onClicked: PanelState.rPanelOpen = false
            }

            // AUDIO TAB BUTTON
            BtnRound {
                t: theme
                icon: "󰕾" // Speaker icon
                showShadow: true
                // Highlights this button if the panel is open AND we are on the audio page
                activeState: PanelState.rPanelOpen && PanelState.rPanelPage === "audio"
                onClicked: {
                    PanelState.rPanelPage = "audio";
                    PanelState.rPanelOpen = true; // Ensure panel is open when clicking a tab
                }
            }

            // NETWORK TAB BUTTON
            BtnRound {
                t: theme
                icon: "󰖩" // WiFi icon
                showShadow: true
                activeState: PanelState.rPanelOpen && PanelState.rPanelPage === "network"
                onClicked: {
                    PanelState.rPanelPage = "network";
                    PanelState.rPanelOpen = true;
                }
            }

            // NOTIFICATION TAB BUTTON
            BtnRound {
                t: theme
                icon: "󰂚" // Bell icon
                showShadow: true
                activeState: PanelState.rPanelOpen && PanelState.rPanelPage === "notif"
                onClicked: {
                    PanelState.rPanelPage = "notif";
                    PanelState.rPanelOpen = true;
                }
            }
        }

//-----------------------------------------------------------------------------------
// THE SLIDE ANIMATION BEHAVIOR
// 
// This is what makes the menu slide smoothly instead of snapping instantly.
// 
// How it works:
// - Whenever menuShape.openAmount changes (from 0 to 1, or 1 to 0),
//   this Behavior intercepts the change.
// - It applies a 400ms NumberAnimation with an OutCubic easing curve.
// - OutCubic makes the menu start fast and gently decelerate as it locks into place.
//-----------------------------------------------------------------------------------
        Behavior on openAmount {
            NumberAnimation {
                duration: 400
                easing.type: Easing.OutCubic
            }
        }

    }

}
