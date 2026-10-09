# ClickNPinch

### Gesture-Based Virtual Mouse

**Control your computer with your hands.**

ClickNPinch is a Windows desktop application that turns any webcam into a
touch-free mouse. It tracks your hand with MediaPipe's 21-point hand-landmark
model, classifies gestures (pinch, point, palm) from normalized landmark
geometry, and drives the real system cursor through PyAutoGUI — all inside a
polished PySide6 dashboard with live preview, calibration, and an emergency
stop.

> ClickNPinch is the upgraded successor of *Virtual Mouse — Operation Using
> Webcam*, which used an OpenCV Haar cascade (`models/hand.xml`). Haar-cascade
> hand detection was unreliable, so the tracker was replaced with MediaPipe
> hand landmarks; `hand.xml` is kept only for historical reference and is no
> longer used.

---

## 🚀 Installation Guide

Follow these steps to install and run ClickNPinch on Windows 10 or Windows 11.

### Prerequisites

Before installing, make sure you have:

- **Windows 10 or Windows 11**
- **Python 3.11 or another version compatible with the project's dependencies**
- A working webcam
- An internet connection for downloading dependencies

> **Note:** Check `requirements.txt` and test the installation with a clean Python environment before publishing. The required Python version may depend on MediaPipe and other dependencies.

### Method 1: Quick Installation (Recommended)

**Step 1 — Download the project**

1. Open the ClickNPinch GitHub repository.
2. Click the green **Code** button.
3. Select **Download ZIP**.
4. Extract the downloaded ZIP file to a folder on your computer.

**Step 2 — Install Python**

