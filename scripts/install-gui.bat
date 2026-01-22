@echo off
setlocal EnableDelayedExpansion
chcp 65001 >nul 2>&1
title WSL GUI Installer

set "SCRIPT_DIR=%~dp0"

cls
echo.
echo ========================================================================
echo              WSL GUI Desktop Environment Installer
echo ========================================================================
echo.

:: List available distributions using PowerShell helper
echo  Available WSL distributions:
echo  ------------------------------------------------------------------------
set "count=0"
for /f "usebackq tokens=*" %%a in (`powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%get-distros.ps1"`) do (
    set "temp=%%a"
    if not "!temp!"=="" (
        set /a "count+=1"
        set "distro_!count!=!temp!"
        echo   [!count!]  !temp!
    )
)
echo  ------------------------------------------------------------------------
echo.

if %count%==0 (
    echo  No WSL distributions found!
    echo  Please install a distribution first using quick-setup.bat
    pause
    exit /b 1
)

set /p "selection=Select distribution [1-%count%]: "

:: Validate selection
if !selection! LSS 1 (
    echo  Invalid selection.
    pause
    exit /b 1
)
if !selection! GTR %count% (
    echo  Invalid selection.
    pause
    exit /b 1
)

set "DISTRO=!distro_%selection%!"

:: Verify distribution exists
wsl -d "!DISTRO!" -- echo OK >nul 2>&1
if errorlevel 1 (
    echo  Error: Cannot access distribution !DISTRO!
    pause
    exit /b 1
)

echo.
echo  Selected: !DISTRO!
echo.
echo  Select GUI Desktop Environment:
echo.
echo   [1]  XFCE (Lightweight, Recommended)
echo   [2]  GNOME (Full Featured)
echo   [3]  KDE Plasma (Beautiful)
echo   [4]  LXQt (Very Lightweight)
echo   [5]  MATE (Traditional)
echo   [6]  Cinnamon (Modern)
echo.
set /p "GUI=Select [1-6]: "

echo.
echo  Installing GUI environment on !DISTRO!...
echo  This may take 10-30 minutes depending on your connection.
echo.

if "%GUI%"=="1" (
    echo  Installing XFCE...
    wsl -d "!DISTRO!" -u root -- bash -c "apt update && DEBIAN_FRONTEND=noninteractive apt install -y xfce4 xfce4-goodies dbus-x11"
)
if "%GUI%"=="2" (
    echo  Installing GNOME...
    wsl -d "!DISTRO!" -u root -- bash -c "apt update && DEBIAN_FRONTEND=noninteractive apt install -y ubuntu-desktop gnome-terminal dbus-x11"
)
if "%GUI%"=="3" (
    echo  Installing KDE Plasma...
    wsl -d "!DISTRO!" -u root -- bash -c "apt update && DEBIAN_FRONTEND=noninteractive apt install -y kde-plasma-desktop dbus-x11"
)
if "%GUI%"=="4" (
    echo  Installing LXQt...
    wsl -d "!DISTRO!" -u root -- bash -c "apt update && DEBIAN_FRONTEND=noninteractive apt install -y lxqt dbus-x11"
)
if "%GUI%"=="5" (
    echo  Installing MATE...
    wsl -d "!DISTRO!" -u root -- bash -c "apt update && DEBIAN_FRONTEND=noninteractive apt install -y mate-desktop-environment dbus-x11"
)
if "%GUI%"=="6" (
    echo  Installing Cinnamon...
    wsl -d "!DISTRO!" -u root -- bash -c "apt update && DEBIAN_FRONTEND=noninteractive apt install -y cinnamon-desktop-environment dbus-x11"
)

:: Configure display
echo.
echo  Configuring display settings...
wsl -d "!DISTRO!" -u root -- bash -c "echo 'export DISPLAY=:0' >> /etc/profile.d/wsl-display.sh"

echo.
echo  GUI installation complete!
echo.
echo  To start the GUI:
echo   1. Install an X Server (VcXsrv or GWSL) on Windows
echo   2. Run: start-gui.bat
echo.
pause
