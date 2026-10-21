import os
import sys
from PySide6.QtWidgets import (
    QMainWindow, QWidget, QVBoxLayout, QHBoxLayout, QGridLayout,
    QFrame, QLabel, QPushButton, QSlider, QDoubleSpinBox, QSpinBox,
    QLineEdit, QPlainTextEdit, QTabWidget, QDialog, QScrollArea,
    QFileDialog, QSizePolicy
)
from PySide6.QtCore import Qt, QTimer, QSize
from PySide6.QtGui import QIcon, QFont, QColor

class InfoDialog(QDialog):
    """Clean, high-readability Modal Dialog for How It Works & Credits"""
    def __init__(self, parent=None):
        super().__init__(parent)
        self.setWindowTitle("Liquid CAD Studio — Guide & Credits")
        self.setMinimumSize(660, 560)
        self.resize(700, 600)
        self.setStyleSheet("""
            QDialog {
                background-color: #0B0F19;
                color: #FFFFFF;
            }
            QLabel {
                color: #E2E8F0;
            }
            QFrame#card {
                background-color: #121826;
                border: 1px solid #1E293B;
                border-radius: 12px;
                padding: 12px;
            }
            QScrollArea {
                border: none;
                background-color: transparent;
            }
            QScrollBar:vertical {
                background: #0B0F19;
                width: 8px;
                margin: 0px;
            }
            QScrollBar::handle:vertical {
                background: #1E293B;
                min-height: 20px;
                border-radius: 4px;
            }
        """)

        layout = QVBoxLayout(self)
        layout.setContentsMargins(24, 24, 24, 24)
        layout.setSpacing(18)

        # Header
        header_layout = QHBoxLayout()
        header_icon = QLabel("ℹ")
        header_icon.setFixedSize(40, 40)
        header_icon.setAlignment(Qt.AlignCenter)
        header_icon.setStyleSheet("""
            background: qlineargradient(x1:0, y1:0, x2:1, y2:1, stop:0 #00F0FF, stop:1 #9D4EDD);
            color: #0B0F19;
            font-size: 20px;
            font-weight: bold;
            border-radius: 10px;
        """)
        header_layout.addWidget(header_icon)

        title_col = QVBoxLayout()
        title_col.setSpacing(2)
        title_label = QLabel("HOW LIQUID CAD WORKS & ARCHITECTURE")
        title_label.setStyleSheet("font-size: 14px; font-weight: bold; letter-spacing: 1px; color: #FFFFFF;")
        subtitle_label = QLabel("Direct CAD synchronization, procedural geometry & developer credits")
        subtitle_label.setStyleSheet("font-size: 11px; color: #8A99AD;")
        title_col.addWidget(title_label)
        title_col.addWidget(subtitle_label)
        header_layout.addLayout(title_col)
        header_layout.addStretch()

        close_btn_top = QPushButton("✕")
        close_btn_top.setFixedSize(32, 32)
        close_btn_top.setCursor(Qt.PointingHandCursor)
        close_btn_top.setStyleSheet("""
            QPushButton {
                background: rgba(255, 255, 255, 0.06);
                border: 1px solid #1E293B;
                border-radius: 8px;
                color: #FFFFFF;
                font-size: 13px;
            }
            QPushButton:hover {
                background: rgba(255, 255, 255, 0.15);
            }
        """)
        close_btn_top.clicked.connect(self.accept)
        header_layout.addWidget(close_btn_top)

        layout.addLayout(header_layout)

        # Separator line
        sep = QFrame()
        sep.setFrameShape(QFrame.HLine)
        sep.setStyleSheet("background-color: #1E293B; max-height: 1px;")
        layout.addWidget(sep)

        # Scroll Area for Content
        scroll = QScrollArea()
        scroll.setWidgetResizable(True)
        content_widget = QWidget()
        content_layout = QVBoxLayout(content_widget)
        content_layout.setContentsMargins(0, 8, 12, 8)
        content_layout.setSpacing(16)

        # Section 1: How It Works
        sec1_title = QLabel("⚡ HOW THE SYSTEM OPERATES")
        sec1_title.setStyleSheet("font-size: 12px; font-weight: bold; color: #00F0FF; letter-spacing: 1px;")
        content_layout.addWidget(sec1_title)

        steps = [
            ("1. Local Ruby Bridge Server", "A lightweight, non-blocking HTTP daemon runs inside SketchUp 2026 on 127.0.0.1:9876. It automatically boots whenever SketchUp opens."),
            ("2. Real-Time Viewport Sync", "Adjusting sliders or presets immediately sends JSON payloads to SketchUp. The geometry is generated procedurally in milliseconds with clean manifold solids."),
            ("3. Full Native Undo (Ctrl+Z / Cmd+Z)", "Every single action is wrapped in a native SketchUp undo transaction. You can undo, redo, or modify the created objects at any time inside SketchUp."),
            ("4. 1-Click Batch Exporter", "Export scenes directly to OBJ, STL (3D Printing), DAE (Blender & Game Engines), or 4K PNG Viewport Renders without going through file dialogs."),
            ("5. Optional AI Model Context Protocol (MCP)", "The included sketchup_mcp.py server connects directly to Claude Desktop, Cursor, or Antigravity to automate 3D modeling via natural language prompts.")
        ]

        for step_title, step_desc in steps:
            card = QFrame()
            card.setObjectName("card")
            card_layout = QHBoxLayout(card)
            card_layout.setContentsMargins(12, 12, 12, 12)
            card_layout.setSpacing(12)

            dot = QLabel()
            dot.setFixedSize(8, 8)
            dot.setStyleSheet("background-color: #00F0FF; border-radius: 4px;")
            card_layout.addWidget(dot, 0, Qt.AlignTop | Qt.AlignHCenter)

            text_col = QVBoxLayout()
            text_col.setSpacing(4)
            st_lbl = QLabel(step_title)
            st_lbl.setStyleSheet("font-size: 12px; font-weight: bold; color: #FFFFFF;")
            sd_lbl = QLabel(step_desc)
            sd_lbl.setWordWrap(True)
            sd_lbl.setStyleSheet("font-size: 11px; color: #94A3B8; line-height: 1.4;")
            text_col.addWidget(st_lbl)
            text_col.addWidget(sd_lbl)
            card_layout.addLayout(text_col)

            content_layout.addWidget(card)

        # Section 2: Credits
        sec2_title = QLabel("💎 CREDITS & SYSTEM SPECIFICATIONS")
        sec2_title.setStyleSheet("font-size: 12px; font-weight: bold; color: #9D4EDD; letter-spacing: 1px; margin-top: 10px;")
        content_layout.addWidget(sec2_title)

        cred_card = QFrame()
        cred_card.setObjectName("card")
        cred_layout = QGridLayout(cred_card)
        cred_layout.setContentsMargins(14, 14, 14, 14)
        cred_layout.setHorizontalSpacing(16)
        cred_layout.setVerticalSpacing(8)

        specs = [
            ("Author / Developer:", "Mohamed Amraoui (@amraoui-mo7amed)"),
            ("UI Framework:", "Pure PySide6 (Qt 6 Widgets) — Liquid Light Theme"),
            ("CAD Engine:", "SketchUp 2026 Ruby C API Bridge"),
            ("AI Protocol:", "Anthropic Model Context Protocol (FastMCP 2.x)"),
            ("Repository:", "github.com/amraoui-mo7amed/sketchup-controller")
        ]

        for row, (k, v) in enumerate(specs):
            lbl_k = QLabel(k)
            lbl_k.setStyleSheet("color: #64748B; font-size: 11px;")
            lbl_v = QLabel(v)
            lbl_v.setStyleSheet("color: #E2E8F0; font-size: 11px; font-weight: bold;")
            if "00F0FF" in k or "@amraoui" in v:
                lbl_v.setStyleSheet("color: #00F0FF; font-size: 11px; font-weight: bold;")
            cred_layout.addWidget(lbl_k, row, 0)
            cred_layout.addWidget(lbl_v, row, 1)

        content_layout.addWidget(cred_card)
        scroll.setWidget(content_widget)
        layout.addWidget(scroll)

        # Bottom Close Button
        btn_close = QPushButton("Close Guide")
        btn_close.setFixedHeight(40)
        btn_close.setCursor(Qt.PointingHandCursor)
        btn_close.setStyleSheet("""
            QPushButton {
                background: qlineargradient(x1:0, y1:0, x2:1, y2:0, stop:0 #00F0FF, stop:1 #7928CA);
                border: none;
                border-radius: 10px;
                color: #FFFFFF;
                font-size: 12px;
                font-weight: bold;
            }
            QPushButton:hover {
                background: qlineargradient(x1:0, y1:0, x2:1, y2:0, stop:0 #2DFEFF, stop:1 #9D4EDD);
            }
        """)
        btn_close.clicked.connect(self.accept)
        layout.addWidget(btn_close)

