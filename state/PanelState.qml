import QtQuick
pragma Singleton

QtObject {
    property bool rPanelOpen: false
    property bool lPanelOpen: false
    property bool cPanelOpen: false
    property bool settingPanelOpen: false

    property string activePage: "session"
    property string rPanelPage: "audio"

    property string pendingAction: ""
    property string pendingCmd: ""

    // WiFi password prompt — stores the network object clicked in NetworkSection
    // WifiPasswordControl reads this to know which network to connect to
    property var wifiTarget: null
}
