import sys
import os
import json
import hashlib
import threading
import httpx
from pathlib import Path
from PySide6.QtCore import QObject, Signal, Slot, Property, QTimer

BRIDGE_URL = "http://127.0.0.1:9876"

EXTS_3D = (".skp", ".obj", ".dae", ".stl", ".3ds", ".dwg", ".dxf", ".ifc")
IMG_EXTS = (".png", ".jpg", ".jpeg", ".webp", ".bmp")

# Auto-rendering a very large .skp can exhaust SketchUp's memory because the
# whole definition is loaded. Files above this size keep a placeholder until
# the user explicitly asks for a preview.
MAX_AUTO_PREVIEW_BYTES = 350 * 1024 * 1024


def to_file_url(path):
    """Return a platform-correct, percent-encoded file:// URL for QML Image sources."""
    if not path:
        return ""
    try:
        return Path(os.path.abspath(path)).as_uri()
    except (ValueError, OSError):
        return ""


class Backend(QObject):
    connectionChanged = Signal(bool)
    statusUpdated = Signal()
    actionFinished = Signal(str, bool)
    assetImported = Signal(str)
    libraryReloaded = Signal()

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

        # Library cache is invalidated when /models/ changes on disk.
        self._library_cache = None
        self._library_signature = None
        self.library_timer = QTimer(self)
        self.library_timer.timeout.connect(self.check_library_changes)
        self.library_timer.start(4000)

        # Previews generated from real .skp geometry (only when the file has
        # no embedded model thumbnail). These run in the background because
        # opening a large .skp inside SketchUp can take a while.
        self._preview_lock = threading.Lock()
        self._preview_pending = set()
        self._preview_failed = set()
        self._preview_worker_running = False

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
        if state_changed and is_connected:
            # A new connection may be able to render previews that failed
            # while the bridge was offline.
            with self._preview_lock:
                self._preview_failed.clear()

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

    @Slot(str, str)
    def insertModel(self, file_path, params_json):
        if not file_path or not os.path.isfile(file_path):
            self.actionFinished.emit("No 3D model file found in this folder", False)
            return
        try:
            params = json.loads(params_json) if isinstance(params_json, str) else params_json
        except Exception:
            params = {}
        payload = {"file_path": file_path}
        payload.update(params)
        name = payload.get("name") or os.path.basename(file_path)
        self._send_action(
            "/api/import",
            payload,
            f"Inserted {name}"
        )

    @Slot(result=str)
    def browse3DFile(self):
        from PySide6.QtWidgets import QFileDialog
        filters = (
            "All Supported 3D Formats (*.skp *.obj *.dae *.stl *.3ds *.dwg *.dxf *.ifc);;"
            "SketchUp Component (*.skp);;"
            "Wavefront OBJ (*.obj);;"
            "COLLADA Asset (*.dae);;"
            "Stereolithography (*.stl);;"
            "3D Studio (*.3ds);;"
            "AutoCAD (*.dwg *.dxf);;"
            "IFC BIM (*.ifc);;"
            "All Files (*.*)"
        )
        file_path, _ = QFileDialog.getOpenFileName(
            None,
            "Select 3D Model / Component",
            os.path.expanduser("~/Downloads"),
            filters
        )
        if not file_path:
            return ""

        asset_info = self._process_3d_file(file_path, cat="imported")
        json_str = json.dumps(asset_info)
        self.assetImported.emit(json_str)
        return json_str

    @Slot(str, result=str)
    def importFileFromPath(self, file_path):
        if not file_path or not os.path.exists(file_path):
            return ""
        asset_info = self._process_3d_file(file_path, cat="imported")
        json_str = json.dumps(asset_info)
        self.assetImported.emit(json_str)
        return json_str

    def get_models_dir(self):
        candidates = [
            os.path.join(os.getcwd(), "models"),
            os.path.join(os.path.dirname(os.path.abspath(__file__)), "models"),
            os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "models"),
            "/models",
        ]
        # One-file builds unpack to a temporary directory, so __file__ cannot
        # find a models folder placed next to the executable. Check the real
        # executable location too (and its parent, for a dist/ layout).
        if getattr(sys, "frozen", False):
            exe_dir = os.path.dirname(os.path.abspath(sys.executable))
            candidates.extend([
                os.path.join(exe_dir, "models"),
                os.path.join(exe_dir, "..", "models"),
            ])
        for c in candidates:
            if os.path.exists(c) and os.path.isdir(c):
                return os.path.abspath(c)
        fallback = os.path.join(os.getcwd(), "models")
        os.makedirs(fallback, exist_ok=True)
        return os.path.abspath(fallback)

    def _get_category_icon_key(self, cat_name):
        name_l = cat_name.lower()
        if any(k in name_l for k in ["arch", "build", "house", "villa", "home", "facade", "wall"]):
            return "house"
        elif any(k in name_l for k in ["furn", "interior", "decor", "chair", "table", "desk", "room", "sofa", "bed"]):
            return "boxes"
        elif any(k in name_l for k in ["land", "urban", "park", "garden", "bench", "tree", "plant", "outdoor", "street"]):
            return "building"
        elif any(k in name_l for k in ["struct", "column", "beam", "molding", "profile", "steel", "concrete", "pedestal", "truss"]):
            return "rulerVertical"
        elif any(k in name_l for k in ["vehic", "car", "truck", "bike", "transport"]):
            return "truck"
        elif any(k in name_l for k in ["light", "lamp", "lum"]):
            return "sun"
        elif any(k in name_l for k in ["door", "window", "aperture"]):
            return "doorOpen"
        elif any(k in name_l for k in ["import"]):
            return "folder"
        return "cube"

    @Slot()
    def refreshLibrary(self):
        self.libraryReloaded.emit()

    @Slot()
    def openModelsFolder(self):
        models_dir = self.get_models_dir()
        os.makedirs(models_dir, exist_ok=True)
        try:
            if sys.platform == "darwin":
                import subprocess
                subprocess.Popen(["open", models_dir])
            elif sys.platform == "win32":
                os.startfile(models_dir)
            else:
                import subprocess
                subprocess.Popen(["xdg-open", models_dir])
        except Exception as e:
            print("Error opening models folder:", e)

    # --- Library scanning helpers ---

    def _read_meta(self, folder):
        try:
            for name in os.listdir(folder):
                if name.lower() != "meta.json":
                    continue
                with open(os.path.join(folder, name), "r", encoding="utf-8") as f:
                    data = json.load(f)
                return data if isinstance(data, dict) else {}
        except (OSError, ValueError):
            pass
        return {}

    @staticmethod
    def _nonempty_file(path):
        try:
            return os.path.isfile(path) and os.path.getsize(path) > 0
        except OSError:
            return False

    @staticmethod
    def _friendly_name(value):
        return value.replace("_", " ").replace("-", " ").strip().title()

    def _list_images(self, folder):
        images = []
        try:
            for name in os.listdir(folder):
                if os.path.splitext(name)[1].lower() in IMG_EXTS:
                    full = os.path.join(folder, name)
                    if self._nonempty_file(full):
                        images.append(full)
        except OSError:
            pass
        return images

    def _find_cover_image(self, unit_dir, model_path, models_dir):
        unit_dir = os.path.abspath(unit_dir)
        dirs = [unit_dir]
        if model_path:
            model_dir = os.path.abspath(os.path.dirname(model_path))
            if model_dir != unit_dir:
                dirs.insert(0, model_dir)

        # 1) Prefer a sidecar image named after the 3D file (old flat layout).
        if model_path:
            base = os.path.splitext(os.path.basename(model_path))[0]
            model_file = os.path.basename(model_path)
            for folder in dirs:
                for iext in IMG_EXTS:
                    for candidate in (
                        base + iext,
                        base + iext.upper(),
                        base + "_preview" + iext,
                        base + "_preview" + iext.upper(),
                        model_file + iext,
                        model_file + iext.upper(),
                    ):
                        full = os.path.join(folder, candidate)
                        if self._nonempty_file(full):
                            return os.path.abspath(full)

        # 2) Generic cover images (new nested layout: <model>/image_1.png).
        rel = os.path.relpath(unit_dir, models_dir)
        parts = [] if rel == "." else rel.split(os.sep)
        # A top-level category folder can contain many sidecars; never pick one
        # of those as the cover for an unrelated model without a sidecar.
        if model_path and len(parts) <= 1:
            return None

        images = []
        for folder in dirs:
            images.extend(self._list_images(folder))

        def rank(path):
            name = os.path.basename(path).lower()
            if name.startswith("image_1"):
                return 0
            if "cover" in name:
                return 1
            if "preview" in name:
                return 2
            if "thumb" in name:
                return 3
            if name.startswith("image_"):
                return 4
            return 5

        images.sort(key=lambda p: (rank(p), p.lower()))
        return os.path.abspath(images[0]) if images else None

    def _resolve_unit_dir(self, file_dir, models_dir, filename):
        """Find the folder representing one model (old flat + new nested layouts)."""
        base = os.path.splitext(filename)[0]
        models_abs = os.path.abspath(models_dir)
        cur = os.path.abspath(file_dir)

        while True:
            for iext in IMG_EXTS:
                for candidate in (
                    base + iext,
                    base + iext.upper(),
                    base + "_preview" + iext,
                    base + "_preview" + iext.upper(),
                ):
                    if self._nonempty_file(os.path.join(cur, candidate)):
                        return cur, self._read_meta(cur)

            meta = self._read_meta(cur)
            if meta:
                return cur, meta

            # In the nested layout the .skp sits in "<unit>/model/" next to
            # dozens of texture images. Those textures are not the article
            # cover, so climb to the parent unit folder instead.
            if os.path.basename(cur).lower() != "model" and self._list_images(cur):
                return cur, {}

            if cur == models_abs:
                break
            parent = os.path.dirname(cur)
            if parent == cur:
                break
            cur = parent

        return os.path.abspath(file_dir), self._read_meta(file_dir)

    def _extract_skp_thumbnail(self, file_path):
        """Extract the real preview embedded in a .skp into the app cache.

        Never writes inside /models/. The cache key includes the file's
        mtime/size so an edited .skp cannot serve a stale preview.
        """
        import zipfile
        if os.path.splitext(file_path)[1].lower() != ".skp":
            return None
        try:
            st = os.stat(file_path)
            key_src = f"{os.path.abspath(file_path)}|{st.st_mtime_ns}|{st.st_size}"
            key = hashlib.md5(key_src.encode("utf-8")).hexdigest()[:16]
        except OSError:
            return None

        thumb_dir = os.path.join(os.path.dirname(os.path.abspath(__file__)), "assets", "thumbnails")
        os.makedirs(thumb_dir, exist_ok=True)
        cached = os.path.join(thumb_dir, f"skp_v2_{key}.png")
        if self._nonempty_file(cached):
            return cached

        preferred = ("meta/preview_thumbnail.png", "meta/model_thumbnail.png")
        try:
            with zipfile.ZipFile(file_path, "r") as z:
                names = z.namelist()
                normalised = {}
                for name in names:
                    normalised.setdefault(name.replace("\\", "/").lower(), name)

                chosen = next(
                    (normalised[p] for p in preferred if p in normalised),
                    None
                )
                if chosen is None:
                    candidates = [
                        n for n in names
                        if n.lower().endswith(".png")
                        and "thumbnail" in n.lower()
                        # Material swatches are tiny textures, not model previews.
                        and not n.replace("\\", "/").lower().startswith("materials/")
                        # "doc_thumbnail.png" is SketchUp's generic document
                        # icon (usually just the SketchUp logo), not the model.
                        and not n.replace("\\", "/").lower().rsplit("/", 1)[-1].startswith("doc_")
                    ]
                    if candidates:
                        def _rank(n):
                            ln = n.replace("\\", "/").lower()
                            base = ln.rsplit("/", 1)[-1]
                            if ln.startswith("meta/"):
                                return (0, ln)
                            if base.startswith("preview"):
                                return (1, ln)
                            if base.startswith("model"):
                                return (2, ln)
                            return (3, ln)
                        chosen = sorted(candidates, key=_rank)[0]

                if chosen:
                    with open(cached, "wb") as out:
                        out.write(z.read(chosen))
        except Exception:
            return None
        return cached if self._nonempty_file(cached) else None

    def _skp_cache_key(self, file_path):
        """Content-based cache key so previews survive moving/renaming a model.

        Reads the size plus the first and last megabyte, which is enough to
        distinguish real model edits without hashing multi-gigabyte files.
        """
        try:
            st = os.stat(file_path)
            digest = hashlib.md5(str(st.st_size).encode("ascii"))
            chunk = 1024 * 1024
            with open(file_path, "rb") as f:
                digest.update(f.read(chunk))
                if st.st_size > chunk * 2:
                    f.seek(-chunk, os.SEEK_END)
                    digest.update(f.read(chunk))
            return digest.hexdigest()[:16]
        except OSError:
            return None

    def _generated_skp_preview(self, file_path):
        """Return a previously generated geometry preview, if it still matches."""
        key = self._skp_cache_key(file_path)
        if not key:
            return None
        path = os.path.join(
            os.path.dirname(os.path.abspath(__file__)),
            "assets", "thumbnails", f"skp_gen_{key}.png"
        )
        return path if self._nonempty_file(path) else None

    def _get_skp_preview(self, file_path):
        """Prefer the .skp's own embedded preview, then a generated one."""
        return self._extract_skp_thumbnail(file_path) or self._generated_skp_preview(file_path)

    def _generate_skp_preview(self, file_path):
        """Ask the connected SketchUp bridge to render a real preview image.

        Many older .skp files only store the generic SketchUp logo in
        doc_thumbnail.png. Loading the definition inside a temporary undo
        operation lets SketchUp render the actual geometry without leaving
        anything behind in the user's active model.
        """
        if os.path.splitext(file_path)[1].lower() != ".skp":
            return None
        existing = self._generated_skp_preview(file_path)
        if existing:
            return existing

        key = self._skp_cache_key(file_path)
        if not key:
            return None
        thumb_dir = os.path.join(os.path.dirname(os.path.abspath(__file__)), "assets", "thumbnails")
        os.makedirs(thumb_dir, exist_ok=True)
        final_path = os.path.join(thumb_dir, f"skp_gen_{key}.png")
        temp_path = os.path.join(thumb_dir, f"skp_gen_{key}.tmp.png")

        ruby_file = os.path.abspath(file_path).replace("\\", "/").replace("'", "\\'")
        ruby_out = temp_path.replace("\\", "/").replace("'", "\\'")
        code = f"""
m = Sketchup.active_model
if m
  begin
    m.start_operation('Generate SKP Preview', true)
    d = m.definitions.load('{ruby_file}')
    b = d.bounds
    c = b.center
    diag = b.diagonal.to_f
    diag = 1.0 if diag <= 0
    v = Geom::Vector3d.new(diag, -diag, diag)
    d.thumbnail_camera = Sketchup::Camera.new(c + v, c, Geom::Vector3d.new(0, 0, 1))
    d.refresh_thumbnail
    d.save_thumbnail('{ruby_out}')
    ok = File.exist?('{ruby_out}') && File.size('{ruby_out}') > 1000
    {{ status: ok ? 'success' : 'failed' }}
  rescue => e
    {{ status: 'error', message: e.message }}
  ensure
    m.abort_operation rescue nil
    GC.start rescue nil
  end
else
  {{ status: 'error', message: 'No active model' }}
end
"""
        try:
            with httpx.Client(timeout=600.0) as client:
                res = client.post(f"{BRIDGE_URL}/api/eval", json={"code": code})
                if res.status_code != 200:
                    return None
                data = res.json()
        except Exception:
            return None

        if data.get("status") != "success" or not self._nonempty_file(temp_path):
            return None
        if os.path.getsize(temp_path) <= 1000:
            try:
                os.remove(temp_path)
            except OSError:
                pass
            return None
        try:
            os.replace(temp_path, final_path)
        except OSError:
            return None
        return final_path if self._nonempty_file(final_path) else None

    def _queue_missing_previews(self, assets):
        """Queue real .skp previews for models that have no embedded image."""
        if not self._connected:
            return

        for asset in assets:
            if asset.get("ext") != "SKP" or asset.get("thumbnail"):
                continue
            path = asset.get("path")
            if not path or not os.path.isfile(path):
                continue
            try:
                if os.path.getsize(path) > MAX_AUTO_PREVIEW_BYTES:
                    continue
            except OSError:
                continue
            key = self._skp_cache_key(path)
            if not key:
                continue
            with self._preview_lock:
                if path in self._preview_pending or key in self._preview_failed:
                    continue
                self._preview_pending.add(path)

        with self._preview_lock:
            # Also covers the race where the worker just stopped while a
            # new path was being added to the pending set.
            if self._preview_worker_running or not self._preview_pending:
                return
            self._preview_worker_running = True
        threading.Thread(target=self._preview_worker, daemon=True).start()

    def _preview_worker(self):
        try:
            while True:
                with self._preview_lock:
                    pending = list(self._preview_pending)
                if not pending:
                    break
                for path in pending:
                    key = self._skp_cache_key(path)
                    try:
                        generated = self._generate_skp_preview(path)
                    except Exception:
                        generated = None
                    with self._preview_lock:
                        self._preview_pending.discard(path)
                        if not generated and key:
                            # Do not hammer SketchUp with a file that failed.
                            self._preview_failed.add(key)
                    if generated:
                        self._library_cache = None
                        self.libraryReloaded.emit()
        finally:
            with self._preview_lock:
                self._preview_worker_running = False

    def _compute_library_signature(self):
        models_dir = self.get_models_dir()
        if not os.path.exists(models_dir):
            return ""
        entries = []
        for root_dir, dirs, files in os.walk(models_dir):
            dirs[:] = sorted(d for d in dirs if not d.startswith("."))
            try:
                st = os.stat(root_dir)
                entries.append(f"D|{os.path.relpath(root_dir, models_dir)}|{st.st_mtime_ns}")
            except OSError:
                pass
            for f in sorted(files):
                ext = os.path.splitext(f)[1].lower()
                if ext in EXTS_3D or ext in IMG_EXTS or f.lower() == "meta.json":
                    try:
                        full = os.path.join(root_dir, f)
                        st = os.stat(full)
                        entries.append(f"F|{os.path.relpath(full, models_dir)}|{st.st_mtime_ns}|{st.st_size}")
                    except OSError:
                        pass
        return "|".join(entries)

    def _get_library_assets(self):
        signature = self._compute_library_signature()
        if self._library_cache is None or signature != self._library_signature:
            self._library_cache = self._scan_library()
            self._library_signature = signature
        return self._library_cache

    @Slot()
    def check_library_changes(self):
        signature = self._compute_library_signature()
        if self._library_signature is None:
            self._library_signature = signature
            return
        if signature != self._library_signature:
            # Force the next QML loadAssets() to rebuild from disk.
            self._library_cache = None
            self.libraryReloaded.emit()

        # Fill in previews for .skp files that only contain the generic
        # SketchUp logo. This runs in the background and refreshes as each
        # real preview becomes available.
        try:
            self._queue_missing_previews(self._get_library_assets())
        except Exception:
            pass

    def _scan_library(self):
        models_dir = self.get_models_dir()
        if not os.path.exists(models_dir):
            return []

        assets = []
        seen_models = set()

        # Every real 3D file becomes an insertable asset.
        for root_dir, dirs, files in os.walk(models_dir):
            dirs[:] = sorted(d for d in dirs if not d.startswith("."))
            for f in sorted(files):
                if os.path.splitext(f)[1].lower() not in EXTS_3D:
                    continue
                full_path = os.path.abspath(os.path.join(root_dir, f))
                real_path = os.path.realpath(full_path)
                if real_path in seen_models:
                    continue
                seen_models.add(real_path)

                unit_dir, meta = self._resolve_unit_dir(root_dir, models_dir, f)
                rel_unit = os.path.relpath(unit_dir, models_dir)
                parts = [] if rel_unit == "." else rel_unit.split(os.sep)
                cat_folder = parts[0] if parts else "General"
                cat_id = cat_folder.lower().replace(" ", "_")
                cat_name = (
                    meta.get("subcategory")
                    or meta.get("category")
                    or cat_folder.replace("_", " ").title()
                )

                display_name = meta.get("title")
                if not display_name and os.path.abspath(unit_dir) != os.path.abspath(root_dir):
                    display_name = self._friendly_name(os.path.basename(unit_dir))

                ext = os.path.splitext(full_path)[1].lower()
                if ext == ".skp":
                    # The card and modal must use the .skp's own preview,
                    # never image_1.jpg / article artwork.
                    cover = self._get_skp_preview(full_path)
                else:
                    cover = self._find_cover_image(unit_dir, full_path, models_dir)

                assets.append(self._process_3d_file(
                    full_path,
                    cat=cat_id,
                    cat_name=cat_name,
                    override_thumb=cover,
                    display_name=display_name,
                    unit_dir=unit_dir,
                    meta=meta
                ))

        assets.sort(key=lambda a: (a.get("category_name", "").lower(), a.get("name", "").lower()))
        return assets

    @Slot(result=str)
    def getLibraryCategories(self):
        """Discover categories and counts from the actual library scanner."""
        assets = self._get_library_assets()
        counts = {}
        names = {}
        for asset in assets:
            cid = asset.get("category") or "general"
            counts[cid] = counts.get(cid, 0) + 1
            names.setdefault(cid, set()).add(asset.get("category_name") or cid.replace("_", " ").title())

        categories = [{
            "id": "all",
            "name": "All 3D Models",
            "count": len(assets),
            "iconKey": "cubes"
        }]

        for cid in sorted(counts, key=lambda c: sorted(names.get(c, {c}))[0].lower()):
            label_set = {n for n in names.get(cid, set()) if n}
            display_name = sorted(label_set)[0] if len(label_set) == 1 else cid.replace("_", " ").title()
            categories.append({
                "id": cid,
                "name": display_name,
                "count": counts[cid],
                "iconKey": self._get_category_icon_key(display_name)
            })

        return json.dumps(categories)

    @Slot(result=str)
    def getLibraryAssets(self):
        """Return the cached library scan, refreshed when /models/ changes."""
        return json.dumps(self._get_library_assets())

    def _default_params(self):
        return [
            {"key": "scale", "name": "Uniform Scale", "val": 1.0, "min": 0.1, "max": 5.0, "step": 0.05, "unit": "x"},
            {"key": "rot_z", "name": "Rotation (Yaw)", "val": 0, "min": 0, "max": 360, "step": 15, "unit": "deg"},
            {"key": "pos_x", "name": "Position X", "val": 0.0, "min": -25.0, "max": 25.0, "step": 0.25, "unit": "m"},
            {"key": "pos_y", "name": "Position Y", "val": 0.0, "min": -25.0, "max": 25.0, "step": 0.25, "unit": "m"},
            {"key": "pos_z", "name": "Elevation Z", "val": 0.0, "min": 0.0, "max": 25.0, "step": 0.10, "unit": "m"},
        ]

    def _process_3d_file(self, file_path, cat=None, cat_name=None, override_thumb=None,
                         display_name=None, unit_dir=None, meta=None):
        base_name = os.path.splitext(os.path.basename(file_path))[0]
        ext = os.path.splitext(file_path)[1].lower()
        size_bytes = os.path.getsize(file_path) if os.path.exists(file_path) else 0
        if size_bytes > 1024 * 1024:
            size_str = f"{size_bytes / (1024 * 1024):.1f} MB"
        else:
            size_str = f"{size_bytes / 1024:.0f} KB"

        thumb_path = override_thumb
        if not thumb_path or not os.path.exists(thumb_path):
            thumb_path = self._get_skp_preview(file_path) if ext == ".skp" else None

        has_thumb = thumb_path and os.path.exists(thumb_path) and os.path.getsize(thumb_path) > 0
        friendly_title = display_name or self._friendly_name(base_name)
        meta = meta or {}
        folder = os.path.abspath(unit_dir or os.path.dirname(file_path))
        asset_id = "comp_" + hashlib.md5(os.path.abspath(file_path).encode("utf-8")).hexdigest()[:12]

        return {
            "id": asset_id,
            "name": friendly_title,
            "filename": os.path.basename(file_path),
            "path": os.path.abspath(file_path),
            "folder": folder,
            "ext": ext.replace(".", "").upper(),
            "size": size_str,
            "category": cat or "imported",
            "category_name": cat_name or (meta.get("subcategory") or meta.get("category") or (cat.title() if cat else "Imported")),
            "desc": f"Native {ext.upper()} model ready to inspect and insert.",
            "thumbnail": os.path.abspath(thumb_path) if has_thumb else "",
            "thumbnail_url": to_file_url(thumb_path) if has_thumb else "",
            "has_model": True,
            "params": self._default_params(),
        }

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