class MainWindow(QMainWindow):
    def __init__(self, backend):
        super().__init__()
        self.backend = backend
        self.setWindowTitle("Liquid CAD Studio — SketchUp 2026 Controller")
        self.setMinimumSize(920, 660)
        self.resize(1020, 720)

        # Apply Global Dark Stylesheet
        self.setStyleSheet("""
            QMainWindow {
                background-color: #080B11;
            }
            QWidget {
                color: #F8FAFC;
                font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
            }
            QFrame.card {
                background-color: #0F1420;
                border: 1px solid #1E293B;
                border-radius: 16px;
            }
            QTabWidget::pane {
                border: 1px solid #1E293B;
                background-color: #0B0F19;
                border-radius: 16px;
                top: -1px;
            }
            QTabBar::tab {
                background: #090C14;
                color: #94A3B8;
                border: 1px solid #1E293B;
                border-bottom: none;
                border-top-left-radius: 10px;
                border-top-right-radius: 10px;
                padding: 10px 18px;
                font-size: 12px;
                font-weight: bold;
                margin-right: 4px;
            }
            QTabBar::tab:selected {
                background: #0F1420;
                color: #00F0FF;
                border-bottom: 2px solid #00F0FF;
            }
            QTabBar::tab:hover:!selected {
                background: #141B2B;
                color: #E2E8F0;
            }
            QSlider::groove:horizontal {
                height: 6px;
                background: #1E293B;
                border-radius: 3px;
            }
            QSlider::sub-page:horizontal {
                background: #00F0FF;
                border-radius: 3px;
            }
            QSlider::handle:horizontal {
                background: #FFFFFF;
                border: 2px solid #00F0FF;
                width: 16px;
                margin-top: -5px;
                margin-bottom: -5px;
                border-radius: 8px;
            }
            QDoubleSpinBox, QSpinBox, QLineEdit {
                background-color: #070A10;
                border: 1px solid #1E293B;
                border-radius: 8px;
                color: #00F0FF;
                padding: 6px 10px;
                font-size: 12px;
                font-weight: bold;
            }
            QDoubleSpinBox:focus, QSpinBox:focus, QLineEdit:focus {
                border: 1px solid #00F0FF;
            }
            QPushButton.primary-btn {
                background: qlineargradient(x1:0, y1:0, x2:1, y2:0, stop:0 #00F0FF, stop:1 #4A00E0);
                border: none;
                border-radius: 12px;
                color: #FFFFFF;
                font-size: 12px;
                font-weight: bold;
                letter-spacing: 0.5px;
                padding: 10px 16px;
            }
            QPushButton.primary-btn:hover {
                background: qlineargradient(x1:0, y1:0, x2:1, y2:0, stop:0 #2DFEFF, stop:1 #7928CA);
            }
            QPushButton.secondary-btn {
                background-color: rgba(255, 255, 255, 0.06);
                border: 1px solid #1E293B;
                border-radius: 10px;
                color: #E2E8F0;
                font-size: 11px;
                font-weight: bold;
                padding: 8px 14px;
            }
            QPushButton.secondary-btn:hover {
                background-color: rgba(255, 255, 255, 0.12);
                border-color: #334155;
            }
            QPushButton.danger-btn {
                background-color: rgba(239, 68, 68, 0.15);
                border: 1px solid rgba(239, 68, 68, 0.4);
                border-radius: 10px;
                color: #F87171;
                font-size: 11px;
                font-weight: bold;
                padding: 8px 14px;
            }
            QPushButton.danger-btn:hover {
                background-color: rgba(239, 68, 68, 0.25);
            }
        """)

        central_widget = QWidget()
        self.setCentralWidget(central_widget)
        main_layout = QVBoxLayout(central_widget)
        main_layout.setContentsMargins(20, 16, 20, 16)
        main_layout.setSpacing(14)

        # ---------------------------------------------------------------------
        # TOP HEADER BAR
        # ---------------------------------------------------------------------
        header = QFrame()
        header.setProperty("class", "card")
        header_layout = QHBoxLayout(header)
        header_layout.setContentsMargins(16, 12, 16, 12)
        header_layout.setSpacing(14)

        # Brand Icon
        brand_icon = QLabel("⌘")
        brand_icon.setFixedSize(38, 38)
        brand_icon.setAlignment(Qt.AlignCenter)
        brand_icon.setStyleSheet("""
            background: qlineargradient(x1:0, y1:0, x2:1, y2:1, stop:0 #00F0FF, stop:1 #9D4EDD);
            color: #080B11;
            font-size: 20px;
            font-weight: bold;
            border-radius: 10px;
        """)
        header_layout.addWidget(brand_icon)

        # Brand Title
        brand_col = QVBoxLayout()
        brand_col.setSpacing(2)
        b_title = QLabel("LIQUID CAD STUDIO")
        b_title.setStyleSheet("font-size: 14px; font-weight: bold; letter-spacing: 1.2px; color: #FFFFFF;")
        b_sub = QLabel("Deterministic SketchUp 2026 Controller")
        b_sub.setStyleSheet("font-size: 11px; color: #64748B;")
        brand_col.addWidget(b_title)
        brand_col.addWidget(b_sub)
        header_layout.addLayout(brand_col)

        header_layout.addStretch()

        # Connection Status Capsule
        self.status_capsule = QFrame()
        self.status_capsule.setFixedHeight(36)
        sc_layout = QHBoxLayout(self.status_capsule)
        sc_layout.setContentsMargins(14, 4, 14, 4)
        sc_layout.setSpacing(8)

        self.status_dot = QLabel()
        self.status_dot.setFixedSize(10, 10)
        sc_layout.addWidget(self.status_dot)

        self.status_text = QLabel("SEARCHING BRIDGE (127.0.0.1:9876)")
        self.status_text.setStyleSheet("font-size: 11px; font-weight: bold;")
        sc_layout.addWidget(self.status_text)
        header_layout.addWidget(self.status_capsule)

        # Refresh Button (↻)
        self.btn_refresh = QPushButton("↻")
        self.btn_refresh.setFixedSize(36, 36)
        self.btn_refresh.setCursor(Qt.PointingHandCursor)
        self.btn_refresh.setStyleSheet("""
            QPushButton {
                background: rgba(255, 255, 255, 0.06);
                border: 1px solid #1E293B;
                border-radius: 10px;
                color: #FFFFFF;
                font-size: 16px;
            }
            QPushButton:hover {
                background: rgba(255, 255, 255, 0.15);
                border-color: #00F0FF;
            }
        """)
        self.btn_refresh.clicked.connect(self.backend.refresh)
        header_layout.addWidget(self.btn_refresh)

        # Info & Credits Button (ℹ) — ICON ONLY BUTTON
        self.btn_info = QPushButton("ℹ")
        self.btn_info.setFixedSize(36, 36)
        self.btn_info.setCursor(Qt.PointingHandCursor)
        self.btn_info.setToolTip("How it works & Credits")
        self.btn_info.setStyleSheet("""
            QPushButton {
                background: rgba(0, 240, 255, 0.10);
                border: 1px solid rgba(0, 240, 255, 0.35);
                border-radius: 10px;
                color: #00F0FF;
                font-size: 16px;
                font-weight: bold;
            }
            QPushButton:hover {
                background: rgba(0, 240, 255, 0.25);
                border-color: #00F0FF;
            }
        """)
        self.btn_info.clicked.connect(self.show_info_dialog)
        header_layout.addWidget(self.btn_info)

        main_layout.addWidget(header)

        # ---------------------------------------------------------------------
        # MAIN TAB WIDGET
        # ---------------------------------------------------------------------
        self.tabs = QTabWidget()
        self.tab_design = self.build_tab_design()
        self.tab_camera = self.build_tab_camera()
        self.tab_export = self.build_tab_export()
        self.tab_telemetry = self.build_tab_telemetry()
        self.tab_ruby = self.build_tab_ruby()

        self.tabs.addTab(self.tab_design, "⚡ Parametric Design")
        self.tabs.addTab(self.tab_camera, "🎥 Camera Views")
        self.tabs.addTab(self.tab_export, "📦 Export Studio")
        self.tabs.addTab(self.tab_telemetry, "📊 Model Telemetry")
        self.tabs.addTab(self.tab_ruby, "💻 Ruby Console")

        main_layout.addWidget(self.tabs)

        # ---------------------------------------------------------------------
        # TOAST NOTIFICATION BAR
        # ---------------------------------------------------------------------
        self.toast_frame = QFrame()
        self.toast_frame.setFixedHeight(40)
        self.toast_frame.hide()
        tf_layout = QHBoxLayout(self.toast_frame)
        tf_layout.setContentsMargins(16, 4, 16, 4)
        self.toast_label = QLabel("")
        self.toast_label.setAlignment(Qt.AlignCenter)
        self.toast_label.setStyleSheet("font-size: 12px; font-weight: bold; color: #FFFFFF;")
        tf_layout.addWidget(self.toast_label)
        main_layout.addWidget(self.toast_frame)

        self.toast_timer = QTimer(self)
        self.toast_timer.setInterval(4000)
        self.toast_timer.timeout.connect(self.toast_frame.hide)

        # Connect Backend Signals
        self.backend.connectionChanged.connect(self.on_connection_changed)
        self.backend.statusUpdated.connect(self.on_status_updated)
        self.backend.actionFinished.connect(self.show_toast)

        # Initial Status Update
        self.update_connection_ui()

    def show_info_dialog(self):
        dlg = InfoDialog(self)
        dlg.exec()

    def show_toast(self, message, success):
        self.toast_label.setText(message)
        if success:
            self.toast_frame.setStyleSheet("""
                background-color: rgba(16, 185, 129, 0.25);
                border: 1px solid #10B981;
                border-radius: 12px;
            """)
        else:
            self.toast_frame.setStyleSheet("""
                background-color: rgba(239, 68, 68, 0.25);
                border: 1px solid #EF4444;
                border-radius: 12px;
            """)
        self.toast_frame.show()
        self.toast_timer.start()

    def on_connection_changed(self, connected):
        self.update_connection_ui()

    def on_status_updated(self):
        self.update_connection_ui()
        self.lbl_stat_dim.setText(self.backend.dimensions)
        self.lbl_stat_faces.setText(str(self.backend.facesCount))
        self.lbl_stat_edges.setText(str(self.backend.edgesCount))
        self.lbl_stat_groups.setText(str(self.backend.groupsCount + self.backend.componentsCount))

    def update_connection_ui(self):
        if self.backend.connected:
            self.status_capsule.setStyleSheet("""
                background-color: rgba(16, 185, 129, 0.12);
                border: 1px solid rgba(16, 185, 129, 0.35);
                border-radius: 18px;
            """)
            self.status_dot.setStyleSheet("background-color: #10B981; border-radius: 5px;")
            self.status_text.setText(f"ONLINE: {self.backend.modelName} ({self.backend.units})")
            self.status_text.setStyleSheet("color: #10B981; font-size: 11px; font-weight: bold;")
        else:
            self.status_capsule.setStyleSheet("""
                background-color: rgba(245, 158, 11, 0.12);
                border: 1px solid rgba(245, 158, 11, 0.35);
                border-radius: 18px;
            """)
            self.status_dot.setStyleSheet("background-color: #F59E0B; border-radius: 5px;")
            self.status_text.setText("BRIDGE OFFLINE (127.0.0.1:9876)")
            self.status_text.setStyleSheet("color: #F59E0B; font-size: 11px; font-weight: bold;")

    # =========================================================================
    # TAB 1: PARAMETRIC DESIGN
    # =========================================================================
    def build_tab_design(self):
        tab = QWidget()
        layout = QHBoxLayout(tab)
        layout.setContentsMargins(16, 16, 16, 16)
        layout.setSpacing(16)

        # Left Panel: Room Generator
        left_card = QFrame()
        left_card.setProperty("class", "card")
        lc_layout = QVBoxLayout(left_card)
        lc_layout.setContentsMargins(20, 20, 20, 20)
        lc_layout.setSpacing(14)

        lc_header = QHBoxLayout()
        lc_title = QLabel("PARAMETRIC ROOM GENERATOR")
        lc_title.setStyleSheet("font-size: 13px; font-weight: bold; color: #00F0FF; letter-spacing: 1px;")
        lc_sub = QLabel("Exact Dimensions (Meters)")
        lc_sub.setStyleSheet("font-size: 11px; color: #64748B;")
        lc_header.addWidget(lc_title)
        lc_header.addStretch()
        lc_header.addWidget(lc_sub)
        lc_layout.addLayout(lc_header)

        # Preset Chips
        preset_layout = QHBoxLayout()
        preset_layout.addWidget(QLabel("Presets:"))
        for name, w, d, h, t in [("Studio 6×5m", 6.0, 5.0, 3.0, 0.20), ("Office 8×6m", 8.0, 6.0, 3.2, 0.25), ("Hall 12×8m", 12.0, 8.0, 4.0, 0.30)]:
            btn = QPushButton(name)
            btn.setProperty("class", "secondary-btn")
            btn.setCursor(Qt.PointingHandCursor)
            btn.clicked.connect(lambda _, w=w, d=d, h=h, t=t: self.set_room_values(w, d, h, t))
            preset_layout.addWidget(btn)
        preset_layout.addStretch()
        lc_layout.addLayout(preset_layout)

        # Sliders + SpinBoxes
        self.spin_w, self.slider_w = self.create_dim_control("Room Width:", 2.0, 25.0, 6.0, "m")
        self.spin_d, self.slider_d = self.create_dim_control("Room Depth / Length:", 2.0, 25.0, 5.0, "m")
        self.spin_h, self.slider_h = self.create_dim_control("Ceiling Height:", 2.0, 10.0, 3.0, "m")
        self.spin_t, self.slider_t = self.create_dim_control("Wall Thickness:", 0.10, 0.60, 0.20, "m", step=0.05)

        lc_layout.addLayout(self.spin_w.parentLayout)
        lc_layout.addLayout(self.spin_d.parentLayout)
        lc_layout.addLayout(self.spin_h.parentLayout)
        lc_layout.addLayout(self.spin_t.parentLayout)
        lc_layout.addStretch()

        btn_gen_room = QPushButton("⚡ GENERATE 3D ROOM IN SKETCHUP")
        btn_gen_room.setProperty("class", "primary-btn")
        btn_gen_room.setFixedHeight(44)
        btn_gen_room.setCursor(Qt.PointingHandCursor)
        btn_gen_room.clicked.connect(lambda: self.backend.createRoom(
            self.spin_w.value(), self.spin_d.value(), self.spin_h.value(), self.spin_t.value()
        ))
        lc_layout.addWidget(btn_gen_room)

        layout.addWidget(left_card, 60)

        # Right Panel: Solids & Primitives
        right_card = QFrame()
        right_card.setProperty("class", "card")
        rc_layout = QVBoxLayout(right_card)
        rc_layout.setContentsMargins(20, 20, 20, 20)
        rc_layout.setSpacing(14)

        rc_title = QLabel("SOLIDS & PRIMITIVES")
        rc_title.setStyleSheet("font-size: 13px; font-weight: bold; color: #9D4EDD; letter-spacing: 1px;")
        rc_layout.addWidget(rc_title)

        # Box controls
        rc_layout.addWidget(QLabel("Solid Box Extrusion"))
        box_grid = QGridLayout()
        self.box_w = QDoubleSpinBox(); self.box_w.setValue(4.0); self.box_w.setSuffix(" m")
        self.box_d = QDoubleSpinBox(); self.box_d.setValue(4.0); self.box_d.setSuffix(" m")
        self.box_h = QDoubleSpinBox(); self.box_h.setValue(3.0); self.box_h.setSuffix(" m")
        box_grid.addWidget(QLabel("W:"), 0, 0); box_grid.addWidget(self.box_w, 0, 1)
        box_grid.addWidget(QLabel("D:"), 0, 2); box_grid.addWidget(self.box_d, 0, 3)
        box_grid.addWidget(QLabel("H:"), 0, 4); box_grid.addWidget(self.box_h, 0, 5)
        rc_layout.addLayout(box_grid)

        btn_box = QPushButton("+ Create Solid Box")
        btn_box.setProperty("class", "secondary-btn")
        btn_box.setCursor(Qt.PointingHandCursor)
        btn_box.clicked.connect(lambda: self.backend.createBox(self.box_w.value(), self.box_d.value(), self.box_h.value()))
        rc_layout.addWidget(btn_box)

        # Cylinder controls
        rc_layout.addWidget(QLabel("Architectural Column"))
        cyl_grid = QGridLayout()
        self.cyl_r = QDoubleSpinBox(); self.cyl_r.setValue(1.0); self.cyl_r.setSuffix(" m")
        self.cyl_h = QDoubleSpinBox(); self.cyl_h.setValue(4.0); self.cyl_h.setSuffix(" m")
        cyl_grid.addWidget(QLabel("Radius:"), 0, 0); cyl_grid.addWidget(self.cyl_r, 0, 1)
        cyl_grid.addWidget(QLabel("Height:"), 0, 2); cyl_grid.addWidget(self.cyl_h, 0, 3)
        rc_layout.addLayout(cyl_grid)

        btn_cyl = QPushButton("+ Create Column")
        btn_cyl.setProperty("class", "secondary-btn")
        btn_cyl.setCursor(Qt.PointingHandCursor)
        btn_cyl.clicked.connect(lambda: self.backend.createCylinder(self.cyl_r.value(), self.cyl_h.value(), 24))
        rc_layout.addWidget(btn_cyl)

        rc_layout.addStretch()

        btn_clear = QPushButton("🗑 Clear Active Entities")
        btn_clear.setProperty("class", "danger-btn")
        btn_clear.setCursor(Qt.PointingHandCursor)
        btn_clear.clicked.connect(self.backend.clearModel)
        rc_layout.addWidget(btn_clear)

        layout.addWidget(right_card, 40)
        return tab

    def set_room_values(self, w, d, h, t):
        self.spin_w.setValue(w)
        self.spin_d.setValue(d)
        self.spin_h.setValue(h)
        self.spin_t.setValue(t)

    def create_dim_control(self, title, min_v, max_v, default_v, unit, step=0.1):
        layout = QVBoxLayout()
        layout.setSpacing(4)

        row = QHBoxLayout()
        lbl = QLabel(title)
        lbl.setStyleSheet("font-size: 11px; color: #CBD5E1;")

        spin = QDoubleSpinBox()
        spin.setRange(min_v, max_v)
        spin.setSingleStep(step)
        spin.setValue(default_v)
        spin.setSuffix(f" {unit}")
        spin.setFixedWidth(90)

        row.addWidget(lbl)
        row.addStretch()
        row.addWidget(spin)
        layout.addLayout(row)

        slider = QSlider(Qt.Horizontal)
        slider.setRange(int(min_v * 10), int(max_v * 10))
        slider.setValue(int(default_v * 10))
        layout.addWidget(slider)

        # Synchronize
        spin.valueChanged.connect(lambda val: slider.setValue(int(val * 10)))
        slider.valueChanged.connect(lambda val: spin.setValue(val / 10.0))

        spin.parentLayout = layout
        return spin, slider

    # =========================================================================
    # TAB 2: CAMERA VIEWS
    # =========================================================================
    def build_tab_camera(self):
        tab = QWidget()
        layout = QVBoxLayout(tab)
        layout.setContentsMargins(24, 24, 24, 24)
        layout.setSpacing(18)

        card = QFrame()
        card.setProperty("class", "card")
        c_layout = QVBoxLayout(card)
        c_layout.setContentsMargins(24, 24, 24, 24)
        c_layout.setSpacing(18)

        title = QLabel("VIEWPORT CAMERA CONTROLS")
        title.setStyleSheet("font-size: 14px; font-weight: bold; color: #00F0FF; letter-spacing: 1px;")
        desc = QLabel("Instantly reorient the SketchUp 3D camera and fit scene extents.")
        desc.setStyleSheet("font-size: 12px; color: #94A3B8;")
        c_layout.addWidget(title)
        c_layout.addWidget(desc)

        grid = QGridLayout()
        grid.setSpacing(16)

        views = [
            ("Isometric (3D)", "Standard perspective angle", "iso", "🧊", 0, 0),
            ("Top View (Floor Plan)", "Orthographic architectural 2D plan", "top", "📐", 0, 1),
            ("Front Elevation", "Facade orientation", "front", "🏢", 1, 0),
            ("Right Elevation", "Side facade view", "right", "➡️", 1, 1),
            ("Left Elevation", "Opposite side facade", "left", "⬅️", 2, 0)
        ]

        for v_name, v_desc, key, icon, r, c in views:
            btn = QPushButton(f"{icon}  {v_name}\n    {v_desc}")
            btn.setFixedHeight(64)
            btn.setCursor(Qt.PointingHandCursor)
            btn.setStyleSheet("""
                QPushButton {
                    background-color: rgba(255, 255, 255, 0.05);
                    border: 1px solid #1E293B;
                    border-radius: 12px;
                    color: #FFFFFF;
                    font-size: 12px;
                    font-weight: bold;
                    text-align: left;
                    padding-left: 18px;
                }
                QPushButton:hover {
                    background-color: rgba(0, 240, 255, 0.12);
                    border-color: #00F0FF;
                    color: #00F0FF;
                }
            """)
            btn.clicked.connect(lambda _, k=key: self.backend.setCamera(k))
            grid.addWidget(btn, r, c)

        c_layout.addLayout(grid)
        c_layout.addStretch()

        layout.addWidget(card)
        return tab

    # =========================================================================
    # TAB 3: EXPORT STUDIO
    # =========================================================================
    def build_tab_export(self):
        tab = QWidget()
        layout = QVBoxLayout(tab)
        layout.setContentsMargins(24, 24, 24, 24)
        layout.setSpacing(18)

        card = QFrame()
        card.setProperty("class", "card")
        c_layout = QVBoxLayout(card)
        c_layout.setContentsMargins(24, 24, 24, 24)
        c_layout.setSpacing(18)

        title = QLabel("EXPORT STUDIO & RENDER PIPELINE")
        title.setStyleSheet("font-size: 14px; font-weight: bold; color: #00F0FF; letter-spacing: 1px;")
        desc = QLabel("Export the active SketchUp model to 3D geometry or instant 4K PNG renders.")
        desc.setStyleSheet("font-size: 12px; color: #94A3B8;")
        c_layout.addWidget(title)
        c_layout.addWidget(desc)

        # Format selector buttons
        c_layout.addWidget(QLabel("Select Output Format:"))
        fmt_layout = QHBoxLayout()
        self.selected_format = "obj"
        self.fmt_buttons = {}

        formats = [
            ("obj", "OBJ (Wavefront)", "Standard 3D mesh"),
            ("stl", "STL (3D Print)", "Additive manufacturing"),
            ("dae", "DAE (Collada)", "Blender & Game engines"),
            ("png", "PNG (Viewport Render)", "4K Instant image")
        ]

        for fmt_id, fmt_name, fmt_desc in formats:
            btn = QPushButton(f"{fmt_name}\n{fmt_desc}")
            btn.setFixedHeight(56)
            btn.setCursor(Qt.PointingHandCursor)
            btn.clicked.connect(lambda _, f=fmt_id: self.set_export_format(f))
            fmt_layout.addWidget(btn)
            self.fmt_buttons[fmt_id] = btn

        c_layout.addLayout(fmt_layout)
        self.update_format_buttons()

        # Destination Path
        c_layout.addWidget(QLabel("Custom File Path (Blank defaults to ~/Desktop):"))
        path_layout = QHBoxLayout()
        self.export_path_input = QLineEdit()
        self.export_path_input.setPlaceholderText("~/Desktop/sketchup_export.obj")
        btn_browse = QPushButton("Browse...")
        btn_browse.setProperty("class", "secondary-btn")
        btn_browse.clicked.connect(self.browse_export_path)
        path_layout.addWidget(self.export_path_input)
        path_layout.addWidget(btn_browse)
        c_layout.addLayout(path_layout)

        c_layout.addStretch()

        btn_export = QPushButton("💾 ONE-CLICK EXPORT TO DISK")
        btn_export.setProperty("class", "primary-btn")
        btn_export.setFixedHeight(46)
        btn_export.setCursor(Qt.PointingHandCursor)
        btn_export.clicked.connect(lambda: self.backend.exportModel(self.selected_format, self.export_path_input.text()))
        c_layout.addWidget(btn_export)

        layout.addWidget(card)
        return tab

    def set_export_format(self, fmt):
        self.selected_format = fmt
        self.update_format_buttons()

    def update_format_buttons(self):
        for fid, btn in self.fmt_buttons.items():
            if fid == self.selected_format:
                btn.setStyleSheet("""
                    QPushButton {
                        background-color: rgba(0, 240, 255, 0.20);
                        border: 2px solid #00F0FF;
                        border-radius: 12px;
                        color: #00F0FF;
                        font-size: 11px;
                        font-weight: bold;
                    }
                """)
            else:
                btn.setStyleSheet("""
                    QPushButton {
                        background-color: rgba(255, 255, 255, 0.05);
                        border: 1px solid #1E293B;
                        border-radius: 12px;
                        color: #E2E8F0;
                        font-size: 11px;
                    }
                    QPushButton:hover {
                        background-color: rgba(255, 255, 255, 0.10);
                    }
                """)

    def browse_export_path(self):
        ext = self.selected_format
        path, _ = QFileDialog.getSaveFileName(self, "Export Model", os.path.expanduser(f"~/Desktop/model.{ext}"), f"{ext.upper()} Files (*.{ext})")
        if path:
            self.export_path_input.setText(path)

    # =========================================================================
    # TAB 4: MODEL TELEMETRY
    # =========================================================================
    def build_tab_telemetry(self):
        tab = QWidget()
        layout = QVBoxLayout(tab)
        layout.setContentsMargins(24, 24, 24, 24)
        layout.setSpacing(18)

        card = QFrame()
        card.setProperty("class", "card")
        c_layout = QVBoxLayout(card)
        c_layout.setContentsMargins(24, 24, 24, 24)
        c_layout.setSpacing(18)

        title = QLabel("ACTIVE MODEL TELEMETRY")
        title.setStyleSheet("font-size: 14px; font-weight: bold; color: #00F0FF; letter-spacing: 1px;")
        desc = QLabel("Real-time architectural statistics fetched directly from SketchUp's memory.")
        desc.setStyleSheet("font-size: 12px; color: #94A3B8;")
        c_layout.addWidget(title)
        c_layout.addWidget(desc)

        grid = QGridLayout()
        grid.setSpacing(16)

        self.lbl_stat_dim = QLabel("—")
        self.lbl_stat_faces = QLabel("0")
        self.lbl_stat_edges = QLabel("0")
        self.lbl_stat_groups = QLabel("0")

        stats = [
            ("Bounding Dimensions", self.lbl_stat_dim, "📐", 0, 0),
            ("Faces / Surfaces", self.lbl_stat_faces, "🔷", 0, 1),
            ("Edges / Wireframe", self.lbl_stat_edges, "📏", 1, 0),
            ("Groups & Components", self.lbl_stat_groups, "📦", 1, 1)
        ]

        for s_title, val_lbl, icon, r, c in stats:
            box = QFrame()
            box.setStyleSheet("background-color: rgba(255, 255, 255, 0.04); border: 1px solid #1E293B; border-radius: 12px; padding: 14px;")
            b_layout = QHBoxLayout(box)
            b_layout.setSpacing(14)

            i_lbl = QLabel(icon)
            i_lbl.setStyleSheet("font-size: 28px;")
            b_layout.addWidget(i_lbl)

            col = QVBoxLayout()
            col.setSpacing(2)
            t_lbl = QLabel(s_title)
            t_lbl.setStyleSheet("font-size: 11px; color: #94A3B8;")
            val_lbl.setStyleSheet("font-size: 18px; font-weight: bold; color: #00F0FF;")
            col.addWidget(t_lbl)
            col.addWidget(val_lbl)
            b_layout.addLayout(col)

            grid.addWidget(box, r, c)

        c_layout.addLayout(grid)
        c_layout.addStretch()

        layout.addWidget(card)
        return tab

    # =========================================================================
    # TAB 5: RUBY CONSOLE
    # =========================================================================
    def build_tab_ruby(self):
        tab = QWidget()
        layout = QVBoxLayout(tab)
        layout.setContentsMargins(24, 24, 24, 24)
        layout.setSpacing(18)

        card = QFrame()
        card.setProperty("class", "card")
        c_layout = QVBoxLayout(card)
        c_layout.setContentsMargins(24, 24, 24, 24)
        c_layout.setSpacing(14)

        title = QLabel("SKETCHUP RUBY SCRIPT EXECUTOR")
        title.setStyleSheet("font-size: 14px; font-weight: bold; color: #9D4EDD; letter-spacing: 1px;")
        desc = QLabel("Execute arbitrary procedural Ruby scripts on SketchUp's main thread with undo tracking.")
        desc.setStyleSheet("font-size: 12px; color: #94A3B8;")
        c_layout.addWidget(title)
        c_layout.addWidget(desc)

        self.ruby_code = QPlainTextEdit()
        self.ruby_code.setStyleSheet("""
            QPlainTextEdit {
                background-color: #05070B;
                border: 1px solid #1E293B;
                border-radius: 10px;
                color: #A0F0FF;
                font-family: Menlo, Monaco, Consolas, "Courier New", monospace;
                font-size: 12px;
                padding: 12px;
            }
        """)
        self.ruby_code.setPlainText(
            "# Example: Procedural grid of 10 cubes\n"
            "10.times do |i|\n"
            "  face = Sketchup.active_model.active_entities.add_face([\n"
            "    [i.m, 0, 0], [(i+0.8).m, 0, 0], [(i+0.8).m, 0.8.m, 0], [i.m, 0.8.m, 0]\n"
            "  ])\n"
            "  face.pushpull(-((i+1)*0.4).m)\n"
            "end"
        )
        c_layout.addWidget(self.ruby_code)

        btn_run_ruby = QPushButton("▶ Execute Ruby in SketchUp")
        btn_run_ruby.setFixedHeight(42)
        btn_run_ruby.setCursor(Qt.PointingHandCursor)
        btn_run_ruby.setStyleSheet("""
            QPushButton {
                background: qlineargradient(x1:0, y1:0, x2:1, y2:0, stop:0 #9D4EDD, stop:1 #4A00E0);
                border: none;
                border-radius: 10px;
                color: #FFFFFF;
                font-size: 12px;
                font-weight: bold;
            }
            QPushButton:hover {
                background: qlineargradient(x1:0, y1:0, x2:1, y2:0, stop:0 #B266EF, stop:1 #7928CA);
            }
        """)
        btn_run_ruby.clicked.connect(lambda: self.backend.evalRuby(self.ruby_code.toPlainText()))
        c_layout.addWidget(btn_run_ruby)

        layout.addWidget(card)
        return tab
