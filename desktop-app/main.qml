import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "shapes_library.js" as ShapeLib

ApplicationWindow {
    id: root
    visible: true
    width: 1240
    height: 780
    minimumWidth: 1040
    minimumHeight: 660
    title: "Liquid CAD Studio — SketchUp 2026 Controller"
    color: "#07090E"

    // --- Modern Spatial Color Palette ---
    readonly property color colBgDark: "#07090E"
    readonly property color colGlassSurface: Qt.rgba(0.06, 0.09, 0.16, 0.65)
    readonly property color colGlassElevated: Qt.rgba(0.09, 0.13, 0.22, 0.85)
    readonly property color colGlassCard: Qt.rgba(0.07, 0.11, 0.19, 0.55)
    readonly property color colBorderSubtle: Qt.rgba(1.0, 1.0, 1.0, 0.08)
    readonly property color colBorderLight: Qt.rgba(1.0, 1.0, 1.0, 0.15)
    readonly property color colBorderActive: "#00F5FF"
    readonly property color colCyan: "#00F5FF"
    readonly property color colViolet: "#8B5CF6"
    readonly property color colEmerald: "#10B981"
    readonly property color colAmber: "#F59E0B"
    readonly property color colRose: "#EC4899"
    readonly property color colTextPrimary: "#F8FAFC"
    readonly property color colTextSecondary: "#94A3B8"
    readonly property color colTextMuted: "#64748B"

    property int activeNav: 0 // 0: Shapes, 1: Solids, 2: Camera, 3: Stats
    property bool infoDrawerOpen: false
    property bool exportModalOpen: false

    // Shape Library & Inspector Drawer State
    property string activeCategory: "all"
    property string searchQuery: ""
    property var selectedShape: null
    property var currentParamValues: ({})
    property bool shapeDrawerOpen: false
    property bool shapeDrawerFullWidth: false

    function selectShape(shape) {
        if (!shape) return
        selectedShape = shape
        var vals = {}
        if (shape.params) {
            for (var i = 0; i < shape.params.length; i++) {
                var p = shape.params[i]
                vals[p.key] = p.val
            }
        }
        currentParamValues = vals
        shapeDrawerOpen = true
    }

    function selectShapeById(shapeId) {
        selectShape(ShapeLib.getShapeById(shapeId))
    }

    function updateShapeParam(key, value) {
        var copy = {}
        for (var k in currentParamValues) {
            copy[k] = currentParamValues[k]
        }
        copy[key] = value
        currentParamValues = copy
    }

    function buildSelectedShape() {
        if (!selectedShape) return
        backend.createParametricShape(selectedShape.id, JSON.stringify(currentParamValues))
    }

    function closeDrawer() {
        shapeDrawerOpen = false
    }

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
        readonly property string minus: "\uf068"
        readonly property string stairs: "\uf550"
        readonly property string search: "\uf002"
        readonly property string sliders: "\uf1de"
        readonly property string shapes: "\uf5aa"
    }

    component FAIcon: Text {
        font.family: root.faFamily
        font.styleName: "Solid"
        font.weight: Font.Black
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    // =========================================================================
    // AMBIENT GRADIENT FIELD (Minimalist, Spatial)
    // =========================================================================
    Item {
        anchors.fill: parent
        z: 0

        Rectangle {
            width: 700; height: 700; radius: 350
            x: -200; y: -200
            opacity: 0.14
            gradient: Gradient {
                GradientStop { position: 0.0; color: colCyan }
                GradientStop { position: 0.6; color: Qt.rgba(0, 0.8, 1, 0.03) }
                GradientStop { position: 1.0; color: "transparent" }
            }
        }

        Rectangle {
            width: 600; height: 600; radius: 300
            x: root.width - 400; y: root.height - 350
            opacity: 0.12
            gradient: Gradient {
                GradientStop { position: 0.0; color: colViolet }
                GradientStop { position: 0.6; color: Qt.rgba(0.5, 0.2, 0.9, 0.03) }
                GradientStop { position: 1.0; color: "transparent" }
            }
        }
    }

    // =========================================================================
    // MAIN APP LAYOUT (Unified Header + Content Area + Right Settings Drawer)
    // =========================================================================
    ColumnLayout {
        anchors.fill: parent
        spacing: 0
        z: 1

        // ---------------------------------------------------------------------
        // 1. TOP UNIFIED APP BAR (Clean, Compact, Focused)
        // ---------------------------------------------------------------------
        Rectangle {
            Layout.fillWidth: true
            height: 54
            color: Qt.rgba(0.04, 0.06, 0.11, 0.92)
            border.width: 1
            border.color: colBorderSubtle

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 16
                anchors.rightMargin: 16
                spacing: 12

                // Brand Emblem
                RowLayout {
                    spacing: 8
                    Rectangle {
                        width: 32; height: 32; radius: 9
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: colCyan }
                            GradientStop { position: 1.0; color: colViolet }
                        }
                        FAIcon {
                            anchors.centerIn: parent
                            text: fa.cube
                            font.pixelSize: 15
                            color: "#05070B"
                        }
                    }

                    ColumnLayout {
                        spacing: 0
                        Text {
                            text: "LIQUID CAD"
                            font.pixelSize: 12
                            font.bold: true
                            font.letterSpacing: 1.2
                            color: "#FFFFFF"
                        }
                        Text {
                            text: "SketchUp 2026 Bridge"
                            font.pixelSize: 9
                            color: colTextMuted
                        }
                    }
                }

                Rectangle { width: 1; height: 24; color: colBorderSubtle }

                // Studio Navigation Segmented Bar: [ Shapes | Solids | Camera | Stats ]
                Rectangle {
                    height: 36
                    implicitWidth: navSegmentsRow.implicitWidth + 8
                    radius: 18
                    color: Qt.rgba(1, 1, 1, 0.04)
                    border.width: 1
                    border.color: colBorderSubtle

                    RowLayout {
                        id: navSegmentsRow
                        anchors.centerIn: parent
                        spacing: 2

                        Repeater {
                            model: [
                                { id: 0, label: "Shapes", icon: fa.cubes },
                                { id: 1, label: "Solids", icon: fa.cube },
                                { id: 2, label: "Camera", icon: fa.camera },
                                { id: 3, label: "Stats", icon: fa.chart }
                            ]

                            Rectangle {
                                property bool isCur: activeNav === modelData.id
                                height: 30
                                implicitWidth: segContent.implicitWidth + 18
                                radius: 15
                                color: isCur ? Qt.rgba(0, 0.95, 1, 0.18) : (segM.containsMouse ? Qt.rgba(1, 1, 1, 0.06) : "transparent")
                                border.width: isCur ? 1 : 0
                                border.color: colCyan

                                Behavior on color { ColorAnimation { duration: 120 } }

                                RowLayout {
                                    id: segContent
                                    anchors.centerIn: parent
                                    spacing: 5
                                    FAIcon {
                                        text: modelData.icon
                                        font.pixelSize: 11
                                        color: parent.parent.isCur ? colCyan : (segM.containsMouse ? colTextPrimary : colTextSecondary)
                                    }
                                    Text {
                                        text: modelData.label
                                        font.pixelSize: 10
                                        font.bold: parent.parent.isCur
                                        color: parent.parent.isCur ? "#FFFFFF" : colTextSecondary
                                    }
                                }

                                MouseArea {
                                    id: segM
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: activeNav = modelData.id
                                }
                            }
                        }
                    }
                }

                Item { Layout.fillWidth: true }

                // Search Bar (Shown in Top Bar for Shapes)
                Rectangle {
                    visible: activeNav === 0
                    height: 32
                    implicitWidth: 240
                    radius: 16
                    color: Qt.rgba(0, 0, 0, 0.40)
                    border.width: 1
                    border.color: topSearchIn.activeFocus ? colCyan : colBorderSubtle

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 8
                        spacing: 6

                        FAIcon { text: fa.search; font.pixelSize: 10; color: topSearchIn.activeFocus ? colCyan : colTextMuted }

                        TextInput {
                            id: topSearchIn
                            Layout.fillWidth: true
                            color: colTextPrimary
                            font.pixelSize: 11
                            verticalAlignment: TextInput.AlignVCenter
                            clip: true

                            Text {
                                text: "Search shapes..."
                                color: Qt.rgba(1, 1, 1, 0.35)
                                font.pixelSize: 10
                                visible: !topSearchIn.text && !topSearchIn.activeFocus
                                anchors.fill: parent
                                verticalAlignment: Text.AlignVCenter
                            }

                            onTextChanged: root.searchQuery = text
                        }

                        Rectangle {
                            visible: topSearchIn.text.length > 0
                            width: 16; height: 16; radius: 8
                            color: Qt.rgba(1, 1, 1, 0.15)
                            FAIcon { anchors.centerIn: parent; text: fa.xmark; font.pixelSize: 8; color: colTextPrimary }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: topSearchIn.text = ""
                            }
                        }
                    }
                }

                // Separated Icon-Only Export Button (Prompt: "the export must be a separated icon-only button that shows a modal")
                Rectangle {
                    width: 32; height: 32; radius: 16
                    color: expBtnM.containsMouse ? Qt.rgba(139, 92, 246, 0.25) : Qt.rgba(1, 1, 1, 0.05)
                    border.width: 1
                    border.color: expBtnM.containsMouse ? colViolet : colBorderSubtle

                    FAIcon {
                        anchors.centerIn: parent
                        text: fa.fileExport
                        font.pixelSize: 12
                        color: expBtnM.containsMouse ? colViolet : colTextSecondary
                    }

                    MouseArea {
                        id: expBtnM
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.exportModalOpen = true
                    }
                }

                // 1-Click Auto Setup Button
                Rectangle {
                    height: 32
                    implicitWidth: autoSetupRow.implicitWidth + 20
                    radius: 16
                    color: autoSetupM.containsMouse ? Qt.rgba(0, 0.95, 1, 0.25) : Qt.rgba(0, 0.95, 1, 0.10)
                    border.width: 1
                    border.color: autoSetupM.containsMouse ? colCyan : Qt.rgba(0, 0.95, 1, 0.35)

                    RowLayout {
                        id: autoSetupRow
                        anchors.centerIn: parent
                        spacing: 6
                        FAIcon { text: fa.bolt; font.pixelSize: 11; color: colCyan }
                        Text {
                            text: "Auto Setup"
                            font.pixelSize: 10
                            font.bold: true
                            color: "#FFFFFF"
                        }
                    }

                    MouseArea {
                        id: autoSetupM
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: backend.autoSetupPlugin()
                    }
                }

                // Bridge Status Pill
                Rectangle {
                    property bool isConn: backend ? backend.connected : false
                    height: 32
                    implicitWidth: statusPillRow.implicitWidth + 22
                    radius: 16
                    color: isConn ? Qt.rgba(0.06, 0.72, 0.50, 0.12) : Qt.rgba(0.96, 0.62, 0.04, 0.12)
                    border.width: 1
                    border.color: isConn ? Qt.rgba(0.06, 0.72, 0.50, 0.35) : Qt.rgba(0.96, 0.62, 0.04, 0.35)

                    RowLayout {
                        id: statusPillRow
                        anchors.centerIn: parent
                        spacing: 6

                        Rectangle {
                            width: 7; height: 7; radius: 3.5
                            color: parent.parent.isConn ? colEmerald : colAmber
                            SequentialAnimation on opacity {
                                loops: Animation.Infinite
                                NumberAnimation { to: 0.3; duration: 800 }
                                NumberAnimation { to: 1.0; duration: 800 }
                            }
                        }

                        Text {
                            text: parent.parent.isConn ? "Bridge Online" : "Bridge Offline"
                            font.pixelSize: 10
                            font.bold: true
                            color: parent.parent.isConn ? colEmerald : colAmber
                        }
                    }
                }

                // Info / Credits Drawer Toggle Button
                Rectangle {
                    width: 32; height: 32; radius: 16
                    color: infoM.containsMouse ? Qt.rgba(1, 1, 1, 0.12) : Qt.rgba(1, 1, 1, 0.05)
                    border.width: 1
                    border.color: colBorderSubtle

                    FAIcon {
                        anchors.centerIn: parent
                        text: fa.info
                        font.pixelSize: 12
                        color: infoM.containsMouse ? colCyan : colTextSecondary
                    }
                    MouseArea {
                        id: infoM
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: infoDrawerOpen = true
                    }
                }
            }
        }

        // ---------------------------------------------------------------------
        // 2. SUB-BAR: CATEGORIES & QUICK RIBBON (Only in Shapes View)
        // ---------------------------------------------------------------------
        Rectangle {
            visible: activeNav === 0
            Layout.fillWidth: true
            height: 42
            color: Qt.rgba(0.05, 0.07, 0.13, 0.75)
            border.width: 1
            border.color: colBorderSubtle

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 16
                anchors.rightMargin: 16
                spacing: 10

                // Category Switcher Pills
                Flickable {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    contentWidth: catRow.implicitWidth
                    contentHeight: height
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds

                    RowLayout {
                        id: catRow
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 6

                        Repeater {
                            model: ShapeLib.categories

                            Rectangle {
                                property bool isSel: root.activeCategory === modelData.id
                                height: 26
                                implicitWidth: catTxtRow.implicitWidth + 16
                                radius: 13
                                color: isSel ? Qt.rgba(0, 0.95, 1, 0.22) : (catMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.08) : "transparent")
                                border.width: isSel ? 1 : 0
                                border.color: colCyan

                                RowLayout {
                                    id: catTxtRow
                                    anchors.centerIn: parent
                                    spacing: 5
                                    FAIcon {
                                        text: modelData.icon
                                        font.pixelSize: 10
                                        color: parent.parent.isSel ? colCyan : colTextSecondary
                                    }
                                    Text {
                                        text: modelData.name
                                        font.pixelSize: 10
                                        font.bold: parent.parent.isSel
                                        color: parent.parent.isSel ? "#FFFFFF" : colTextSecondary
                                    }
                                }

                                MouseArea {
                                    id: catMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: root.activeCategory = modelData.id
                                }
                            }
                        }
                    }
                }

                Rectangle { width: 1; height: 18; color: colBorderSubtle }

                Text {
                    text: shapesRepeater.count + " shapes"
                    font.pixelSize: 10
                    color: colTextMuted
                }

                // Drawer Toggle Indicator
                Rectangle {
                    visible: root.selectedShape !== null
                    height: 24
                    implicitWidth: drwToggleRow.implicitWidth + 14
                    radius: 12
                    color: drwToggleM.containsMouse ? Qt.rgba(139, 92, 246, 0.25) : Qt.rgba(139, 92, 246, 0.12)
                    border.width: 1
                    border.color: colViolet

                    RowLayout {
                        id: drwToggleRow
                        anchors.centerIn: parent
                        spacing: 5
                        FAIcon { text: fa.sliders; font.pixelSize: 9; color: colViolet }
                        Text {
                            text: root.shapeDrawerOpen ? "Hide Inspector" : "Show Inspector"
                            font.pixelSize: 9
                            font.bold: true
                            color: "#FFFFFF"
                        }
                    }

                    MouseArea {
                        id: drwToggleM
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.shapeDrawerOpen = !root.shapeDrawerOpen
                    }
                }
            }
        }

        // ---------------------------------------------------------------------
        // 3. WORKSPACE STAGE WITH INTEGRATED RIGHT INSPECTOR DRAWER
        // ---------------------------------------------------------------------
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0

            // -----------------------------------------------------------------
            // MAIN CONTENT STAGE (StackLayout for remaining Studios)
            // -----------------------------------------------------------------
            Item {
                Layout.fillWidth: !root.shapeDrawerFullWidth
                Layout.fillHeight: true
                visible: !root.shapeDrawerFullWidth
                clip: true

                StackLayout {
                    anchors.fill: parent
                    anchors.margins: 14
                    currentIndex: activeNav

                    // =========================================================
                    // VIEW 0: SHAPES CATALOG GRID
                    // =========================================================
                    ScrollView {
                        clip: true

                        Flickable {
                            contentWidth: width
                            contentHeight: shapesFlow.implicitHeight + 20
                            boundsBehavior: Flickable.StopAtBounds

                            Flow {
                                id: shapesFlow
                                width: parent.width
                                spacing: 12

                                Repeater {
                                    id: shapesRepeater
                                    model: ShapeLib.getShapesByCategory(root.activeCategory, root.searchQuery)

                                    Rectangle {
                                        property bool isAct: root.selectedShape && root.selectedShape.id === modelData.id
                                        width: Math.max(180, Math.floor((shapesFlow.width - (3 * 12)) / (root.shapeDrawerOpen ? 3 : 4)))
                                        height: 120
                                        radius: 14
                                        color: isAct ? Qt.rgba(0, 0.95, 1, 0.12) : (cardMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.07) : colGlassCard)
                                        border.width: isAct ? 1.5 : 1
                                        border.color: isAct ? colCyan : (cardMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.25) : colBorderSubtle)
                                        clip: true

                                        Behavior on border.color { ColorAnimation { duration: 120 } }
                                        Behavior on color { ColorAnimation { duration: 120 } }

                                        ColumnLayout {
                                            anchors.fill: parent
                                            anchors.margins: 12
                                            spacing: 6

                                            // Card Top Row: Squircle Icon + Category Pill
                                            RowLayout {
                                                Layout.fillWidth: true

                                                Rectangle {
                                                    width: 32; height: 32; radius: 9
                                                    gradient: Gradient {
                                                        GradientStop { position: 0.0; color: isAct ? colCyan : (cardMouse.containsMouse ? colCyan : Qt.rgba(0, 0.95, 1, 0.25)) }
                                                        GradientStop { position: 1.0; color: isAct ? colViolet : (cardMouse.containsMouse ? colViolet : Qt.rgba(139, 92, 246, 0.25)) }
                                                    }
                                                    FAIcon {
                                                        anchors.centerIn: parent
                                                        text: modelData.icon
                                                        font.pixelSize: 14
                                                        color: (isAct || cardMouse.containsMouse) ? "#05070B" : colCyan
                                                    }
                                                }

                                                Item { Layout.fillWidth: true }

                                                Rectangle {
                                                    height: 16
                                                    implicitWidth: cTagTxt.implicitWidth + 10
                                                    radius: 8
                                                    color: Qt.rgba(1, 1, 1, 0.05)
                                                    Text {
                                                        id: cTagTxt
                                                        anchors.centerIn: parent
                                                        text: modelData.category.toUpperCase()
                                                        font.pixelSize: 8
                                                        font.bold: true
                                                        color: colTextMuted
                                                    }
                                                }
                                            }

                                            // Shape Name
                                            Text {
                                                text: modelData.name
                                                font.pixelSize: 12
                                                font.bold: true
                                                color: isAct ? colCyan : "#FFFFFF"
                                                elide: Text.ElideRight
                                                Layout.fillWidth: true
                                            }

                                            // Shape Description
                                            Text {
                                                text: modelData.desc
                                                font.pixelSize: 9
                                                color: colTextSecondary
                                                wrapMode: Text.Wrap
                                                maximumLineCount: 2
                                                elide: Text.ElideRight
                                                Layout.fillWidth: true
                                            }

                                            Item { Layout.fillHeight: true }

                                            // Bottom Micro-Bar: Parameter count & Configure cue
                                            RowLayout {
                                                Layout.fillWidth: true
                                                Text {
                                                    text: (modelData.params ? modelData.params.length : 0) + " params"
                                                    font.pixelSize: 9
                                                    color: colTextMuted
                                                }
                                                Item { Layout.fillWidth: true }
                                                Text {
                                                    text: isAct ? "Editing in Drawer →" : "Configure →"
                                                    font.pixelSize: 9
                                                    font.bold: true
                                                    color: isAct ? colCyan : (cardMouse.containsMouse ? colTextPrimary : "transparent")
                                                }
                                            }
                                        }

                                        MouseArea {
                                            id: cardMouse
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: root.selectShape(modelData)
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // =========================================================
                    // VIEW 1: SOLIDS MASSING
                    // =========================================================
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: 16

                        Rectangle {
                            Layout.fillWidth: true; Layout.fillHeight: true; radius: 16; color: colGlassCard; border.width: 1; border.color: colBorderSubtle
                            ColumnLayout {
                                anchors.fill: parent; anchors.margins: 20; spacing: 12
                                Text { text: "BOX MASSING"; font.pixelSize: 13; font.bold: true; color: colCyan }
                                ColumnLayout {
                                    Layout.fillWidth: true; spacing: 2
                                    RowLayout {
                                        Text { text: "Width (X):"; font.pixelSize: 11; color: colTextPrimary }
                                        Item { Layout.fillWidth: true }
                                        Text { text: bxW.value.toFixed(1) + " m"; font.pixelSize: 11; font.bold: true; color: colCyan }
                                    }
                                    Slider { id: bxW; Layout.fillWidth: true; from: 0.5; to: 30.0; value: 4.0; stepSize: 0.5 }
                                }
                                ColumnLayout {
                                    Layout.fillWidth: true; spacing: 2
                                    RowLayout {
                                        Text { text: "Depth (Y):"; font.pixelSize: 11; color: colTextPrimary }
                                        Item { Layout.fillWidth: true }
                                        Text { text: bxD.value.toFixed(1) + " m"; font.pixelSize: 11; font.bold: true; color: colCyan }
                                    }
                                    Slider { id: bxD; Layout.fillWidth: true; from: 0.5; to: 30.0; value: 4.0; stepSize: 0.5 }
                                }
                                ColumnLayout {
                                    Layout.fillWidth: true; spacing: 2
                                    RowLayout {
                                        Text { text: "Height (Z):"; font.pixelSize: 11; color: colTextPrimary }
                                        Item { Layout.fillWidth: true }
                                        Text { text: bxH.value.toFixed(1) + " m"; font.pixelSize: 11; font.bold: true; color: colCyan }
                                    }
                                    Slider { id: bxH; Layout.fillWidth: true; from: 0.5; to: 30.0; value: 3.0; stepSize: 0.5 }
                                }
                                Item { Layout.fillHeight: true }
                                Rectangle {
                                    Layout.fillWidth: true; height: 42; radius: 12
                                    gradient: Gradient {
                                        GradientStop { position: 0.0; color: colCyan }
                                        GradientStop { position: 1.0; color: "#0066FF" }
                                    }
                                    RowLayout {
                                        anchors.centerIn: parent; spacing: 8
                                        FAIcon { text: fa.cube; font.pixelSize: 12; color: "#FFFFFF" }
                                        Text { text: "CREATE BOX IN SKETCHUP"; font.pixelSize: 11; font.bold: true; color: "#FFFFFF" }
                                    }
                                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: backend.createBox(bxW.value, bxD.value, bxH.value) }
                                }
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true; Layout.fillHeight: true; radius: 16; color: colGlassCard; border.width: 1; border.color: colBorderSubtle
                            ColumnLayout {
                                anchors.fill: parent; anchors.margins: 20; spacing: 12
                                Text { text: "CYLINDER MASSING"; font.pixelSize: 13; font.bold: true; color: colViolet }
                                ColumnLayout {
                                    Layout.fillWidth: true; spacing: 2
                                    RowLayout {
                                        Text { text: "Radius:"; font.pixelSize: 11; color: colTextPrimary }
                                        Item { Layout.fillWidth: true }
                                        Text { text: cyR.value.toFixed(2) + " m"; font.pixelSize: 11; font.bold: true; color: colViolet }
                                    }
                                    Slider { id: cyR; Layout.fillWidth: true; from: 0.1; to: 10.0; value: 1.0; stepSize: 0.1 }
                                }
                                ColumnLayout {
                                    Layout.fillWidth: true; spacing: 2
                                    RowLayout {
                                        Text { text: "Height:"; font.pixelSize: 11; color: colTextPrimary }
                                        Item { Layout.fillWidth: true }
                                        Text { text: cyH.value.toFixed(1) + " m"; font.pixelSize: 11; font.bold: true; color: colViolet }
                                    }
                                    Slider { id: cyH; Layout.fillWidth: true; from: 0.5; to: 25.0; value: 3.5; stepSize: 0.5 }
                                }
                                Item { Layout.fillHeight: true }
                                Rectangle {
                                    Layout.fillWidth: true; height: 42; radius: 12
                                    gradient: Gradient {
                                        GradientStop { position: 0.0; color: colViolet }
                                        GradientStop { position: 1.0; color: "#4A00E0" }
                                    }
                                    RowLayout {
                                        anchors.centerIn: parent; spacing: 8
                                        FAIcon { text: fa.circle; font.pixelSize: 12; color: "#FFFFFF" }
                                        Text { text: "CREATE CYLINDER IN SKETCHUP"; font.pixelSize: 11; font.bold: true; color: "#FFFFFF" }
                                    }
                                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: backend.createCylinder(cyR.value, cyH.value, 24) }
                                }
                            }
                        }
                    }

                    // =========================================================
                    // VIEW 2: CAMERA VIEWPORT RIG
                    // =========================================================
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: 16; color: colGlassCard; border.width: 1; border.color: colBorderSubtle
                        ColumnLayout {
                            anchors.fill: parent; anchors.margins: 24; spacing: 16
                            Text { text: "VIEWPORT PRESETS"; font.pixelSize: 14; font.bold: true; color: colCyan }
                            Flow {
                                Layout.fillWidth: true; spacing: 14
                                Repeater {
                                    model: [
                                        { view: "iso", name: "Isometric 3D", icon: fa.cubes },
                                        { view: "top", name: "Top Plan", icon: fa.arrowUp },
                                        { view: "front", name: "Front Elevation", icon: fa.arrowRight },
                                        { view: "right", name: "Right Elevation", icon: fa.arrowRight }
                                    ]
                                    Rectangle {
                                        width: 170; height: 80; radius: 12; color: Qt.rgba(1, 1, 1, 0.05); border.width: 1; border.color: colBorderSubtle
                                        ColumnLayout {
                                            anchors.centerIn: parent; spacing: 6
                                            FAIcon { Layout.alignment: Qt.AlignHCenter; text: modelData.icon; font.pixelSize: 18; color: colCyan }
                                            Text { Layout.alignment: Qt.AlignHCenter; text: modelData.name; font.pixelSize: 11; font.bold: true; color: "#FFFFFF" }
                                        }
                                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: backend.setCamera(modelData.view) }
                                    }
                                }
                            }
                            Item { Layout.fillHeight: true }
                        }
                    }

                    // =========================================================
                    // VIEW 3: MODEL STATS & TELEMETRY
                    // =========================================================
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: 16; color: colGlassCard; border.width: 1; border.color: colBorderSubtle
                        ColumnLayout {
                            anchors.fill: parent; anchors.margins: 24; spacing: 16
                            Text { text: "MODEL TELEMETRY"; font.pixelSize: 14; font.bold: true; color: colEmerald }
                            Flow {
                                Layout.fillWidth: true; spacing: 12
                                Repeater {
                                    model: [
                                        { label: "Active Model", val: backend ? backend.modelName : "", icon: fa.house },
                                        { label: "Entities", val: backend ? backend.entitiesCount.toString() : "0", icon: fa.cubes },
                                        { label: "Faces", val: backend ? backend.facesCount.toString() : "0", icon: fa.polygon },
                                        { label: "Edges", val: backend ? backend.edgesCount.toString() : "0", icon: fa.ruler },
                                        { label: "Dimensions", val: backend ? backend.dimensions : "0×0×0m", icon: fa.rulerVertical },
                                        { label: "Units", val: backend ? backend.units : "Meters", icon: fa.ruler }
                                    ]
                                    Rectangle {
                                        width: 180; height: 70; radius: 10; color: Qt.rgba(1, 1, 1, 0.04); border.width: 1; border.color: colBorderSubtle
                                        ColumnLayout {
                                            anchors.centerIn: parent; spacing: 4
                                            Text { text: modelData.label; font.pixelSize: 10; color: colTextMuted }
                                            Text { text: modelData.val; font.pixelSize: 13; font.bold: true; color: colTextPrimary }
                                        }
                                    }
                                }
                            }
                            Item { Layout.fillHeight: true }
                            Rectangle {
                                Layout.fillWidth: true; height: 36; radius: 8; color: Qt.rgba(0.94, 0.27, 0.27, 0.15); border.width: 1; border.color: Qt.rgba(0.94, 0.27, 0.27, 0.4)
                                RowLayout {
                                    anchors.centerIn: parent; spacing: 6
                                    FAIcon { text: fa.trash; font.pixelSize: 10; color: "#EF4444" }
                                    Text { text: "Clear All Active Model Entities"; font.pixelSize: 10; font.bold: true; color: "#EF4444" }
                                }
                                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: backend.clearModel() }
                            }
                        }
                    }
                }
            }

            // -----------------------------------------------------------------
            // RIGHT SETTINGS INSPECTOR DRAWER WITH LIVE PREVIEW CANVAS
            // -----------------------------------------------------------------
            Rectangle {
                id: inspectorDrawer
                Layout.preferredWidth: (root.shapeDrawerOpen && root.selectedShape !== null) ? (root.shapeDrawerFullWidth ? parent.width : 400) : 0
                Layout.fillWidth: root.shapeDrawerFullWidth
                Layout.fillHeight: true
                visible: (root.shapeDrawerOpen && root.selectedShape !== null)
                color: "#090D18"
                border.width: 1
                border.color: colBorderLight
                clip: true

                Behavior on Layout.preferredWidth {
                    NumberAnimation { duration: 240; easing.type: Easing.OutCubic }
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 18
                    spacing: 12

                    // Drawer Header
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        Rectangle {
                            width: 38; height: 38; radius: 10
                            gradient: Gradient {
                                GradientStop { position: 0.0; color: colCyan }
                                GradientStop { position: 1.0; color: colViolet }
                            }
                            FAIcon {
                                anchors.centerIn: parent
                                text: root.selectedShape ? root.selectedShape.icon : fa.cube
                                font.pixelSize: 16
                                color: "#05070B"
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 1

                            RowLayout {
                                spacing: 6
                                Text {
                                    text: root.selectedShape ? root.selectedShape.name : "Parametric Shape"
                                    font.pixelSize: 13
                                    font.bold: true
                                    color: "#FFFFFF"
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }
                                Rectangle {
                                    height: 16
                                    implicitWidth: dCatTag.implicitWidth + 8
                                    radius: 8
                                    color: Qt.rgba(0, 0.95, 1, 0.15)
                                    border.width: 1
                                    border.color: colCyan
                                    Text {
                                        id: dCatTag
                                        anchors.centerIn: parent
                                        text: root.selectedShape ? root.selectedShape.category.toUpperCase() : ""
                                        font.pixelSize: 7
                                        font.bold: true
                                        color: colCyan
                                    }
                                }
                            }

                            Text {
                                text: root.selectedShape ? root.selectedShape.desc : ""
                                font.pixelSize: 9
                                color: colTextSecondary
                                wrapMode: Text.Wrap
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }
                        }

                        // Full-Width / Side Panel Mode Toggle Button
                        Rectangle {
                            height: 26
                            implicitWidth: fwTxt.implicitWidth + 18
                            radius: 13
                            color: root.shapeDrawerFullWidth ? Qt.rgba(0, 0.95, 1, 0.20) : (drwExpM.containsMouse ? Qt.rgba(1, 1, 1, 0.15) : Qt.rgba(1, 1, 1, 0.05))
                            border.width: 1
                            border.color: root.shapeDrawerFullWidth ? colCyan : colBorderSubtle

                            RowLayout {
                                anchors.centerIn: parent
                                spacing: 5
                                FAIcon {
                                    text: root.shapeDrawerFullWidth ? fa.boxes : fa.sliders
                                    font.pixelSize: 9
                                    color: root.shapeDrawerFullWidth ? colCyan : colTextSecondary
                                }
                                Text {
                                    id: fwTxt
                                    text: root.shapeDrawerFullWidth ? "Side Panel" : "Full Width"
                                    font.pixelSize: 9
                                    font.bold: true
                                    color: root.shapeDrawerFullWidth ? colCyan : colTextPrimary
                                }
                            }

                            MouseArea {
                                id: drwExpM
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.shapeDrawerFullWidth = !root.shapeDrawerFullWidth
                            }
                        }

                        // Close Drawer Button
                        Rectangle {
                            width: 28; height: 28; radius: 14
                            color: drwCloseM.containsMouse ? Qt.rgba(1, 1, 1, 0.15) : Qt.rgba(1, 1, 1, 0.05)
                            border.width: 1
                            border.color: colBorderSubtle

                            FAIcon { anchors.centerIn: parent; text: fa.xmark; font.pixelSize: 10; color: colTextPrimary }

                            MouseArea {
                                id: drwCloseM
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.closeDrawer()
                            }
                        }
                    }

                    // ---------------------------------------------------------
                    // LIVE 2.5D GEOMETRIC PREVIEW CANVAS (Prompt: "what about showing the live preview")
                    // ---------------------------------------------------------
                    Rectangle {
                        Layout.fillWidth: true
                        height: root.shapeDrawerFullWidth ? 200 : 135
                        radius: 12
                        color: Qt.rgba(0, 0, 0, 0.50)
                        border.width: 1
                        border.color: colBorderSubtle
                        clip: true

                        RowLayout {
                            anchors.top: parent.top
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.margins: 8
                            z: 2

                            Text {
                                text: "LIVE 2.5D PREVIEW"
                                font.pixelSize: 8
                                font.bold: true
                                font.letterSpacing: 0.8
                                color: colViolet
                            }

                            Item { Layout.fillWidth: true }

                            Text {
                                text: {
                                    if (!root.selectedShape) return ""
                                    var p = root.currentParamValues
                                    var w = p["width"] || p["length"] || p["size"] || p["base_size"] || p["base_w"] || p["span"] || p["radius"] || 1.0
                                    var d = p["depth"] || p["width"] || p["projection"] || p["top_w"] || 1.0
                                    var h = p["height"] || p["rise"] || p["thickness"] || (p["steps"] ? p["steps"] * 0.18 : 1.0) || 1.0
                                    return Number(w).toFixed(1) + " × " + Number(d).toFixed(1) + " × " + Number(h).toFixed(1) + "m"
                                }
                                font.pixelSize: 8
                                font.bold: true
                                color: colCyan
                            }
                        }

                        Canvas {
                            id: liveShapeCanvas
                            anchors.fill: parent
                            anchors.topMargin: 16

                            property var params: root.currentParamValues
                            property var shapeObj: root.selectedShape

                            onParamsChanged: requestPaint()
                            onShapeObjChanged: requestPaint()

                            onPaint: {
                                var ctx = getContext("2d")
                                ctx.clearRect(0, 0, width, height)
                                if (!shapeObj) return

                                var p = params || {}
                                var cat = shapeObj.category || "primitives"
                                var sid = shapeObj.id || ""

                                var cx = width / 2.0
                                var cy = height / 2.0 + 16

                                var wVal = Number(p["width"] || p["length"] || p["size"] || p["base_size"] || p["base_w"] || p["span"] || 2.5)
                                var dVal = Number(p["depth"] || p["projection"] || p["tread"] || p["radius"] || (wVal * 0.7) || 2.0)
                                var hVal = Number(p["height"] || p["rise"] || p["thickness"] || (p["steps"] ? p["steps"] * 0.18 : 2.5) || 2.5)

                                var maxDim = Math.max(wVal, dVal, hVal, 1.5)
                                var scale = Math.min((width * 0.45) / maxDim, (height * 0.55) / maxDim)

                                var sw = Math.max(12, wVal * scale * 0.866)
                                var sd = Math.max(10, dVal * scale * 0.866)
                                var sh = Math.max(14, hVal * scale * 1.0)

                                if (cat === "stairs" || sid.indexOf("stair") !== -1 || sid.indexOf("step") !== -1) {
                                    var nSteps = Math.min(14, Math.max(4, Math.round(Number(p["steps"] || 10))))
                                    var rStep = (sh * 0.85) / nSteps
                                    var tStep = (sw * 1.2) / nSteps
                                    var startX = cx - (sw * 0.6)
                                    var startY = cy + (sh * 0.4)
                                    var depthOffset = sd * 0.35

                                    ctx.beginPath()
                                    var curX = startX
                                    var curY = startY
                                    ctx.moveTo(curX, curY)
                                    for (var i = 0; i < nSteps; i++) {
                                        curY -= rStep
                                        ctx.lineTo(curX, curY)
                                        curX += tStep
                                        ctx.lineTo(curX, curY)
                                    }
                                    ctx.lineTo(curX, startY)
                                    ctx.closePath()
                                    ctx.fillStyle = "rgba(0, 245, 255, 0.12)"
                                    ctx.fill()
                                    ctx.strokeStyle = "#00F5FF"
                                    ctx.lineWidth = 1.8
                                    ctx.stroke()

                                    ctx.beginPath()
                                    curX = startX
                                    curY = startY
                                    for (var j = 0; j < nSteps; j++) {
                                        curY -= rStep
                                        ctx.moveTo(curX, curY)
                                        ctx.lineTo(curX + depthOffset, curY - (depthOffset * 0.4))
                                        curX += tStep
                                        ctx.lineTo(curX + depthOffset, curY - (depthOffset * 0.4))
                                        ctx.lineTo(curX, curY)
                                    }
                                    ctx.strokeStyle = "rgba(139, 92, 246, 0.8)"
                                    ctx.lineWidth = 1.2
                                    ctx.stroke()
                                } else if (cat === "columns" || sid.indexOf("col_") !== -1 || sid.indexOf("cyl") !== -1 || sid.indexOf("pipe") !== -1 || sid.indexOf("cone") !== -1) {
                                    var rPix = Math.max(14, (wVal / 2.0) * scale * 0.9)
                                    var topY = cy - (sh * 0.45)
                                    var botY = cy + (sh * 0.35)

                                    // Bottom ellipse
                                    ctx.save()
                                    ctx.translate(cx, botY)
                                    ctx.scale(1, 0.35)
                                    ctx.beginPath()
                                    ctx.arc(0, 0, rPix, 0, 2 * Math.PI)
                                    ctx.restore()
                                    ctx.fillStyle = "rgba(0, 245, 255, 0.12)"
                                    ctx.fill()
                                    ctx.strokeStyle = "#00F5FF"
                                    ctx.lineWidth = 1.5
                                    ctx.stroke()

                                    // Side profile lines
                                    ctx.beginPath()
                                    ctx.moveTo(cx - rPix, botY); ctx.lineTo(cx - rPix, topY)
                                    ctx.moveTo(cx + rPix, botY); ctx.lineTo(cx + rPix, topY)
                                    ctx.strokeStyle = "rgba(0, 245, 255, 0.7)"
                                    ctx.lineWidth = 1.5
                                    ctx.stroke()

                                    // Top ellipse
                                    ctx.save()
                                    ctx.translate(cx, topY)
                                    ctx.scale(1, 0.35)
                                    ctx.beginPath()
                                    ctx.arc(0, 0, rPix, 0, 2 * Math.PI)
                                    ctx.restore()
                                    ctx.fillStyle = "rgba(139, 92, 246, 0.25)"
                                    ctx.fill()
                                    ctx.strokeStyle = "#8B5CF6"
                                    ctx.lineWidth = 1.8
                                    ctx.stroke()
                                } else if (sid.indexOf("sphere") !== -1 || sid.indexOf("dome") !== -1 || sid.indexOf("globe") !== -1) {
                                    var rPix = Math.max(16, (wVal / 2.0) * scale * 1.1)

                                    ctx.beginPath()
                                    ctx.arc(cx, cy, rPix, 0, 2 * Math.PI)
                                    ctx.fillStyle = "rgba(0, 245, 255, 0.08)"
                                    ctx.fill()
                                    ctx.strokeStyle = "#00F5FF"
                                    ctx.lineWidth = 1.6
                                    ctx.stroke()

                                    ctx.save()
                                    ctx.translate(cx, cy)
                                    ctx.scale(1, 0.35)
                                    ctx.beginPath()
                                    ctx.arc(0, 0, rPix, 0, 2 * Math.PI)
                                    ctx.restore()
                                    ctx.strokeStyle = "rgba(139, 92, 246, 0.7)"
                                    ctx.lineWidth = 1.4
                                    ctx.stroke()

                                    ctx.save()
                                    ctx.translate(cx, cy)
                                    ctx.scale(0.35, 1)
                                    ctx.beginPath()
                                    ctx.arc(0, 0, rPix, 0, 2 * Math.PI)
                                    ctx.restore()
                                    ctx.strokeStyle = "rgba(139, 92, 246, 0.5)"
                                    ctx.lineWidth = 1.2
                                    ctx.stroke()
                                } else if (cat === "roofs" || sid.indexOf("roof") !== -1 || sid.indexOf("truss") !== -1 || sid.indexOf("gable") !== -1) {
                                    var halfW = sw * 0.85
                                    var apexY = cy - (sh * 0.5)
                                    var baseLeftX = cx - halfW
                                    var baseRightX = cx + halfW
                                    var baseFrontY = cy + (sh * 0.35)
                                    var ridgeDx = -sd * 0.45
                                    var ridgeDy = -sd * 0.25

                                    ctx.beginPath()
                                    ctx.moveTo(baseLeftX, baseFrontY)
                                    ctx.lineTo(cx, apexY)
                                    ctx.lineTo(baseRightX, baseFrontY)
                                    ctx.closePath()
                                    ctx.fillStyle = "rgba(0, 245, 255, 0.12)"
                                    ctx.fill()
                                    ctx.strokeStyle = "#00F5FF"
                                    ctx.lineWidth = 1.8
                                    ctx.stroke()

                                    ctx.beginPath()
                                    ctx.moveTo(cx, apexY)
                                    ctx.lineTo(cx + ridgeDx, apexY + ridgeDy)
                                    ctx.lineTo(baseRightX + ridgeDx, baseFrontY + ridgeDy)
                                    ctx.lineTo(baseRightX, baseFrontY)
                                    ctx.closePath()
                                    ctx.fillStyle = "rgba(139, 92, 246, 0.20)"
                                    ctx.fill()
                                    ctx.strokeStyle = "#8B5CF6"
                                    ctx.lineWidth = 1.5
                                    ctx.stroke()

                                    ctx.beginPath()
                                    ctx.moveTo(cx + ridgeDx, apexY + ridgeDy)
                                    ctx.lineTo(baseLeftX + ridgeDx, baseFrontY + ridgeDy)
                                    ctx.lineTo(baseLeftX, baseFrontY)
                                    ctx.strokeStyle = "rgba(139, 92, 246, 0.6)"
                                    ctx.lineWidth = 1.2
                                    ctx.stroke()
                                } else {
                                    // Universal 2.5D Isometric Prism
                                    var bx = cx
                                    var by = cy + (sh * 0.35)
                                    var rx = sw * 0.866
                                    var ry = sw * 0.4
                                    var lx = -sd * 0.866
                                    var ly = sd * 0.4

                                    ctx.beginPath()
                                    ctx.moveTo(bx, by - sh)
                                    ctx.lineTo(bx + rx, by - ry - sh)
                                    ctx.lineTo(bx + rx + lx, by - ry - ly - sh)
                                    ctx.lineTo(bx + lx, by - ly - sh)
                                    ctx.closePath()
                                    ctx.fillStyle = "rgba(139, 92, 246, 0.2)"
                                    ctx.fill()
                                    ctx.strokeStyle = "#8B5CF6"
                                    ctx.lineWidth = 1.8
                                    ctx.stroke()

                                    ctx.beginPath()
                                    ctx.moveTo(bx, by)
                                    ctx.lineTo(bx + rx, by - ry)
                                    ctx.lineTo(bx + rx, by - ry - sh)
                                    ctx.lineTo(bx, by - sh)
                                    ctx.closePath()
                                    ctx.fillStyle = "rgba(0, 245, 255, 0.12)"
                                    ctx.fill()
                                    ctx.strokeStyle = "#00F5FF"
                                    ctx.lineWidth = 1.5
                                    ctx.stroke()

                                    ctx.beginPath()
                                    ctx.moveTo(bx, by)
                                    ctx.lineTo(bx + lx, by - ly)
                                    ctx.lineTo(bx + lx, by - ly - sh)
                                    ctx.lineTo(bx, by - sh)
                                    ctx.closePath()
                                    ctx.fillStyle = "rgba(0, 245, 255, 0.06)"
                                    ctx.fill()
                                    ctx.strokeStyle = "rgba(0, 245, 255, 0.7)"
                                    ctx.lineWidth = 1.5
                                    ctx.stroke()
                                }
                            }
                        }
                    }

                    Rectangle { Layout.fillWidth: true; height: 1; color: colBorderSubtle }

                    // Scrollable Parameter Sliders List
                    ScrollView {
                        id: paramsScrollView
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        contentWidth: availableWidth

                        ColumnLayout {
                            width: paramsScrollView.availableWidth
                            spacing: 12

                            RowLayout {
                                Layout.fillWidth: true
                                Text {
                                    text: "PARAMETRIC SPECIFICATIONS"
                                    font.pixelSize: 9
                                    font.bold: true
                                    font.letterSpacing: 0.8
                                    color: colCyan
                                }
                                Item { Layout.fillWidth: true }
                                Text {
                                    text: "Live visual tuning"
                                    font.pixelSize: 9
                                    color: colTextMuted
                                }
                            }

                            Repeater {
                                model: root.selectedShape ? root.selectedShape.params : []

                                Rectangle {
                                    Layout.fillWidth: true
                                    width: paramsScrollView.availableWidth
                                    height: 60
                                    radius: 10
                                    color: Qt.rgba(1, 1, 1, 0.04)
                                    border.width: 1
                                    border.color: colBorderSubtle

                                    property real curVal: (root.currentParamValues[modelData.key] !== undefined) ? root.currentParamValues[modelData.key] : modelData.val

                                    ColumnLayout {
                                        anchors.fill: parent
                                        anchors.leftMargin: 10
                                        anchors.rightMargin: 10
                                        anchors.topMargin: 6
                                        anchors.bottomMargin: 6
                                        spacing: 2

                                        RowLayout {
                                            Layout.fillWidth: true
                                            Text {
                                                text: modelData.name
                                                font.pixelSize: 10
                                                font.bold: true
                                                color: colTextPrimary
                                            }
                                            Item { Layout.fillWidth: true }
                                            Text {
                                                text: (modelData.step >= 1 ? parent.parent.parent.curVal.toFixed(0) : parent.parent.parent.curVal.toFixed(2)) + " " + modelData.unit
                                                font.pixelSize: 10
                                                font.bold: true
                                                color: colCyan
                                            }
                                        }

                                        RowLayout {
                                            Layout.fillWidth: true
                                            spacing: 6

                                            // Stepper -
                                            Rectangle {
                                                width: 22; height: 22; radius: 5
                                                color: stepMinM.containsMouse ? Qt.rgba(1, 1, 1, 0.18) : Qt.rgba(1, 1, 1, 0.08)
                                                border.width: 1; border.color: colBorderSubtle
                                                FAIcon { anchors.centerIn: parent; text: fa.minus; font.pixelSize: 8; color: colTextPrimary }
                                                MouseArea {
                                                    id: stepMinM
                                                    anchors.fill: parent
                                                    hoverEnabled: true
                                                    cursorShape: Qt.PointingHandCursor
                                                    onClicked: {
                                                        var nv = Math.max(modelData.min, parent.parent.parent.parent.curVal - modelData.step)
                                                        root.updateShapeParam(modelData.key, nv)
                                                        liveShapeCanvas.requestPaint()
                                                    }
                                                }
                                            }

                                            Slider {
                                                id: paramSlider
                                                Layout.fillWidth: true
                                                from: modelData.min
                                                to: modelData.max
                                                stepSize: modelData.step
                                                value: parent.parent.parent.curVal
                                                onMoved: {
                                                    root.updateShapeParam(modelData.key, value)
                                                    liveShapeCanvas.requestPaint()
                                                }
                                            }

                                            // Stepper +
                                            Rectangle {
                                                width: 22; height: 22; radius: 5
                                                color: stepPluM.containsMouse ? Qt.rgba(1, 1, 1, 0.18) : Qt.rgba(1, 1, 1, 0.08)
                                                border.width: 1; border.color: colBorderSubtle
                                                FAIcon { anchors.centerIn: parent; text: fa.plus; font.pixelSize: 8; color: colTextPrimary }
                                                MouseArea {
                                                    id: stepPluM
                                                    anchors.fill: parent
                                                    hoverEnabled: true
                                                    cursorShape: Qt.PointingHandCursor
                                                    onClicked: {
                                                        var nv = Math.min(modelData.max, parent.parent.parent.parent.curVal + modelData.step)
                                                        root.updateShapeParam(modelData.key, nv)
                                                        liveShapeCanvas.requestPaint()
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }

                            // Reset Defaults Button
                            Rectangle {
                                Layout.alignment: Qt.AlignRight
                                height: 22
                                implicitWidth: rstTxt.implicitWidth + 14
                                radius: 11
                                color: rstM.containsMouse ? Qt.rgba(1, 1, 1, 0.12) : "transparent"
                                border.width: 1
                                border.color: colBorderSubtle

                                RowLayout {
                                    anchors.centerIn: parent
                                    spacing: 5
                                    FAIcon { text: fa.sync; font.pixelSize: 8; color: colTextSecondary }
                                    Text {
                                        id: rstTxt
                                        text: "Reset Defaults"
                                        font.pixelSize: 9
                                        color: colTextSecondary
                                    }
                                }

                                MouseArea {
                                    id: rstM
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (root.selectedShape) {
                                            var vals = {}
                                            for (var i = 0; i < root.selectedShape.params.length; i++) {
                                                var p = root.selectedShape.params[i]
                                                vals[p.key] = p.val
                                            }
                                            root.currentParamValues = vals
                                            liveShapeCanvas.requestPaint()
                                        }
                                    }
                                }
                            }
                        }
                    }

                    Rectangle { Layout.fillWidth: true; height: 1; color: colBorderSubtle }

                    // Drawer Action Button (Bottom Fixed)
                    Rectangle {
                        Layout.fillWidth: true
                        height: 42
                        radius: 12
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: mBuildM.containsMouse ? "#2DFEFF" : colCyan }
                            GradientStop { position: 1.0; color: "#5E17EB" }
                        }

                        RowLayout {
                            anchors.centerIn: parent
                            spacing: 8
                            FAIcon { text: fa.bolt; font.pixelSize: 12; color: "#FFFFFF" }
                            Text {
                                text: "BUILD IN SKETCHUP 2026"
                                font.pixelSize: 11
                                font.bold: true
                                font.letterSpacing: 0.8
                                color: "#FFFFFF"
                            }
                        }

                        MouseArea {
                            id: mBuildM
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.buildSelectedShape()
                        }
                    }
                }
            }
        }
    }

    // =========================================================================
    // EXPORT PIPELINE MODAL (Triggered by Icon-Only Export Button in Top Bar)
    // =========================================================================
    Rectangle {
        id: exportModalOverlay
        anchors.fill: parent
        z: 9999
        visible: root.exportModalOpen
        opacity: visible ? 1.0 : 0.0
        color: Qt.rgba(0.02, 0.04, 0.08, 0.82)
        Behavior on opacity { NumberAnimation { duration: 160 } }
        MouseArea { anchors.fill: parent; onClicked: root.exportModalOpen = false }

        Rectangle {
            anchors.centerIn: parent
            width: 480
            height: 320
            radius: 20
            color: "#0A0F1D"
            border.width: 1
            border.color: colViolet
            clip: true
            MouseArea { anchors.fill: parent; onClicked: {} }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 22
                spacing: 14

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10
                    Rectangle {
                        width: 36; height: 36; radius: 10
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: colViolet }
                            GradientStop { position: 1.0; color: "#4A00E0" }
                        }
                        FAIcon { anchors.centerIn: parent; text: fa.fileExport; font.pixelSize: 14; color: "#FFFFFF" }
                    }
                    ColumnLayout {
                        spacing: 1
                        Text { text: "EXPORT MODEL PIPELINE"; font.pixelSize: 13; font.bold: true; color: "#FFFFFF" }
                        Text { text: "Direct 3D export from active SketchUp 2026 session"; font.pixelSize: 10; color: colTextSecondary }
                    }
                    Item { Layout.fillWidth: true }
                    Rectangle {
                        width: 28; height: 28; radius: 14
                        color: expCloseM.containsMouse ? Qt.rgba(1, 1, 1, 0.15) : Qt.rgba(1, 1, 1, 0.05)
                        FAIcon { anchors.centerIn: parent; text: fa.xmark; font.pixelSize: 10; color: colTextPrimary }
                        MouseArea { id: expCloseM; anchors.fill: parent; onClicked: root.exportModalOpen = false }
                    }
                }

                Rectangle { Layout.fillWidth: true; height: 1; color: colBorderSubtle }

                Flow {
                    Layout.fillWidth: true
                    spacing: 10

                    Repeater {
                        model: [
                            { fmt: "obj", name: "Wavefront OBJ", desc: "Meshes + MTL textures", icon: fa.fileExport },
                            { fmt: "dae", name: "COLLADA DAE", desc: "Digital Asset Exchange", icon: fa.fileExport },
                            { fmt: "stl", name: "Stereolithography STL", desc: "3D Slicer / Printing", icon: fa.fileExport },
                            { fmt: "skp", name: "SketchUp SKP", desc: "Native model archive", icon: fa.floppy }
                        ]

                        Rectangle {
                            width: 210
                            height: 70
                            radius: 12
                            color: expCardM.containsMouse ? Qt.rgba(139, 92, 246, 0.25) : Qt.rgba(1, 1, 1, 0.04)
                            border.width: 1
                            border.color: expCardM.containsMouse ? colViolet : colBorderSubtle

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 10
                                spacing: 10

                                FAIcon { text: modelData.icon; font.pixelSize: 16; color: colViolet }
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 2
                                    Text { text: modelData.name; font.pixelSize: 11; font.bold: true; color: "#FFFFFF" }
                                    Text { text: modelData.desc; font.pixelSize: 9; color: colTextSecondary }
                                }
                            }

                            MouseArea {
                                id: expCardM
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    backend.exportModel(modelData.fmt, "")
                                    root.exportModalOpen = false
                                }
                            }
                        }
                    }
                }

                Item { Layout.fillHeight: true }
            }
        }
    }

    // =========================================================
    // SLIDE-OVER DRAWER: HOW IT WORKS & CREDITS
    // =========================================================
    Rectangle {
        id: infoDrawerBackdrop
        anchors.fill: parent
        z: 900
        visible: infoDrawerOpen
        opacity: infoDrawerOpen ? 1.0 : 0.0
        color: Qt.rgba(0, 0, 0, 0.65)
        Behavior on opacity { NumberAnimation { duration: 180 } }
        MouseArea { anchors.fill: parent; onClicked: infoDrawerOpen = false }
    }

    Rectangle {
        id: infoDrawerPanel
        z: 950
        width: Math.min(460, root.width - 40)
        height: root.height
        x: infoDrawerOpen ? root.width - width : root.width
        color: "#080C16"
        border.width: 1
        border.color: colBorderActive
        Behavior on x { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 24
            spacing: 14

            RowLayout {
                Layout.fillWidth: true
                spacing: 10
                Rectangle {
                    width: 32; height: 32; radius: 8
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: colCyan }
                        GradientStop { position: 1.0; color: colViolet }
                    }
                    FAIcon { anchors.centerIn: parent; text: fa.info; font.pixelSize: 14; color: "#05070B" }
                }
                ColumnLayout {
                    spacing: 1
                    Text { text: "HOW IT WORKS & CREDITS"; font.pixelSize: 13; font.bold: true; color: colTextPrimary }
                    Text { text: "Direct SketchUp 2026 procedural engine"; font.pixelSize: 10; color: colTextSecondary }
                }
                Item { Layout.fillWidth: true }
                Rectangle {
                    width: 28; height: 28; radius: 14
                    color: idCloseM.containsMouse ? Qt.rgba(1, 1, 1, 0.15) : Qt.rgba(1, 1, 1, 0.05)
                    FAIcon { anchors.centerIn: parent; text: fa.xmark; font.pixelSize: 10; color: colTextPrimary }
                    MouseArea { id: idCloseM; anchors.fill: parent; onClicked: infoDrawerOpen = false }
                }
            }

            Rectangle { Layout.fillWidth: true; height: 1; color: colBorderSubtle }

            ScrollView {
                Layout.fillWidth: true; Layout.fillHeight: true; clip: true
                ColumnLayout {
                    width: parent.width; spacing: 12
                    Text { text: "1. 150 Parametric Shapes Library"; font.pixelSize: 11; font.bold: true; color: colCyan }
                    Text { text: "Catalog of 150 procedural shapes across Architecture, Stairs, Columns, Steel, Roofs, Primitives, Furniture, and Landscape. Every shape has dedicated visual sliders and a live 2.5D preview."; font.pixelSize: 10; color: colTextSecondary; wrapMode: Text.Wrap; Layout.fillWidth: true }

                    Text { text: "2. Zero-Ruby Assumption"; font.pixelSize: 11; font.bold: true; color: colViolet }
                    Text { text: "No coding or Ruby knowledge is required. You adjust intuitive sliders and steppers, and the internal SketchUp API bridge automatically generates valid 3D geometry wrapped in an undo operation."; font.pixelSize: 10; color: colTextSecondary; wrapMode: Text.Wrap; Layout.fillWidth: true }

                    Text { text: "3. 1-Click Auto Setup"; font.pixelSize: 11; font.bold: true; color: colEmerald }
                    Text { text: "Auto-detects your SketchUp Plugins folder (macOS & Windows) and installs the connector plugin with one click."; font.pixelSize: 10; color: colTextSecondary; wrapMode: Text.Wrap; Layout.fillWidth: true }
                }
            }

            Rectangle {
                Layout.fillWidth: true; height: 36; radius: 8
                gradient: Gradient {
                    GradientStop { position: 0.0; color: colCyan }
                    GradientStop { position: 1.0; color: colViolet }
                }
                Text { anchors.centerIn: parent; text: "Close Guide"; font.pixelSize: 11; font.bold: true; color: "#05070B" }
                MouseArea { anchors.fill: parent; onClicked: infoDrawerOpen = false }
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
        anchors.bottomMargin: toastVisible ? 20 : -50
        width: Math.min(toastRow.implicitWidth + 30, root.width - 40)
        height: 34
        radius: 17
        z: 99
        color: toastSuccess ? Qt.rgba(0.06, 0.72, 0.50, 0.95) : Qt.rgba(0.94, 0.27, 0.27, 0.95)
        Behavior on anchors.bottomMargin { NumberAnimation { duration: 220; easing.type: Easing.OutBack } }

        RowLayout {
            id: toastRow
            anchors.centerIn: parent
            spacing: 6
            FAIcon { text: toastSuccess ? fa.check : fa.warning; font.pixelSize: 11; color: "#FFFFFF" }
            Text { text: toastText; font.pixelSize: 10; font.bold: true; color: "#FFFFFF" }
        }
    }
}
