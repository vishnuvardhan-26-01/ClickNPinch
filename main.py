"""ClickNPinch — Gesture-Based Virtual Mouse.

Control your computer with your hands.

Entry point: checks dependencies, wires the global emergency stop, and runs
the Qt application loop.
"""
from __future__ import annotations

import sys
from pathlib import Path

# Make ``import app`` work no matter where the user starts Python from.
sys.path.insert(0, str(Path(__file__).resolve().parent))

from app.utils.logger import get_logger, setup_logging  # noqa: E402

logger = get_logger("main")

MISSING_PACKAGES: dict[str, str] = {
    "cv2": "pip install opencv-python",
    "mediapipe": "pip install mediapipe",
    "pyautogui": "pip install pyautogui",
    "PySide6": "pip install PySide6",
}


def check_dependencies() -> list[str]:
    """Return install instructions for every missing package."""
    missing: list[str] = []
    for module, install_hint in MISSING_PACKAGES.items():
        try:
            __import__(module)
        except ImportError:
            missing.append(f"{module}  →  {install_hint}")
    return missing


def main() -> int:
    setup_logging()
    logger.info("ClickNPinch starting (Gesture-Based Virtual Mouse)")

    missing = check_dependencies()
    if missing:
        logger.error("Missing dependencies: %s", ", ".join(missing))
        print("ClickNPinch is missing required packages:\n")
        for item in missing:
            print(f"  • {item}")
        print("\nInstall them, then run ClickNPinch again.")
        return 1

    try:
        import pyautogui
        # ClickNPinch implements safe screen clamping and its own ESC emergency stop.
        # Disabling PyAutoGUI's corner fail-safe avoids freezing if the cursor starts at (0, 0).
        pyautogui.FAILSAFE = False
    except Exception as exc:  # pragma: no cover
        logger.error("PyAutoGUI init failed: %s", exc)
        print(f"Mouse automation is unavailable: {exc}")
        return 1

    try:
        from PySide6.QtGui import QIcon
        from PySide6.QtWidgets import QApplication

        from app.camera.worker import VisionWorker
        from app.config.settings import SettingsStore
        from app.ui.compact_window import CompactCompanionWindow
        from app.ui.main_window import MainWindow

        qt_app = QApplication(sys.argv)
        qt_app.setApplicationName("ClickNPinch")
        qt_app.setOrganizationName("ClickNPinch")
        icon_path = Path(__file__).resolve().parent / "assets" / "icons" / "clicknpinch.ico"
        if icon_path.exists():
            qt_app.setWindowIcon(QIcon(str(icon_path)))

        store = SettingsStore()
        settings = store.load()

        use_classic = "--classic" in sys.argv
        if use_classic:
            window = MainWindow(settings=settings, store=store)
            window.show()
        else:
            # Background vision worker & compact companion UI (no camera in normal view)
            worker = VisionWorker(settings=settings, camera_index=settings.last_camera_index)
            if not settings.test_mode:
                worker.arm()
            worker.start()
            window = CompactCompanionWindow(settings=settings, store=store, worker=worker)
            if not getattr(settings.ui, "start_minimized", True):
                window.expand()
            window.show()
            qt_app.aboutToQuit.connect(worker.emergency_stop)

        exit_code = qt_app.exec()
        logger.info("ClickNPinch exited with code %s", exit_code)
        return exit_code
    except SystemExit:
        raise
    except Exception:
        logger.exception("Fatal error in ClickNPinch")
        try:
            import pyautogui
            pyautogui.mouseUp(button="left")
            pyautogui.mouseUp(button="right")
        except Exception:
            pass
        print(
            "ClickNPinch hit an unexpected error and stopped safely.\n"
            "Details are in clicknpinch.log next to main.py."
        )
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
