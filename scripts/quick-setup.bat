@echo off
setlocal EnableDelayedExpansion
chcp 65001 >nul 2>&1
title WSL Quick Setup

cls
echo.
echo ========================================================================
echo              WSL QUICK SETUP - One-Click Installation
echo ========================================================================
echo.

:: Check if WSL is installed
wsl --status >nul 2>&1
if errorlevel 1 (
    echo  WSL is not installed. Installing now...
    echo.
    dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart >nul 2>&1
    dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart >nul 2>&1
    wsl --set-default-version 2 >nul 2>&1
    echo  WSL installed! Please restart and run again.
    pause
    exit /b 0
)

echo  [OK] WSL is ready.
echo.

:: Distribution selection
echo  Select Linux Distribution:
echo  ------------------------------------------------------------------------
echo   [1]   Ubuntu 22.04 LTS        (Recommended)
echo   [2]   Ubuntu 24.04 LTS        (Latest)
echo   [3]   Debian 12 (Bookworm)
echo   [4]   Kali Linux              (Security/Pentest)
echo   [5]   openSUSE Leap 15.5
echo   [6]   Alpine Linux            (Lightweight)
echo   [7]   Arch Linux
echo   [8]   Fedora Remix
echo   [9]   Oracle Linux 9
echo   [10]  AlmaLinux 9
echo.
set /p "c=Select [1-10]: "

if "%c%"=="1" set "D=Ubuntu-22.04" & set "DN=Ubuntu 22.04"
if "%c%"=="2" set "D=Ubuntu-24.04" & set "DN=Ubuntu 24.04"
if "%c%"=="3" set "D=Debian" & set "DN=Debian"
if "%c%"=="4" set "D=kali-linux" & set "DN=Kali Linux"
if "%c%"=="5" set "D=openSUSE-Leap-15.5" & set "DN=openSUSE Leap"
if "%c%"=="6" set "D=Alpine" & set "DN=Alpine Linux"
if "%c%"=="7" set "D=Arch" & set "DN=Arch Linux"
if "%c%"=="8" set "D=FedoraRemix" & set "DN=Fedora Remix"
if "%c%"=="9" set "D=OracleLinux_9_1" & set "DN=Oracle Linux"
if "%c%"=="10" set "D=AlmaLinux-9" & set "DN=AlmaLinux"

if not defined D (
    echo  Invalid selection.
    pause
    exit /b 1
)

echo.
echo  Installation Type for %DN%:
echo  ------------------------------------------------------------------------
echo   [1]   Headless / CLI Only
echo         Minimal installation, command-line interface only.
echo         Best for: Servers, development, Docker hosts
echo.
echo   [2]   With GUI Desktop
echo         Full desktop environment with graphical interface.
echo         Best for: Desktop usage, GUI applications
echo.
set /p "gui=Select [1-2]: "

echo.
echo  Installing %DN%...
wsl --install -d %D%

if "%gui%"=="2" (
    echo.
    echo  After first boot, run the GUI installer:
    echo    scripts\install-gui.bat
    echo.
    echo  Or from the main menu: wsl-manager.bat - Option 9
)

echo.
echo  Installation initiated!
echo.
echo  Next steps:
echo   1. Complete the initial setup (create username/password)
if "%gui%"=="2" (
    echo   2. Run scripts\install-gui.bat to add desktop environment
)
echo.
pause
