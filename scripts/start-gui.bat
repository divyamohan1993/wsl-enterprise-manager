@echo off
setlocal EnableDelayedExpansion
chcp 65001 >nul 2>&1
title Start WSL GUI

set "SCRIPT_DIR=%~dp0"

cls
echo.
echo ========================================================================
echo                    START WSL GUI DESKTOP
echo ========================================================================
echo.

:: Check for X server
tasklist /FI "IMAGENAME eq vcxsrv.exe" 2>nul | find "vcxsrv.exe" >nul
if not errorlevel 1 (
    echo  [OK] VcXsrv is running.
    goto start_gui
)

tasklist /FI "IMAGENAME eq GWSL.exe" 2>nul | find "GWSL.exe" >nul
if not errorlevel 1 (
    echo  [OK] GWSL is running.
    goto start_gui
)

echo  No X Server detected!
echo.
echo  [1] Start VcXsrv (if installed)
echo  [2] Download VcXsrv
echo  [3] Download GWSL from Microsoft Store
echo  [4] Continue anyway (WSLg)
echo.
set /p "xserver=Select [1-4]: "

if "%xserver%"=="1" (
    if exist "C:\Program Files\VcXsrv\vcxsrv.exe" (
        start "" "C:\Program Files\VcXsrv\vcxsrv.exe" :0 -multiwindow -clipboard -wgl -ac
        timeout /t 2 >nul
    ) else (
        echo  VcXsrv not found.
    )
)
if "%xserver%"=="2" (
    start https://sourceforge.net/projects/vcxsrv/
    echo  Download and install VcXsrv, then run this again.
    pause
    goto :eof
)
if "%xserver%"=="3" (
    start ms-windows-store://pdp/?productid=9NL6KD1H33V3
    pause
    goto :eof
)

:start_gui
echo.
echo  Available distributions:
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
    pause
    exit /b 1
)

set /p "selection=Select distribution [1-%count%]: "
set "DISTRO=!distro_%selection%!"

echo.
echo  Select desktop environment:
echo   [1] XFCE    [2] GNOME    [3] KDE    [4] LXQt    [5] MATE
set /p "de=Select [1-5]: "

if "%de%"=="1" set "SESSION=startxfce4"
if "%de%"=="2" set "SESSION=gnome-session"
if "%de%"=="3" set "SESSION=startplasma-x11"
if "%de%"=="4" set "SESSION=startlxqt"
if "%de%"=="5" set "SESSION=mate-session"

echo.
echo  Starting %SESSION% in !DISTRO!...
echo.

:: Start D-Bus and the session
start wsl -d "!DISTRO!" -- bash -c "export DISPLAY=:0 && export LIBGL_ALWAYS_INDIRECT=1 && dbus-launch --exit-with-session %SESSION%"

echo  GUI session started!
echo.
echo  If no windows appear, ensure your X server is configured with:
echo   - Access control disabled
echo   - Multiple windows mode
echo.
pause
