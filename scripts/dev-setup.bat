@echo off
setlocal EnableDelayedExpansion
chcp 65001 >nul 2>&1
title WSL Development Environment

set "SCRIPT_DIR=%~dp0"

cls
echo.
echo ========================================================================
echo                    DEVELOPMENT ENVIRONMENT SETUP
echo ========================================================================
echo.

:: List distributions using PowerShell helper
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
echo  Select development stack:
echo.
echo   [1]  Full Stack Web Developer
echo   [2]  Python/Data Science
echo   [3]  DevOps/SRE
echo   [4]  System Programming (C/C++/Rust)
echo   [5]  Java Enterprise
echo.
set /p "stack=Select [1-5]: "

echo.
echo  Installing packages on !DISTRO!... This may take a while.
echo.

:: Base tools for all
wsl -d "!DISTRO!" -u root -- bash -c "apt update && apt install -y curl wget git vim nano htop tree unzip"

if "%stack%"=="1" (
    echo  Installing Full Stack Web Development tools...
    wsl -d "!DISTRO!" -u root -- bash -c "apt install -y nodejs npm && npm install -g yarn pnpm"
    wsl -d "!DISTRO!" -u root -- bash -c "apt install -y python3 python3-pip python3-venv"
    wsl -d "!DISTRO!" -u root -- bash -c "curl -fsSL https://get.docker.com | sh"
    wsl -d "!DISTRO!" -u root -- bash -c "apt install -y postgresql redis-server"
)

if "%stack%"=="2" (
    echo  Installing Python/Data Science tools...
    wsl -d "!DISTRO!" -u root -- bash -c "apt install -y python3 python3-pip python3-venv python3-dev"
    wsl -d "!DISTRO!" -u root -- bash -c "pip3 install numpy pandas matplotlib seaborn scikit-learn jupyter"
)

if "%stack%"=="3" (
    echo  Installing DevOps tools...
    wsl -d "!DISTRO!" -u root -- bash -c "curl -fsSL https://get.docker.com | sh"
    wsl -d "!DISTRO!" -u root -- bash -c "apt install -y ansible"
    wsl -d "!DISTRO!" -u root -- bash -c "curl -LO https://dl.k8s.io/release/v1.29.0/bin/linux/amd64/kubectl && chmod +x kubectl && mv kubectl /usr/local/bin/"
)

if "%stack%"=="4" (
    echo  Installing System Programming tools...
    wsl -d "!DISTRO!" -u root -- bash -c "apt install -y build-essential gcc g++ make cmake gdb valgrind"
    wsl -d "!DISTRO!" -u root -- bash -c "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y"
)

if "%stack%"=="5" (
    echo  Installing Java Enterprise tools...
    wsl -d "!DISTRO!" -u root -- bash -c "apt install -y openjdk-17-jdk maven gradle"
)

echo.
echo  Development environment ready on !DISTRO!!
pause
