import os
import sys
import traceback

def resolve_path(relative_path):
    """
    Robust resource path resolver for dev and PyInstaller frozen builds.
    """
    candidates = []

    if hasattr(sys, "_MEIPASS"):
        candidates.append(os.path.join(sys._MEIPASS, relative_path))
        candidates.append(os.path.join(sys._MEIPASS, "desktop-app", relative_path))

    script_dir = os.path.dirname(os.path.abspath(__file__))
    candidates.append(os.path.join(script_dir, relative_path))
    candidates.append(os.path.join(script_dir, "desktop-app", relative_path))

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
                0x10
            )
        except Exception:
            pass

def main():
    try:
        from PySide6.QtWidgets import QApplication
        from PySide6.QtGui import QIcon
        from backend import Backend
        from ui_widgets import MainWindow

        app = QApplication(sys.argv)
        app.setApplicationName("Liquid CAD Studio")
        app.setOrganizationName("Antigravity")

        # Set Window and Taskbar Icon
        icon_path = resolve_path(os.path.join("assets", "taskbar_icon.png"))
        if os.path.exists(icon_path):
            app.setWindowIcon(QIcon(icon_path))

        backend = Backend()
        window = MainWindow(backend)
        window.show()

        sys.exit(app.exec())

    except Exception:
        err = traceback.format_exc()
        log_fatal_error(err)
        sys.exit(1)

if __name__ == "__main__":
    main()
