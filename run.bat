@echo off
rem ============================================================
rem  ClickNPinch one-click Windows launcher
rem
rem  Priority: project .venv  ->  py -3  ->  python on PATH
rem  Never relies on the Microsoft Store python alias.
rem ============================================================
setlocal EnableExtensions

cd /d "%~dp0"

echo ========================================
echo        CLICKNPINCH
echo    Gesture-Based Virtual Mouse
echo ========================================
echo.

set "PYEXE="

rem ---- 1) Preferred: the project's own virtual environment ----
if exist ".venv\Scripts\python.exe" (
    set "PYEXE=.venv\Scripts\python.exe"
    echo [launcher] Using project virtual environment: .venv\Scripts\python.exe
    goto :have_python
)

rem ---- 2) Windows Python launcher (py.exe) ----
where py >nul 2>nul
if not errorlevel 1 (
    py -3 --version >nul 2>nul
    if not errorlevel 1 (
        echo [launcher] No .venv found. Creating one with "py -3"...
        py -3 -m venv .venv
        if errorlevel 1 (
            echo.
            echo [launcher ERROR] Failed to create the virtual environment.
            echo The "py -3 -m venv .venv" command reported an error. See the
            echo message above. Press any key to close this window.
            pause >nul
            exit /b 1
        )
        if exist ".venv\Scripts\python.exe" (
            set "PYEXE=.venv\Scripts\python.exe"
            echo [launcher] Virtual environment created.
            goto :have_python
        )
    )
)

rem ---- 3) Fallback: python.exe on PATH (only if it actually runs) ----
where python >nul 2>nul
if not errorlevel 1 (
    python --version >nul 2>nul
    if not errorlevel 1 (
        set "PYEXE=python"
        echo [launcher] Using system Python from PATH.
        goto :have_python
    )
)

rem ---- Nothing worked ----
echo.
echo [launcher ERROR] Python could not be found.
echo.
echo ClickNPinch needs Python 3.x installed, or the Windows Python
echo launcher "py.exe" (installed with python.org Python by default, or
echo available separately from the Microsoft Store as "Python launcher").
echo.
echo  1. Install Python 3.x from https://www.python.org/downloads/
echo  2. During setup, tick "Add python.exe to PATH".
echo  3. Run run.bat again.
echo.
echo Press any key to close this window.
pause >nul
exit /b 1

:have_python
rem ---- One-time dependency install (only when imports actually fail) ----
rem Probe EVERY runtime import main.py needs: OpenCV, NumPy, Qt, pyautogui,
rem and the MediaPipe Tasks API (mediapipe.tasks) used by the hand tracker.
rem A bare "import mediapipe" is not enough — the Tasks submodule is the
rem actual API this app calls, and it is what breaks on wrong versions.
"%PYEXE%" -c "import cv2, numpy, PySide6, pyautogui, mediapipe; from mediapipe.tasks.python import vision; from mediapipe.tasks.python.core import base_options" >nul 2>nul
if errorlevel 1 (
    echo [launcher] Some dependencies are missing. Installing requirements...
    "%PYEXE%" -m pip install -r requirements.txt
    if errorlevel 1 (
        echo.
        echo [launcher ERROR] Dependency installation failed.
        echo Check your internet connection and the pip output above.
        echo Press any key to close this window.
        pause >nul
        exit /b 1
    )
    echo [launcher] Dependencies installed.
)

rem ---- Launch ----
echo [launcher] Starting ClickNPinch...
echo.
"%PYEXE%" main.py %*
set "EXITCODE=%ERRORLEVEL%"
if %EXITCODE% neq 0 (
    echo.
    echo [launcher] ClickNPinch failed to start ^(exit code %EXITCODE%^).
    if exist clicknpinch.log (
        echo ---------- last log lines ----------
        powershell -NoProfile -Command "Get-Content clicknpinch.log -Tail 25"
        echo ------------------------------------
    )
    echo Press any key to close this window.
    pause >nul
)
endlocal & exit /b %EXITCODE%
