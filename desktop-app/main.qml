import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ApplicationWindow {
    id: root
    visible: true
    width: 1040
    height: 720
    minimumWidth: 920
    minimumHeight: 640
    title: "Liquid Light Glass — SketchUp 2026 Controller"
    color: "#080B11"

    // --- Color Palette: Liquid Light Glass ---
    readonly property color colBg: "#080B11"
    readonly property color colGlassCard: Qt.rgba(0.07, 0.11, 0.20, 0.62)
    readonly property color colGlassBorder: Qt.rgba(1.0, 1.0, 1.0, 0.14)
    readonly property color colGlassBorderHighlight: Qt.rgba(0.0, 0.94, 1.0, 0.40)
    readonly property color colCyanGlow: "#00F0FF"
    readonly property color colVioletGlow: "#9D4EDD"
    readonly property color colEmeraldGlow: "#00E599"
    readonly property color colAmberGlow: "#FF9E00"
    readonly property color colTextPrimary: "#FFFFFF"
    readonly property color colTextSecondary: "#8A99AD"

    property int activeTab: 0

    // Toast state
    property string toastMsg: ""
    property bool toastSuccess: true
    property bool toastVisible: false

    Connections {
        target: backend
        function onActionFinished(message, success) {
            toastMsg = message
            toastSuccess = success
            toastVisible = true
            toastTimer.restart()
        }
    }

    Timer {
        id: toastTimer
        interval: 3800
        onTriggered: toastVisible = false
    }

    // =========================================================================
    // BACKGROUND: LIQUID LIGHT FIELD (Animated fluid ambient glow)
    // =========================================================================
    Item {
        anchors.fill: parent
        z: 0

        // Cyan Orb (Top-Left)
        Rectangle {
            id: orb1
            width: 520
            height: 520
            radius: 260
            x: -80
            y: -100
            opacity: 0.28
            gradient: Gradient {
                GradientStop { position: 0.0; color: colCyanGlow }
                GradientStop { position: 0.6; color: Qt.rgba(0.0, 0.8, 1.0, 0.15) }
                GradientStop { position: 1.0; color: "transparent" }
            }
            SequentialAnimation on y {
                loops: Animation.Infinite
                NumberAnimation { to: -50; duration: 6000; easing.type: Easing.InOutQuad }
                NumberAnimation { to: -100; duration: 6000; easing.type: Easing.InOutQuad }
            }
            SequentialAnimation on x {
                loops: Animation.Infinite
                NumberAnimation { to: -40; duration: 8000; easing.type: Easing.InOutQuad }
                NumberAnimation { to: -80; duration: 8000; easing.type: Easing.InOutQuad }
            }
        }

        // Violet Orb (Bottom-Right)
        Rectangle {
            id: orb2
            width: 580
            height: 580
            radius: 290
            x: orb2.parent ? orb2.parent.width - 450 : 500
            y: orb2.parent ? orb2.parent.height - 450 : 300
            opacity: 0.24
            gradient: Gradient {
                GradientStop { position: 0.0; color: colVioletGlow }
                GradientStop { position: 0.55; color: Qt.rgba(0.6, 0.2, 0.9, 0.12) }
                GradientStop { position: 1.0; color: "transparent" }
            }
            SequentialAnimation on x {
                loops: Animation.Infinite
                NumberAnimation { to: 550; duration: 7000; easing.type: Easing.InOutQuad }
                NumberAnimation { to: 500; duration: 7000; easing.type: Easing.InOutQuad }
            }
            SequentialAnimation on y {
                loops: Animation.Infinite
                NumberAnimation { to: 350; duration: 9000; easing.type: Easing.InOutQuad }
                NumberAnimation { to: 300; duration: 9000; easing.type: Easing.InOutQuad }
            }
        }

        // Emerald Center Orb (Breathing)
        Rectangle {
            id: orb3
            width: 440
            height: 440
            radius: 220
            x: (parent.width - width) / 2
            y: 120
            opacity: 0.16
            gradient: Gradient {
                GradientStop { position: 0.0; color: colEmeraldGlow }
                GradientStop { position: 0.65; color: Qt.rgba(0.0, 0.9, 0.6, 0.08) }
                GradientStop { position: 1.0; color: "transparent" }
            }
            SequentialAnimation on opacity {
                loops: Animation.Infinite
                NumberAnimation { to: 0.26; duration: 4000; easing.type: Easing.InOutSine }
                NumberAnimation { to: 0.14; duration: 4000; easing.type: Easing.InOutSine }
            }
        }
    }

    // =========================================================================
    // MAIN CONTAINER (Foreground Glass Layer)
    // =========================================================================
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 18
        z: 1

        // ---------------------------------------------------------------------
        // HEADER BAR: Liquid Branding & Real-time Connection Status
        // ---------------------------------------------------------------------
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 70
            radius: 18
            color: colGlassCard
            border.width: 1
            border.color: colGlassBorder

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 20
                anchors.rightMargin: 20
                spacing: 16

                // Brand Logo / Icon
                Rectangle {
                    width: 42
                    height: 42
                    radius: 12
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: colCyanGlow }
                        GradientStop { position: 1.0; color: colVioletGlow }
                    }
                    Text {
                        anchors.centerIn: parent
                        text: "⌘"
                        font.pixelSize: 22
                        font.bold: true
                        color: "#080B11"
                    }
                }

                // Brand Text
                ColumnLayout {
                    spacing: 2
                    Text {
                        text: "LIQUID CAD STUDIO"
                        font.pixelSize: 15
                        font.bold: true
                        font.letterSpacing: 1.2
                        color: colTextPrimary
                    }
                    Text {
                        text: "Deterministic SketchUp 2026 Controller"
                        font.pixelSize: 11
                        color: colTextSecondary
                    }
                }

                Item { Layout.fillWidth: true }

                // Live Connection Status Glass Badge
                Rectangle {
                    id: statusBadge
                    readonly property bool isConn: backend ? backend.connected : false
                    Layout.preferredHeight: 38
                    Layout.preferredWidth: statusRow.width + 24
                    radius: 19
                    color: statusBadge.isConn ? Qt.rgba(0.0, 0.9, 0.6, 0.12) : Qt.rgba(1.0, 0.6, 0.0, 0.12)
                    border.width: 1
                    border.color: statusBadge.isConn ? Qt.rgba(0.0, 0.9, 0.6, 0.35) : Qt.rgba(1.0, 0.6, 0.0, 0.35)

                    RowLayout {
                        id: statusRow
                        anchors.centerIn: parent
                        spacing: 8

                        // Pulsing Dot
                        Rectangle {
                            width: 10
                            height: 10
                            radius: 5
                            color: statusBadge.isConn ? colEmeraldGlow : colAmberGlow
                            SequentialAnimation on opacity {
                                loops: Animation.Infinite
                                NumberAnimation { to: 0.35; duration: 900 }
                                NumberAnimation { to: 1.0; duration: 900 }
                            }
                        }

                        Text {
                            text: statusBadge.isConn ? ("ONLINE: " + (backend ? backend.modelName : "") + " (" + (backend ? backend.units : "") + ")") : "BRIDGE OFFLINE (127.0.0.1:9876)"
                            font.pixelSize: 11
                            font.bold: true
                            color: statusBadge.isConn ? colEmeraldGlow : colAmberGlow
                        }
                    }
                }

                // Quick Ping / Refresh Glass Button
                Rectangle {
                    width: 38
                    height: 38
                    radius: 12
                    color: refreshMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.15) : Qt.rgba(1, 1, 1, 0.06)
                    border.width: 1
                    border.color: colGlassBorder

                    Text {
                        anchors.centerIn: parent
                        text: "↻"
                        font.pixelSize: 17
                        color: colTextPrimary
                    }
                    MouseArea {
                        id: refreshMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: backend.refresh()
                    }
                }

                // Info & Credits Glass Button (Icon-Only)
                Rectangle {
                    width: 38
                    height: 38
                    radius: 12
                    color: infoBtnMouse.containsMouse ? Qt.rgba(0.0, 0.94, 1.0, 0.22) : Qt.rgba(1, 1, 1, 0.06)
                    border.width: 1
                    border.color: infoBtnMouse.containsMouse ? colCyanGlow : colGlassBorder

                    Text {
                        anchors.centerIn: parent
                        text: "ℹ"
                        font.pixelSize: 16
                        font.bold: true
                        color: infoBtnMouse.containsMouse ? colCyanGlow : colTextPrimary
                    }
                    MouseArea {
                        id: infoBtnMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: infoModal.visible = true
                    }
                }
            }
        }

        // ---------------------------------------------------------------------
        // LIQUID NAVIGATION TABS
        // ---------------------------------------------------------------------
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 48
            radius: 14
            color: Qt.rgba(0.04, 0.07, 0.14, 0.55)
            border.width: 1
            border.color: colGlassBorder

            RowLayout {
                anchors.fill: parent
                spacing: 4

                Repeater {
                    model: [
                        { label: "⚡ Parametric Design", id: 0 },
                        { label: "🎥 Camera Views", id: 1 },
                        { label: "📦 Export Studio", id: 2 },
                        { label: "📊 Model Telemetry", id: 3 },
                        { label: "💻 Ruby Console", id: 4 }
                    ]

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: 12
                        color: activeTab === modelData.id ? Qt.rgba(0.0, 0.94, 1.0, 0.16) : (tabMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.05) : "transparent")
                        border.width: activeTab === modelData.id ? 1 : 0
                        border.color: colGlassBorderHighlight

                        Behavior on color { ColorAnimation { duration: 180 } }

                        Text {
                            anchors.centerIn: parent
                            text: modelData.label
                            font.pixelSize: 12
                            font.bold: activeTab === modelData.id
                            color: activeTab === modelData.id ? colCyanGlow : colTextSecondary
                        }

                        MouseArea {
                            id: tabMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: activeTab = modelData.id
                        }
                    }
                }
            }
        }

        // ---------------------------------------------------------------------
        // TAB VIEW CONTENT (Switchable panels)
        // ---------------------------------------------------------------------
        StackLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: activeTab

            // =================================================================
            // TAB 0: PARAMETRIC DESIGN (100% Deterministic Generator)
            // =================================================================
            RowLayout {
                spacing: 18

                // Left Panel: Parametric Room Generator
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: 20
                    color: colGlassCard
                    border.width: 1
                    border.color: colGlassBorder

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 22
                        spacing: 14

                        RowLayout {
                            spacing: 8
                            Text {
                                text: "PARAMETRIC ROOM GENERATOR"
                                font.pixelSize: 13
                                font.bold: true
                                font.letterSpacing: 1.1
                                color: colCyanGlow
                            }
                            Item { Layout.fillWidth: true }
                            Text {
                                text: "Exact Dimensions (Meters)"
                                font.pixelSize: 11
                                color: colTextSecondary
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            height: 1
                            color: colGlassBorder
                        }

                        // Presets Chips
                        RowLayout {
                            spacing: 8
                            Text { text: "Presets:"; font.pixelSize: 11; color: colTextSecondary }
                            
                            Component {
                                id: presetChip
                                Rectangle {
                                    property string label: ""
                                    property real pw: 6.0
                                    property real pd: 5.0
                                    property real ph: 3.0
                                    property real pt: 0.20

                                    width: pTxt.width + 16
                                    height: 26
                                    radius: 13
                                    color: pMouse.containsMouse ? Qt.rgba(0.0, 0.94, 1.0, 0.22) : Qt.rgba(1, 1, 1, 0.08)
                                    border.width: 1
                                    border.color: colGlassBorder

                                    Text {
                                        id: pTxt
                                        anchors.centerIn: parent
                                        text: parent.label
                                        font.pixelSize: 10
                                        font.bold: true
                                        color: colTextPrimary
                                    }
                                    MouseArea {
                                        id: pMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            sliderW.value = pw
                                            sliderD.value = pd
                                            sliderH.value = ph
                                            sliderT.value = pt
                                        }
                                    }
                                }
                            }

                            Loader { sourceComponent: presetChip; property string label: "Studio 6×5m"; property real pw: 6; property real pd: 5; property real ph: 3; property real pt: 0.20 }
                            Loader { sourceComponent: presetChip; property string label: "Office 8×6m"; property real pw: 8; property real pd: 6; property real ph: 3.2; property real pt: 0.25 }
                            Loader { sourceComponent: presetChip; property string label: "Hall 12×8m"; property real pw: 12; property real pd: 8; property real ph: 4.0; property real pt: 0.30 }
                        }

                        // Slider 1: Width
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4
                            RowLayout {
                                Text { text: "Room Width:"; font.pixelSize: 12; color: colTextPrimary }
                                Item { Layout.fillWidth: true }
                                Text { text: sliderW.value.toFixed(2) + " m"; font.pixelSize: 12; font.bold: true; color: colCyanGlow }
                            }
                            Slider {
                                id: sliderW
                                Layout.fillWidth: true
                                from: 2.0; to: 20.0; value: 6.0; stepSize: 0.5
                            }
                        }

                        // Slider 2: Depth
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4
                            RowLayout {
                                Text { text: "Room Depth / Length:"; font.pixelSize: 12; color: colTextPrimary }
                                Item { Layout.fillWidth: true }
                                Text { text: sliderD.value.toFixed(2) + " m"; font.pixelSize: 12; font.bold: true; color: colCyanGlow }
                            }
                            Slider {
                                id: sliderD
                                Layout.fillWidth: true
                                from: 2.0; to: 20.0; value: 5.0; stepSize: 0.5
                            }
                        }

                        // Slider 3: Height
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4
                            RowLayout {
                                Text { text: "Ceiling Height:"; font.pixelSize: 12; color: colTextPrimary }
                                Item { Layout.fillWidth: true }
                                Text { text: sliderH.value.toFixed(2) + " m"; font.pixelSize: 12; font.bold: true; color: colCyanGlow }
                            }
                            Slider {
                                id: sliderH
                                Layout.fillWidth: true
                                from: 2.0; to: 8.0; value: 3.0; stepSize: 0.1
                            }
                        }

                        // Slider 4: Wall Thickness
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4
                            RowLayout {
                                Text { text: "Wall Thickness:"; font.pixelSize: 12; color: colTextPrimary }
                                Item { Layout.fillWidth: true }
                                Text { text: (sliderT.value * 100).toFixed(0) + " cm"; font.pixelSize: 12; font.bold: true; color: colCyanGlow }
                            }
                            Slider {
                                id: sliderT
                                Layout.fillWidth: true
                                from: 0.10; to: 0.50; value: 0.20; stepSize: 0.05
                            }
                        }

                        Item { Layout.fillHeight: true }

                        // Generate Room Action Button (Liquid Glow)
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 46
                            radius: 14
                            gradient: Gradient {
                                GradientStop { position: 0.0; color: btnRoomMouse.containsMouse ? "#2DFEFF" : colCyanGlow }
                                GradientStop { position: 1.0; color: btnRoomMouse.containsMouse ? "#7928CA" : "#4A00E0" }
                            }
                            border.width: 1
                            border.color: Qt.rgba(1, 1, 1, 0.4)

                            RowLayout {
                                anchors.centerIn: parent
                                spacing: 8
                                Text { text: "⚡"; font.pixelSize: 16 }
                                Text {
                                    text: "GENERATE 3D ROOM IN SKETCHUP"
                                    font.pixelSize: 12
                                    font.bold: true
                                    font.letterSpacing: 1.0
                                    color: "#FFFFFF"
                                }
                            }

                            MouseArea {
                                id: btnRoomMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: backend.createRoom(sliderW.value, sliderD.value, sliderH.value, sliderT.value)
                            }
                        }
                    }
                }

                // Right Panel: Solid Volume & Column Generator
                Rectangle {
                    Layout.preferredWidth: 380
                    Layout.fillHeight: true
                    radius: 20
                    color: colGlassCard
                    border.width: 1
                    border.color: colGlassBorder

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 22
                        spacing: 14

                        Text {
                            text: "SOLIDS & PRIMITIVES"
                            font.pixelSize: 13
                            font.bold: true
                            font.letterSpacing: 1.1
                            color: colVioletGlow
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            height: 1
                            color: colGlassBorder
                        }

                        // Box Controls
                        Text { text: "Solid Extrusion / Massing Box"; font.pixelSize: 11; font.bold: true; color: colTextSecondary }

                        RowLayout {
                            spacing: 8
                            ColumnLayout {
                                Text { text: "W (m)"; font.pixelSize: 10; color: colTextSecondary }
                                SpinBox { id: boxW; from: 1; to: 50; value: 4 }
                            }
                            ColumnLayout {
                                Text { text: "D (m)"; font.pixelSize: 10; color: colTextSecondary }
                                SpinBox { id: boxD; from: 1; to: 50; value: 4 }
                            }
                            ColumnLayout {
                                Text { text: "H (m)"; font.pixelSize: 10; color: colTextSecondary }
                                SpinBox { id: boxH; from: 1; to: 50; value: 3 }
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 36
                            radius: 10
                            color: boxMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.20) : Qt.rgba(1, 1, 1, 0.08)
                            border.width: 1
                            border.color: colGlassBorder

                            Text {
                                anchors.centerIn: parent
                                text: "+ Create Solid Box"
                                font.pixelSize: 11
                                font.bold: true
                                color: colTextPrimary
                            }
                            MouseArea {
                                id: boxMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: backend.createBox(boxW.value, boxD.value, boxH.value)
                            }
                        }

                        Rectangle { Layout.fillWidth: true; height: 1; color: colGlassBorder }

                        // Cylinder / Column
                        Text { text: "Architectural Column / Cylinder"; font.pixelSize: 11; font.bold: true; color: colTextSecondary }

                        RowLayout {
                            spacing: 8
                            ColumnLayout {
                                Text { text: "Radius (m)"; font.pixelSize: 10; color: colTextSecondary }
                                SpinBox { id: cylR; from: 1; to: 10; value: 1 }
                            }
                            ColumnLayout {
                                Text { text: "Height (m)"; font.pixelSize: 10; color: colTextSecondary }
                                SpinBox { id: cylH; from: 1; to: 20; value: 4 }
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 36
                            radius: 10
                            color: cylMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.20) : Qt.rgba(1, 1, 1, 0.08)
                            border.width: 1
                            border.color: colGlassBorder

                            Text {
                                anchors.centerIn: parent
                                text: "+ Create Column"
                                font.pixelSize: 11
                                font.bold: true
                                color: colTextPrimary
                            }
                            MouseArea {
                                id: cylMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: backend.createCylinder(cylR.value, cylH.value, 24)
                            }
                        }

                        Item { Layout.fillHeight: true }

                        // Dangerous Action: Clear
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 38
                            radius: 12
                            color: Qt.rgba(1.0, 0.2, 0.3, 0.15)
                            border.width: 1
                            border.color: Qt.rgba(1.0, 0.2, 0.3, 0.35)

                            Text {
                                anchors.centerIn: parent
                                text: "🗑 Clear Active Entities"
                                font.pixelSize: 11
                                font.bold: true
                                color: "#FF5370"
                            }
                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: backend.clearModel()
                            }
                        }
                    }
                }
            }

            // =================================================================
            // TAB 1: CAMERA & VIEWPORT RIG
            // =================================================================
            Rectangle {
                radius: 20
                color: colGlassCard
                border.width: 1
                border.color: colGlassBorder

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 28
                    spacing: 20

                    Text {
                        text: "VIEWPORT CAMERA CONTROLS"
                        font.pixelSize: 14
                        font.bold: true
                        font.letterSpacing: 1.1
                        color: colCyanGlow
                    }
                    Text {
                        text: "Instantly reorient the 3D viewport camera and fit extents with one click."
                        font.pixelSize: 12
                        color: colTextSecondary
                    }

                    GridLayout {
                        columns: 3
                        rowSpacing: 16
                        columnSpacing: 16
                        Layout.fillWidth: true

                        Component {
                            id: cameraCard
                            Rectangle {
                                property string title: ""
                                property string subtitle: ""
                                property string viewKey: ""
                                property string icon: ""

                                Layout.fillWidth: true
                                Layout.preferredHeight: 90
                                radius: 14
                                color: cMouse.containsMouse ? Qt.rgba(0.0, 0.94, 1.0, 0.15) : Qt.rgba(1, 1, 1, 0.05)
                                border.width: 1
                                border.color: cMouse.containsMouse ? colCyanGlow : colGlassBorder

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 18
                                    spacing: 14

                                    Text {
                                        text: icon
                                        font.pixelSize: 28
                                    }
                                    ColumnLayout {
                                        Text { text: title; font.pixelSize: 14; font.bold: true; color: colTextPrimary }
                                        Text { text: subtitle; font.pixelSize: 11; color: colTextSecondary }
                                    }
                                }

                                MouseArea {
                                    id: cMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: backend.setCamera(viewKey)
                                }
                            }
                        }

                        Loader { sourceComponent: cameraCard; property string title: "Isometric (3D)"; property string subtitle: "Default standard 3D perspective"; property string viewKey: "iso"; property string icon: "🧊" }
                        Loader { sourceComponent: cameraCard; property string title: "Top View (Plan)"; property string subtitle: "Architectural 2D floor plan"; property string viewKey: "top"; property string icon: "📐" }
                        Loader { sourceComponent: cameraCard; property string title: "Front Elevation"; property string subtitle: "Facade perspective"; property string viewKey: "front"; property string icon: "🏢" }
                        Loader { sourceComponent: cameraCard; property string title: "Right Elevation"; property string subtitle: "Side perspective"; property string viewKey: "right"; property string icon: "➡️" }
                        Loader { sourceComponent: cameraCard; property string title: "Left Elevation"; property string subtitle: "Opposite side perspective"; property string viewKey: "left"; property string icon: "⬅️" }
                    }

                    Item { Layout.fillHeight: true }
                }
            }

            // =================================================================
            // TAB 2: EXPORT STUDIO
            // =================================================================
            Rectangle {
                radius: 20
                color: colGlassCard
                border.width: 1
                border.color: colGlassBorder

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 28
                    spacing: 18

                    Text {
                        text: "EXPORT STUDIO & RENDER PIPELINE"
                        font.pixelSize: 14
                        font.bold: true
                        font.letterSpacing: 1.1
                        color: colCyanGlow
                    }

                    Text {
                        text: "Export the current SketchUp scene directly to 3D geometry formats or 4K viewport screenshots."
                        font.pixelSize: 12
                        color: colTextSecondary
                    }

                    // Format Selection Cards
                    RowLayout {
                        spacing: 14
                        property string selectedFormat: "obj"

                        Repeater {
                            model: [
                                { fmt: "obj", title: "OBJ (Wavefront)", desc: "Standard 3D mesh" },
                                { fmt: "stl", title: "STL (3D Print)", desc: "Additive manufacturing" },
                                { fmt: "dae", title: "DAE (Collada)", desc: "Blender & Game engines" },
                                { fmt: "png", title: "PNG (Viewport Render)", desc: "Instant high-res image" }
                            ]

                            Rectangle {
                                property bool isChosen: exportFormatGroup.currentFmt === modelData.fmt

                                Layout.preferredWidth: 210
                                Layout.preferredHeight: 80
                                radius: 14
                                color: isChosen ? Qt.rgba(0.0, 0.94, 1.0, 0.20) : (fMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.08) : Qt.rgba(1, 1, 1, 0.04))
                                border.width: 1
                                border.color: isChosen ? colCyanGlow : colGlassBorder

                                ColumnLayout {
                                    anchors.centerIn: parent
                                    spacing: 4
                                    Text {
                                        text: modelData.title
                                        font.pixelSize: 12
                                        font.bold: true
                                        color: isChosen ? colCyanGlow : colTextPrimary
                                    }
                                    Text {
                                        text: modelData.desc
                                        font.pixelSize: 10
                                        color: colTextSecondary
                                    }
                                }

                                MouseArea {
                                    id: fMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: exportFormatGroup.currentFmt = modelData.fmt
                                }
                            }
                        }
                    }

                    QtObject {
                        id: exportFormatGroup
                        property string currentFmt: "obj"
                    }

                    // Destination Path Input
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 6

                        Text { text: "Destination File Path (Leave blank to save to ~/Desktop automatically):"; font.pixelSize: 11; color: colTextSecondary }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 42
                            radius: 12
                            color: Qt.rgba(0.03, 0.05, 0.10, 0.70)
                            border.width: 1
                            border.color: colGlassBorder

                            TextInput {
                                id: exportPathInput
                                anchors.fill: parent
                                anchors.leftMargin: 16
                                anchors.rightMargin: 16
                                verticalAlignment: TextInput.AlignVCenter
                                color: colTextPrimary
                                font.pixelSize: 12
                                text: ""
                            }
                        }
                    }

                    Item { Layout.fillHeight: true }

                    // Export Trigger Button
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 50
                        radius: 14
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: btnExportMouse.containsMouse ? "#00F5A0" : "#00DF89" }
                            GradientStop { position: 1.0; color: "#007A50" }
                        }
                        border.width: 1
                        border.color: Qt.rgba(1, 1, 1, 0.3)

                        RowLayout {
                            anchors.centerIn: parent
                            spacing: 10
                            Text { text: "💾"; font.pixelSize: 18 }
                            Text {
                                text: "ONE-CLICK EXPORT TO DISK (" + exportFormatGroup.currentFmt.toUpperCase() + ")"
                                font.pixelSize: 13
                                font.bold: true
                                font.letterSpacing: 1.1
                                color: "#FFFFFF"
                            }
                        }

                        MouseArea {
                            id: btnExportMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: backend.exportModel(exportFormatGroup.currentFmt, exportPathInput.text)
                        }
                    }
                }
            }

            // =================================================================
            // TAB 3: MODEL TELEMETRY (Live CAD Metrics)
            // =================================================================
            Rectangle {
                radius: 20
                color: colGlassCard
                border.width: 1
                border.color: colGlassBorder

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 28
                    spacing: 20

                    Text {
                        text: "ACTIVE MODEL TELEMETRY"
                        font.pixelSize: 14
                        font.bold: true
                        font.letterSpacing: 1.1
                        color: colCyanGlow
                    }

                    GridLayout {
                        columns: 2
                        rowSpacing: 16
                        columnSpacing: 16
                        Layout.fillWidth: true

                        Component {
                            id: telemetryCard
                            Rectangle {
                                property string label: ""
                                property string value: ""
                                property string icon: ""

                                Layout.fillWidth: true
                                Layout.preferredHeight: 88
                                radius: 14
                                color: Qt.rgba(1, 1, 1, 0.05)
                                border.width: 1
                                border.color: colGlassBorder

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 18
                                    spacing: 16

                                    Text { text: icon; font.pixelSize: 32 }
                                    ColumnLayout {
                                        Text { text: label; font.pixelSize: 11; color: colTextSecondary }
                                        Text { text: value; font.pixelSize: 18; font.bold: true; color: colCyanGlow }
                                    }
                                }
                            }
                        }

                        Loader { sourceComponent: telemetryCard; property string label: "Bounding Dimensions"; property string value: backend ? backend.dimensions : "—"; property string icon: "📐" }
                        Loader { sourceComponent: telemetryCard; property string label: "Faces / Surfaces"; property string value: backend ? backend.facesCount.toString() : "0"; property string icon: "🔷" }
                        Loader { sourceComponent: telemetryCard; property string label: "Edges / Wireframe"; property string value: backend ? backend.edgesCount.toString() : "0"; property string icon: "📏" }
                        Loader { sourceComponent: telemetryCard; property string label: "Groups & Components"; property string value: backend ? (backend.groupsCount + backend.componentsCount).toString() : "0"; property string icon: "📦" }
                    }

                    Item { Layout.fillHeight: true }
                }
            }

            // =================================================================
            // TAB 4: RUBY CONSOLE (Power script runner)
            // =================================================================
            Rectangle {
                radius: 20
                color: colGlassCard
                border.width: 1
                border.color: colGlassBorder

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 24
                    spacing: 14

                    RowLayout {
                        Text {
                            text: "SKETCHUP RUBY SCRIPT EXECUTOR"
                            font.pixelSize: 13
                            font.bold: true
                            font.letterSpacing: 1.1
                            color: colVioletGlow
                        }
                        Item { Layout.fillWidth: true }
                        Text { text: "Runs in SketchUp Main Thread with Undo support"; font.pixelSize: 11; color: colTextSecondary }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: 14
                        color: "#05070B"
                        border.width: 1
                        border.color: colGlassBorder

                        TextArea {
                            id: rubyInput
                            anchors.fill: parent
                            anchors.margins: 14
                            color: "#A0F0FF"
                            font.family: "Menlo"
                            font.pixelSize: 12
                            wrapMode: TextArea.Wrap
                            text: "# Example: Add a colorful grid of cubes\n10.times do |i|\n  face = Sketchup.active_model.active_entities.add_face([\n    [i.m, 0, 0], [(i+0.8).m, 0, 0], [(i+0.8).m, 0.8.m, 0], [i.m, 0.8.m, 0]\n  ])\n  face.pushpull(-((i+1)*0.4).m)\nend"
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 44
                        radius: 12
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: colVioletGlow }
                            GradientStop { position: 1.0; color: "#4A00E0" }
                        }
                        border.width: 1
                        border.color: Qt.rgba(1, 1, 1, 0.3)

                        Text {
                            anchors.centerIn: parent
                            text: "▶ Execute Ruby in SketchUp"
                            font.pixelSize: 12
                            font.bold: true
                            color: "#FFFFFF"
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: backend.evalRuby(rubyInput.text)
                        }
                    }
                }
            }
        }
    }

    // =========================================================================
    // TOAST NOTIFICATION (Liquid floating capsule)
    // =========================================================================
    Rectangle {
        id: toast
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: toastVisible ? 24 : -60
        width: Math.min(toastText.width + 50, root.width - 48)
        height: 44
        radius: 22
        z: 99
        color: toastSuccess ? Qt.rgba(0.0, 0.20, 0.12, 0.92) : Qt.rgba(0.25, 0.05, 0.08, 0.92)
        border.width: 1
        border.color: toastSuccess ? colEmeraldGlow : "#FF5370"

        Behavior on anchors.bottomMargin {
            NumberAnimation { duration: 250; easing.type: Easing.OutBack }
        }

        RowLayout {
            anchors.centerIn: parent
            spacing: 10
            Text {
                text: toastSuccess ? "✓" : "⚠"
                font.pixelSize: 16
                font.bold: true
                color: toastSuccess ? colEmeraldGlow : "#FF5370"
            }
            Text {
                id: toastText
                text: toastMsg
                font.pixelSize: 12
                font.bold: true
                color: "#FFFFFF"
            }
        }
    }

    // =========================================================================
    // HOW IT WORKS & CREDITS MODAL (Liquid Glass Overlay)
    // =========================================================================
    Rectangle {
        id: infoModal
        anchors.fill: parent
        z: 100
        visible: false
        color: Qt.rgba(0.03, 0.05, 0.09, 0.82)

        MouseArea {
            anchors.fill: parent
            // Prevent clicks from passing through
            onClicked: {}
        }

        Rectangle {
            id: infoCard
            anchors.centerIn: parent
            width: Math.min(680, root.width - 48)
            height: Math.min(560, root.height - 48)
            radius: 22
            color: Qt.rgba(0.07, 0.11, 0.20, 0.95)
            border.width: 1
            border.color: colGlassBorderHighlight

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 28
                spacing: 16

                // Header
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12

                    Rectangle {
                        width: 36
                        height: 36
                        radius: 10
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: colCyanGlow }
                            GradientStop { position: 1.0; color: colVioletGlow }
                        }
                        Text {
                            anchors.centerIn: parent
                            text: "ℹ"
                            font.pixelSize: 18
                            font.bold: true
                            color: "#080B11"
                        }
                    }

                    ColumnLayout {
                        spacing: 2
                        Text {
                            text: "HOW LIQUID CAD WORKS & CREDITS"
                            font.pixelSize: 14
                            font.bold: true
                            font.letterSpacing: 1.1
                            color: colTextPrimary
                        }
                        Text {
                            text: "Architecture, direct CAD synchronization, and project information"
                            font.pixelSize: 11
                            color: colTextSecondary
                        }
                    }

                    Item { Layout.fillWidth: true }

                    // Close Button (✕)
                    Rectangle {
                        width: 32
                        height: 32
                        radius: 10
                        color: closeMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.15) : Qt.rgba(1, 1, 1, 0.05)
                        border.width: 1
                        border.color: colGlassBorder

                        Text {
                            anchors.centerIn: parent
                            text: "✕"
                            font.pixelSize: 14
                            color: colTextPrimary
                        }
                        MouseArea {
                            id: closeMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: infoModal.visible = false
                        }
                    }
                }

                Rectangle { Layout.fillWidth: true; height: 1; color: colGlassBorder }

                // Scrollable Content
                Flickable {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    contentHeight: contentCol.height
                    clip: true

                    ColumnLayout {
                        id: contentCol
                        width: parent.width
                        spacing: 16

                        // Section 1: How It Works
                        Text {
                            text: "⚡ HOW THE SYSTEM OPERATES"
                            font.pixelSize: 12
                            font.bold: true
                            font.letterSpacing: 1.0
                            color: colCyanGlow
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 10

                            Repeater {
                                model: [
                                    { step: "1. Local Ruby Bridge", desc: "A non-blocking HTTP REST daemon runs automatically inside SketchUp 2026 on port 9876. It requires zero configuration." },
                                    { step: "2. Real-Time Viewport Sync", desc: "Moving sliders or triggering presets dispatches JSON to SketchUp. Geometry is generated instantly in milliseconds with clean manifold topology." },
                                    { step: "3. Full Native Undo (Ctrl+Z / Cmd+Z)", desc: "Every operation is grouped into SketchUp's undo stack, allowing full rollback and redo inside the 3D model." },
                                    { step: "4. Direct 1-Click Exporter", desc: "Exports scenes to OBJ, STL (3D Printing), DAE (Blender/Unity), or high-res 4K PNG renders with no intermediate popups." },
                                    { step: "5. Optional AI Model Context Protocol (MCP)", desc: "The included FastMCP server (sketchup_mcp.py) lets you connect Claude Desktop or Cursor to drive SketchUp using natural language." }
                                ]

                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: stepText.height + 18
                                    radius: 10
                                    color: Qt.rgba(1, 1, 1, 0.04)
                                    border.width: 1
                                    border.color: Qt.rgba(1, 1, 1, 0.08)

                                    RowLayout {
                                        id: stepText
                                        anchors.fill: parent
                                        anchors.margins: 10
                                        spacing: 12

                                        Rectangle {
                                            width: 6
                                            height: 6
                                            radius: 3
                                            color: colCyanGlow
                                        }

                                        ColumnLayout {
                                            Layout.fillWidth: true
                                            spacing: 2
                                            Text { text: modelData.step; font.pixelSize: 11; font.bold: true; color: colTextPrimary }
                                            Text { text: modelData.desc; font.pixelSize: 10; color: colTextSecondary; wrapMode: Text.WordWrap; Layout.fillWidth: true }
                                        }
                                    }
                                }
                            }
                        }

                        Rectangle { Layout.fillWidth: true; height: 1; color: colGlassBorder }

                        // Section 2: Credits
                        Text {
                            text: "💎 CREDITS & SYSTEM SPECIFICATIONS"
                            font.pixelSize: 12
                            font.bold: true
                            font.letterSpacing: 1.0
                            color: colVioletGlow
                        }

                        GridLayout {
                            columns: 2
                            rowSpacing: 8
                            columnSpacing: 14
                            Layout.fillWidth: true

                            Text { text: "Author / Developer:"; font.pixelSize: 11; color: colTextSecondary }
                            Text { text: "Mohamed Amraoui (@amraoui-mo7amed)"; font.pixelSize: 11; font.bold: true; color: colTextPrimary }

                            Text { text: "UI Framework:"; font.pixelSize: 11; color: colTextSecondary }
                            Text { text: "PySide6 (Qt 6 Quick / QML) Liquid Light Glass"; font.pixelSize: 11; font.bold: true; color: colCyanGlow }

                            Text { text: "CAD Integration:"; font.pixelSize: 11; color: colTextSecondary }
                            Text { text: "SketchUp 2026 Ruby C API Bridge"; font.pixelSize: 11; font.bold: true; color: colTextPrimary }

                            Text { text: "AI Protocol:"; font.pixelSize: 11; color: colTextSecondary }
                            Text { text: "Model Context Protocol (FastMCP 2.x)"; font.pixelSize: 11; font.bold: true; color: colEmeraldGlow }

                            Text { text: "Repository:"; font.pixelSize: 11; color: colTextSecondary }
                            Text { text: "github.com/amraoui-mo7amed/sketchup-controller"; font.pixelSize: 11; color: colCyanGlow }
                        }
                    }
                }

                // Bottom Dismiss Action
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 42
                    radius: 12
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: dismissMouse.containsMouse ? "#2DFEFF" : colCyanGlow }
                        GradientStop { position: 1.0; color: dismissMouse.containsMouse ? "#7928CA" : "#4A00E0" }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "Close Guide"
                        font.pixelSize: 12
                        font.bold: true
                        color: "#FFFFFF"
                    }

                    MouseArea {
                        id: dismissMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: infoModal.visible = false
                    }
                }
            }
        }
    }
}
