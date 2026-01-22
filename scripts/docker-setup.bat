@echo off
setlocal EnableDelayedExpansion
chcp 65001 >nul 2>&1
title WSL Docker Setup

set "SCRIPT_DIR=%~dp0"

cls
echo.
echo ========================================================================
echo                    WSL DOCKER AND CONTAINER SETUP
echo ========================================================================
echo.

echo  [1] Install Docker Engine in WSL
echo  [2] Install Docker Desktop integration
echo  [3] Install Podman (Docker alternative)
echo  [4] Install Docker Compose
echo  [5] Install container tools
echo  [6] Setup local registry
echo  [7] Container status
echo  [8] Cancel
echo.
set /p "choice=Select [1-8]: "

if "%choice%"=="8" goto :eof
if "%choice%"=="2" (
    echo.
    echo  Docker Desktop Integration:
    echo  1. Install Docker Desktop for Windows
    echo  2. Open Docker Desktop Settings
    echo  3. Go to Resources - WSL Integration
    echo  4. Enable integration for your distributions
    echo.
    echo  Opening Docker Desktop download page...
    start https://www.docker.com/products/docker-desktop/
    pause
    goto :eof
)

:: For other options, need to select distribution
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
    echo  Installing Docker Engine on !DISTRO!...
    wsl -d "!DISTRO!" -u root -- bash -c "curl -fsSL https://get.docker.com | sh"
    wsl -d "!DISTRO!" -u root -- bash -c "usermod -aG docker $SUDO_USER"
    wsl -d "!DISTRO!" -u root -- bash -c "service docker start"
    echo  Docker installed!
    echo  Log out and back in for group changes.
)

if "%choice%"=="3" (
    echo  Installing Podman on !DISTRO!...
    wsl -d "!DISTRO!" -u root -- bash -c "apt update && apt install -y podman"
    echo  Podman installed!
)

if "%choice%"=="4" (
    echo  Installing Docker Compose on !DISTRO!...
    wsl -d "!DISTRO!" -u root -- bash -c "curl -L 'https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64' -o /usr/local/bin/docker-compose && chmod +x /usr/local/bin/docker-compose"
    echo  Docker Compose installed!
)

if "%choice%"=="5" (
    echo  Installing container tools on !DISTRO!...
    wsl -d "!DISTRO!" -u root -- bash -c "curl -sS https://webinstall.dev/k9s | bash"
    echo  Tools installed!
)

if "%choice%"=="6" (
    echo  Setting up local registry on port 5000...
    wsl -d "!DISTRO!" -- docker run -d -p 5000:5000 --restart=always --name registry registry:2
    echo  Local registry running at localhost:5000
)

if "%choice%"=="7" (
    echo.
    echo  Docker Status on !DISTRO!:
    wsl -d "!DISTRO!" -- docker ps -a 2>nul
    echo.
    echo  Docker Images:
    wsl -d "!DISTRO!" -- docker images 2>nul
)

echo.
pause
