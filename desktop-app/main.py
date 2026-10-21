import os
import sys
import traceback

def resolve_path(relative_path):
    """
    Robust resource path resolver that works in both:
    1. Development mode (source script)
    2. PyInstaller standalone bundle (--onefile and --onedir on Windows/macOS)
    """
    candidates = []

    # PyInstaller temporary extraction directory
    if hasattr(sys, "_MEIPASS"):
        candidates.append(os.path.join(sys._MEIPASS, relative_path))
        candidates.append(os.path.join(sys._MEIPASS, "desktop-app", relative_path))

    # Directory of main.py
    script_dir = os.path.dirname(os.path.abspath(__file__))
    candidates.append(os.path.join(script_dir, relative_path))
    candidates.append(os.path.join(script_dir, "desktop-app", relative_path))

    # Current working directory
    cwd = os.getcwd()
    candidates.append(os.path.join(cwd, relative_path))
    candidates.append(os.path.join(cwd, "desktop-app", relative_path))

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
                0x10 # MB_ICONERROR
            )
        except Exception:
            pass

def main():
    try:
        os.environ["QT_QUICK_CONTROLS_STYLE"] = "Basic"

        # Explicitly configure QML import paths in PyInstaller frozen environment
        if hasattr(sys, "_MEIPASS"):
            for qml_sub in ["PySide6/qml", "PySide6/Qt/qml", "qml", "Qt/qml"]:
                qpath = os.path.join(sys._MEIPASS, qml_sub)
                if os.path.exists(qpath):
                    os.environ["QML2_IMPORT_PATH"] = qpath
                    break

        from PySide6.QtGui import QGuiApplication, QIcon
        from PySide6.QtQml import QQmlApplicationEngine
        from PySide6.QtCore import QUrl
        from backend import Backend

        app = QGuiApplication(sys.argv)
        app.setApplicationName("Liquid CAD Studio")
        app.setOrganizationName("Antigravity")

        # Set Application & Taskbar Icon
        icon_path = resolve_path(os.path.join("assets", "taskbar_icon.png"))
        if os.path.exists(icon_path):
            app.setWindowIcon(QIcon(icon_path))

        engine = QQmlApplicationEngine()

        # Add PyInstaller QML import paths
        if hasattr(sys, "_MEIPASS"):
            for qml_sub in ["PySide6/qml", "PySide6/Qt/qml", "qml", "Qt/qml"]:
                qpath = os.path.join(sys._MEIPASS, qml_sub)
                if os.path.exists(qpath):
                    engine.addImportPath(qpath)

        backend = Backend()
        engine.rootContext().setContextProperty("backend", backend)

        qml_file = resolve_path("main.qml")
        if not os.path.exists(qml_file):
            raise FileNotFoundError(f"main.qml not found. Tried paths starting from: {getattr(sys, '_MEIPASS', os.path.dirname(__file__))}")

        # Capture QML warnings
        engine.warnings.connect(lambda ws: [print("[QML Warning]", w.toString()) for w in ws])

        engine.load(QUrl.fromLocalFile(qml_file))

        if not engine.rootObjects():
            raise RuntimeError(f"Could not initialize QML root object from: {qml_file}")

        sys.exit(app.exec())

    except Exception:
        err = traceback.format_exc()
        log_fatal_error(err)
        sys.exit(1)

if __name__ == "__main__":
    main()
