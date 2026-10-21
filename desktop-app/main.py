import os
import sys
import traceback
from PySide6.QtWidgets import QApplication
from PySide6.QtGui import QIcon, QFontDatabase
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtCore import QUrl
from backend import Backend

def resolve_path(relative_path):
    candidates = [
        os.path.join(os.path.dirname(os.path.abspath(__file__)), relative_path),
        os.path.join(os.getcwd(), relative_path),
        os.path.join(os.getcwd(), "desktop-app", relative_path),
    ]
    if hasattr(sys, "_MEIPASS"):
        candidates.insert(0, os.path.join(sys._MEIPASS, relative_path))
        candidates.insert(1, os.path.join(sys._MEIPASS, "desktop-app", relative_path))

    for path in candidates:
        if os.path.exists(path):
            return os.path.abspath(path)
    return os.path.abspath(candidates[0])

def log_fatal_error(err_str):
    print(err_str, file=sys.stderr)
    try:
        log_dir = os.path.expanduser("~")
        log_file = os.path.join(log_dir, "LiquidCAD_crash.log")
        with open(log_file, "a", encoding="utf-8") as f:
            f.write(err_str + "\n\n")
    except Exception:
        pass

    if sys.platform == "win32":
        try:
            import ctypes
            ctypes.windll.user32.MessageBoxW(
                0,
                f"Liquid CAD Studio encountered an error during startup:\n\n{err_str[:400]}\n\nSee ~/LiquidCAD_crash.log for details.",
                "Liquid CAD Studio — Startup Error",
                0x10
            )
        except Exception:
            pass

def main():
    try:
        os.environ["QT_QUICK_CONTROLS_STYLE"] = "Basic"

        app = QApplication(sys.argv)
        app.setApplicationName("Liquid CAD Studio")
        app.setOrganizationName("Antigravity")

        icon_path = resolve_path(os.path.join("assets", "taskbar_icon.png"))
        if os.path.exists(icon_path):
            app.setWindowIcon(QIcon(icon_path))

        # Register FontAwesome Fonts
        solid_font_path = resolve_path(os.path.join("assets", "fonts", "fa-solid-900.ttf"))
        if os.path.exists(solid_font_path):
            QFontDatabase.addApplicationFont(solid_font_path)

        brands_font_path = resolve_path(os.path.join("assets", "fonts", "fa-brands-400.ttf"))
        if os.path.exists(brands_font_path):
            QFontDatabase.addApplicationFont(brands_font_path)

        engine = QQmlApplicationEngine()

        backend = Backend()
        engine.rootContext().setContextProperty("backend", backend)

        qml_file = resolve_path("main.qml")
        engine.warnings.connect(lambda ws: [print("[QML Warning]", w.toString()) for w in ws])
        engine.load(QUrl.fromLocalFile(qml_file))

        if not engine.rootObjects():
            err_msg = f"Error: Could not load QML from {qml_file}"
            log_fatal_error(err_msg)
            sys.exit(-1)

        sys.exit(app.exec())

    except Exception:
        err = traceback.format_exc()
        log_fatal_error(err)
        sys.exit(1)

if __name__ == "__main__":
    main()
