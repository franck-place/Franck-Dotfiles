import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io

Scope {
    id: root
    
    property string currentTime: ""
    property string currentDate: ""
    property real volumeLevel: 0
    property bool volumeMuted: false
    property int activeWorkspace: -1
    property string mpdSong: "No music playing"
    property bool mpdPlaying: false
    property bool volumeDropdownVisible: false
    property bool menuDropdownVisible: false
    property string username: ""
    property real cpuUsage: 0
    property real memoryUsage: 0
    property real diskUsage: 0
    property var installedApps: []
    property string appSearchQuery: ""
    
    // Main Bar
    Variants {
        model: Quickshell.screens
        delegate: Component {
            PanelWindow {
                property var modelData
                screen: modelData
                
                // Position the bar at the top of the screen
                anchors {
                    top: true
                    left: true
                    right: true
                }
                
                // Bar styling
                implicitHeight: 40
                color: "#80000000"  // Semi-transparent black background
                
                // Bottom border for visual separation
                Rectangle {
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 2
                    color: "#000000"
                }
                
                /**
                 * Main layout container
                 */
                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 8
                    anchors.rightMargin: 8
                    spacing: 12
                    
                    /**
                     * Left section: Menu button and workspace switcher
                     */
                    RowLayout {
                        Layout.alignment: Qt.AlignVCenter
                        spacing: 4
                        
                        // Menu button with hover effect
                        Rectangle {
                            Layout.alignment: Qt.AlignVCenter
                            Layout.preferredHeight: 24
                            Layout.preferredWidth: 50
                            
                            color: root.menuDropdownVisible ? "#45475a" : "transparent"
                            border.color: "transparent"
                            border.width: 0
                            radius: 4
                            
                            Text {
                                anchors.centerIn: parent
                                text: "󰣇"
                                color: "#ffffff"
                                font.pixelSize: 22
                                font.family: "Terminus"
                            }
                            
                            // Click handler for menu toggle
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    console.log("Menu button clicked, current state:", root.menuDropdownVisible)
                                    root.menuDropdownVisible = !root.menuDropdownVisible
                                    if (root.menuDropdownVisible) {
                                        root.appSearchQuery = ""  // Clear search when opening menu
                                    }
                                    console.log("New state:", root.menuDropdownVisible)
                                }
                            }
                        }
                        
                        // Visual separator between menu and workspaces
                        Rectangle {
                            Layout.preferredWidth: 1
                            Layout.preferredHeight: 16
                            color: "#45475a"
                            Layout.alignment: Qt.AlignVCenter
                        }
                        
                        /**
                         * Workspace switcher
                         * Create 10 workspace buttons
                         */
                        Repeater {
                            model: 10
                            delegate: Rectangle {
                                width: 24
                                height: 24
                                radius: 4
                                Layout.alignment: Qt.AlignVCenter
                                
                                property bool hovered: false
                                
                                // Dynamic coloring based on state
                                color: {
                                    if (root.activeWorkspace === (index + 1)) {
                                        "#ffffff"  // Active workspace
                                    } else if (hovered) {
                                        "#45475a"  // Hovered
                                    } else {
                                        "#000000"  // Inactive
                                    }
                                }
                                
                                // Workspace number
                                Text {
                                    anchors.centerIn: parent
                                    text: index + 1
                                    color: root.activeWorkspace === (index + 1) ? "#000000" : "#cdd6f4"
                                    font.pixelSize: 14
                                    font.family: "Terminus"
                                }
                                
                                // Interaction handling
                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onEntered: parent.hovered = true
                                    onExited: parent.hovered = false
                                    onClicked: {
                                        root.activeWorkspace = index + 1
                                        // Use Hyprland's dispatch system to switch workspaces
                                        hyprlandDispatch.command = ["hyprctl", "dispatch", "workspace", (index + 1).toString()]
                                        hyprlandDispatch.running = true
                                    }
                                }
                            }
                        }
                    }
                    
                    /**
                     * Center section: MPD module
                     * Show current playing song from MPD
                     */
                    Item {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                        Layout.preferredHeight: 28
                        
                        RowLayout {
                            anchors.centerIn: parent
                            spacing: 8
                            visible: root.mpdSong !== "No music playing"
                            
                            // Play/Pause indicator
                            Rectangle {
                                width: 28
                                height: 28
                                radius: 3
                                color: "transparent"
                                Layout.alignment: Qt.AlignVCenter
                                
                                Text {
                                    anchors.centerIn: parent
                                    text: root.mpdPlaying ? "󰐊" : "󰏤"
                                    color: "#ffffff"
                                    font.pixelSize: 14
                                    font.family: "Terminus"
                                }
                            }
                            
                            // Song title
                            Text {
                                text: root.mpdSong
                                color: "#cdd6f4"
                                font.pixelSize: 14
                                font.family: "Terminus"
                                elide: Text.ElideRight
                                maximumLineCount: 1
                                Layout.alignment: Qt.AlignVCenter
                                Layout.maximumWidth: 300
                            }
                        }
                    }
                    
                    /**
                     * Right section: System indicators and control
                     */
                    RowLayout {
                        Layout.alignment: Qt.AlignVCenter
                        spacing: 8
                        
                         // Volume control widget
                        Item {
                            Layout.alignment: Qt.AlignVCenter
                            Layout.preferredHeight: 24
                            Layout.preferredWidth: volumeRow.implicitWidth
                            
                            RowLayout {
                                id: volumeRow
                                spacing: 4
                                anchors.centerIn: parent
                                
                                // Volume icon changes based on mute state
                                Text {
                                    text: root.volumeMuted ? "󰖁" : "󰕾"
                                    color: "#ffffff"
                                    font.pixelSize: 14
                                    font.family: "Terminus"
                                    Layout.alignment: Qt.AlignVCenter
                                }
                                
                                // Volume percentage or mute statu
                                Text {
                                    text: root.volumeMuted ? "Muted" : Math.round(root.volumeLevel) + "%"
                                    color: "#ffffff"
                                    font.pixelSize: 14
                                    font.family: "Terminus"
                                    Layout.alignment: Qt.AlignVCenter
                                }
                            }
                            
                            // Click to show volume dropdown
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    root.volumeDropdownVisible = !root.volumeDropdownVisible
                                }
                            }
                        }
                        
                        // Separator
                        Rectangle {
                            Layout.preferredWidth: 1
                            Layout.preferredHeight: 16
                            color: "#45475a"
                            Layout.alignment: Qt.AlignVCenter
                        }
                        
                        // Separator before date/time
                        Item {
                            Layout.preferredWidth: 7
                            Layout.preferredHeight: 1
                            Layout.alignment: Qt.AlignVCenter
                        }
                        
                        // Date Display
                        Item {
                            Layout.alignment: Qt.AlignVCenter
                            Layout.preferredHeight: 24
                            Layout.preferredWidth: Math.max(dateText.implicitWidth, 80)
                            
                            Text {
                                id: dateText
                                anchors.centerIn: parent
                                text: root.currentDate
                                color: "#ffffff"
                                font.pixelSize: 14
                                font.family: "Terminus"
                            }
                        }
                        
                        // Separator
                        Item {
                            Layout.preferredWidth: 7
                            Layout.preferredHeight: 1
                            Layout.alignment: Qt.AlignVCenter
                        }
                        
                        // Clock
                        Item {
                            Layout.alignment: Qt.AlignVCenter
                            Layout.preferredHeight: 24
                            Layout.preferredWidth: Math.max(timeText.implicitWidth, 60)
                            
                            Text {
                                id: timeText
                                anchors.centerIn: parent
                                text: root.currentTime
                                color: "#ffffff"
                                font.bold: true
                                font.pixelSize: 14
                                font.family: "Terminus"
                            }
                        }
                    }
                }
            }
        }
    }
    
    /**
     * Menu dropdown window
     * application launcher and system control
     */
    Variants {
        model: root.menuDropdownVisible ? Quickshell.screens : []
        delegate: Component {
            PanelWindow {
                property var modelData
                screen: modelData
                
                // Full screen to catch clicks outside menu
                anchors {
                    top: true
                    left: true
                    right: true
                    bottom: true
                }
                
                color: "transparent"
                
                // Click outside to close menu
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        console.log("Click outside detected, closing menu")
                        root.menuDropdownVisible = false
                    }
                }
                
                /**
                 * Menu dropdown content
                 * system info, app launcher, and power option
                 */
                Rectangle {
                    id: menuDropdown
                    x: 8
                    y: 41  // Position below the main bar
                    width: 350
                    height: 575
                    color: "#80000000"
                    radius: 8
                    border.color: "#45475a"
                    border.width: 1
                    z: 1000
                    
                    // Smooth fade-in/scale animation
                    opacity: root.menuDropdownVisible ? 1.0 : 0.0
                    scale: root.menuDropdownVisible ? 1.0 : 0.8
                    
                    Behavior on opacity {
                        NumberAnimation {
                            duration: 200
                            easing.type: Easing.OutQuad
                        }
                    }
                    
                    Behavior on scale {
                        NumberAnimation {
                            duration: 200
                            easing.type: Easing.OutBack
                            easing.overshoot: 0.2
                        }
                    }
                    
                    // Prevent click from closing menu when clicking inside
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                        }
                    }
                    
                    /**
                     * Menu content layout
                     */
                    Column {
                        anchors.fill: parent
                        anchors.margins: 15
                        spacing: 8
                        anchors.bottomMargin: 15
                        
                        // Username header
                        Text {
                            text: root.username || "User"
                            color: "#ffffff"
                            font.pixelSize: 14
                            font.family: "Terminus"
                            font.bold: true
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                        
                        Rectangle {
                            width: parent.width
                            height: 1
                            color: "#45475a"
                        }
                        
                        /**
                         * System monitoring section
                         * CPU, memory, and disk usage
                         */
                        Text {
                            text: "System Information"
                            color: "#ffffff"
                            font.pixelSize: 14
                            font.family: "Terminus"
                            font.bold: true
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                        
                        // System monitoring
                        Row {
                            anchors.horizontalCenter: parent.horizontalCenter
                            spacing: 15
                            
                            // CPU Usage
                            Column {
                                spacing: 4
                                
                                Text {
                                    text: "CPU"
                                    color: "#ffffff"
                                    font.pixelSize: 12
                                    font.family: "Terminus"
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }
                                
                                Rectangle {
                                    width: 60
                                    height: 60
                                    color: "transparent"
                                    border.color: "#45475a"
                                    border.width: 2
                                    radius: 30
                                    
                                    Text {
                                        anchors.centerIn: parent
                                        text: "󰻠"
                                        color: "#ffffff"  // Always white
                                        font.pixelSize: 24
                                        font.family: "Terminus"
                                    }
                                    
                                    // Progress indicator
                                    Canvas {
                                        anchors.fill: parent
                                        rotation: -90
                                        
                                        property real progress: root.cpuUsage
                                        
                                        onProgressChanged: requestPaint()
                                        
                                        onPaint: {
                                            var ctx = getContext("2d")
                                            ctx.clearRect(0, 0, width, height)
                                            
                                            var centerX = width / 2
                                            var centerY = height / 2
                                            var radius = 28
                                            
                                            // Progress arc
                                            ctx.beginPath()
                                            ctx.arc(centerX, centerY, radius, 0, (progress / 100) * 2 * Math.PI)
                                            ctx.lineWidth = 3
                                            ctx.strokeStyle = "#ffffff"  // Always white
                                            ctx.stroke()
                                        }
                                    }
                                }
                                
                                Text {
                                    text: Math.round(root.cpuUsage) + "%"
                                    color: "#ffffff"
                                    font.pixelSize: 12
                                    font.family: "Terminus"
                                    font.bold: true
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }
                            }
                            
                            // Memory Usage
                            Column {
                                spacing: 4
                                
                                Text {
                                    text: "Memory"
                                    color: "#ffffff"
                                    font.pixelSize: 12
                                    font.family: "Terminus"
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }
                                
                                Rectangle {
                                    width: 60
                                    height: 60
                                    color: "transparent"
                                    border.color: "#45475a"
                                    border.width: 2
                                    radius: 30
                                    
                                    Text {
                                        anchors.centerIn: parent
                                        text: "󰍛"
                                        color: "#ffffff"  // Always white
                                        font.pixelSize: 24
                                        font.family: "Terminus"
                                    }
                                    
                                    // Progress indicator
                                    Canvas {
                                        anchors.fill: parent
                                        rotation: -90
                                        
                                        property real progress: root.memoryUsage
                                        
                                        onProgressChanged: requestPaint()
                                        
                                        onPaint: {
                                            var ctx = getContext("2d")
                                            ctx.clearRect(0, 0, width, height)
                                            
                                            var centerX = width / 2
                                            var centerY = height / 2
                                            var radius = 28
                                            
                                            // Progress arc
                                            ctx.beginPath()
                                            ctx.arc(centerX, centerY, radius, 0, (progress / 100) * 2 * Math.PI)
                                            ctx.lineWidth = 3
                                            ctx.strokeStyle = "#ffffff"  // Always white
                                            ctx.stroke()
                                        }
                                    }
                                }
                                
                                Text {
                                    text: Math.round(root.memoryUsage) + "%"
                                    color: "#ffffff"
                                    font.pixelSize: 12
                                    font.family: "Terminus"
                                    font.bold: true
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }
                            }
                            
                            // Disk Usage
                            Column {
                                spacing: 4
                                
                                Text {
                                    text: "Disk"
                                    color: "#ffffff"
                                    font.pixelSize: 12
                                    font.family: "Terminus"
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }
                                
                                Rectangle {
                                    width: 60
                                    height: 60
                                    color: "transparent"
                                    border.color: "#45475a"
                                    border.width: 2
                                    radius: 30
                                    
                                    Text {
                                        anchors.centerIn: parent
                                        text: "󰋊"
                                        color: "#ffffff"  // Always white
                                        font.pixelSize: 24
                                        font.family: "Terminus"
                                    }
                                    
                                    // Progress indicator
                                    Canvas {
                                        anchors.fill: parent
                                        rotation: -90
                                        
                                        property real progress: root.diskUsage
                                        
                                        onProgressChanged: requestPaint()
                                        
                                        onPaint: {
                                            var ctx = getContext("2d")
                                            ctx.clearRect(0, 0, width, height)
                                            
                                            var centerX = width / 2
                                            var centerY = height / 2
                                            var radius = 28
                                            
                                            // Progress arc
                                            ctx.beginPath()
                                            ctx.arc(centerX, centerY, radius, 0, (progress / 100) * 2 * Math.PI)
                                            ctx.lineWidth = 3
                                            ctx.strokeStyle = "#ffffff"  // Always white
                                            ctx.stroke()
                                        }
                                    }
                                }
                                
                                Text {
                                    text: Math.round(root.diskUsage) + "%"
                                    color: "#ffffff"
                                    font.pixelSize: 12
                                    font.family: "Terminus"
                                    font.bold: true
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }
                            }
                        }
                        
                        Rectangle {
                            width: parent.width
                            height: 1
                            color: "#45475a"
                        }
                        
                        /**
                         * Application section with search
                         */
                        Text {
                            text: "Applications"
                            color: "#ffffff"
                            font.pixelSize: 14
                            font.family: "Terminus"
                            font.bold: true
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                        
                        // Search input field
                        Rectangle {
                            width: parent.width
                            height: 30
                            color: "#313244"
                            radius: 4
                            border.color: searchInput.activeFocus ? "#ffffff" : "#45475a"
                            border.width: 1
                            
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    searchInput.forceActiveFocus()
                                }
                            }
                            
                            Row {
                                anchors.left: parent.left
                                anchors.leftMargin: 8
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 6
                                
                                Text {
                                    text: "󰍉"
                                    color: "#ffffff"
                                    font.pixelSize: 14
                                    font.family: "Terminus"
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                                
                                TextInput {
                                    id: searchInput
                                    width: menuDropdown.width - 60
                                    color: "#ffffff"
                                    font.pixelSize: 13
                                    font.family: "Terminus"
                                    anchors.verticalCenter: parent.verticalCenter
                                    clip: true
                                    selectByMouse: true
                                    focus: root.menuDropdownVisible  // Get focus when menu opens
                                    
                                    property string placeholderText: "Search applications..."
                                    
                                    Text {
                                        text: parent.placeholderText
                                        color: "#6c7086"
                                        font: parent.font
                                        visible: parent.text.length === 0
                                    }
                                    
                                    onTextChanged: root.appSearchQuery = text
                                    
                                    Keys.onEscapePressed: {
                                        root.menuDropdownVisible = false
                                        root.appSearchQuery = ""
                                    }
                                    
                                    Keys.onEnterPressed: {
                                        // Launch first app in filtered list
                                        if (appListView.count > 0) {
                                            var firstApp = appListView.model[0]
                                            console.log("Launching app:", firstApp.exec)
                                            launchAppProcess.command = ["sh", "-c", firstApp.exec]
                                            launchAppProcess.running = true
                                            root.menuDropdownVisible = false
                                            root.appSearchQuery = ""
                                        }
                                    }
                                    
                                    Keys.onReturnPressed: {
                                        // Same as Enter
                                        if (appListView.count > 0) {
                                            var firstApp = appListView.model[0]
                                            console.log("Launching app:", firstApp.exec)
                                            launchAppProcess.command = ["sh", "-c", firstApp.exec]
                                            launchAppProcess.running = true
                                            root.menuDropdownVisible = false
                                            root.appSearchQuery = ""
                                        }
                                    }
                                }
                            }
                        }
                        
                        Rectangle {
                            width: parent.width
                            height: 1
                            color: "#45475a"
                        }
                        
                        /**
                         * Scrollable application list
                         */
                        Item {
                            width: parent.width
                            height: 180  // Fixed height for scrollable area
                            
                            ListView {
                                id: appListView
                                anchors.fill: parent
                                clip: true
                                spacing: 2
                                boundsBehavior: Flickable.StopAtBounds
                                interactive: true
                                
                                // Ensure scroll events are handled properly
                                MouseArea {
                                    anchors.fill: parent
                                    propagateComposedEvents: true
                                    
                                    onWheel: function(wheel) {
                                        // Handle scrolling
                                        var delta = wheel.angleDelta.y / 120
                                        appListView.contentY -= delta * 40
                                        wheel.accepted = true
                                    }
                                    
                                    onPressed: function(mouse) {
                                        mouse.accepted = false
                                    }
                                }
                                
                                model: {
                                    if (root.appSearchQuery.length === 0) {
                                        return root.installedApps
                                    } else {
                                        return root.installedApps.filter(function(app) {
                                            return app.name.toLowerCase().includes(root.appSearchQuery.toLowerCase()) ||
                                                   app.exec.toLowerCase().includes(root.appSearchQuery.toLowerCase())
                                        })
                                    }
                                }
                                
                                delegate: Rectangle {
                                    width: 310
                                    height: 32
                                    color: appMouseArea.hovered ? "#45475a" : "transparent"
                                    radius: 4
                                    
                                    Row {
                                        anchors.left: parent.left
                                        anchors.leftMargin: 8
                                        anchors.verticalCenter: parent.verticalCenter
                                        spacing: 12
                                        
                                        // Application icon placeholder
                                        Text {
                                            text: modelData.icon || "󰀻"
                                            color: "#ffffff"
                                            font.pixelSize: 16
                                            font.family: "Terminus"
                                            anchors.verticalCenter: parent.verticalCenter
                                        }
                                        
                                        // Application name
                                        Text {
                                            text: modelData.name
                                            color: "#ffffff"
                                            font.pixelSize: 14
                                            font.family: "Terminus"
                                            anchors.verticalCenter: parent.verticalCenter
                                        }
                                    }
                                    
                                    // Launch application on click
                                    MouseArea {
                                        id: appMouseArea
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        z: 10
                                        
                                        property bool hovered: false
                                        
                                        onEntered: hovered = true
                                        onExited: hovered = false
                                        onClicked: {
                                            console.log("Launching app:", modelData.exec)
                                            launchAppProcess.command = ["sh", "-c", modelData.exec]
                                            launchAppProcess.running = true
                                            root.menuDropdownVisible = false
                                            root.appSearchQuery = ""  // Clear search on close
                                        }
                                    }
                                }
                                
                                // Scrollbar
                                ScrollBar.vertical: ScrollBar {
                                    width: 6
                                    policy: ScrollBar.AsNeeded
                                    
                                    contentItem: Rectangle {
                                        radius: 3
                                        color: "#45475a"
                                    }
                                }
                            }
                            
                            // Show message when no apps found
                            Text {
                                anchors.centerIn: parent
                                text: "No applications found"
                                color: "#6c7086"
                                font.pixelSize: 13
                                font.family: "Terminus"
                                visible: appListView.count === 0
                            }
                        }
                        
                        Rectangle {
                            width: parent.width
                            height: 1
                            color: "#45475a"
                        }
                        
                        Item {
                            width: parent.width
                            height: 10
                        }
                        
                        /**
                         * Power option
                         * Logout, restart, and shutdown controls
                         */
                        Row {
                            anchors.horizontalCenter: parent.horizontalCenter
                            spacing: 12
                            
                            Repeater {
                                model: [
                                    { name: "Logout", icon: "󰍃", command: "hyprctl dispatch exit" },
                                    { name: "Restart", icon: "󰜉", command: "systemctl reboot" },
                                    { name: "Shutdown", icon: "󰐥", command: "systemctl poweroff" }
                                ]
                                
                                delegate: Rectangle {
                                    width: 70
                                    height: 60
                                    color: powerMouseArea.hovered ? "#45475a" : "transparent"
                                    radius: 6
                                    border.color: "#45475a"
                                    border.width: 1
                                    
                                    property var powerData: modelData
                                    
                                    Column {
                                        anchors.centerIn: parent
                                        spacing: 6
                                        
                                        // Power action icon
                                        Text {
                                            text: powerData.icon
                                            color: "#ffffff"
                                            font.pixelSize: 20
                                            font.family: "Terminus"
                                            anchors.horizontalCenter: parent.horizontalCenter
                                        }
                                        
                                        // Power action label
                                        Text {
                                            text: powerData.name
                                            color: "#ffffff"
                                            font.pixelSize: 12
                                            font.family: "Terminus"
                                            anchors.horizontalCenter: parent.horizontalCenter
                                        }
                                    }
                                    
                                    // Execute power action on click
                                    MouseArea {
                                        id: powerMouseArea
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        z: 10
                                        
                                        property bool hovered: false
                                        
                                        onEntered: hovered = true
                                        onExited: hovered = false
                                        onClicked: {
                                            console.log("Power action:", powerData.command)
                                            powerActionProcess.command = ["sh", "-c", powerData.command]
                                            powerActionProcess.running = true
                                            root.menuDropdownVisible = false
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    /**
     * Volume control dropdown
     * slider and mute toggle
     */
    Variants {
        model: root.volumeDropdownVisible ? Quickshell.screens : []
        delegate: Component {
            PanelWindow {
                property var modelData
                screen: modelData
                
                implicitWidth: 250
                implicitHeight: 80
                
                // Position below the volume indicator
                anchors {
                    top: true
                    right: true
                }
                
                margins {
                    top: 41
                    right: 50
                }
                
                color: "transparent"
                
                Rectangle {
                    anchors.fill: parent
                    color: "#80000000"
                    radius: 8
                    border.color: "#45475a"
                    border.width: 1
                    
                    // Smooth animation
                    opacity: root.volumeDropdownVisible ? 1.0 : 0.0
                    scale: root.volumeDropdownVisible ? 1.0 : 0.8
                    
                    Behavior on opacity {
                        NumberAnimation {
                            duration: 200
                            easing.type: Easing.OutQuad
                        }
                    }
                    
                    Behavior on scale {
                        NumberAnimation {
                            duration: 200
                            easing.type: Easing.OutBack
                            easing.overshoot: 0.2
                        }
                    }
                    
                    Column {
                        anchors.fill: parent
                        anchors.margins: 15
                        spacing: 10
                        
                        /**
                         * Volume slider control
                         */
                        Row {
                            spacing: 8
                            anchors.horizontalCenter: parent.horizontalCenter
                            
                            Text {
                                text: "Volume"
                                color: "#ffffff"
                                font.pixelSize: 14
                                font.family: "Terminus"
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            
                            // Volume slider background
                            Rectangle {
                                width: 100
                                height: 6
                                color: "#313244"
                                radius: 3
                                anchors.verticalCenter: parent.verticalCenter
                                
                                // Volume level fill
                                Rectangle {
                                    width: (root.volumeLevel / 200) * parent.width
                                    height: parent.height
                                    color: "#ffffff"
                                    radius: 3
                                }
                                
                                // Volume handle
                                Rectangle {
                                    id: volumeHandle
                                    width: 12
                                    height: 12
                                    radius: 6
                                    color: "#ffffff"
                                    border.color: "#313244"
                                    border.width: 1
                                    
                                    x: (root.volumeLevel / 200) * (parent.width - width)
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                                
                                // Volume adjustment
                                MouseArea {
                                    anchors.fill: parent
                                    
                                    property bool dragging: false
                                    
                                    onPressed: function(mouse) {
                                        dragging = true
                                        updateVolume(mouse.x)
                                    }
                                    
                                    onPositionChanged: function(mouse) {
                                        if (dragging) {
                                            updateVolume(mouse.x)
                                        }
                                    }
                                    
                                    onReleased: function(mouse) {
                                        dragging = false
                                    }
                                    
                                    /**
                                     * Update system volume based on mouse position
                                     * Use wpctl for PipeWire control
                                     */
                                    function updateVolume(mouseX) {
                                        var newVolume = Math.max(0, Math.min(200, Math.round((mouseX / width) * 200)))
                                        setVolumeProcess.command = ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", newVolume + "%"]
                                        setVolumeProcess.running = true
                                        root.volumeLevel = newVolume
                                    }
                                }
                            }
                            
                            // Volume percentage display
                            Text {
                                text: Math.round(root.volumeLevel) + "%"
                                color: "#ffffff"
                                font.pixelSize: 14
                                font.family: "Terminus"
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                        
                        /**
                         * Mute toggle button
                         */
                        Rectangle {
                            width: 100
                            height: 25
                            color: root.volumeMuted ? "#ffffff" : "#000000"
                            radius: 4
                            anchors.horizontalCenter: parent.horizontalCenter
                            
                            Text {
                                anchors.centerIn: parent
                                text: root.volumeMuted ? "Unmute" : "Mute"
                                color: root.volumeMuted ? "#000000" : "#ffffff"
                                font.pixelSize: 14
                                font.family: "Terminus"
                            }
                            
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    toggleMuteProcess.command = ["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "toggle"]
                                    toggleMuteProcess.running = true
                                }
                            }
                        }
                    }
                    
                    // Click outside to close dropdown
                    MouseArea {
                        anchors.fill: parent
                        z: -1
                        onClicked: root.volumeDropdownVisible = false
                    }
                }
            }
        }
    }
    
    /**
     * Timer for updating active workspace
     */
    Timer {
        interval: 500
        running: true
        repeat: true
        onTriggered: getCurrentWorkspace.running = true
    }
    
    // Get current active workspace
    Process {
        id: getCurrentWorkspace
        command: ["hyprctl", "activeworkspace", "-j"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    var workspace = JSON.parse(text.trim())
                    root.activeWorkspace = workspace.id || 1
                } catch (e) {
                    root.activeWorkspace = 1
                }
            }
        }
    }
    
    // Set system volume
    Process {
        id: setVolumeProcess
    }
    
    // Toggle mute state
    Process {
        id: toggleMuteProcess
    }
    
    // Switch workspace
    Process {
        id: hyprlandDispatch
    }
    
    // Launch applications
    Process {
        id: launchAppProcess
    }
    
    // Get current username
    Process {
        id: usernameProcess
        command: ["whoami"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: root.username = text.trim()
        }
    }
    
    // Execute power actions (logout/restart/shutdown)
    Process {
        id: powerActionProcess
    }
    
    /**
     * System monitoring
     */
    
    // CPU usage
    Process {
        id: cpuUsageProcess
        command: ["sh", "-c", "top -bn1 | grep 'Cpu(s)' | awk '{print $2}' | cut -d'%' -f1"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                var usage = parseFloat(text.trim())
                root.cpuUsage = isNaN(usage) ? 0 : usage
            }
        }
    }
    
    // Memory usage
    Process {
        id: memoryUsageProcess
        command: ["sh", "-c", "free | grep Mem | awk '{print ($2-$7)/$2 * 100.0}'"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                var usage = parseFloat(text.trim())
                root.memoryUsage = isNaN(usage) ? 0 : usage
            }
        }
    }
    
    // Disk usage
    Process {
        id: diskUsageProcess
        command: ["sh", "-c", "df -h / | awk 'NR==2 {print $5}' | sed 's/%//'"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                var usage = parseFloat(text.trim())
                root.diskUsage = isNaN(usage) ? 0 : usage
            }
        }
    }
    
    // Get installed application from desktop files
    Process {
        id: getInstalledAppsProcess
        command: ["sh", "-c", "for f in /usr/share/applications/*.desktop ~/.local/share/applications/*.desktop; do [ -f \"$f\" ] && awk -F= '/^Name=/{name=$2} /^Exec=/{exec=$2; gsub(/%[FfUu]/, \"\", exec)} /^Icon=/{icon=$2} END{if(name && exec) printf \"%s|%s|%s\\n\", name, exec, icon}' \"$f\" 2>/dev/null; done | sort -u"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    var apps = []
                    var lines = text.trim().split('\n')
                    for (var i = 0; i < lines.length; i++) {
                        if (lines[i].trim()) {
                            var parts = lines[i].split('|')
                            if (parts.length >= 2) {
                                var app = {
                                    name: parts[0].trim(),
                                    exec: parts[1].trim(),
                                    icon: parts[2] ? parts[2].trim() : ""
                                }
                                
                                // Map some common icons to nerd font icons
                                if (app.icon) {
                                    var iconMap = {
                                        "firefox": "󰈹",
                                        "chromium": "󰊯",
                                        "chrome": "󰊯",
                                        "code": "",
                                        "vscode": "",
                                        "steam": "󰓓",
                                        "discord": "󰙯",
                                        "thunar": "󰉋",
                                        "nautilus": "󰉋",
                                        "dolphin": "󰉋",
                                        "gimp": "󰹑",
                                        "vlc": "󰕼",
                                        "mpv": "󰐹",
                                        "spotify": "󰓇",
                                        "telegram": "󰔶",
                                        "thunderbird": "󰇮",
                                        "libreoffice": "󰏆",
                                        "obs": "󰕧",
                                        "kitty": "󰆍",
                                        "ghostty": "󰆍",
                                        "transmission": "󰶘",
                                        "qbittorrent": "󰶘",
                                        "ark": "󰗄",
                                        "rhythmbox": "󰓃",
                                        "clementine": "󰓃",
                                    }
                                    
                                    var iconLower = app.icon.toLowerCase()
                                    var matched = false
                                    for (var key in iconMap) {
                                        if (iconLower.includes(key)) {
                                            app.icon = iconMap[key]
                                            matched = true
                                            break
                                        }
                                    }
                                    
                                    // If no match found, use generic icon
                                    if (!matched) {
                                        app.icon = "󰀻"
                                    }
                                } else {
                                    app.icon = "󰀻"
                                }
                                apps.push(app)
                            }
                        }
                    }
                    root.installedApps = apps
                    console.log("Loaded", apps.length, "applications")
                } catch (e) {
                    console.log("Error parsing apps:", e)
                    root.installedApps = []
                }
            }
        }
    }
    
    /**
     * Timer for system monitoring update
     */
    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: {
            cpuUsageProcess.running = true
            memoryUsageProcess.running = true
            diskUsageProcess.running = true
        }
    }
    
    /**
     * MPD integration
     */
    
    // Get current playing song
    Process {
        id: mpdProcess
        command: ["mpc", "current", "-f", "%artist% - %title%"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                var song = text.trim()
                if (song !== "" && !song.includes("error") && !song.includes("not connected")) {
                    root.mpdSong = song
                } else {
                    root.mpdSong = "No music playing"
                }
            }
        }
    }
    
    // Get MPD playing status
    Process {
        id: mpdStatusProcess
        command: ["mpc", "status"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                var status = text.trim()
                var isPlaying = status.includes("[playing]")
                root.mpdPlaying = isPlaying
            }
        }
    }
    
    /**
     * Check every 2 seconds for song change
     */
    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: {
            mpdProcess.running = true
            mpdStatusProcess.running = true
        }
    }
    
    /**
     * Date and time process
     */
    
    // Get current date
    Process {
        id: dateProcess
        command: ["date", "+%a %b %d"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: root.currentDate = text.trim()
        }
    }
    
    // Get current time
    Process {
        id: timeProcess
        command: ["date", "+%H:%M"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: root.currentTime = text.trim()
        }
    }
    
    /**
     * Timer for date/time update
     */
    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            dateProcess.running = true
            timeProcess.running = true
        }
    }
    
    /**
     * Timer for refreshing application list
     */
    Timer {
        interval: 30000
        running: true
        repeat: true
        onTriggered: getInstalledAppsProcess.running = true
    }
    
    /**
     * Audio system monitoring
     */
    
    // Get current volume level
    Process {
        id: volumeProcess
        command: ["sh", "-c", "wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print $2*100}'"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                root.volumeLevel = parseInt(text.trim()) || 0
            }
        }
    }
    
    // Get mute status
    Process {
        id: muteProcess
        command: ["sh", "-c", "wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -q 'MUTED' && echo 'true' || echo 'false'"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: root.volumeMuted = text.trim() === "true"
        }
    }
    
    /**
     * Timer for audio status updates
     */
    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            volumeProcess.running = true
            muteProcess.running = true
        }
    }
    
    /**
     * Component initialization
     */
    Component.onCompleted: {
        getCurrentWorkspace.running = true
        mpdProcess.running = true
        mpdStatusProcess.running = true
        dateProcess.running = true
        timeProcess.running = true
        volumeProcess.running = true
        muteProcess.running = true
        usernameProcess.running = true
        cpuUsageProcess.running = true
        memoryUsageProcess.running = true
        diskUsageProcess.running = true
        getInstalledAppsProcess.running = true
    }
}