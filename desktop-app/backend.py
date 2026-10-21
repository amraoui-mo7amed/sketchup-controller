import sys
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
    def refresh(self):
        self.poll_status_async()
