import sys
import os
import json
import threading
import httpx
from PySide6.QtCore import QObject, Signal, Slot, Property, QTimer

BRIDGE_URL = "http://127.0.0.1:9876"

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

    @Slot(str, str)
    def insertModel(self, file_path, params_json):
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

    @Slot(result=str)
    def getLibraryCategories(self):
        """
        Dynamically scans /models/ directory and discovers category folders.
        Returns a JSON list of categories with counts and icon keys.
        """
        models_dir = self.get_models_dir()
        exts_3d = (".skp", ".obj", ".dae", ".stl", ".3ds", ".dwg", ".dxf", ".ifc")

        # Discover top-level directories under models/
        subdirs = []
        if os.path.exists(models_dir):
            for entry in sorted(os.listdir(models_dir)):
                full_sub = os.path.join(models_dir, entry)
                if os.path.isdir(full_sub) and not entry.startswith("."):
                    subdirs.append(entry)

        # Count models per category
        cat_counts = {d.lower().replace(" ", "_"): 0 for d in subdirs}
        cat_names_map = {d.lower().replace(" ", "_"): d.replace("_", " ").title() for d in subdirs}
        total_models = 0

        if os.path.exists(models_dir):
            for root_dir, _, files in os.walk(models_dir):
                for f in files:
                    ext = os.path.splitext(f)[1].lower()
                    if ext in exts_3d:
                        total_models += 1
                        rel = os.path.relpath(os.path.join(root_dir, f), models_dir)
                        parts = rel.split(os.sep)
                        if len(parts) > 1:
                            cid = parts[0].lower().replace(" ", "_")
                            cat_counts[cid] = cat_counts.get(cid, 0) + 1
                            if cid not in cat_names_map:
                                cat_names_map[cid] = parts[0].replace("_", " ").title()
                        else:
                            cat_counts["general"] = cat_counts.get("general", 0) + 1
                            cat_names_map["general"] = "General"

        categories = [
            {
                "id": "all",
                "name": "All 3D Models",
                "count": total_models,
                "iconKey": "cubes"
            }
        ]

        for cid, display_name in sorted(cat_names_map.items(), key=lambda x: x[1]):
            categories.append({
                "id": cid,
                "name": display_name,
                "count": cat_counts.get(cid, 0),
                "iconKey": self._get_category_icon_key(display_name)
            })

        return json.dumps(categories)

    @Slot(result=str)
    def getLibraryAssets(self):
        """
        Recursively scans /models/<category>/** for 3D files and matching preview images.
        """
        assets = []
        seen_paths = set()
        seen_names = set()

        models_dir = self.get_models_dir()
        if not os.path.exists(models_dir):
            return json.dumps([])

        exts_3d = (".skp", ".obj", ".dae", ".stl", ".3ds", ".dwg", ".dxf", ".ifc")
        img_exts = (".png", ".jpg", ".jpeg", ".webp", ".bmp")

        for root_dir, _, files in os.walk(models_dir):
            for f in sorted(files):
                ext = os.path.splitext(f)[1].lower()
                if ext in exts_3d:
                    full_path = os.path.abspath(os.path.join(root_dir, f))
                    real_p = os.path.realpath(full_path)
                    if real_p in seen_paths or f in seen_names:
                        continue
                    seen_paths.add(real_p)
                    seen_names.add(f)

                    # Dynamic category from top-level folder inside models/
                    rel = os.path.relpath(full_path, models_dir)
                    parts = rel.split(os.sep)
                    if len(parts) > 1:
                        cat_folder = parts[0]
                    else:
                        cat_folder = "General"

                    cat_id = cat_folder.lower().replace(" ", "_")
                    cat_name = cat_folder.replace("_", " ").title()

                    # Dynamic search for matching companion image in the same directory
                    base_name = os.path.splitext(f)[0]
                    matched_img = None
                    for iext in img_exts:
                        cand = os.path.join(root_dir, base_name + iext)
                        if os.path.exists(cand) and os.path.getsize(cand) > 0:
                            matched_img = os.path.abspath(cand)
                            break
                        cand_upper = os.path.join(root_dir, base_name + iext.upper())
                        if os.path.exists(cand_upper) and os.path.getsize(cand_upper) > 0:
                            matched_img = os.path.abspath(cand_upper)
                            break
                        cand_preview = os.path.join(root_dir, f"{base_name}_preview{iext}")
                        if os.path.exists(cand_preview) and os.path.getsize(cand_preview) > 0:
                            matched_img = os.path.abspath(cand_preview)
                            break
                        cand_skp = os.path.join(root_dir, f"{f}{iext}")
                        if os.path.exists(cand_skp) and os.path.getsize(cand_skp) > 0:
                            matched_img = os.path.abspath(cand_skp)
                            break

                    assets.append(self._process_3d_file(
                        full_path,
                        cat=cat_id,
                        cat_name=cat_name,
                        override_thumb=matched_img
                    ))

        return json.dumps(assets)

    def _process_3d_file(self, file_path, cat=None, cat_name=None, override_thumb=None):
        import zipfile
        base_name = os.path.splitext(os.path.basename(file_path))[0]
        ext = os.path.splitext(file_path)[1].lower()
        size_bytes = os.path.getsize(file_path) if os.path.exists(file_path) else 0
        if size_bytes > 1024 * 1024:
            size_str = f"{size_bytes / (1024 * 1024):.1f} MB"
        else:
            size_str = f"{size_bytes / 1024:.0f} KB"

        thumb_path = override_thumb
        if not thumb_path or not os.path.exists(thumb_path):
            thumb_dir = os.path.join(os.path.dirname(os.path.abspath(__file__)), "assets", "thumbnails")
            os.makedirs(thumb_dir, exist_ok=True)
            cached_thumb = os.path.join(thumb_dir, f"{base_name}.png")
            if ext == ".skp" and not (os.path.exists(cached_thumb) and os.path.getsize(cached_thumb) > 0):
                try:
                    with zipfile.ZipFile(file_path, "r") as z:
                        for n in z.namelist():
                            if "thumbnail" in n.lower() and n.endswith(".png"):
                                with open(cached_thumb, "wb") as f_out:
                                    f_out.write(z.read(n))
                                break
                except Exception:
                    pass
            if os.path.exists(cached_thumb) and os.path.getsize(cached_thumb) > 0:
                thumb_path = cached_thumb

        has_thumb = thumb_path and os.path.exists(thumb_path) and os.path.getsize(thumb_path) > 0
        friendly_title = base_name.replace("_", " ").replace("-", " ").title()

        return {
            "id": f"comp_{base_name}",
            "name": friendly_title,
            "filename": os.path.basename(file_path),
            "path": os.path.abspath(file_path),
            "ext": ext.replace(".", "").upper(),
            "size": size_str,
            "category": cat or "imported",
            "category_name": cat_name or (cat.title() if cat else "Imported"),
            "desc": f"Native {ext.upper()} model in /models/{cat_name or ''} ready to inspect and insert.",
            "thumbnail": os.path.abspath(thumb_path) if has_thumb else "",
            "params": [
                {"key": "scale", "name": "Uniform Scale", "val": 1.0, "min": 0.1, "max": 5.0, "step": 0.05, "unit": "x"},
                {"key": "rot_z", "name": "Rotation (Yaw)", "val": 0, "min": 0, "max": 360, "step": 15, "unit": "deg"},
                {"key": "pos_x", "name": "Position X", "val": 0.0, "min": -25.0, "max": 25.0, "step": 0.25, "unit": "m"},
                {"key": "pos_y", "name": "Position Y", "val": 0.0, "min": -25.0, "max": 25.0, "step": 0.25, "unit": "m"},
                {"key": "pos_z", "name": "Elevation Z", "val": 0.0, "min": 0.0, "max": 25.0, "step": 0.10, "unit": "m"},
            ]
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
