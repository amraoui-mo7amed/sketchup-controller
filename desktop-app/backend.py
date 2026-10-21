import sys
import json
import threading
import httpx
from PySide6.QtCore import QObject, Signal, Slot, Property, QTimer

BRIDGE_URL = "http://127.0.0.1:9876"

class Backend(QObject):
    connectionChanged = Signal(bool)
    statusUpdated = Signal()
    actionFinished = Signal(str, bool)

    def __init__(self):
        super().__init__()
        self._connected = False
        self._model_name = "Not Connected"
        self._units = "Meters"
        self._entities_count = 0
        self._faces_count = 0
        self._edges_count = 0
        self._groups_count = 0
        self._components_count = 0
        self._dimensions = "0m × 0m × 0m"
        self._status_text = "Searching for SketchUp 2026..."
        self._last_error = ""

        # Background polling timer (every 1.5 seconds)
        self.poll_timer = QTimer(self)
        self.poll_timer.timeout.connect(self.poll_status_async)
        self.poll_timer.start(1500)

        # Initial check
        self.poll_status_async()

    # --- Properties exposed to QML ---

    @Property(bool, notify=connectionChanged)
    def connected(self):
        return self._connected

    @Property(str, notify=statusUpdated)
    def modelName(self):
        return self._model_name

    @Property(str, notify=statusUpdated)
    def units(self):
        return self._units

    @Property(int, notify=statusUpdated)
    def entitiesCount(self):
        return self._entities_count

    @Property(int, notify=statusUpdated)
    def facesCount(self):
        return self._faces_count

    @Property(int, notify=statusUpdated)
    def edgesCount(self):
        return self._edges_count

    @Property(int, notify=statusUpdated)
    def groupsCount(self):
        return self._groups_count

    @Property(int, notify=statusUpdated)
    def componentsCount(self):
        return self._components_count

    @Property(str, notify=statusUpdated)
    def dimensions(self):
        return self._dimensions

    @Property(str, notify=statusUpdated)
    def statusText(self):
        return self._status_text

    @Property(str, notify=statusUpdated)
    def lastError(self):
        return self._last_error

    # --- Async Polling ---

    def poll_status_async(self):
        threading.Thread(target=self._poll_worker, daemon=True).start()

    def _poll_worker(self):
        try:
            with httpx.Client(timeout=1.0) as client:
                res = client.get(f"{BRIDGE_URL}/api/status")
                if res.status_code == 200:
                    data = res.json()
                    self._update_status(data, True)
                    return
        except Exception:
            pass
        self._update_status(None, False)

    def _update_status(self, data, is_connected):
        state_changed = (self._connected != is_connected)
        self._connected = is_connected

        if is_connected and data:
            self._model_name = data.get("model_name", "Active Model")
            self._units = data.get("units", "Meters")
            counts = data.get("counts", {})
            self._entities_count = counts.get("entities", 0)
            self._faces_count = counts.get("faces", 0)
            self._edges_count = counts.get("edges", 0)
            self._groups_count = counts.get("groups", 0)
            self._components_count = counts.get("components", 0)

            bounds = data.get("bounds", {})
            w = bounds.get("width_m", 0)
            d = bounds.get("depth_m", 0)
            h = bounds.get("height_m", 0)
            self._dimensions = f"{w}m × {d}m × {h}m"
            self._status_text = f"Connected to SketchUp ({data.get('app_version', '')})"
            self._last_error = ""
        else:
            self._model_name = "Not Connected"
            self._status_text = "Bridge Server Offline (Launch SketchUp with plugin)"
            self._dimensions = "—"

        if state_changed:
            self.connectionChanged.emit(self._connected)
        self.statusUpdated.emit()

    # --- Actions (Slots called from QML) ---

    def _send_action(self, endpoint, payload, action_name):
        def worker():
            try:
                with httpx.Client(timeout=5.0) as client:
                    res = client.post(f"{BRIDGE_URL}{endpoint}", json=payload)
                    data = res.json()
                    if data.get("status") == "success":
                        self.actionFinished.emit(f"✓ {action_name} executed successfully", True)
                    else:
                        self.actionFinished.emit(f"Error: {data.get('message', 'Failed')}", False)
                # Refresh status right after
                self._poll_worker()
            except Exception as e:
                self.actionFinished.emit(f"Connection failed: {str(e)}", False)

        threading.Thread(target=worker, daemon=True).start()

    @Slot(float, float, float)
    def createBox(self, w, d, h):
        self._send_action("/api/design/box", {"width": w, "depth": d, "height": h}, f"Box ({w}×{d}×{h}m)")

    @Slot(float, float, float, float)
    def createRoom(self, w, d, h, thickness):
        self._send_action(
            "/api/design/room",
            {"width": w, "depth": d, "height": h, "wall_thickness": thickness, "has_floor": True},
            f"Room ({w}×{d}×{h}m)"
        )

    @Slot(float, float, int)
    def createCylinder(self, r, h, segs):
        self._send_action(
            "/api/design/cylinder",
            {"radius": r, "height": h, "segments": segs},
            f"Column (r={r}m, h={h}m)"
        )

    @Slot(int, float, float, float, str)
    def createStairs(self, steps, width, tread, riser, style):
        self._send_action(
            "/api/design/stairs",
            {
                "steps": steps,
                "width": width,
                "tread": tread,
                "riser": riser,
                "style": style
            },
            f"Stairs ({style.capitalize()}, {steps} steps)"
        )

    @Slot(str, str)
    def createParametricShape(self, shape_id, params_json):
        try:
            params = json.loads(params_json) if isinstance(params_json, str) else params_json
        except Exception:
            params = {}
        friendly_name = shape_id.replace("_", " ").title()
        self._send_action(
            "/api/design/shape",
            {"shape_id": shape_id, "params": params},
            f"Created {friendly_name}"
        )

    @Slot()
    def clearModel(self):
        self._send_action("/api/design/clear", {}, "Clear Entities")

    @Slot(str)
    def setCamera(self, view_name):
        self._send_action("/api/camera", {"view": view_name}, f"Camera {view_name.upper()}")

    @Slot(str, str)
    def exportModel(self, fmt, custom_path):
        payload = {"format": fmt}
        if custom_path and custom_path.strip():
            payload["path"] = custom_path.strip()
        self._send_action("/api/export", payload, f"Export {fmt.upper()}")

    @Slot(str)
    def evalRuby(self, code):
        self._send_action("/api/eval", {"code": code}, "Ruby Script")

    @Slot()
    def autoSetupPlugin(self):
        """
        Automatically detects installed SketchUp versions on macOS and Windows,
        and copies the Ruby extension files directly into the Plugins directory.
        """
        def worker():
            import os
            import shutil

            def safe_remove(p):
                try:
                    if os.path.islink(p) or os.path.isfile(p):
                        os.unlink(p)
                    elif os.path.isdir(p):
                        shutil.rmtree(p)
                except Exception:
                    pass

            def get_source_plugin_dir():
                candidates = [
                    os.path.join(os.path.dirname(os.path.abspath(__file__)), "assets", "sketchup-plugin"),
                    os.path.join(os.getcwd(), "desktop-app", "assets", "sketchup-plugin"),
                    os.path.join(os.getcwd(), "assets", "sketchup-plugin"),
                    os.path.join(os.getcwd(), "sketchup-plugin"),
                    os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "sketchup-plugin"),
                ]
                if hasattr(sys, "_MEIPASS"):
                    candidates.insert(0, os.path.join(sys._MEIPASS, "assets", "sketchup-plugin"))
                    candidates.insert(1, os.path.join(sys._MEIPASS, "desktop-app", "assets", "sketchup-plugin"))

                for c in candidates:
                    if os.path.exists(os.path.join(c, "sketchup_controller.rb")):
                        return os.path.abspath(c)
                return None

            src_dir = get_source_plugin_dir()
            if not src_dir:
                self.actionFinished.emit("Plugin assets not found in app bundle.", False)
                return

            installed_targets = []
            home = os.path.expanduser("~")

            if sys.platform == "darwin":
                base_app_support = os.path.join(home, "Library", "Application Support")
                years = ["2026", "2025", "2024", "2023", "2022", "2021"]
                for yr in years:
                    p_dir = os.path.join(base_app_support, f"SketchUp {yr}", "SketchUp", "Plugins")
                    installed_targets.append((f"SketchUp {yr}", p_dir))
            elif sys.platform == "win32":
                appdata = os.environ.get("APPDATA", os.path.join(home, "AppData", "Roaming"))
                years = ["2026", "2025", "2024", "2023", "2022", "2021"]
                for yr in years:
                    p_dir = os.path.join(appdata, "SketchUp", f"SketchUp {yr}", "SketchUp", "Plugins")
                    installed_targets.append((f"SketchUp {yr}", p_dir))
            else:
                self.actionFinished.emit("Unsupported operating system for auto-setup.", False)
                return

            success_count = 0
            installed_names = []

            for name, target_dir in installed_targets:
                parent_su = os.path.dirname(target_dir)
                if os.path.exists(parent_su) or "2026" in name:
                    try:
                        os.makedirs(target_dir, exist_ok=True)

                        src_rb = os.path.join(src_dir, "sketchup_controller.rb")
                        dst_rb = os.path.join(target_dir, "sketchup_controller.rb")
                        safe_remove(dst_rb)
                        shutil.copy2(src_rb, dst_rb)

                        src_sub = os.path.join(src_dir, "sketchup_controller")
                        dst_sub = os.path.join(target_dir, "sketchup_controller")
                        safe_remove(dst_sub)
                        shutil.copytree(src_sub, dst_sub)

                        success_count += 1
                        installed_names.append(name)
                    except Exception as err:
                        print(f"[AutoSetup] Failed for {name}: {err}", file=sys.stderr)

            if success_count > 0:
                joined = ", ".join(installed_names)
                msg = f"Setup complete for {joined}! Please restart SketchUp."
                self.actionFinished.emit(msg, True)
            else:
                try:
                    name, target_dir = installed_targets[0]
                    os.makedirs(target_dir, exist_ok=True)
                    src_rb = os.path.join(src_dir, "sketchup_controller.rb")
                    dst_rb = os.path.join(target_dir, "sketchup_controller.rb")
                    safe_remove(dst_rb)
                    shutil.copy2(src_rb, dst_rb)

                    dst_sub = os.path.join(target_dir, "sketchup_controller")
                    safe_remove(dst_sub)
                    shutil.copytree(os.path.join(src_dir, "sketchup_controller"), dst_sub)
                    self.actionFinished.emit(f"Setup complete for {name}! Restart SketchUp.", True)
                except Exception as e:
                    self.actionFinished.emit(f"Auto-setup failed: {str(e)}", False)

        threading.Thread(target=worker, daemon=True).start()

    @Slot()
    def refresh(self):
        self.poll_status_async()
