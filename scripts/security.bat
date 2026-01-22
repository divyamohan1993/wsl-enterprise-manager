@echo off
setlocal EnableDelayedExpansion
chcp 65001 >nul 2>&1
title WSL Security Hardening

set "SCRIPT_DIR=%~dp0"

cls
echo.
echo ========================================================================
echo                    WSL SECURITY HARDENING
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
echo  Security Options:
echo.
echo   [1]  Full security setup (recommended)
echo   [2]  Configure firewall (UFW)
echo   [3]  Harden SSH configuration
echo   [4]  Install Fail2Ban
echo   [5]  Security audit
echo   [6]  Setup automatic updates
echo   [7]  Configure user permissions
echo   [8]  Cancel
echo.
set /p "choice=Select [1-8]: "

if "%choice%"=="8" goto :eof

if "%choice%"=="1" (
    echo.
    echo  Running full security setup on !DISTRO!...
    
    echo  [1/5] Installing security packages...
    wsl -d "!DISTRO!" -u root -- bash -c "apt update && apt install -y ufw fail2ban unattended-upgrades"
    
    echo  [2/5] Configuring firewall...
    wsl -d "!DISTRO!" -u root -- bash -c "ufw default deny incoming && ufw default allow outgoing && ufw allow ssh && ufw --force enable"
    
    echo  [3/5] Hardening SSH...
    wsl -d "!DISTRO!" -u root -- bash -c "sed -i 's/#PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config"
    wsl -d "!DISTRO!" -u root -- bash -c "sed -i 's/#MaxAuthTries.*/MaxAuthTries 3/' /etc/ssh/sshd_config"
    
    echo  [4/5] Configuring Fail2Ban...
    wsl -d "!DISTRO!" -u root -- bash -c "systemctl enable fail2ban && systemctl start fail2ban"
    
    echo  [5/5] Enabling automatic updates...
    wsl -d "!DISTRO!" -u root -- bash -c "dpkg-reconfigure -f noninteractive unattended-upgrades"
    
    echo.
    echo  Full security setup complete!
)

if "%choice%"=="2" (
    echo  Configuring UFW firewall on !DISTRO!...
    wsl -d "!DISTRO!" -u root -- bash -c "apt install -y ufw && ufw default deny incoming && ufw default allow outgoing && ufw --force enable && ufw status"
    echo  Firewall configured.
)

if "%choice%"=="3" (
    echo  Hardening SSH on !DISTRO!...
    wsl -d "!DISTRO!" -u root -- bash -c "sed -i 's/#PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config"
    wsl -d "!DISTRO!" -u root -- bash -c "sed -i 's/#PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config"
    wsl -d "!DISTRO!" -u root -- bash -c "sed -i 's/#MaxAuthTries.*/MaxAuthTries 3/' /etc/ssh/sshd_config"
    echo  SSH hardened. Restart SSH to apply.
)

if "%choice%"=="4" (
    echo  Installing Fail2Ban on !DISTRO!...
    wsl -d "!DISTRO!" -u root -- bash -c "apt install -y fail2ban && systemctl enable fail2ban && systemctl start fail2ban"
    echo  Fail2Ban installed.
)

if "%choice%"=="5" (
    echo.
    echo  Running security audit on !DISTRO!...
    echo.
    echo  OS Information:
    wsl -d "!DISTRO!" -- cat /etc/os-release
    echo.
    echo  Open Ports:
    wsl -d "!DISTRO!" -- ss -tuln
    echo.
    echo  SUID Files:
    wsl -d "!DISTRO!" -- find /usr -perm -4000 -type f 2^>/dev/null
    echo.
    echo  Users with shell access:
    wsl -d "!DISTRO!" -- grep -v nologin /etc/passwd ^| grep -v false
)

if "%choice%"=="6" (
    echo  Enabling automatic updates on !DISTRO!...
    wsl -d "!DISTRO!" -u root -- bash -c "apt install -y unattended-upgrades && dpkg-reconfigure -f noninteractive unattended-upgrades"
    echo  Automatic updates enabled.
)

if "%choice%"=="7" (
    echo.
    set /p "user=Enter username to configure: "
    echo  [1] Add to sudo group
    echo  [2] Remove from sudo group
    set /p "perm=Select: "
    if "!perm!"=="1" wsl -d "!DISTRO!" -u root -- bash -c "usermod -aG sudo !user!"
    if "!perm!"=="2" wsl -d "!DISTRO!" -u root -- bash -c "deluser !user! sudo"
    echo  Done.
)

echo.
pause
