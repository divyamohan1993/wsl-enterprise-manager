@echo off
setlocal EnableDelayedExpansion
chcp 65001 >nul 2>&1
title WSL Network Configuration

set "SCRIPT_DIR=%~dp0"

cls
echo.
echo ========================================================================
echo                    WSL NETWORK CONFIGURATION
echo ========================================================================
echo.

echo  [1] View network info
echo  [2] Configure port forwarding
echo  [3] Setup SSH access
echo  [4] Configure DNS settings
echo  [5] Test connectivity
echo  [6] Reset network
echo  [7] Cancel
echo.
set /p "choice=Select [1-7]: "

if "%choice%"=="7" goto :eof

if "%choice%"=="1" (
    echo.
    echo  Windows Host Network:
    ipconfig | findstr /i "IPv4 Subnet Gateway"
    echo.
    echo  WSL Network:
    wsl -- ip addr show eth0 2>nul
    echo.
    echo  WSL Default Gateway:
    wsl -- ip route show default 2>nul
    pause
    goto :eof
)

if "%choice%"=="5" (
    echo.
    echo  Testing WSL network connectivity...
    wsl -- ping -c 3 8.8.8.8
    echo.
    wsl -- ping -c 3 google.com
    pause
    goto :eof
)

if "%choice%"=="6" (
    echo  Resetting network configuration...
    wsl --shutdown
    netsh interface portproxy reset
    echo  Network reset. Restart WSL.
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

if "%choice%"=="2" (
    set /p "wport=Windows port: "
    set /p "lport=Linux port: "
    
    for /f "tokens=*" %%i in ('wsl -d "!DISTRO!" -- hostname -I 2^>nul') do set "wsl_ip=%%i"
    set "wsl_ip=!wsl_ip: =!"
    
    echo  Forwarding port !wport! to !wsl_ip!:!lport!...
    netsh interface portproxy add v4tov4 listenport=!wport! listenaddress=0.0.0.0 connectport=!lport! connectaddress=!wsl_ip!
    echo  Port forwarding configured.
    echo.
    echo  Current port forwards:
    netsh interface portproxy show all
)

if "%choice%"=="3" (
    echo  Setting up SSH server in !DISTRO!...
    wsl -d "!DISTRO!" -u root -- bash -c "apt update && apt install -y openssh-server"
    wsl -d "!DISTRO!" -u root -- bash -c "sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config"
    wsl -d "!DISTRO!" -u root -- bash -c "service ssh start"
    echo  SSH server started.
    wsl -d "!DISTRO!" -- hostname -I
)

if "%choice%"=="4" (
    echo  Warning: This modifies /etc/resolv.conf
    set /p "dns=Enter DNS server (e.g., 8.8.8.8): "
    wsl -d "!DISTRO!" -u root -- bash -c "echo 'nameserver !dns!' > /etc/resolv.conf"
    echo  DNS configured.
)

echo.
pause
