@echo off
setlocal EnableDelayedExpansion
chcp 65001 >nul 2>&1
title WSL Update Manager

set "SCRIPT_DIR=%~dp0"

cls
echo.
echo ========================================================================
echo                    WSL UPDATE AND MAINTENANCE
echo ========================================================================
echo.

echo  [1] Update single distribution
echo  [2] Update ALL distributions
echo  [3] Upgrade distribution (dist-upgrade)
echo  [4] Update WSL kernel
echo  [5] Check for Windows updates
echo  [6] Cancel
echo.
set /p "choice=Select [1-6]: "

if "%choice%"=="6" goto :eof

if "%choice%"=="2" (
    echo.
    echo  Updating all distributions...
    for /f "usebackq tokens=*" %%a in (`powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%get-distros.ps1"`) do (
        echo.
        echo  Updating %%a...
        wsl -d "%%a" -u root -- bash -c "apt update && apt upgrade -y 2>/dev/null || yum update -y 2>/dev/null || dnf update -y 2>/dev/null"
    )
    echo.
    echo  All distributions updated!
    pause
    goto :eof
)

if "%choice%"=="4" (
    echo.
    echo  Updating WSL kernel...
    wsl --update
    echo  WSL kernel updated!
    pause
    goto :eof
)

if "%choice%"=="5" (
    echo.
    echo  Opening Windows Update...
    start ms-settings:windowsupdate
    goto :eof
)

:: For options 1 and 3, need to select distribution
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
echo  Selected: !DISTRO!
echo.

if "%choice%"=="1" (
    echo  Updating !DISTRO!...
    wsl -d "!DISTRO!" -u root -- bash -c "apt update && apt upgrade -y"
    echo  Update complete!
)

if "%choice%"=="3" (
    echo  Running dist-upgrade on !DISTRO!...
    wsl -d "!DISTRO!" -u root -- bash -c "apt update && apt dist-upgrade -y && apt autoremove -y"
    echo  Upgrade complete!
)

echo.
pause