1. Download Python from [python.org](https://www.python.org/downloads/).
2. Run the installer.
3. Enable **Add Python to PATH** if the installer provides that option.
4. Complete the installation.

Verify Python is installed by opening Command Prompt and running:

```bash
python --version
```

**Step 3 — Run ClickNPinch**

1. Open the extracted ClickNPinch folder.
2. Double-click `run.bat`.
3. Allow the application to install or check its required dependencies if prompted.
4. Wait for the application to launch.

If Windows displays a security warning, verify that you downloaded the project from the official repository before proceeding.

### Method 2: Manual Installation

If `run.bat` does not work, follow these steps.

**Step 1 — Open a terminal**

Open the ClickNPinch project folder in File Explorer, click the address bar, type `cmd`, and press Enter.

**Step 2 — Create a virtual environment**

```bash
python -m venv .venv
```

**Step 3 — Activate the environment**

```bash
.venv\Scripts\activate
```

**Step 4 — Install dependencies**

Upgrade pip:

```bash
python -m pip install --upgrade pip
```

Install the project dependencies:

```bash
python -m pip install -r requirements.txt
```

**Step 5 — Launch the application**

```bash
python main.py
```

If the project specifies a different Python entry point, use the launch command documented for that version.

### 🎮 Using ClickNPinch

1. Connect or enable your webcam.
2. Launch ClickNPinch.
3. Allow the application to access the camera if Windows requests permission.
4. Position your hand where the webcam can clearly see it.
5. Follow the configured gesture controls.

For reliable tracking, use adequate lighting and keep your hand within the camera's field of view.

### 🛠️ Troubleshooting

**Python is not recognized**

Reinstall Python and enable the PATH option, or try the Python launcher:

```bash
py --version
```

**Dependencies fail to install**

Check your Python version and the error message. Some computer-vision packages have specific Python compatibility requirements.

**The camera is not detected**

- Close other applications that may be using the webcam.
- Check Windows camera privacy settings.
- Select the correct camera in ClickNPinch settings, if available.

**The application opens but mouse control does not work**

Check that the application is active and not paused. If the issue persists, consult the project's Issues page and include the relevant error logs.

**The application fails to start**

Run `run.bat` from the project directory and read the terminal output. Include the error message when reporting a problem.

### 🗑️ Uninstallation

1. Close ClickNPinch.
2. Remove the extracted project folder.
3. If you added ClickNPinch to Windows startup, disable that option first.

If you created a virtual environment inside the project folder, deleting the folder also removes that environment.

---

**Need help?**

If you encounter an installation problem, open an issue in the ClickNPinch GitHub repository and include your Windows version, Python version, and the relevant error message.

## About

- **What it is:** a local, offline desktop app that lets you move the cursor,
  click, drag, and scroll using hand gestures in front of your webcam.
- **Who it is for:** students and developers who want a presentation-ready
  computer-vision project that is easy to run and easy to tune.
- **Design principle:** reliability over gesture count. Every gesture is
  debounced, thresholded with hysteresis, and dispatched through a
  single-winner priority system so one physical gesture produces exactly one
  mouse action.

## Features

- Real-time MediaPipe **hand-landmark tracking** (21 points, configurable
  detection/presence/tracking confidence, 1–2 hands)
- **Cursor movement** driven by the index fingertip (never the bounding box),
  with sensitivity, dead zone, optional acceleration, and adaptive 1-Euro
  smoothing
- **Left click** — thumb + index pinch with hysteresis and cooldown
- **Right click** — thumb + middle pinch (distinct finger, distinct threshold)
- **Double click** — two pinches inside a configurable time window
- **Drag & drop** — pinch and hold; the button is always released when the
  pinch ends, the hand is lost, tracking stops, or ESC is pressed
- **Scrolling** — index + middle fingers up, vertical hand motion with
  smoothing, dead zone, and interval pacing
- **Pause** — open palm freezes all mouse interaction; the camera keeps
  running and the preview shows a PAUSED banner
- **Interactive 4-corner calibration** with visual targets, dwell sampling,
  and persistence
- **Emergency stop** — ESC instantly releases every mouse button and halts
  gesture control, even mid-drag
- **Settings persistence** — JSON file, auto-repaired when corrupted
- **Onboarding** — welcome → camera → gesture guide → ready, shown once
- **Debug overlay** — landmarks, gesture, FPS, handedness, tracking state
- **Live FPS** monitoring and a responsive non-blocking UI (vision runs on a
  QThread, never the UI thread)

## How It Works

1. The camera thread captures frames (default 1280×720, mirrored).
2. MediaPipe's Hand Landmarker (Tasks API, LIVE_STREAM mode) returns 21
   normalized landmarks per hand.
3. The **gesture detector** computes finger states (tip-vs-pip ordering) and
   thumb-to-fingertip distances normalized by palm size, then runs a
   hysteresis state machine (`IDLE → PINCH_STARTED → CLICKED / PINCH_HELD →
   DRAGGING → RELEASED`) with per-action cooldowns.
4. The **index fingertip** position is filtered with a 1-Euro filter and
   mapped from the calibrated tracking region onto your actual screen
   resolution (queried live from PyAutoGUI — nothing is hard-coded).
5. Discrete events (click/drag/scroll) are applied through PyAutoGUI; every
   shutdown path calls `release_all()` so a mouse button can never stick.

## Gesture Controls

| Gesture | Action |
|---|---|
| ☝️ Index finger up | Move cursor |
| 🤏 Pinch thumb + index | Left click |
| 🤏 Pinch thumb + middle | Right click |
| 🤏 + hold | Drag & drop (release to drop) |
| ✌️ Index + middle up, move hand | Scroll up / down |
| 🖐️ Open palm | Pause / resume |
| `P` key | Pause toggle from the UI |
| `ESC` key | **Emergency stop** (releases buttons, stops control) |

## Screenshots / Demo

Run the app and take screenshots of the dashboard with your hand in frame to
fill this section. Assets live in `assets/icons/` (app logo:

![ClickNPinch icon](assets/icons/clicknpinch_256.png)).

## Requirements

- Windows 10 / 11
- Python 3.13 (MediaPipe 1.1+ wheels; Python 3.9–3.12 also supported)
- A working webcam
- No GPU required — MediaPipe CPU inference is fast enough for 30 FPS

## Installation

```bash
git clone <repository>
cd ClickNPinch

python -m venv venv
venv\Scripts\activate

pip install -r requirements.txt

python main.py
```

Or simply double-click `run.bat`.

## First Launch

1. A welcome screen introduces the app (shown only once).
2. Pick your camera; ClickNPinch scans and validates available devices.
3. Skim the gesture guide and press **FINISH**.
4. Press **START CLICKNPINCH**, then **CALIBRATE** and touch the four on-screen
   corners with your index fingertip.
5. You can replay onboarding any time from **Settings → Replay onboarding**.

## Calibration

Calibration maps the region of camera space where your hand comfortably moves
onto the full screen. During calibration the preview shows four target rings;
hold your fingertip in each ring until the progress bar fills. The resulting
region is stored in `clicknpinch_settings.json` and reused on every launch.
Use **Settings → Start calibration** to redo it, or delete
`clicknpinch_settings.json` to reset everything.

## Configuration

All settings persist in `clicknpinch_settings.json` next to `main.py`:

- **Mouse** — sensitivity, smoothing, dead zone, acceleration
- **Gestures** — pinch thresholds, click cooldowns, double-click window,
  scroll speed
- **Camera** — device, resolution (default 1280×720), mirror mode
- **Vision** — detection/presence/tracking confidence, max hands
- **Interface** — debug overlay, FPS display, onboarding replay

A corrupted settings file is renamed to `.corrupt` and replaced with defaults
automatically.

## Troubleshooting

- **"Camera unavailable"** — close other apps using the webcam, check Windows
  privacy settings (Settings → Bluetooth & devices → Cameras), and try a
  different camera index in Settings.
- **Hand not detected** — improve lighting, keep your hand fully in frame at
  roughly arm's length, and lower detection confidence in Settings.
- **Cursor jitters** — increase smoothing, decrease sensitivity, recalibrate.
- **Clicks fire too easily** — lower the pinch threshold (e.g. 0.18) and
  increase the click cooldown.
- **PyAutoGUI fail-safe triggered** — the cursor entered a screen corner;
  this is a safety feature. Move ClickNPinch's cursor away from corners and
  restart tracking.
- **Logs** — `clicknpinch.log` (rotating) sits next to `main.py`.

## Project Architecture

```text
ClickNPinch/
├── main.py                      # entry point, dependency checks, Qt loop
├── requirements.txt
├── run.bat                      # Windows launcher
├── LICENSE                      # MIT
├── clicknpinch_settings.json    # created on first run
├── app/
│   ├── camera/
│   │   ├── camera.py            # webcam enumeration/probing
│   │   └── worker.py            # QThread vision worker (camera+ML+mouse)
│   ├── config/settings.py       # JSON-backed settings + defaults
│   ├── mouse/
│   │   ├── mapping.py           # normalized→screen coordinate mapping
│   │   ├── smoothing.py         # 1-Euro adaptive filter
│   │   └── mouse_controller.py  # PyAutoGUI facade, release_all()
│   ├── ui/
│   │   ├── main_window.py       # dashboard, start/stop, emergency stop
│   │   ├── widgets.py           # status rows, gesture card, guide entries
│   │   ├── settings_dialog.py
│   │   ├── onboarding.py        # first-launch wizard
│   │   └── styles.py            # QSS dark theme
│   ├── vision/
│   │   ├── hand_tracker.py      # MediaPipe Tasks wrapper + drawing
│   │   ├── gesture_detector.py  # landmark math + state machine
│   │   ├── calibration.py       # 4-corner calibration
│   │   └── overlay.py           # preview overlays
│   └── utils/logger.py          # rotating file + console logging
├── assets/icons/                # generated logo/icon
├── models/
│   ├── hand_landmarker.task     # MediaPipe model (auto-located)
│   └── hand.xml                 # legacy Haar cascade, unused
├── scripts/make_icons.py        # regenerates brand assets
└── tests/                       # webcam-free unit tests
```

## Technologies Used

- **Python 3.13**
- **OpenCV** — capture, color conversion, preview drawing
- **MediaPipe Tasks (Hand Landmarker)** — 21-point hand tracking
- **PyAutoGUI** — cursor movement, clicks, drag, scroll
- **PySide6 (Qt 6)** — desktop UI with QThread worker architecture

## Testing

Webcam-free unit tests cover coordinate mapping, smoothing, finger-state
detection, gesture classification, priority, cooldowns, drag lifecycle,
calibration math, and settings load/save/corruption recovery:

```bash
python -m pytest tests/ -v
```

Camera-dependent behavior (device enumeration, live tracking FPS, real mouse
actions) requires a physical webcam and is verified manually on Windows.

## Future Improvements

- Multi-monitor support
- Horizontal scrolling and pinch-zoom gestures
- Optional gesture-sound feedback for presentations
- Single-file Windows executable via PyInstaller
- Per-application gesture profiles

## License

MIT — see [LICENSE](LICENSE).
