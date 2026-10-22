import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

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

    // 3D Model Components & Assets State (Loaded dynamically from /models/<category>/**)
    property var modelAssets: []
    property var assetCategories: []
    property var selectedAsset: null
    property string activeCategory: "all"
    property string searchQuery: ""
    property var selectedShape: null
    property var currentParamValues: ({})
    property bool modelModalOpen: false

    Component.onCompleted: {
        loadAssets()
    }

    function loadAssets() {
        try {
            var raw = backend.getLibraryAssets()
            modelAssets = JSON.parse(raw)
        } catch(e) {
            modelAssets = []
        }
        try {
            var rawCats = backend.getLibraryCategories()
            var parsed = JSON.parse(rawCats)
            if (parsed && parsed.length > 0) {
                assetCategories = parsed
            } else {
                assetCategories = [{ "id": "all", "name": "All 3D Models", "count": modelAssets.length, "iconKey": "cubes" }]
            }
        } catch(e) {
            assetCategories = [{ "id": "all", "name": "All 3D Models", "count": modelAssets.length, "iconKey": "cubes" }]
        }
        // Verify activeCategory exists in newly loaded categories
        var validCat = false
        for (var i = 0; i < assetCategories.length; i++) {
            if (assetCategories[i].id === activeCategory) {
                validCat = true
                break
            }
        }
        if (!validCat) {
            activeCategory = "all"
        }
    }

    // Build a valid, platform-independent file:// URL for QML Image sources.
    // On Windows a raw path ("D:\\models\\x.png") must become "file:///D:/models/x.png".
    function assetThumbUrl(asset) {
        if (!asset) return ""
        if (asset.thumbnail_url) return asset.thumbnail_url
        var p = asset.thumbnail || ""
        if (!p) return ""
        p = String(p).replace(/\\/g, "/")
        if (/^[A-Za-z]:\//.test(p)) return "file:///" + p
        if (p.charAt(0) === "/") return "file://" + p
        return "file:///" + p
    }

    function getFilteredAssets(cat, query) {
        var res = []
        var q = (query || "").toLowerCase().trim()
        for (var i = 0; i < modelAssets.length; i++) {
            var item = modelAssets[i]
            var matchCat = (cat === "all") || (item.category === cat)
            var matchQuery = (q === "") || 
                             (item.name && item.name.toLowerCase().indexOf(q) !== -1) || 
                             (item.filename && item.filename.toLowerCase().indexOf(q) !== -1) || 
                             (item.ext && item.ext.toLowerCase().indexOf(q) !== -1) ||
                             (item.category_name && item.category_name.toLowerCase().indexOf(q) !== -1)
            if (matchCat && matchQuery) {
                res.push(item)
            }
        }
        return res
    }

    function selectAsset(asset) {
        if (!asset) return
        selectedAsset = asset
        selectedShape = asset
        var vals = {
            "scale": 1.0,
            "rot_z": 0.0,
            "pos_x": 0.0,
            "pos_y": 0.0,
            "pos_z": 0.0,
            "name": asset.name || asset.filename || "Model",
            "layer": "Untagged"
        }
        if (asset.params) {
            for (var i = 0; i < asset.params.length; i++) {
                var p = asset.params[i]
                vals[p.key] = p.val
            }
        }
        currentParamValues = vals
        modelModalOpen = true
    }

    function selectShape(shape) {
        selectAsset(shape)
    }

    function selectShapeById(shapeId) {
        for (var i = 0; i < modelAssets.length; i++) {
            if (modelAssets[i].id === shapeId) {
                selectAsset(modelAssets[i])
                return
            }
        }
    }

    function updateShapeParam(key, value) {
        var copy = {}
        for (var k in currentParamValues) {
            copy[k] = currentParamValues[k]
        }
        copy[key] = value
        currentParamValues = copy
    }

    function insertSelectedModel() {
        if (!selectedAsset) return
        if (selectedAsset.has_model === false || !selectedAsset.path) {
            toastText = "Preview only — no 3D model file found in this folder"
            toastSuccess = false
            toastVisible = true
            toastTimer.restart()
            return
        }
        backend.insertModel(selectedAsset.path, JSON.stringify(currentParamValues))
        modelModalOpen = false
    }

    function buildSelectedShape() {
        insertSelectedModel()
    }

    function closeModelModal() {
        modelModalOpen = false
    }

    function closeDrawer() {
        modelModalOpen = false
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
        function onLibraryReloaded() {
            loadAssets()
        }
        function onAssetImported(jsonStr) {
            try {
                var asset = JSON.parse(jsonStr)
                if (asset && asset.id) {
                    var list = [asset]
                    for (var i = 0; i < modelAssets.length; i++) {
                        if (modelAssets[i].id !== asset.id) {
                            list.push(modelAssets[i])
                        }
                    }
                    modelAssets = list
                    selectAsset(asset)
                    root.activeCategory = "all"
                }
            } catch(e) {
                console.log("Error parsing imported asset:", e)
            }
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
        readonly property string arrowDown: "\uf063"
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
                                { id: 0, label: "3D Models", icon: fa.cubes },
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
                                text: "Search 3D models & components..."
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

                // Import 3D File Button (.skp, .obj, .dae, .stl, etc.)
                Rectangle {
                    height: 32
                    implicitWidth: importTopBtnRow.implicitWidth + 20
                    radius: 16
                    color: importTopBtnM.containsMouse ? Qt.rgba(139, 92, 246, 0.28) : Qt.rgba(139, 92, 246, 0.14)
                    border.width: 1
                    border.color: importTopBtnM.containsMouse ? colViolet : Qt.rgba(139, 92, 246, 0.40)

                    RowLayout {
                        id: importTopBtnRow
                        anchors.centerIn: parent
                        spacing: 6
                        FAIcon { text: fa.folder; font.pixelSize: 11; color: colViolet }
                        Text {
                            text: "Import 3D"
                            font.pixelSize: 10
                            font.bold: true
                            color: "#FFFFFF"
                        }
                    }

                    MouseArea {
                        id: importTopBtnM
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: backend.browse3DFile()
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
                    id: statusPill
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

                // Retry / Reconnect Bridge Button (icon-only, shown when offline)
                Rectangle {
                    id: retryBridgeBtn
                    width: 32; height: 32; radius: 16
                    visible: !(backend ? backend.connected : true)
                    color: retryBridgeM.containsMouse ? Qt.rgba(0.96, 0.62, 0.04, 0.20) : Qt.rgba(1, 1, 1, 0.05)
                    border.width: 1
                    border.color: retryBridgeM.containsMouse ? colAmber : colBorderSubtle

                    FAIcon {
                        anchors.centerIn: parent
                        text: fa.sync
                        font.pixelSize: 12
                        color: retryBridgeM.containsMouse ? colAmber : colTextSecondary
                        RotationAnimation on rotation {
                            running: retryBridgeM.pressed
                            loops: Animation.Infinite
                            from: 0; to: 360; duration: 600
                        }
                    }

                    MouseArea {
                        id: retryBridgeM
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (backend) backend.poll_status_async()
                        }
                    }

                    ToolTip.visible: retryBridgeM.containsMouse
                    ToolTip.text: "Retry connecting to SketchUp Bridge"
                    ToolTip.delay: 500
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
                            model: root.assetCategories

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
                                        text: (modelData.iconKey && fa[modelData.iconKey] !== undefined) ? fa[modelData.iconKey] : (modelData.icon || fa.folder)
                                        font.pixelSize: 10
                                        color: parent.parent.isSel ? colCyan : colTextSecondary
                                    }
                                    Text {
                                        text: modelData.name + (modelData.count !== undefined && modelData.id !== "all" ? (" (" + modelData.count + ")") : "")
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
                    text: modelCardsRepeater.count + " models"
                    font.pixelSize: 10
                    color: colTextMuted
                }

                // Import 3D File Button in Ribbon
                Rectangle {
                    height: 26
                    implicitWidth: ribImpRow.implicitWidth + 16
                    radius: 13
                    color: ribImpM.containsMouse ? Qt.rgba(139, 92, 246, 0.3) : Qt.rgba(139, 92, 246, 0.15)
                    border.width: 1
                    border.color: colViolet

                    RowLayout {
                        id: ribImpRow
                        anchors.centerIn: parent
                        spacing: 5
                        FAIcon { text: fa.plus; font.pixelSize: 9; color: colViolet }
                        Text { text: "Import File"; font.pixelSize: 10; font.bold: true; color: "#FFFFFF" }
                    }

                    MouseArea {
                        id: ribImpM
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: backend.browse3DFile()
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
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true

                DropArea {
                    id: stageDropArea
                    anchors.fill: parent
                    onEntered: function(drag) {
                        if (drag.hasUrls) drag.acceptProposedAction()
                    }
                    onDropped: function(drop) {
                        if (drop.hasUrls) {
                            for (var i = 0; i < drop.urls.length; i++) {
                                var u = drop.urls[i].toString()
                                var localPath = u.replace(/^file:\/\//, "")
                                backend.importFileFromPath(decodeURIComponent(localPath))
                            }
                            drop.acceptProposedAction()
                        }
                    }
                }

                Rectangle {
                    anchors.fill: parent
                    anchors.margins: 14
                    z: 999
                    visible: stageDropArea.containsDrag
                    color: Qt.rgba(0.04, 0.08, 0.16, 0.92)
                    border.width: 2
                    border.color: colCyan
                    radius: 16

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 12
                        Rectangle {
                            Layout.alignment: Qt.AlignHCenter
                            width: 60; height: 60; radius: 30
                            color: Qt.rgba(0, 0.95, 1, 0.15)
                            border.width: 1.5; border.color: colCyan
                            FAIcon { anchors.centerIn: parent; text: fa.plus; font.pixelSize: 22; color: colCyan }
                        }
                        Text { text: "Drop 3D Model to Import"; font.pixelSize: 16; font.bold: true; color: "#FFFFFF"; Layout.alignment: Qt.AlignHCenter }
                        Text { text: "Supports .SKP, .OBJ, .DAE, .STL, .3DS, .DWG, .DXF, .IFC"; font.pixelSize: 11; color: colTextSecondary; Layout.alignment: Qt.AlignHCenter }
                    }
                }

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
                                    id: modelCardsRepeater
                                    model: root.getFilteredAssets(root.activeCategory, root.searchQuery)

                                    Rectangle {
                                        property bool isAct: root.selectedAsset && root.selectedAsset.id === modelData.id
                                        width: Math.max(220, Math.floor((shapesFlow.width - (3 * 14)) / 4))
                                        height: 210
                                        radius: 14
                                        color: isAct ? Qt.rgba(0, 0.95, 1, 0.12) : (cardMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.07) : colGlassCard)
                                        border.width: isAct ? 1.5 : 1
                                        border.color: isAct ? colCyan : (cardMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.25) : colBorderSubtle)
                                        clip: true

                                        Behavior on border.color { ColorAnimation { duration: 120 } }
                                        Behavior on color { ColorAnimation { duration: 120 } }

                                        ColumnLayout {
                                            anchors.fill: parent
                                            spacing: 0

                                            // Full-width thumbnail banner
                                            Item {
                                                Layout.fillWidth: true
                                                Layout.preferredHeight: 120
                                                clip: true

                                                Rectangle {
                                                    anchors.fill: parent
                                                    color: Qt.rgba(0.04, 0.06, 0.12, 1)
                                                }

                                                Image {
                                                    id: cardThumbImg
                                                    anchors.fill: parent
                                                    source: root.assetThumbUrl(modelData)
                                                    fillMode: Image.PreserveAspectCrop
                                                    smooth: true
                                                    visible: root.assetThumbUrl(modelData) !== "" && status === Image.Ready
                                                }

                                                FAIcon {
                                                    anchors.centerIn: parent
                                                    visible: root.assetThumbUrl(modelData) === "" || cardThumbImg.status !== Image.Ready
                                                    text: modelData.ext === "SKP" ? fa.cube : fa.folder
                                                    font.pixelSize: 32
                                                    color: isAct ? colCyan : Qt.rgba(1, 1, 1, 0.18)
                                                }

                                                // Extension pill overlay top-right
                                                Rectangle {
                                                    anchors.top: parent.top
                                                    anchors.right: parent.right
                                                    anchors.margins: 8
                                                    height: 18
                                                    implicitWidth: extTag.implicitWidth + 12
                                                    radius: 9
                                                    color: modelData.ext === "SKP" ? Qt.rgba(0, 0.95, 1, 0.16) : Qt.rgba(139, 92, 246, 0.20)
                                                    border.width: 1
                                                    border.color: modelData.ext === "SKP" ? colCyan : colViolet
                                                    Text {
                                                        id: extTag
                                                        anchors.centerIn: parent
                                                        text: (modelData.ext || "SKP").toUpperCase()
                                                        font.pixelSize: 8
                                                        font.bold: true
                                                        color: modelData.ext === "SKP" ? colCyan : colViolet
                                                    }
                                                }

                                                // Bottom gradient fade into card body
                                                Rectangle {
                                                    anchors.bottom: parent.bottom
                                                    anchors.left: parent.left
                                                    anchors.right: parent.right
                                                    height: 28
                                                    gradient: Gradient {
                                                        orientation: Gradient.Vertical
                                                        GradientStop { position: 0.0; color: "transparent" }
                                                        GradientStop { position: 1.0; color: isAct ? Qt.rgba(0, 0.05, 0.10, 0.90) : Qt.rgba(0.07, 0.11, 0.19, 0.90) }
                                                    }
                                                }
                                            }

                                            // Card info body
                                            ColumnLayout {
                                                Layout.fillWidth: true
                                                Layout.fillHeight: true
                                                Layout.leftMargin: 12
                                                Layout.rightMargin: 12
                                                Layout.topMargin: 8
                                                Layout.bottomMargin: 10
                                                spacing: 3

                                                Text {
                                                    text: modelData.name
                                                    font.pixelSize: 12
                                                    font.bold: true
                                                    color: isAct ? colCyan : "#FFFFFF"
                                                    elide: Text.ElideRight
                                                    Layout.fillWidth: true
                                                }

                                                Text {
                                                    text: (modelData.category_name ? modelData.category_name.toUpperCase() : (modelData.category ? modelData.category.toUpperCase() : "3D")) + " \u2022 " + (modelData.has_model === false ? "NO 3D FILE" : (modelData.size || ""))
                                                    font.pixelSize: 9
                                                    color: modelData.has_model === false ? colAmber : colTextSecondary
                                                    elide: Text.ElideRight
                                                    Layout.fillWidth: true
                                                }

                                                Item { Layout.fillHeight: true }

                                                RowLayout {
                                                    Layout.fillWidth: true
                                                    Text {
                                                        text: modelData.has_model === false ? "Preview only" : "Customizable"
                                                        font.pixelSize: 8
                                                        color: colTextMuted
                                                    }
                                                    Item { Layout.fillWidth: true }
                                                    Text {
                                                        text: modelData.has_model === false ? "View preview \u2192" : (isAct ? "Tuning in Studio \u2192" : "Tune & Insert \u2192")
                                                        font.pixelSize: 9
                                                        font.bold: true
                                                        color: modelData.has_model === false ? colAmber : (isAct ? colCyan : (cardMouse.containsMouse ? colTextPrimary : colViolet))
                                                    }
                                                }
                                            }
                                        }

                                        MouseArea {
                                            id: cardMouse
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: root.selectAsset(modelData)
                                        }
                                    }
                                }
                            }

                            // Empty State when no models match category or search
                            Rectangle {
                                anchors.centerIn: parent
                                width: Math.min(520, parent.width - 40)
                                height: 230
                                radius: 18
                                color: colGlassCard
                                border.width: 1
                                border.color: colBorderSubtle
                                visible: modelCardsRepeater.count === 0

                                ColumnLayout {
                                    anchors.centerIn: parent
                                    spacing: 12

                                    Rectangle {
                                        Layout.alignment: Qt.AlignHCenter
                                        width: 54; height: 54; radius: 27
                                        color: Qt.rgba(0, 0.95, 1, 0.12)
                                        border.width: 1; border.color: colCyan
                                        FAIcon {
                                            anchors.centerIn: parent
                                            text: fa.folder
                                            font.pixelSize: 22
                                            color: colCyan
                                        }
                                    }

                                    Text {
                                        Layout.alignment: Qt.AlignHCenter
                                        text: root.activeCategory === "all" ? "No 3D model files in /models/" : ("No 3D files in category: " + root.activeCategory.toUpperCase())
                                        font.pixelSize: 15
                                        font.bold: true
                                        color: "#FFFFFF"
                                    }

                                    Text {
                                        Layout.alignment: Qt.AlignHCenter
                                        text: "Add .skp files anywhere under /models/ — e.g. /models/<category>/<model>/model/file.skp. The library refreshes automatically."
                                        font.pixelSize: 11
                                        color: colTextSecondary
                                    }

                                    RowLayout {
                                        Layout.alignment: Qt.AlignHCenter
                                        spacing: 10

                                        Rectangle {
                                            height: 32
                                            implicitWidth: empOpenTxt.implicitWidth + 24
                                            radius: 16
                                            color: empOpenM.containsMouse ? Qt.rgba(0, 0.95, 1, 0.25) : Qt.rgba(0, 0.95, 1, 0.15)
                                            border.width: 1; border.color: colCyan
                                            Text {
                                                id: empOpenTxt
                                                anchors.centerIn: parent
                                                text: "Open /models/ Folder"
                                                font.pixelSize: 11; font.bold: true; color: colCyan
                                            }
                                            MouseArea {
                                                id: empOpenM
                                                anchors.fill: parent
                                                hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                                onClicked: backend.openModelsFolder()
                                            }
                                        }

                                        Rectangle {
                                            height: 32
                                            implicitWidth: empScanTxt.implicitWidth + 24
                                            radius: 16
                                            color: empScanM.containsMouse ? Qt.rgba(255, 255, 255, 0.15) : Qt.rgba(255, 255, 255, 0.08)
                                            border.width: 1; border.color: colBorderSubtle
                                            Text {
                                                id: empScanTxt
                                                anchors.centerIn: parent
                                                text: "Scan /models/"
                                                font.pixelSize: 11; font.bold: true; color: colTextPrimary
                                            }
                                            MouseArea {
                                                id: empScanM
                                                anchors.fill: parent
                                                hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                                onClicked: {
                                                    backend.refreshLibrary()
                                                    root.loadAssets()
                                                }
                                            }
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
    // 3D MODEL SPECIFICATION & LIVE PREVIEW MODAL DIALOG
    // =========================================================================
    Rectangle {
        id: modelModalOverlay
        anchors.fill: parent
        z: 9998
        visible: root.modelModalOpen && root.selectedAsset !== null
        opacity: visible ? 1.0 : 0.0
        color: Qt.rgba(0.02, 0.04, 0.08, 0.86)
        Behavior on opacity { NumberAnimation { duration: 160 } }

        MouseArea {
            anchors.fill: parent
            onClicked: root.closeModelModal()
        }

        Rectangle {
            id: modalContainer
            anchors.centerIn: parent
            width: Math.min(1080, root.width - 48)
            height: Math.min(680, root.height - 48)
            radius: 20
            color: "#090D18"
            border.width: 1
            border.color: colCyan
            clip: true

            MouseArea {
                anchors.fill: parent
                onClicked: {}
            }

            property int modalPreviewTab: 0 // 0: Rendered Image, 1: 3D Orientation Gimbal

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 12

                // -------------------------------------------------------------
                // 1. MODAL HEADER
                // -------------------------------------------------------------
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12

                    Rectangle {
                        width: 44; height: 44; radius: 10
                        color: Qt.rgba(0, 0, 0, 0.50)
                        border.width: 1; border.color: colCyan
                        clip: true

                        Image {
                            anchors.fill: parent
                            anchors.margins: 2
                            source: root.assetThumbUrl(root.selectedAsset)
                            fillMode: Image.PreserveAspectFit
                            visible: root.assetThumbUrl(root.selectedAsset) !== "" && status === Image.Ready
                        }
                        FAIcon {
                            anchors.centerIn: parent
                            visible: root.assetThumbUrl(root.selectedAsset) === ""
                            text: (root.selectedAsset && root.selectedAsset.ext === "SKP") ? fa.cube : fa.folder
                            font.pixelSize: 18
                            color: colCyan
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        RowLayout {
                            spacing: 8
                            Text {
                                text: root.selectedAsset ? root.selectedAsset.name : "3D Model Specification"
                                font.pixelSize: 15
                                font.bold: true
                                color: "#FFFFFF"
                                elide: Text.ElideRight
                            }
                            Rectangle {
                                height: 18
                                implicitWidth: mExtTag.implicitWidth + 10
                                radius: 9
                                color: Qt.rgba(0, 0.95, 1, 0.18)
                                border.width: 1; border.color: colCyan
                                Text {
                                    id: mExtTag
                                    anchors.centerIn: parent
                                    text: root.selectedAsset ? (root.selectedAsset.ext || "SKP").toUpperCase() : "SKP"
                                    font.pixelSize: 8; font.bold: true; color: colCyan
                                }
                            }
                            Rectangle {
                                height: 18
                                implicitWidth: mCatTag.implicitWidth + 10
                                radius: 9
                                color: Qt.rgba(139, 92, 246, 0.18)
                                border.width: 1; border.color: colViolet
                                Text {
                                    id: mCatTag
                                    anchors.centerIn: parent
                                    text: root.selectedAsset ? ((root.selectedAsset.category_name || root.selectedAsset.category || "").toUpperCase()) : ""
                                    font.pixelSize: 8; font.bold: true; color: colViolet
                                }
                            }
                        }

                        Text {
                            text: root.selectedAsset
                                  ? (root.selectedAsset.has_model === false
                                     ? ("Preview only \u2022 " + (root.selectedAsset.folder || "") )
                                     : (root.selectedAsset.filename + " \u2022 " + root.selectedAsset.size + " \u2022 " + (root.selectedAsset.path || "")))
                                  : ""
                            font.pixelSize: 9
                            color: root.selectedAsset && root.selectedAsset.has_model === false ? colAmber : colTextSecondary
                            elide: Text.ElideMiddle
                            Layout.fillWidth: true
                        }
                    }

                    // Close Button
                    Rectangle {
                        width: 32; height: 32; radius: 16
                        color: mCloseM.containsMouse ? Qt.rgba(1, 1, 1, 0.18) : Qt.rgba(1, 1, 1, 0.06)
                        border.width: 1; border.color: colBorderSubtle
                        FAIcon { anchors.centerIn: parent; text: fa.xmark; font.pixelSize: 11; color: colTextPrimary }
                        MouseArea {
                            id: mCloseM
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.closeModelModal()
                        }
                    }
                }

                Rectangle { Layout.fillWidth: true; height: 1; color: colBorderSubtle }

                // -------------------------------------------------------------
                // 2. TWO-COLUMN SPLIT: PREVIEW (LEFT) + SPECIFICATIONS (RIGHT)
                // -------------------------------------------------------------
                RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 16

                    // =========================================================
                    // LEFT COLUMN: DUAL LIVE PREVIEW (PHOTO & 3D GIMBAL)
                    // =========================================================
                    ColumnLayout {
                        Layout.preferredWidth: Math.min(480, Math.floor(modalContainer.width * 0.46))
                        Layout.fillHeight: true
                        spacing: 8

                        // Preview Mode Switcher Tabs
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8

                            Rectangle {
                                Layout.fillWidth: true
                                height: 28
                                radius: 8
                                color: modalContainer.modalPreviewTab === 0 ? Qt.rgba(0, 0.95, 1, 0.22) : Qt.rgba(1, 1, 1, 0.05)
                                border.width: modalContainer.modalPreviewTab === 0 ? 1 : 0
                                border.color: colCyan

                                RowLayout {
                                    anchors.centerIn: parent
                                    spacing: 6
                                    FAIcon { text: fa.camera; font.pixelSize: 10; color: modalContainer.modalPreviewTab === 0 ? colCyan : colTextSecondary }
                                    Text {
                                        text: (root.selectedAsset && root.selectedAsset.ext === "SKP") ? "SKP FILE PREVIEW" : "RENDERED IMAGE PREVIEW"
                                        font.pixelSize: 9
                                        font.bold: true
                                        color: modalContainer.modalPreviewTab === 0 ? colCyan : colTextSecondary
                                    }
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: modalContainer.modalPreviewTab = 0
                                }
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                height: 28
                                radius: 8
                                color: modalContainer.modalPreviewTab === 1 ? Qt.rgba(139, 92, 246, 0.22) : Qt.rgba(1, 1, 1, 0.05)
                                border.width: modalContainer.modalPreviewTab === 1 ? 1 : 0
                                border.color: colViolet

                                RowLayout {
                                    anchors.centerIn: parent
                                    spacing: 6
                                    FAIcon { text: fa.cube; font.pixelSize: 10; color: modalContainer.modalPreviewTab === 1 ? colViolet : colTextSecondary }
                                    Text {
                                        text: "3D ORIENTATION GIMBAL"
                                        font.pixelSize: 9
                                        font.bold: true
                                        color: modalContainer.modalPreviewTab === 1 ? colViolet : colTextSecondary
                                    }
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        modalContainer.modalPreviewTab = 1
                                        modalGimbalCanvas.requestPaint()
                                    }
                                }
                            }
                        }

                        // Live Viewport Display Box
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            radius: 14
                            color: Qt.rgba(0, 0, 0, 0.60)
                            border.width: 1
                            border.color: colBorderSubtle
                            clip: true

                            // 1. Rendered Image Viewport
                            Item {
                                anchors.fill: parent
                                visible: modalContainer.modalPreviewTab === 0

                                RowLayout {
                                    anchors.top: parent.top
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.margins: 10
                                    z: 3

                                    Rectangle {
                                        height: 18
                                        implicitWidth: mImgPill.implicitWidth + 12
                                        radius: 9
                                        color: Qt.rgba(0, 0, 0, 0.70)
                                        border.width: 1; border.color: Qt.rgba(0, 0.95, 1, 0.4)
                                        Text {
                                            id: mImgPill
                                            anchors.centerIn: parent
                                            text: (root.selectedAsset && root.selectedAsset.has_model === false) ? "PREVIEW IMAGE \u2022 NO 3D FILE" : ((root.selectedAsset && root.selectedAsset.ext === "SKP") ? "SKP MODEL PREVIEW" : "SKETCHUP NATIVE PREVIEW")
                                            font.pixelSize: 8; font.bold: true; color: root.selectedAsset && root.selectedAsset.has_model === false ? colAmber : colCyan
                                        }
                                    }
                                    Item { Layout.fillWidth: true }
                                    Text {
                                        text: (root.selectedAsset ? (root.selectedAsset.ext || "SKP") : "") + " MODEL"
                                        font.pixelSize: 9; font.bold: true; color: colViolet
                                    }
                                }

                                Image {
                                    id: modalImgPreview
                                    anchors.fill: parent
                                    anchors.margins: 16
                                    anchors.topMargin: 30
                                    source: root.assetThumbUrl(root.selectedAsset)
                                    fillMode: Image.PreserveAspectFit
                                    smooth: true
                                    visible: root.assetThumbUrl(root.selectedAsset) !== "" && status === Image.Ready
                                }

                                ColumnLayout {
                                    anchors.centerIn: parent
                                    visible: !modalImgPreview.visible
                                    spacing: 10
                                    FAIcon {
                                        Layout.alignment: Qt.AlignHCenter
                                        text: (root.selectedAsset && root.selectedAsset.ext === "SKP") ? fa.cube : fa.folder
                                        font.pixelSize: 48
                                        color: Qt.rgba(1, 1, 1, 0.25)
                                    }
                                    Text {
                                        Layout.alignment: Qt.AlignHCenter
                                        text: root.selectedAsset ? root.selectedAsset.filename : "No Image Detected"
                                        font.pixelSize: 11
                                        color: colTextMuted
                                    }
                                }
                            }

                            // 2. 3D Orientation Gimbal Canvas Viewport
                            Item {
                                anchors.fill: parent
                                visible: modalContainer.modalPreviewTab === 1

                                RowLayout {
                                    anchors.top: parent.top
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.margins: 10
                                    z: 3

                                    Rectangle {
                                        height: 18
                                        implicitWidth: mGmbPill.implicitWidth + 12
                                        radius: 9
                                        color: Qt.rgba(0, 0, 0, 0.70)
                                        border.width: 1; border.color: Qt.rgba(139, 92, 246, 0.5)
                                        Text {
                                            id: mGmbPill
                                            anchors.centerIn: parent
                                            text: "3D ORIENTATION GIMBAL"
                                            font.pixelSize: 8; font.bold: true; color: colViolet
                                        }
                                    }
                                    Item { Layout.fillWidth: true }
                                    Text {
                                        text: "Yaw: " + Math.round(root.currentParamValues["rot_z"] || 0) + "° • Scale: " + Number(root.currentParamValues["scale"] || 1.0).toFixed(2) + "x"
                                        font.pixelSize: 9; font.bold: true; color: colCyan
                                    }
                                }

                                Canvas {
                                    id: modalGimbalCanvas
                                    anchors.fill: parent
                                    anchors.topMargin: 20

                                    property var params: root.currentParamValues
                                    property var assetObj: root.selectedAsset

                                    onParamsChanged: requestPaint()
                                    onAssetObjChanged: requestPaint()

                                    onPaint: {
                                        var ctx = getContext("2d")
                                        ctx.clearRect(0, 0, width, height)
                                        var cx = width / 2.0
                                        var cy = height / 2.0 + 12

                                        var p = params || {}
                                        var scaleVal = Number(p["scale"] || 1.0)
                                        var rotDeg = Number(p["rot_z"] || 0.0)
                                        var rad = rotDeg * Math.PI / 180.0
                                        var elevZ = Number(p["pos_z"] || 0.0)

                                        // Ground grid
                                        ctx.lineWidth = 1.0
                                        ctx.strokeStyle = "rgba(255, 255, 255, 0.06)"
                                        var gridSteps = 4
                                        var sp = 26
                                        for (var gx = -gridSteps; gx <= gridSteps; gx++) {
                                            var x1 = cx + (gx * sp * 0.866) - (gridSteps * sp * 0.866)
                                            var y1 = cy + (gx * sp * 0.45) + (gridSteps * sp * 0.45)
                                            var x2 = cx + (gx * sp * 0.866) + (gridSteps * sp * 0.866)
                                            var y2 = cy + (gx * sp * 0.45) - (gridSteps * sp * 0.45)
                                            ctx.beginPath(); ctx.moveTo(x1, y1); ctx.lineTo(x2, y2); ctx.stroke()

                                            var x3 = cx - (gridSteps * sp * 0.866) + (gx * sp * 0.866)
                                            var y3 = cy - (gridSteps * sp * 0.45) + (gx * sp * 0.45)
                                            var x4 = cx + (gridSteps * sp * 0.866) + (gx * sp * 0.866)
                                            var y4 = cy + (gridSteps * sp * 0.45) + (gx * sp * 0.45)
                                            ctx.beginPath(); ctx.moveTo(x3, y3); ctx.lineTo(x4, y4); ctx.stroke()
                                        }

                                        // Coordinate Axes:
                                        // +X (Red)
                                        ctx.beginPath(); ctx.moveTo(cx, cy); ctx.lineTo(cx + 65 * 0.866, cy + 65 * 0.45)
                                        ctx.strokeStyle = "#EF4444"; ctx.lineWidth = 2.0; ctx.stroke()
                                        ctx.fillStyle = "#EF4444"; ctx.font = "bold 9px sans-serif"; ctx.fillText("+X", cx + 58, cy + 34)

                                        // +Y (Green)
                                        ctx.beginPath(); ctx.moveTo(cx, cy); ctx.lineTo(cx - 65 * 0.866, cy + 65 * 0.45)
                                        ctx.strokeStyle = "#10B981"; ctx.lineWidth = 2.0; ctx.stroke()
                                        ctx.fillStyle = "#10B981"; ctx.font = "bold 9px sans-serif"; ctx.fillText("+Y", cx - 72, cy + 34)

                                        // +Z (Cyan)
                                        ctx.beginPath(); ctx.moveTo(cx, cy); ctx.lineTo(cx, cy - 65)
                                        ctx.strokeStyle = "#00F5FF"; ctx.lineWidth = 2.0; ctx.stroke()
                                        ctx.fillStyle = "#00F5FF"; ctx.font = "bold 9px sans-serif"; ctx.fillText("+Z", cx + 6, cy - 54)

                                        // 3D Bounding Box Projection
                                        var bw = 30 * Math.min(2.2, Math.max(0.4, scaleVal))
                                        var bd = 22 * Math.min(2.2, Math.max(0.4, scaleVal))
                                        var bh = 40 * Math.min(2.2, Math.max(0.4, scaleVal))
                                        var elevOffset = Math.min(45, elevZ * 2.8)

                                        var cosA = Math.cos(rad)
                                        var sinA = Math.sin(rad)

                                        function iso(lx, ly, lz) {
                                            var rx = lx * cosA - ly * sinA
                                            var ry = lx * sinA + ly * cosA
                                            var px = cx + (rx - ry) * 0.866
                                            var py = (cy - elevOffset) + (rx + ry) * 0.45 - lz
                                            return { x: px, y: py }
                                        }

                                        var b1 = iso(-bw, -bd, 0); var b2 = iso(bw, -bd, 0)
                                        var b3 = iso(bw, bd, 0); var b4 = iso(-bw, bd, 0)
                                        var t1 = iso(-bw, -bd, bh); var t2 = iso(bw, -bd, bh)
                                        var t3 = iso(bw, bd, bh); var t4 = iso(-bw, bd, bh)

                                        // Ground drop shadow
                                        if (elevOffset > 2) {
                                            var g1 = iso(-bw, -bd, 0); var g2 = iso(bw, -bd, 0)
                                            var g3 = iso(bw, bd, 0); var g4 = iso(-bw, bd, 0)
                                            ctx.beginPath()
                                            ctx.moveTo(g1.x, g1.y + elevOffset); ctx.lineTo(g2.x, g2.y + elevOffset)
                                            ctx.lineTo(g3.x, g3.y + elevOffset); ctx.lineTo(g4.x, g4.y + elevOffset)
                                            ctx.closePath()
                                            ctx.fillStyle = "rgba(0, 0, 0, 0.45)"
                                            ctx.fill()
                                        }

                                        // Base face
                                        ctx.beginPath()
                                        ctx.moveTo(b1.x, b1.y); ctx.lineTo(b2.x, b2.y); ctx.lineTo(b3.x, b3.y); ctx.lineTo(b4.x, b4.y)
                                        ctx.closePath()
                                        ctx.fillStyle = "rgba(0, 245, 255, 0.10)"
                                        ctx.fill()
                                        ctx.strokeStyle = "rgba(0, 245, 255, 0.4)"
                                        ctx.lineWidth = 1.2
                                        ctx.stroke()

                                        // Vertical pillars
                                        ctx.beginPath()
                                        ctx.moveTo(b1.x, b1.y); ctx.lineTo(t1.x, t1.y)
                                        ctx.moveTo(b2.x, b2.y); ctx.lineTo(t2.x, t2.y)
                                        ctx.moveTo(b3.x, b3.y); ctx.lineTo(t3.x, t3.y)
                                        ctx.moveTo(b4.x, b4.y); ctx.lineTo(t4.x, t4.y)
                                        ctx.strokeStyle = "rgba(0, 245, 255, 0.75)"
                                        ctx.lineWidth = 1.5
                                        ctx.stroke()

                                        // Top face
                                        ctx.beginPath()
                                        ctx.moveTo(t1.x, t1.y); ctx.lineTo(t2.x, t2.y); ctx.lineTo(t3.x, t3.y); ctx.lineTo(t4.x, t4.y)
                                        ctx.closePath()
                                        ctx.fillStyle = "rgba(139, 92, 246, 0.30)"
                                        ctx.fill()
                                        ctx.strokeStyle = "#8B5CF6"
                                        ctx.lineWidth = 2.0
                                        ctx.stroke()

                                        // Heading orientation pointer arrow on top face
                                        var fFront = iso(0, bd, bh)
                                        var fCenter = iso(0, 0, bh)
                                        ctx.beginPath()
                                        ctx.moveTo(fCenter.x, fCenter.y); ctx.lineTo(fFront.x, fFront.y)
                                        ctx.strokeStyle = "#00F5FF"; ctx.lineWidth = 2.6; ctx.stroke()
                                        ctx.beginPath(); ctx.arc(fFront.x, fFront.y, 3.6, 0, 2 * Math.PI)
                                        ctx.fillStyle = "#00F5FF"; ctx.fill()
                                    }
                                }
                            }
                        }

                        // Quick Ground & Origin Alignment Bar
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8

                            Rectangle {
                                Layout.fillWidth: true
                                height: 28
                                radius: 8
                                color: mGndBtnM.containsMouse ? Qt.rgba(16, 185, 129, 0.25) : Qt.rgba(16, 185, 129, 0.12)
                                border.width: 1; border.color: colEmerald

                                RowLayout {
                                    anchors.centerIn: parent
                                    spacing: 5
                                    FAIcon { text: fa.arrowDown; font.pixelSize: 9; color: colEmerald }
                                    Text { text: "Drop on Ground (Z=0)"; font.pixelSize: 9; font.bold: true; color: colEmerald }
                                }
                                MouseArea {
                                    id: mGndBtnM; anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        root.updateShapeParam("pos_z", 0.0)
                                        modalGimbalCanvas.requestPaint()
                                    }
                                }
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                height: 28
                                radius: 8
                                color: mOrigBtnM.containsMouse ? Qt.rgba(0, 0.95, 1, 0.25) : Qt.rgba(0, 0.95, 1, 0.12)
                                border.width: 1; border.color: colCyan

                                RowLayout {
                                    anchors.centerIn: parent
                                    spacing: 5
                                    FAIcon { text: fa.circle; font.pixelSize: 8; color: colCyan }
                                    Text { text: "Center at Origin (0,0,0)"; font.pixelSize: 9; font.bold: true; color: colCyan }
                                }
                                MouseArea {
                                    id: mOrigBtnM; anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        root.updateShapeParam("pos_x", 0.0)
                                        root.updateShapeParam("pos_y", 0.0)
                                        root.updateShapeParam("pos_z", 0.0)
                                        modalGimbalCanvas.requestPaint()
                                    }
                                }
                            }
                        }
                    }

                    // =========================================================
                    // RIGHT COLUMN: SPECIFICATION CONTROLS
                    // =========================================================
                    ScrollView {
                        id: modalParamsScroll
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        contentWidth: availableWidth
                        contentHeight: modalParamsCol.implicitHeight + 10

                        ColumnLayout {
                            id: modalParamsCol
                            width: modalParamsScroll.availableWidth
                            spacing: 12

                            // 1. Uniform Scale Card
                            Rectangle {
                                id: mScaleCard
                                Layout.fillWidth: true
                                height: 86
                                radius: 10
                                color: Qt.rgba(1, 1, 1, 0.04)
                                border.width: 1
                                border.color: colBorderSubtle

                                readonly property real curScale: Number(root.currentParamValues["scale"] !== undefined ? root.currentParamValues["scale"] : 1.0)

                                ColumnLayout {
                                    anchors.fill: parent
                                    anchors.margins: 10
                                    spacing: 4

                                    RowLayout {
                                        Layout.fillWidth: true
                                        Text { text: "Uniform Scale Factor"; font.pixelSize: 10; font.bold: true; color: colTextPrimary }
                                        Item { Layout.fillWidth: true }
                                        Text {
                                            text: mScaleCard.curScale.toFixed(2) + "x (" + Math.round(mScaleCard.curScale * 100) + "%)"
                                            font.pixelSize: 10; font.bold: true; color: colCyan
                                        }
                                    }

                                    RowLayout {
                                        Layout.fillWidth: true
                                        spacing: 4
                                        Repeater {
                                            model: [
                                                { label: "0.25x", val: 0.25 },
                                                { label: "0.5x", val: 0.50 },
                                                { label: "1.0x", val: 1.00 },
                                                { label: "1.5x", val: 1.50 },
                                                { label: "2.0x", val: 2.00 },
                                                { label: "5.0x", val: 5.00 }
                                            ]
                                            Rectangle {
                                                Layout.fillWidth: true
                                                height: 20
                                                radius: 4
                                                color: (Math.abs(mScaleCard.curScale - modelData.val) < 0.01) ? Qt.rgba(0, 0.95, 1, 0.25) : Qt.rgba(1, 1, 1, 0.06)
                                                border.width: (Math.abs(mScaleCard.curScale - modelData.val) < 0.01) ? 1 : 0
                                                border.color: colCyan
                                                Text {
                                                    anchors.centerIn: parent
                                                    text: modelData.label
                                                    font.pixelSize: 8; font.bold: true
                                                    color: (Math.abs(mScaleCard.curScale - modelData.val) < 0.01) ? colCyan : colTextSecondary
                                                }
                                                MouseArea {
                                                    anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                                    onClicked: {
                                                        root.updateShapeParam("scale", modelData.val)
                                                        modalGimbalCanvas.requestPaint()
                                                    }
                                                }
                                            }
                                        }
                                    }

                                    RowLayout {
                                        Layout.fillWidth: true
                                        spacing: 6

                                        Rectangle {
                                            width: 22; height: 22; radius: 5
                                            color: msMinM.containsMouse ? Qt.rgba(1, 1, 1, 0.18) : Qt.rgba(1, 1, 1, 0.08)
                                            border.width: 1; border.color: colBorderSubtle
                                            FAIcon { anchors.centerIn: parent; text: fa.minus; font.pixelSize: 8; color: colTextPrimary }
                                            MouseArea {
                                                id: msMinM; anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                                onClicked: {
                                                    var nv = Math.max(0.1, mScaleCard.curScale - 0.1)
                                                    root.updateShapeParam("scale", Number(nv.toFixed(2)))
                                                    modalGimbalCanvas.requestPaint()
                                                }
                                            }
                                        }

                                        Slider {
                                            Layout.fillWidth: true
                                            from: 0.1; to: 5.0; stepSize: 0.05
                                            value: mScaleCard.curScale
                                            onMoved: {
                                                root.updateShapeParam("scale", Number(value.toFixed(2)))
                                                modalGimbalCanvas.requestPaint()
                                            }
                                        }

                                        Rectangle {
                                            width: 22; height: 22; radius: 5
                                            color: msPluM.containsMouse ? Qt.rgba(1, 1, 1, 0.18) : Qt.rgba(1, 1, 1, 0.08)
                                            border.width: 1; border.color: colBorderSubtle
                                            FAIcon { anchors.centerIn: parent; text: fa.plus; font.pixelSize: 8; color: colTextPrimary }
                                            MouseArea {
                                                id: msPluM; anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                                onClicked: {
                                                    var nv = Math.min(5.0, mScaleCard.curScale + 0.1)
                                                    root.updateShapeParam("scale", Number(nv.toFixed(2)))
                                                    modalGimbalCanvas.requestPaint()
                                                }
                                            }
                                        }
                                    }
                                }
                            }

                            // 2. Rotation Yaw Card
                            Rectangle {
                                id: mRotCard
                                Layout.fillWidth: true
                                height: 86
                                radius: 10
                                color: Qt.rgba(1, 1, 1, 0.04)
                                border.width: 1
                                border.color: colBorderSubtle

                                readonly property real curRot: Number(root.currentParamValues["rot_z"] !== undefined ? root.currentParamValues["rot_z"] : 0)

                                ColumnLayout {
                                    anchors.fill: parent
                                    anchors.margins: 10
                                    spacing: 4

                                    RowLayout {
                                        Layout.fillWidth: true
                                        Text { text: "Rotation (Yaw / Z-Axis)"; font.pixelSize: 10; font.bold: true; color: colTextPrimary }
                                        Item { Layout.fillWidth: true }
                                        Text {
                                            text: Math.round(mRotCard.curRot) + "°"
                                            font.pixelSize: 10; font.bold: true; color: colViolet
                                        }
                                    }

                                    RowLayout {
                                        Layout.fillWidth: true
                                        spacing: 4
                                        Repeater {
                                            model: [
                                                { label: "0° (North)", val: 0 },
                                                { label: "90° (East)", val: 90 },
                                                { label: "180° (South)", val: 180 },
                                                { label: "270° (West)", val: 270 }
                                            ]
                                            Rectangle {
                                                Layout.fillWidth: true
                                                height: 20
                                                radius: 4
                                                color: (Math.round(mRotCard.curRot) === modelData.val) ? Qt.rgba(139, 92, 246, 0.25) : Qt.rgba(1, 1, 1, 0.06)
                                                border.width: (Math.round(mRotCard.curRot) === modelData.val) ? 1 : 0
                                                border.color: colViolet
                                                Text {
                                                    anchors.centerIn: parent
                                                    text: modelData.label
                                                    font.pixelSize: 8; font.bold: true
                                                    color: (Math.round(mRotCard.curRot) === modelData.val) ? colViolet : colTextSecondary
                                                }
                                                MouseArea {
                                                    anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                                    onClicked: {
                                                        root.updateShapeParam("rot_z", modelData.val)
                                                        modalGimbalCanvas.requestPaint()
                                                    }
                                                }
                                            }
                                        }
                                    }

                                    RowLayout {
                                        Layout.fillWidth: true
                                        spacing: 6

                                        Rectangle {
                                            width: 22; height: 22; radius: 5
                                            color: mrMinM.containsMouse ? Qt.rgba(1, 1, 1, 0.18) : Qt.rgba(1, 1, 1, 0.08)
                                            border.width: 1; border.color: colBorderSubtle
                                            FAIcon { anchors.centerIn: parent; text: fa.minus; font.pixelSize: 8; color: colTextPrimary }
                                            MouseArea {
                                                id: mrMinM; anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                                onClicked: {
                                                    var nv = (mRotCard.curRot - 15 + 360) % 360
                                                    root.updateShapeParam("rot_z", nv)
                                                    modalGimbalCanvas.requestPaint()
                                                }
                                            }
                                        }

                                        Slider {
                                            Layout.fillWidth: true
                                            from: 0; to: 360; stepSize: 5
                                            value: mRotCard.curRot
                                            onMoved: {
                                                root.updateShapeParam("rot_z", Math.round(value))
                                                modalGimbalCanvas.requestPaint()
                                            }
                                        }

                                        Rectangle {
                                            width: 22; height: 22; radius: 5
                                            color: mrPluM.containsMouse ? Qt.rgba(1, 1, 1, 0.18) : Qt.rgba(1, 1, 1, 0.08)
                                            border.width: 1; border.color: colBorderSubtle
                                            FAIcon { anchors.centerIn: parent; text: fa.plus; font.pixelSize: 8; color: colTextPrimary }
                                            MouseArea {
                                                id: mrPluM; anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                                onClicked: {
                                                    var nv = (mRotCard.curRot + 15) % 360
                                                    root.updateShapeParam("rot_z", nv)
                                                    modalGimbalCanvas.requestPaint()
                                                }
                                            }
                                        }
                                    }
                                }
                            }

                            // 3. Position & Elevation Coordinates Card
                            Rectangle {
                                Layout.fillWidth: true
                                height: 136
                                radius: 10
                                color: Qt.rgba(1, 1, 1, 0.04)
                                border.width: 1
                                border.color: colBorderSubtle

                                ColumnLayout {
                                    anchors.fill: parent
                                    anchors.margins: 10
                                    spacing: 5

                                    RowLayout {
                                        Layout.fillWidth: true
                                        Text { text: "Scene Placement Coordinates"; font.pixelSize: 10; font.bold: true; color: colTextPrimary }
                                        Item { Layout.fillWidth: true }
                                        Text { text: "World Coordinates (m)"; font.pixelSize: 8; color: colTextMuted }
                                    }

                                    // Position X Slider
                                    RowLayout {
                                        Layout.fillWidth: true
                                        spacing: 6
                                        Text { text: "X Offset:"; font.pixelSize: 9; color: "#EF4444"; width: 44 }
                                        Slider {
                                            Layout.fillWidth: true
                                            from: -25.0; to: 25.0; stepSize: 0.25
                                            value: Number(root.currentParamValues["pos_x"] || 0.0)
                                            onMoved: {
                                                root.updateShapeParam("pos_x", Number(value.toFixed(2)))
                                                modalGimbalCanvas.requestPaint()
                                            }
                                        }
                                        Text { text: Number(root.currentParamValues["pos_x"] || 0.0).toFixed(1) + "m"; font.pixelSize: 9; font.bold: true; color: "#EF4444"; width: 36; horizontalAlignment: Text.AlignRight }
                                    }

                                    // Position Y Slider
                                    RowLayout {
                                        Layout.fillWidth: true
                                        spacing: 6
                                        Text { text: "Y Offset:"; font.pixelSize: 9; color: "#10B981"; width: 44 }
                                        Slider {
                                            Layout.fillWidth: true
                                            from: -25.0; to: 25.0; stepSize: 0.25
                                            value: Number(root.currentParamValues["pos_y"] || 0.0)
                                            onMoved: {
                                                root.updateShapeParam("pos_y", Number(value.toFixed(2)))
                                                modalGimbalCanvas.requestPaint()
                                            }
                                        }
                                        Text { text: Number(root.currentParamValues["pos_y"] || 0.0).toFixed(1) + "m"; font.pixelSize: 9; font.bold: true; color: "#10B981"; width: 36; horizontalAlignment: Text.AlignRight }
                                    }

                                    // Elevation Z Slider
                                    RowLayout {
                                        Layout.fillWidth: true
                                        spacing: 6
                                        Text { text: "Elev. Z:"; font.pixelSize: 9; color: "#00F5FF"; width: 44 }
                                        Slider {
                                            Layout.fillWidth: true
                                            from: 0.0; to: 25.0; stepSize: 0.10
                                            value: Number(root.currentParamValues["pos_z"] || 0.0)
                                            onMoved: {
                                                root.updateShapeParam("pos_z", Number(value.toFixed(2)))
                                                modalGimbalCanvas.requestPaint()
                                            }
                                        }
                                        Text { text: Number(root.currentParamValues["pos_z"] || 0.0).toFixed(1) + "m"; font.pixelSize: 9; font.bold: true; color: "#00F5FF"; width: 36; horizontalAlignment: Text.AlignRight }
                                    }
                                }
                            }

                            // 4. Instance Name & Tag Card
                            Rectangle {
                                Layout.fillWidth: true
                                height: 110
                                radius: 10
                                color: Qt.rgba(1, 1, 1, 0.04)
                                border.width: 1
                                border.color: colBorderSubtle

                                ColumnLayout {
                                    anchors.fill: parent
                                    anchors.margins: 10
                                    spacing: 6

                                    RowLayout {
                                        Layout.fillWidth: true
                                        Text { text: "Instance Name in SketchUp"; font.pixelSize: 10; font.bold: true; color: colTextPrimary }
                                        Item { Layout.fillWidth: true }
                                        Text { text: "Outliner Identifier"; font.pixelSize: 8; color: colTextMuted }
                                    }

                                    Rectangle {
                                        Layout.fillWidth: true
                                        height: 28
                                        radius: 6
                                        color: Qt.rgba(0, 0, 0, 0.4)
                                        border.width: 1; border.color: colBorderSubtle

                                        TextInput {
                                            anchors.fill: parent
                                            anchors.leftMargin: 8; anchors.rightMargin: 8
                                            verticalAlignment: TextInput.AlignVCenter
                                            color: "#FFFFFF"; font.pixelSize: 10
                                            text: root.selectedAsset ? (root.currentParamValues["name"] !== undefined ? root.currentParamValues["name"] : root.selectedAsset.name) : ""
                                            onTextEdited: root.updateShapeParam("name", text)
                                        }
                                    }

                                    RowLayout {
                                        Layout.fillWidth: true
                                        Text { text: "SketchUp Layer / Tag:"; font.pixelSize: 9; color: colTextSecondary }
                                        Item { Layout.fillWidth: true }
                                        Repeater {
                                            model: ["Untagged", "Architecture", "Furniture", "Landscape", "Structure"]
                                            Rectangle {
                                                property bool isCurTag: (root.currentParamValues["layer"] || "Untagged") === modelData
                                                height: 18
                                                implicitWidth: tagTxt.implicitWidth + 10
                                                radius: 4
                                                color: isCurTag ? Qt.rgba(0, 0.95, 1, 0.20) : Qt.rgba(1, 1, 1, 0.05)
                                                border.width: isCurTag ? 1 : 0; border.color: colCyan
                                                Text {
                                                    id: tagTxt
                                                    anchors.centerIn: parent
                                                    text: modelData
                                                    font.pixelSize: 8; font.bold: isCurTag
                                                    color: isCurTag ? colCyan : colTextMuted
                                                }
                                                MouseArea {
                                                    anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                                    onClicked: root.updateShapeParam("layer", modelData)
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
                                implicitWidth: mrstTxt.implicitWidth + 14
                                radius: 11
                                color: mrstM.containsMouse ? Qt.rgba(1, 1, 1, 0.12) : "transparent"
                                border.width: 1; border.color: colBorderSubtle

                                RowLayout {
                                    anchors.centerIn: parent
                                    spacing: 5
                                    FAIcon { text: fa.sync; font.pixelSize: 8; color: colTextSecondary }
                                    Text {
                                        id: mrstTxt
                                        text: "Reset All Transforms"
                                        font.pixelSize: 9
                                        color: colTextSecondary
                                    }
                                }
                                MouseArea {
                                    id: mrstM; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (root.selectedAsset) {
                                            root.selectAsset(root.selectedAsset)
                                            modalGimbalCanvas.requestPaint()
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                Rectangle { Layout.fillWidth: true; height: 1; color: colBorderSubtle }

                // -------------------------------------------------------------
                // 3. MODAL FOOTER ACTION BAR
                // -------------------------------------------------------------
                RowLayout {
                    Layout.fillWidth: true
                    height: 44
                    spacing: 12

                    RowLayout {
                        spacing: 6
                        FAIcon { text: root.selectedAsset && root.selectedAsset.has_model === false ? fa.warning : fa.check; font.pixelSize: 10; color: root.selectedAsset && root.selectedAsset.has_model === false ? colAmber : colEmerald }
                        Text {
                            text: root.selectedAsset && root.selectedAsset.has_model === false
                                  ? "Preview only — add a 3D file to this folder to enable insertion"
                                  : "Ready to insert into active SketchUp session with matrix transform"
                            font.pixelSize: 10
                            color: root.selectedAsset && root.selectedAsset.has_model === false ? colAmber : colTextSecondary
                        }
                    }

                    Item { Layout.fillWidth: true }

                    // Cancel / Close Button
                    Rectangle {
                        height: 38
                        implicitWidth: mCancelTxt.implicitWidth + 24
                        radius: 10
                        color: mCancelM.containsMouse ? Qt.rgba(1, 1, 1, 0.12) : Qt.rgba(1, 1, 1, 0.05)
                        border.width: 1; border.color: colBorderSubtle
                        Text {
                            id: mCancelTxt
                            anchors.centerIn: parent
                            text: "Cancel"
                            font.pixelSize: 11
                            color: colTextPrimary
                        }
                        MouseArea {
                            id: mCancelM; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                            onClicked: root.closeModelModal()
                        }
                    }

                    // Primary Action Button: ADD TO SKETCHUP 2026
                    Rectangle {
                        id: mAddBtn
                        property bool noModel: root.selectedAsset && root.selectedAsset.has_model === false
                        height: 38
                        implicitWidth: mAddTxtRow.implicitWidth + 28
                        radius: 10
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: mAddBtn.noModel ? (mAddBtnM.containsMouse ? "#D97706" : colAmber) : (mAddBtnM.containsMouse ? "#2DFEFF" : colCyan) }
                            GradientStop { position: 1.0; color: mAddBtn.noModel ? "#92400E" : "#5E17EB" }
                        }

                        RowLayout {
                            id: mAddTxtRow
                            anchors.centerIn: parent
                            spacing: 8
                            FAIcon { text: mAddBtn.noModel ? fa.warning : fa.bolt; font.pixelSize: 12; color: "#FFFFFF" }
                            Text {
                                text: mAddBtn.noModel ? "NO 3D FILE IN FOLDER" : "ADD TO SKETCHUP 2026"
                                font.pixelSize: 11
                                font.bold: true
                                font.letterSpacing: 0.8
                                color: "#FFFFFF"
                            }
                        }

                        MouseArea {
                            id: mAddBtnM
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.insertSelectedModel()
                        }
                    }
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
