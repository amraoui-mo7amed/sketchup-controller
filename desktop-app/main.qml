import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ApplicationWindow {
    id: root
    visible: true
    width: 1080
    height: 720
    minimumWidth: 960
    minimumHeight: 640
    title: "Liquid CAD Studio — SketchUp 2026 Controller"
    color: "#05070B"

    // --- Color Palette: Spatial Liquid Glass ---
    readonly property color colBg: "#05070B"
    readonly property color colGlassBase: Qt.rgba(0.06, 0.09, 0.16, 0.72)
    readonly property color colGlassCard: Qt.rgba(0.09, 0.13, 0.22, 0.65)
    readonly property color colBorderLight: Qt.rgba(1.0, 1.0, 1.0, 0.12)
    readonly property color colBorderActive: Qt.rgba(0.0, 0.95, 1.0, 0.50)
    readonly property color colCyan: "#00F5FF"
    readonly property color colViolet: "#8B5CF6"
    readonly property color colEmerald: "#10B981"
    readonly property color colAmber: "#F59E0B"
    readonly property color colRose: "#EC4899"
    readonly property color colTextPrimary: "#F8FAFC"
    readonly property color colTextSecondary: "#94A3B8"

    property int activeNav: 0
    property bool infoDrawerOpen: false

    // Toast state
    property string toastText: ""
    property bool toastSuccess: true
    property bool toastVisible: false

    Connections {
        target: backend
        function onActionFinished(message, success) {
            toastText = message
            toastSuccess = success
            toastVisible = true
            toastTimer.restart()
        }
    }

    Timer {
        id: toastTimer
        interval: 3600
        onTriggered: toastVisible = false
    }

    // =========================================================================
    // FONTAWESOME ICON RIG
    // =========================================================================
    FontLoader {
        id: faFont
        source: "assets/fonts/fa-solid-900.ttf"
    }

    readonly property string faFamily: faFont.name ? faFont.name : "Font Awesome 6 Free"

    QtObject {
        id: fa
        readonly property string cube: "\uf1b2"
        readonly property string cubes: "\uf1b3"
        readonly property string house: "\uf015"
        readonly property string ruler: "\uf545"
        readonly property string rulerVertical: "\uf547"
        readonly property string camera: "\uf030"
        readonly property string fileExport: "\uf56e"
        readonly property string chart: "\uf080"
        readonly property string terminal: "\uf120"
        readonly property string code: "\uf121"
        readonly property string gem: "\uf3a5"
        readonly property string info: "\uf05a"
        readonly property string sync: "\uf021"
        readonly property string bolt: "\uf0e7"
        readonly property string building: "\uf1ad"
        readonly property string arrowRight: "\uf061"
        readonly property string arrowLeft: "\uf060"
        readonly property string arrowUp: "\uf062"
        readonly property string play: "\uf04b"
        readonly property string xmark: "\uf00d"
        readonly property string check: "\uf00c"
        readonly property string warning: "\uf071"
        readonly property string floppy: "\uf0c7"
        readonly property string database: "\uf1c0"
        readonly property string circle: "\uf111"
        readonly property string folder: "\uf07b"
        readonly property string boxes: "\uf468"
        readonly property string polygon: "\uf5ee"
        readonly property string trash: "\uf2ed"
        readonly property string plus: "\uf067"
    }

    component FAIcon: Text {
        font.family: root.faFamily
        font.styleName: "Solid"
        font.weight: Font.Black
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    // =========================================================================
    // BACKGROUND: AMBIENT LIQUID ORBS (Fluid, luminous refraction field)
    // =========================================================================
    Item {
        anchors.fill: parent
        z: 0

        Rectangle {
            width: 580; height: 580; radius: 290
            x: -120; y: -120
            opacity: 0.22
            gradient: Gradient {
                GradientStop { position: 0.0; color: colCyan }
                GradientStop { position: 0.7; color: Qt.rgba(0, 0.8, 1, 0.05) }
                GradientStop { position: 1.0; color: "transparent" }
            }
            SequentialAnimation on y {
                loops: Animation.Infinite
                NumberAnimation { to: -80; duration: 7000; easing.type: Easing.InOutSine }
                NumberAnimation { to: -120; duration: 7000; easing.type: Easing.InOutSine }
            }
        }

        Rectangle {
            width: 620; height: 620; radius: 310
            x: root.width - 450; y: root.height - 450
            opacity: 0.18
            gradient: Gradient {
                GradientStop { position: 0.0; color: colViolet }
                GradientStop { position: 0.65; color: Qt.rgba(0.6, 0.2, 0.9, 0.06) }
                GradientStop { position: 1.0; color: "transparent" }
            }
            SequentialAnimation on x {
                loops: Animation.Infinite
                NumberAnimation { to: root.width - 400; duration: 8000; easing.type: Easing.InOutSine }
                NumberAnimation { to: root.width - 450; duration: 8000; easing.type: Easing.InOutSine }
            }
        }
    }

    // =========================================================================
    // MAIN APP LAYOUT (Vertical Left Dock + Spacious Main Stage)
    // =========================================================================
    RowLayout {
        anchors.fill: parent
        anchors.margins: 18
        spacing: 16
        z: 1

        // ---------------------------------------------------------------------
        // LEFT FLOATING CAPSULE DOCK
        // ---------------------------------------------------------------------
        Rectangle {
            Layout.preferredWidth: 76
            Layout.fillHeight: true
            radius: 24
            color: colGlassBase
            border.width: 1
            border.color: colBorderLight

            ColumnLayout {
                anchors.fill: parent
                anchors.topMargin: 20
                anchors.bottomMargin: 20
                spacing: 12

                // Brand Emblem
                Rectangle {
                    Layout.alignment: Qt.AlignHCenter
                    width: 44
                    height: 44
                    radius: 14
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: colCyan }
                        GradientStop { position: 1.0; color: colViolet }
                    }
                    FAIcon {
                        anchors.centerIn: parent
                        text: fa.cube
                        font.pixelSize: 20
                        color: "#05070B"
                    }
                }

                Rectangle {
                    Layout.alignment: Qt.AlignHCenter
                    width: 36
                    height: 1
                    color: Qt.rgba(1, 1, 1, 0.1)
                }

                // Nav Items
                Repeater {
                    model: [
                        { icon: fa.house, label: "Rooms", id: 0 },
                        { icon: fa.cubes, label: "Solids", id: 1 },
                        { icon: fa.camera, label: "Camera", id: 2 },
                        { icon: fa.fileExport, label: "Export", id: 3 },
                        { icon: fa.chart, label: "Stats", id: 4 },
                        { icon: fa.terminal, label: "Ruby", id: 5 }
                    ]

                    Rectangle {
                        id: navBtn
                        Layout.alignment: Qt.AlignHCenter
                        width: 52
                        height: 52
                        radius: 16
                        color: activeNav === modelData.id ? Qt.rgba(0, 0.95, 1, 0.18) : (navMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.08) : "transparent")
                        border.width: activeNav === modelData.id ? 1 : 0
                        border.color: colBorderActive

                        Behavior on color { ColorAnimation { duration: 150 } }

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 3
                            FAIcon {
                                Layout.alignment: Qt.AlignHCenter
                                text: modelData.icon
                                font.pixelSize: 16
                                color: activeNav === modelData.id ? colCyan : (navMouse.containsMouse ? colTextPrimary : colTextSecondary)
                            }
                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: modelData.label
                                font.pixelSize: 9
                                font.bold: activeNav === modelData.id
                                color: activeNav === modelData.id ? colCyan : colTextSecondary
                            }
                        }

                        MouseArea {
                            id: navMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: activeNav = modelData.id
                        }
                    }
                }

                Item { Layout.fillHeight: true }

                Rectangle {
                    Layout.alignment: Qt.AlignHCenter
                    width: 36
                    height: 1
                    color: Qt.rgba(1, 1, 1, 0.1)
                }

                // Info & Credits Button (Icon-Only)
                Rectangle {
                    Layout.alignment: Qt.AlignHCenter
                    width: 44
                    height: 44
                    radius: 14
                    color: infoMouse.containsMouse ? Qt.rgba(0, 0.95, 1, 0.22) : Qt.rgba(1, 1, 1, 0.06)
                    border.width: 1
                    border.color: infoMouse.containsMouse ? colCyan : colBorderLight

                    FAIcon {
                        anchors.centerIn: parent
                        text: fa.info
                        font.pixelSize: 16
                        color: infoMouse.containsMouse ? colCyan : colTextPrimary
                    }
                    MouseArea {
                        id: infoMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: infoDrawerOpen = true
                    }
                }

                // Ping / Refresh Button
                Rectangle {
                    Layout.alignment: Qt.AlignHCenter
                    width: 44
                    height: 44
                    radius: 14
                    color: refMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.14) : Qt.rgba(1, 1, 1, 0.06)
                    border.width: 1
                    border.color: colBorderLight

                    FAIcon {
                        anchors.centerIn: parent
                        text: fa.sync
                        font.pixelSize: 15
                        color: colTextPrimary
                    }
                    MouseArea {
                        id: refMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: backend.refresh()
                    }
                }
            }
        }

        // ---------------------------------------------------------------------
        // MAIN WORKSPACE CANVAS
        // ---------------------------------------------------------------------
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: 24
            color: colGlassBase
            border.width: 1
            border.color: colBorderLight

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 24
                spacing: 20

                // Top Status Bar (Breadcrumbs + Live SketchUp Telemetry Pill)
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 14

                    ColumnLayout {
                        spacing: 2
                        Text {
                            text: {
                                switch (activeNav) {
                                case 0: return "PARAMETRIC ARCHITECTURE"
                                case 1: return "3D SOLIDS & MASSING"
                                case 2: return "VIEWPORT CAMERA RIG"
                                case 3: return "EXPORT STUDIO PIPELINE"
                                case 4: return "MODEL TELEMETRY"
                                case 5: return "RUBY SCRIPT TERMINAL"
                                default: return "STUDIO"
                                }
                            }
                            font.pixelSize: 16
                            font.bold: true
                            font.letterSpacing: 1.2
                            color: colTextPrimary
                        }
                        Text {
                            text: "Deterministic live controller for SketchUp 2026"
                            font.pixelSize: 11
                            color: colTextSecondary
                        }
                    }

                    Item { Layout.fillWidth: true }

                    // Live Status Capsule
                    Rectangle {
                        property bool isConn: backend ? backend.connected : false
                        height: 38
                        width: statusRow.implicitWidth + 28
                        radius: 19
                        color: isConn ? Qt.rgba(0.06, 0.72, 0.50, 0.15) : Qt.rgba(0.96, 0.62, 0.04, 0.15)
                        border.width: 1
                        border.color: isConn ? Qt.rgba(0.06, 0.72, 0.50, 0.40) : Qt.rgba(0.96, 0.62, 0.04, 0.40)

                        RowLayout {
                            id: statusRow
                            anchors.centerIn: parent
                            spacing: 8

                            Rectangle {
                                width: 8; height: 8; radius: 4
                                color: parent.parent.isConn ? colEmerald : colAmber
                                SequentialAnimation on opacity {
                                    loops: Animation.Infinite
                                    NumberAnimation { to: 0.3; duration: 800 }
                                    NumberAnimation { to: 1.0; duration: 800 }
                                }
                            }

                            Text {
                                text: parent.parent.isConn ? ("ONLINE: " + (backend ? backend.modelName : "") + " (" + (backend ? backend.units : "") + ")") : "BRIDGE OFFLINE (127.0.0.1:9876)"
                                font.pixelSize: 11
                                font.bold: true
                                color: parent.parent.isConn ? colEmerald : colAmber
                            }
                        }
                    }
                }

                Rectangle { Layout.fillWidth: true; height: 1; color: colBorderLight }

                // Dynamic Workspace Views
                StackLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    currentIndex: activeNav

                    // =========================================================
                    // VIEW 0: PARAMETRIC ROOMS WITH INTERACTIVE SCHEMATIC
                    // =========================================================
                    RowLayout {
                        spacing: 20

                        // Parameter Controls Card
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            radius: 18
                            color: colGlassCard
                            border.width: 1
                            border.color: colBorderLight

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 20
                                spacing: 14

                                // Presets Bar
                                RowLayout {
                                    spacing: 8
                                    Text { text: "Presets:"; font.pixelSize: 11; color: colTextSecondary }

                                    Repeater {
                                        model: [
                                            { label: "Studio 6×5m", pw: 6.0, pd: 5.0, ph: 3.0, pt: 0.20 },
                                            { label: "Office 8×6m", pw: 8.0, pd: 6.0, ph: 3.2, pt: 0.25 },
                                            { label: "Gallery 12×8m", pw: 12.0, pd: 8.0, ph: 4.0, pt: 0.30 }
                                        ]

                                        Rectangle {
                                            width: cTxt.implicitWidth + 20
                                            height: 28
                                            radius: 14
                                            color: cMouse.containsMouse ? Qt.rgba(0, 0.95, 1, 0.22) : Qt.rgba(1, 1, 1, 0.08)
                                            border.width: 1
                                            border.color: colBorderLight
                                            Text {
                                                id: cTxt
                                                anchors.centerIn: parent
                                                text: modelData.label
                                                font.pixelSize: 10
                                                font.bold: true
                                                color: colTextPrimary
                                            }
                                            MouseArea {
                                                id: cMouse
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: {
                                                    rWidth.value = modelData.pw
                                                    rDepth.value = modelData.pd
                                                    rHeight.value = modelData.ph
                                                    rThick.value = modelData.pt
                                                }
                                            }
                                        }
                                    }
                                }

                                // Dimension Sliders
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 4
                                    RowLayout {
                                        Text { text: "Width (X):"; font.pixelSize: 12; color: colTextPrimary }
                                        Item { Layout.fillWidth: true }
                                        Text { text: rWidth.value.toFixed(2) + " m"; font.pixelSize: 12; font.bold: true; color: colCyan }
                                    }
                                    Slider { id: rWidth; Layout.fillWidth: true; from: 2.0; to: 25.0; value: 6.0; stepSize: 0.5 }
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 4
                                    RowLayout {
                                        Text { text: "Depth / Length (Y):"; font.pixelSize: 12; color: colTextPrimary }
                                        Item { Layout.fillWidth: true }
                                        Text { text: rDepth.value.toFixed(2) + " m"; font.pixelSize: 12; font.bold: true; color: colCyan }
                                    }
                                    Slider { id: rDepth; Layout.fillWidth: true; from: 2.0; to: 25.0; value: 5.0; stepSize: 0.5 }
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 4
                                    RowLayout {
                                        Text { text: "Ceiling Height (Z):"; font.pixelSize: 12; color: colTextPrimary }
                                        Item { Layout.fillWidth: true }
                                        Text { text: rHeight.value.toFixed(2) + " m"; font.pixelSize: 12; font.bold: true; color: colCyan }
                                    }
                                    Slider { id: rHeight; Layout.fillWidth: true; from: 2.0; to: 10.0; value: 3.0; stepSize: 0.1 }
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 4
                                    RowLayout {
                                        Text { text: "Wall Thickness:"; font.pixelSize: 12; color: colTextPrimary }
                                        Item { Layout.fillWidth: true }
                                        Text { text: (rThick.value * 100).toFixed(0) + " cm"; font.pixelSize: 12; font.bold: true; color: colCyan }
                                    }
                                    Slider { id: rThick; Layout.fillWidth: true; from: 0.10; to: 0.60; value: 0.20; stepSize: 0.05 }
                                }

                                Item { Layout.fillHeight: true }

                                // Build Button
                                Rectangle {
                                    Layout.fillWidth: true
                                    height: 48
                                    radius: 14
                                    gradient: Gradient {
                                        GradientStop { position: 0.0; color: btnGenMouse.containsMouse ? "#2DFEFF" : colCyan }
                                        GradientStop { position: 1.0; color: "#4A00E0" }
                                    }

                                    RowLayout {
                                        anchors.centerIn: parent
                                        spacing: 10
                                        FAIcon { text: fa.bolt; font.pixelSize: 15; color: "#FFFFFF" }
                                        Text {
                                            text: "BUILD 3D ROOM IN SKETCHUP"
                                            font.pixelSize: 12
                                            font.bold: true
                                            font.letterSpacing: 1.0
                                            color: "#FFFFFF"
                                        }
                                    }

                                    MouseArea {
                                        id: btnGenMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: backend.createRoom(rWidth.value, rDepth.value, rHeight.value, rThick.value)
                                    }
                                }
                            }
                        }

                        // Right: Interactive 2.5D Schematic Wireframe Canvas
                        Rectangle {
                            Layout.preferredWidth: 380
                            Layout.fillHeight: true
                            radius: 18
                            color: colGlassCard
                            border.width: 1
                            border.color: colBorderLight

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 18
                                spacing: 12

                                RowLayout {
                                    Text { text: "LIVE 2.5D SCHEMATIC"; font.pixelSize: 11; font.bold: true; color: colViolet }
                                    Item { Layout.fillWidth: true }
                                    Text { text: rWidth.value.toFixed(1) + " × " + rDepth.value.toFixed(1) + " × " + rHeight.value.toFixed(1) + "m"; font.pixelSize: 11; color: colCyan }
                                }

                                // Custom Canvas rendering isometric room wireframe in real-time
                                Canvas {
                                    id: schematicCanvas
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true

                                    property real wVal: rWidth.value
                                    property real dVal: rDepth.value
                                    property real hVal: rHeight.value
                                    property real tVal: rThick.value

                                    onWValChanged: requestPaint()
                                    onDValChanged: requestPaint()
                                    onHValChanged: requestPaint()
                                    onTValChanged: requestPaint()

                                    onPaint: {
                                        var ctx = getContext("2d")
                                        ctx.clearRect(0, 0, width, height)

                                        var cx = width / 2.0
                                        var cy = height / 2.0 + 30

                                        var scale = Math.min(width, height) / 45.0
                                        var sw = wVal * scale * 0.866
                                        var sd = dVal * scale * 0.866
                                        var sh = hVal * scale * 1.2

                                        // Floor footprint
                                        ctx.beginPath()
                                        ctx.moveTo(cx, cy)
                                        ctx.lineTo(cx + sw, cy - (wVal * scale * 0.5))
                                        ctx.lineTo(cx + sw - sd, cy - ((wVal + dVal) * scale * 0.5))
                                        ctx.lineTo(cx - sd, cy - (dVal * scale * 0.5))
                                        ctx.closePath()
                                        ctx.fillStyle = "rgba(0, 245, 255, 0.08)"
                                        ctx.fill()
                                        ctx.strokeStyle = "#00F5FF"
                                        ctx.lineWidth = 1.5
                                        ctx.stroke()

                                        // Extruded vertical walls
                                        ctx.beginPath()
                                        ctx.moveTo(cx, cy); ctx.lineTo(cx, cy - sh)
                                        ctx.moveTo(cx + sw, cy - (wVal * scale * 0.5)); ctx.lineTo(cx + sw, cy - (wVal * scale * 0.5) - sh)
                                        ctx.moveTo(cx - sd, cy - (dVal * scale * 0.5)); ctx.lineTo(cx - sd, cy - (dVal * scale * 0.5) - sh)
                                        ctx.strokeStyle = "rgba(139, 92, 246, 0.8)"
                                        ctx.lineWidth = 1.5
                                        ctx.stroke()

                                        // Top ceiling rim
                                        ctx.beginPath()
                                        ctx.moveTo(cx, cy - sh)
                                        ctx.lineTo(cx + sw, cy - (wVal * scale * 0.5) - sh)
                                        ctx.lineTo(cx + sw - sd, cy - ((wVal + dVal) * scale * 0.5) - sh)
                                        ctx.lineTo(cx - sd, cy - (dVal * scale * 0.5) - sh)
                                        ctx.closePath()
                                        ctx.strokeStyle = "#8B5CF6"
                                        ctx.lineWidth = 2.0
                                        ctx.stroke()
                                    }
                                }

                                Text {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: "Real-time geometric scale preview"
                                    font.pixelSize: 10
                                    color: colTextSecondary
                                }
                            }
                        }
                    }

                    // =========================================================
                    // VIEW 1: 3D SOLIDS & MASSING
                    // =========================================================
                    RowLayout {
                        spacing: 20

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            radius: 18
                            color: colGlassCard
                            border.width: 1
                            border.color: colBorderLight

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 22
                                spacing: 14

                                Text { text: "EXTRUSION BOX MASSING"; font.pixelSize: 13; font.bold: true; color: colCyan }

                                RowLayout {
                                    spacing: 12
                                    ColumnLayout {
                                        Text { text: "Width (m):"; font.pixelSize: 11; color: colTextSecondary }
                                        SpinBox { id: sBoxW; from: 1; to: 50; value: 4 }
                                    }
                                    ColumnLayout {
                                        Text { text: "Depth (m):"; font.pixelSize: 11; color: colTextSecondary }
                                        SpinBox { id: sBoxD; from: 1; to: 50; value: 4 }
                                    }
                                    ColumnLayout {
                                        Text { text: "Height (m):"; font.pixelSize: 11; color: colTextSecondary }
                                        SpinBox { id: sBoxH; from: 1; to: 50; value: 3 }
                                    }
                                }

                                Rectangle {
                                    Layout.fillWidth: true; height: 42; radius: 10
                                    color: bBoxM.containsMouse ? Qt.rgba(1, 1, 1, 0.16) : Qt.rgba(1, 1, 1, 0.08)
                                    border.width: 1; border.color: colBorderLight
                                    RowLayout {
                                        anchors.centerIn: parent
                                        spacing: 8
                                        FAIcon { text: fa.plus; font.pixelSize: 11; color: colCyan }
                                        FAIcon { text: fa.cube; font.pixelSize: 13; color: colCyan }
                                        Text { text: "Generate Solid Box"; font.pixelSize: 12; font.bold: true; color: colTextPrimary }
                                    }
                                    MouseArea { id: bBoxM; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: backend.createBox(sBoxW.value, sBoxD.value, sBoxH.value) }
                                }

                                Rectangle { Layout.fillWidth: true; height: 1; color: colBorderLight }

                                Text { text: "ARCHITECTURAL COLUMN"; font.pixelSize: 13; font.bold: true; color: colViolet }

                                RowLayout {
                                    spacing: 12
                                    ColumnLayout {
                                        Text { text: "Radius (m):"; font.pixelSize: 11; color: colTextSecondary }
                                        SpinBox { id: sCylR; from: 1; to: 10; value: 1 }
                                    }
                                    ColumnLayout {
                                        Text { text: "Height (m):"; font.pixelSize: 11; color: colTextSecondary }
                                        SpinBox { id: sCylH; from: 1; to: 30; value: 4 }
                                    }
                                }

                                Rectangle {
                                    Layout.fillWidth: true; height: 42; radius: 10
                                    color: bCylM.containsMouse ? Qt.rgba(1, 1, 1, 0.16) : Qt.rgba(1, 1, 1, 0.08)
                                    border.width: 1; border.color: colBorderLight
                                    RowLayout {
                                        anchors.centerIn: parent
                                        spacing: 8
                                        FAIcon { text: fa.plus; font.pixelSize: 11; color: colViolet }
                                        FAIcon { text: fa.database; font.pixelSize: 13; color: colViolet }
                                        Text { text: "Generate Column"; font.pixelSize: 12; font.bold: true; color: colTextPrimary }
                                    }
                                    MouseArea { id: bCylM; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: backend.createCylinder(sCylR.value, sCylH.value, 24) }
                                }

                                Item { Layout.fillHeight: true }

                                Rectangle {
                                    Layout.fillWidth: true; height: 40; radius: 10
                                    color: Qt.rgba(0.9, 0.2, 0.3, 0.16)
                                    border.width: 1; border.color: Qt.rgba(0.9, 0.2, 0.3, 0.4)
                                    RowLayout {
                                        anchors.centerIn: parent
                                        spacing: 8
                                        FAIcon { text: fa.trash; font.pixelSize: 13; color: "#FF5370" }
                                        Text { text: "Clear Active Entities"; font.pixelSize: 11; font.bold: true; color: "#FF5370" }
                                    }
                                    MouseArea { anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: backend.clearModel() }
                                }
                            }
                        }
                    }

                    // =========================================================
                    // VIEW 2: CAMERA RIG
                    // =========================================================
                    Rectangle {
                        radius: 18
                        color: colGlassCard
                        border.width: 1
                        border.color: colBorderLight

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 28
                            spacing: 18

                            Text { text: "SKETCHUP CAMERA VIEWPORT RIG"; font.pixelSize: 14; font.bold: true; color: colCyan }
                            Text { text: "Reorient the active viewport and fit scene extents with one click."; font.pixelSize: 12; color: colTextSecondary }

                            GridLayout {
                                columns: 3
                                rowSpacing: 14
                                columnSpacing: 14
                                Layout.fillWidth: true

                                Repeater {
                                    model: [
                                        { title: "Isometric (3D)", subtitle: "Default standard 3D perspective", cKey: "iso", icon: fa.cube },
                                        { title: "Top View (Floor Plan)", subtitle: "Architectural 2D orthographic plan", cKey: "top", icon: fa.ruler },
                                        { title: "Front Elevation", subtitle: "Facade perspective", cKey: "front", icon: fa.building },
                                        { title: "Right Elevation", subtitle: "Side perspective", cKey: "right", icon: fa.arrowRight },
                                        { title: "Left Elevation", subtitle: "Opposite side perspective", cKey: "left", icon: fa.arrowLeft }
                                    ]

                                    Rectangle {
                                        Layout.fillWidth: true
                                        height: 84
                                        radius: 14
                                        color: cmM.containsMouse ? Qt.rgba(0, 0.95, 1, 0.16) : Qt.rgba(1, 1, 1, 0.05)
                                        border.width: 1
                                        border.color: cmM.containsMouse ? colCyan : colBorderLight

                                        RowLayout {
                                            anchors.fill: parent
                                            anchors.margins: 16
                                            spacing: 14

                                            FAIcon {
                                                text: modelData.icon
                                                font.pixelSize: 22
                                                color: cmM.containsMouse ? colCyan : colTextPrimary
                                            }
                                            ColumnLayout {
                                                Text { text: modelData.title; font.pixelSize: 13; font.bold: true; color: colTextPrimary }
                                                Text { text: modelData.subtitle; font.pixelSize: 10; color: colTextSecondary }
                                            }
                                        }

                                        MouseArea {
                                            id: cmM
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: backend.setCamera(modelData.cKey)
                                        }
                                    }
                                }
                            }
                            Item { Layout.fillHeight: true }
                        }
                    }

                    // =========================================================
                    // VIEW 3: EXPORT STUDIO
                    // =========================================================
                    Rectangle {
                        radius: 18
                        color: colGlassCard
                        border.width: 1
                        border.color: colBorderLight

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 28
                            spacing: 18

                            Text { text: "EXPORT PIPELINE & RENDERS"; font.pixelSize: 14; font.bold: true; color: colCyan }
                            Text { text: "Directly export 3D geometry or trigger 4K viewport screenshots."; font.pixelSize: 12; color: colTextSecondary }

                            RowLayout {
                                spacing: 14
                                property string selFmt: "obj"

                                Repeater {
                                    model: [
                                        { fmt: "obj", title: "OBJ (Wavefront)", desc: "Standard 3D mesh" },
                                        { fmt: "stl", title: "STL (3D Print)", desc: "Additive manufacturing" },
                                        { fmt: "dae", title: "DAE (Collada)", desc: "Blender & Game engines" },
                                        { fmt: "png", title: "PNG (Viewport Render)", desc: "Instant high-res image" }
                                    ]

                                    Rectangle {
                                        property bool isPicked: expGroup.fmt === modelData.fmt
                                        Layout.preferredWidth: 200
                                        height: 76
                                        radius: 14
                                        color: isPicked ? Qt.rgba(0, 0.95, 1, 0.20) : (fmM.containsMouse ? Qt.rgba(1, 1, 1, 0.08) : Qt.rgba(1, 1, 1, 0.04))
                                        border.width: 1
                                        border.color: isPicked ? colCyan : colBorderLight

                                        ColumnLayout {
                                            anchors.centerIn: parent
                                            spacing: 4
                                            Text { text: modelData.title; font.pixelSize: 12; font.bold: true; color: isPicked ? colCyan : colTextPrimary }
                                            Text { text: modelData.desc; font.pixelSize: 10; color: colTextSecondary }
                                        }
                                        MouseArea {
                                            id: fmM
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: expGroup.fmt = modelData.fmt
                                        }
                                    }
                                }
                            }

                            QtObject { id: expGroup; property string fmt: "obj" }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 6
                                Text { text: "Custom File Path (Leave blank to save to ~/Desktop automatically):"; font.pixelSize: 11; color: colTextSecondary }
                                Rectangle {
                                    Layout.fillWidth: true
                                    height: 42
                                    radius: 10
                                    color: "#05070B"
                                    border.width: 1; border.color: colBorderLight
                                    TextInput {
                                        id: expPath
                                        anchors.fill: parent
                                        anchors.leftMargin: 14; anchors.rightMargin: 14
                                        verticalAlignment: TextInput.AlignVCenter
                                        color: colTextPrimary
                                        font.pixelSize: 12
                                    }
                                }
                            }

                            Item { Layout.fillHeight: true }

                            Rectangle {
                                Layout.fillWidth: true; height: 50; radius: 14
                                gradient: Gradient {
                                    GradientStop { position: 0.0; color: expBtnM.containsMouse ? "#00F5A0" : "#10B981" }
                                    GradientStop { position: 1.0; color: "#047857" }
                                }
                                RowLayout {
                                    anchors.centerIn: parent
                                    spacing: 10
                                    FAIcon { text: fa.floppy; font.pixelSize: 16; color: "#FFFFFF" }
                                    Text {
                                        text: "ONE-CLICK EXPORT TO DISK (" + expGroup.fmt.toUpperCase() + ")"
                                        font.pixelSize: 12
                                        font.bold: true
                                        font.letterSpacing: 1.0
                                        color: "#FFFFFF"
                                    }
                                }
                                MouseArea {
                                    id: expBtnM
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: backend.exportModel(expGroup.fmt, expPath.text)
                                }
                            }
                        }
                    }

                    // =========================================================
                    // VIEW 4: MODEL TELEMETRY
                    // =========================================================
                    Rectangle {
                        radius: 18
                        color: colGlassCard
                        border.width: 1
                        border.color: colBorderLight

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 28
                            spacing: 18

                            Text { text: "MODEL TELEMETRY & STATS"; font.pixelSize: 14; font.bold: true; color: colCyan }

                            GridLayout {
                                columns: 2
                                rowSpacing: 14
                                columnSpacing: 14
                                Layout.fillWidth: true

                                // Card 1: Dimensions
                                Rectangle {
                                    Layout.fillWidth: true
                                    height: 84
                                    radius: 14
                                    color: Qt.rgba(1, 1, 1, 0.05)
                                    border.width: 1
                                    border.color: colBorderLight

                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.margins: 18
                                        spacing: 16
                                        FAIcon { text: fa.ruler; font.pixelSize: 26; color: colCyan }
                                        ColumnLayout {
                                            Text { text: "Bounding Dimensions"; font.pixelSize: 11; color: colTextSecondary }
                                            Text { text: backend ? backend.dimensions : "—"; font.pixelSize: 18; font.bold: true; color: colCyan }
                                        }
                                    }
                                }

                                // Card 2: Faces
                                Rectangle {
                                    Layout.fillWidth: true
                                    height: 84
                                    radius: 14
                                    color: Qt.rgba(1, 1, 1, 0.05)
                                    border.width: 1
                                    border.color: colBorderLight

                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.margins: 18
                                        spacing: 16
                                        FAIcon { text: fa.polygon; font.pixelSize: 26; color: colViolet }
                                        ColumnLayout {
                                            Text { text: "Faces / Surfaces"; font.pixelSize: 11; color: colTextSecondary }
                                            Text { text: backend ? backend.facesCount.toString() : "0"; font.pixelSize: 18; font.bold: true; color: colCyan }
                                        }
                                    }
                                }

                                // Card 3: Edges
                                Rectangle {
                                    Layout.fillWidth: true
                                    height: 84
                                    radius: 14
                                    color: Qt.rgba(1, 1, 1, 0.05)
                                    border.width: 1
                                    border.color: colBorderLight

                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.margins: 18
                                        spacing: 16
                                        FAIcon { text: fa.rulerVertical; font.pixelSize: 26; color: colAmber }
                                        ColumnLayout {
                                            Text { text: "Edges / Wireframe"; font.pixelSize: 11; color: colTextSecondary }
                                            Text { text: backend ? backend.edgesCount.toString() : "0"; font.pixelSize: 18; font.bold: true; color: colCyan }
                                        }
                                    }
                                }

                                // Card 4: Groups & Components
                                Rectangle {
                                    Layout.fillWidth: true
                                    height: 84
                                    radius: 14
                                    color: Qt.rgba(1, 1, 1, 0.05)
                                    border.width: 1
                                    border.color: colBorderLight

                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.margins: 18
                                        spacing: 16
                                        FAIcon { text: fa.boxes; font.pixelSize: 26; color: colEmerald }
                                        ColumnLayout {
                                            Text { text: "Groups & Components"; font.pixelSize: 11; color: colTextSecondary }
                                            Text { text: backend ? (backend.groupsCount + backend.componentsCount).toString() : "0"; font.pixelSize: 18; font.bold: true; color: colCyan }
                                        }
                                    }
                                }
                            }
                            Item { Layout.fillHeight: true }
                        }
                    }

                    // =========================================================
                    // VIEW 5: RUBY SCRIPT TERMINAL
                    // =========================================================
                    Rectangle {
                        radius: 18
                        color: colGlassCard
                        border.width: 1
                        border.color: colBorderLight

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 24
                            spacing: 14

                            RowLayout {
                                Text { text: "RUBY SCRIPT TERMINAL"; font.pixelSize: 13; font.bold: true; color: colViolet }
                                Item { Layout.fillWidth: true }
                                Text { text: "Executes on SketchUp main UI thread with undo tracking"; font.pixelSize: 11; color: colTextSecondary }
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                radius: 12
                                color: "#05070B"
                                border.width: 1; border.color: colBorderLight

                                TextArea {
                                    id: rbCode
                                    anchors.fill: parent
                                    anchors.margins: 14
                                    color: "#A0F0FF"
                                    font.family: "Menlo, Monaco, Consolas, monospace"
                                    font.pixelSize: 12
                                    wrapMode: TextArea.Wrap
                                    text: "# Example: 10 procedural cubes in an ascending helix\n10.times do |i|\n  face = Sketchup.active_model.active_entities.add_face([\n    [i.m, 0, (i*0.5).m], [(i+0.8).m, 0, (i*0.5).m], [(i+0.8).m, 0.8.m, (i*0.5).m], [i.m, 0.8.m, (i*0.5).m]\n  ])\n  face.pushpull(-0.6.m)\nend"
                                }
                            }

                            Rectangle {
                                Layout.fillWidth: true; height: 42; radius: 10
                                gradient: Gradient {
                                    GradientStop { position: 0.0; color: colViolet }
                                    GradientStop { position: 1.0; color: "#4A00E0" }
                                }
                                RowLayout {
                                    anchors.centerIn: parent
                                    spacing: 8
                                    FAIcon { text: fa.play; font.pixelSize: 11; color: "#FFFFFF" }
                                    Text { text: "Execute Ruby in SketchUp"; font.pixelSize: 12; font.bold: true; color: "#FFFFFF" }
                                }
                                MouseArea { anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: backend.evalRuby(rbCode.text) }
                            }
                        }
                    }
                }
            }
        }
    }

    // =========================================================================
    // SLIDE-OVER DRAWER: HOW IT WORKS & CREDITS (Spacious & Clean Layout)
    // =========================================================================
    Rectangle {
        id: drawerBackdrop
        anchors.fill: parent
        z: 90
        visible: infoDrawerOpen
        opacity: infoDrawerOpen ? 1.0 : 0.0
        color: Qt.rgba(0, 0, 0, 0.65)

        Behavior on opacity { NumberAnimation { duration: 200 } }

        MouseArea {
            anchors.fill: parent
            onClicked: infoDrawerOpen = false
        }
    }

    Rectangle {
        id: drawerPanel
        z: 100
        width: Math.min(520, root.width - 40)
        height: root.height
        x: infoDrawerOpen ? root.width - width : root.width
        color: "#080C16"
        border.width: 1
        border.color: colBorderActive

        Behavior on x { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 28
            spacing: 18

            // Drawer Header
            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                Rectangle {
                    width: 36; height: 36; radius: 10
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: colCyan }
                        GradientStop { position: 1.0; color: colViolet }
                    }
                    FAIcon { anchors.centerIn: parent; text: fa.info; font.pixelSize: 16; color: "#05070B" }
                }

                ColumnLayout {
                    spacing: 2
                    Text { text: "HOW IT WORKS & CREDITS"; font.pixelSize: 14; font.bold: true; color: colTextPrimary }
                    Text { text: "Architecture, direct sync, and project information"; font.pixelSize: 11; color: colTextSecondary }
                }

                Item { Layout.fillWidth: true }

                Rectangle {
                    width: 32; height: 32; radius: 8
                    color: drwCloseM.containsMouse ? Qt.rgba(1, 1, 1, 0.15) : Qt.rgba(1, 1, 1, 0.05)
                    border.width: 1; border.color: colBorderLight
                    FAIcon { anchors.centerIn: parent; text: fa.xmark; font.pixelSize: 13; color: colTextPrimary }
                    MouseArea {
                        id: drwCloseM
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: infoDrawerOpen = false
                    }
                }
            }

            Rectangle { Layout.fillWidth: true; height: 1; color: colBorderLight }

            // Scrollable Info Area
            Flickable {
                Layout.fillWidth: true
                Layout.fillHeight: true
                contentHeight: drwCol.implicitHeight
                clip: true

                ColumnLayout {
                    id: drwCol
                    width: parent.width
                    spacing: 16

                    RowLayout {
                        spacing: 8
                        FAIcon { text: fa.bolt; font.pixelSize: 12; color: colCyan }
                        Text { text: "HOW THE SYSTEM OPERATES"; font.pixelSize: 12; font.bold: true; color: colCyan; font.letterSpacing: 1.0 }
                    }

                    Repeater {
                        model: [
                            { title: "1. Local Ruby Bridge Server", desc: "A non-blocking HTTP REST daemon runs inside SketchUp 2026 on 127.0.0.1:9876. It automatically boots whenever SketchUp opens." },
                            { title: "2. Real-Time Viewport Sync", desc: "Adjusting sliders or triggering presets dispatches JSON to SketchUp. Geometry is generated procedurally in milliseconds with clean manifold solids." },
                            { title: "3. Full Native Undo (Ctrl+Z / Cmd+Z)", desc: "Every single action is wrapped in a native SketchUp undo transaction. You can undo or redo anything at any time inside the 3D model." },
                            { title: "4. Direct 1-Click Exporter", desc: "Export scenes to OBJ, STL (3D Printing), DAE (Blender/Unity), or high-res 4K PNG renders with no intermediate popups." },
                            { title: "5. Optional AI Model Context Protocol (MCP)", desc: "The included sketchup_mcp.py server connects directly to Claude Desktop or Cursor to drive SketchUp using natural language." }
                        ]

                        Rectangle {
                            Layout.fillWidth: true
                            implicitHeight: rCol.implicitHeight + 20
                            radius: 12
                            color: Qt.rgba(1, 1, 1, 0.04)
                            border.width: 1
                            border.color: colBorderLight

                            RowLayout {
                                id: rCol
                                anchors.fill: parent
                                anchors.margins: 12
                                spacing: 10

                                Rectangle {
                                    width: 8; height: 8; radius: 4
                                    color: colCyan
                                    Layout.alignment: Qt.AlignTop
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 4
                                    Text {
                                        text: modelData.title
                                        font.pixelSize: 12
                                        font.bold: true
                                        color: colTextPrimary
                                    }
                                    Text {
                                        text: modelData.desc
                                        font.pixelSize: 11
                                        color: colTextSecondary
                                        wrapMode: Text.WordWrap
                                        Layout.fillWidth: true
                                    }
                                }
                            }
                        }
                    }

                    Rectangle { Layout.fillWidth: true; height: 1; color: colBorderLight }

                    RowLayout {
                        spacing: 8
                        FAIcon { text: fa.gem; font.pixelSize: 12; color: colViolet }
                        Text { text: "CREDITS & TECHNICAL STACK"; font.pixelSize: 12; font.bold: true; color: colViolet; font.letterSpacing: 1.0 }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: credCol.implicitHeight + 24
                        radius: 12
                        color: Qt.rgba(1, 1, 1, 0.04)
                        border.width: 1
                        border.color: colBorderLight

                        ColumnLayout {
                            id: credCol
                            anchors.fill: parent
                            anchors.margins: 14
                            spacing: 8

                            RowLayout {
                                Text { text: "Author / Developer:"; font.pixelSize: 11; color: colTextSecondary; Layout.preferredWidth: 140 }
                                Text { text: "Mohamed Amraoui (@amraoui-mo7amed)"; font.pixelSize: 11; font.bold: true; color: colCyan }
                            }
                            RowLayout {
                                Text { text: "UI Framework:"; font.pixelSize: 11; color: colTextSecondary; Layout.preferredWidth: 140 }
                                Text { text: "PySide6 / Qt Quick QML (Spatial Liquid Glass)"; font.pixelSize: 11; font.bold: true; color: colTextPrimary }
                            }
                            RowLayout {
                                Text { text: "CAD Integration:"; font.pixelSize: 11; color: colTextSecondary; Layout.preferredWidth: 140 }
                                Text { text: "SketchUp 2026 Ruby C API Bridge"; font.pixelSize: 11; font.bold: true; color: colTextPrimary }
                            }
                            RowLayout {
                                Text { text: "AI Protocol:"; font.pixelSize: 11; color: colTextSecondary; Layout.preferredWidth: 140 }
                                Text { text: "Model Context Protocol (FastMCP 2.x)"; font.pixelSize: 11; font.bold: true; color: colEmerald }
                            }
                            RowLayout {
                                Text { text: "Repository:"; font.pixelSize: 11; color: colTextSecondary; Layout.preferredWidth: 140 }
                                Text { text: "github.com/amraoui-mo7amed/sketchup-controller"; font.pixelSize: 11; color: colCyan }
                            }
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true; height: 42; radius: 10
                gradient: Gradient {
                    GradientStop { position: 0.0; color: colCyan }
                    GradientStop { position: 1.0; color: colViolet }
                }
                Text { anchors.centerIn: parent; text: "Close Guide"; font.pixelSize: 12; font.bold: true; color: "#05070B" }
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: infoDrawerOpen = false
                }
            }
        }
    }

    // =========================================================================
    // FLOATING TOAST NOTIFICATION
    // =========================================================================
    Rectangle {
        id: toast
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: toastVisible ? 24 : -60
        width: Math.min(toastRow.implicitWidth + 40, root.width - 48)
        height: 40
        radius: 20
        z: 99
        color: toastSuccess ? Qt.rgba(0.06, 0.72, 0.50, 0.95) : Qt.rgba(0.94, 0.27, 0.27, 0.95)

        Behavior on anchors.bottomMargin { NumberAnimation { duration: 250; easing.type: Easing.OutBack } }

        RowLayout {
            id: toastRow
            anchors.centerIn: parent
            spacing: 8
            FAIcon { text: toastSuccess ? fa.check : fa.warning; font.pixelSize: 13; color: "#FFFFFF" }
            Text { text: toastText; font.pixelSize: 11; font.bold: true; color: "#FFFFFF" }
        }
    }
}
