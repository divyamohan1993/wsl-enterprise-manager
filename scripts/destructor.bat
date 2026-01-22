@echo off
setlocal EnableDelayedExpansion
chcp 65001 >nul 2>&1
title WSL Destructor

set "SCRIPT_DIR=%~dp0"
set "FORENSICS_DIR=%SCRIPT_DIR%..\forensics"

if not exist "%FORENSICS_DIR%" mkdir "%FORENSICS_DIR%" 2>nul

cls
echo.
echo ========================================================================
echo              WSL DESTRUCTOR - Uninstall and Cleanup
echo ========================================================================
echo.
echo  WARNING: This tool will permanently delete WSL data!
echo  NOTE: Forensic data will be saved before destruction.
echo.

echo  [1] Unregister single distribution (with forensic dump)
echo  [2] Unregister ALL distributions (with forensic dumps)
echo  [3] Clean temporary files
echo  [4] Compact VHD files
echo  [5] Complete WSL removal (with full forensics)
echo  [6] View forensic reports
echo  [7] Cancel
echo.
set /p "choice=Select option [1-7]: "

if "%choice%"=="7" goto :eof

if "%choice%"=="1" (
    echo.
    echo  Available distributions:
    echo  ----------------------------------------------------------------
    set "count=0"
    for /f "usebackq tokens=*" %%a in (`powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%get-distros.ps1"`) do (
        set "temp=%%a"
        if not "!temp!"=="" (
            set /a "count+=1"
            set "distro_!count!=!temp!"
            echo   [!count!]  !temp!
        )
    )
    echo  ----------------------------------------------------------------
    echo.
    
    if !count!==0 (
        echo  No WSL distributions found!
        pause
        goto :eof
    )
    
    set /p "selection=Select distribution [1-!count!]: "
    set "DISTRO=!distro_%selection%!"
    
    echo.
    echo  This will delete !DISTRO! and all its data!
    echo  Forensic data will be saved before destruction.
    echo.
    set /p "confirm=Type 'DELETE' to confirm: "
    if "!confirm!"=="DELETE" (
        call :forensic_dump "!DISTRO!"
        echo.
        echo  Unregistering !DISTRO!...
        wsl --unregister "!DISTRO!"
        echo  Distribution removed. Forensic report saved.
    ) else (
        echo  Operation cancelled.
    )
)

if "%choice%"=="2" (
    echo.
    echo  This will delete ALL WSL distributions:
    echo  ----------------------------------------------------------------
    for /f "usebackq tokens=*" %%a in (`powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%get-distros.ps1"`) do (
        echo   %%a
    )
    echo  ----------------------------------------------------------------
    echo.
    echo  Forensic data will be saved for each before destruction.
    echo.
    set /p "confirm=Type 'DELETE ALL' to confirm: "
    if "!confirm!"=="DELETE ALL" (
        for /f "usebackq tokens=*" %%a in (`powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%get-distros.ps1"`) do (
            call :forensic_dump "%%a"
            echo  Removing %%a...
            wsl --unregister "%%a" 2>nul
        )
        echo  All distributions removed. Forensic reports saved.
    ) else (
        echo  Operation cancelled.
    )
)

if "%choice%"=="3" (
    echo  Cleaning temp files...
    del /q "%TEMP%\wsl*" 2>nul
    echo  Cleaned.
)

if "%choice%"=="4" (
    echo  Shutting down WSL...
    wsl --shutdown
    timeout /t 3 >nul
    echo  Compacting VHD files...
    for /r "%LOCALAPPDATA%\Packages" %%f in (ext4.vhdx) do (
        echo  Compacting: %%f
        powershell -Command "Optimize-VHD -Path '%%f' -Mode Full" 2>nul
    )
    echo  Done.
)

if "%choice%"=="5" (
    echo.
    echo  ================================================================
    echo                    COMPLETE WSL REMOVAL
    echo  ================================================================
    echo.
    echo  This will:
    echo   - Save forensic data for ALL distributions
    echo   - Remove all distributions
    echo   - Disable WSL features
    echo   - Clean all WSL data
    echo.
    set /p "confirm=Type 'REMOVE WSL' to confirm: "
    if "!confirm!"=="REMOVE WSL" (
        echo.
        echo  [1/4] Collecting forensic data...
        for /f "usebackq tokens=*" %%a in (`powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%get-distros.ps1"`) do (
            call :forensic_dump "%%a"
        )
        
        echo  [2/4] Removing all distributions...
        for /f "usebackq tokens=*" %%a in (`powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%get-distros.ps1"`) do (
            wsl --unregister "%%a" 2>nul
        )
        
        echo  [3/4] Disabling WSL features...
        dism.exe /online /disable-feature /featurename:Microsoft-Windows-Subsystem-Linux /norestart >nul 2>&1
        dism.exe /online /disable-feature /featurename:VirtualMachinePlatform /norestart >nul 2>&1
        
        echo  [4/4] Creating final report...
        call :create_removal_report
        
        echo.
        echo  WSL completely removed.
        echo  Forensic reports saved to: %FORENSICS_DIR%
        echo.
        echo  Restart your computer to complete removal.
    ) else (
        echo  Operation cancelled.
    )
)

if "%choice%"=="6" (
    echo.
    echo  Forensic Reports:
    echo  ----------------------------------------------------------------
    if exist "%FORENSICS_DIR%" (
        set "fcount=0"
        for %%f in ("%FORENSICS_DIR%\*.txt") do (
            set /a "fcount+=1"
            set "report_!fcount!=%%~nxf"
            echo   [!fcount!]  %%~nxf
        )
        echo  ----------------------------------------------------------------
        
        if !fcount! GTR 0 (
            echo.
            set /p "fselection=Select report to view (0 to skip): "
            if not "!fselection!"=="0" (
                set "viewfile=!report_%fselection%!"
                if not "!viewfile!"=="" (
                    type "%FORENSICS_DIR%\!viewfile!" | more
                )
            )
        ) else (
            echo  No forensic reports found.
        )
    ) else (
        echo  No forensic reports found.
    )
)

echo.
pause
goto :eof

:: ============================================================================
:: Forensic Dump Function
:: ============================================================================
:forensic_dump
set "fdistro=%~1"
set "timestamp=%date:~-4%%date:~3,2%%date:~0,2%_%time:~0,2%%time:~3,2%%time:~6,2%"
set "timestamp=%timestamp: =0%"
set "report_file=%FORENSICS_DIR%\%fdistro%_forensic_%timestamp%.txt"

echo  Collecting forensic data for %fdistro%...

(
echo ================================================================================
echo                        WSL FORENSIC REPORT
echo ================================================================================
echo.
echo Report Generated: %date% %time%
echo Distribution: %fdistro%
echo Report File: %report_file%
echo.
echo ================================================================================
echo                        HOST SYSTEM INFORMATION
echo ================================================================================
echo.
echo [Computer Name]
hostname
echo.
echo [Windows Version]
ver
echo.
echo [System Info]
systeminfo | findstr /B /C:"OS Name" /C:"OS Version" /C:"System Type" /C:"Total Physical Memory"
echo.
echo [Current User]
whoami
echo.
echo [Network Configuration]
ipconfig /all | findstr /C:"Host Name" /C:"IPv4" /C:"Subnet" /C:"Gateway" /C:"DNS"
echo.
echo ================================================================================
echo                        WSL ENVIRONMENT
echo ================================================================================
echo.
echo [WSL Version]
wsl --version 2^>nul
echo.
echo [All WSL Distributions]
wsl --list --verbose 2^>nul
echo.
echo [WSL Status]
wsl --status 2^>nul
echo.
echo ================================================================================
echo                        DISTRIBUTION: %fdistro%
echo ================================================================================
echo.
) > "%report_file%"

:: Collect data from inside WSL
(
echo [OS Release Information]
wsl -d "%fdistro%" -- cat /etc/os-release 2^>nul
echo.
echo [Kernel Version]
wsl -d "%fdistro%" -- uname -a 2^>nul
echo.
echo [System Uptime]
wsl -d "%fdistro%" -- uptime 2^>nul
echo.
echo ================================================================================
echo                        USER INFORMATION
echo ================================================================================
echo.
echo [Current User]
wsl -d "%fdistro%" -- whoami 2^>nul
echo.
echo [User ID]
wsl -d "%fdistro%" -- id 2^>nul
echo.
echo [All Users - /etc/passwd]
wsl -d "%fdistro%" -- cat /etc/passwd 2^>nul
echo.
echo [Groups - /etc/group]
wsl -d "%fdistro%" -- cat /etc/group 2^>nul
echo.
echo [Sudo Users]
wsl -d "%fdistro%" -- getent group sudo 2^>nul
echo.
echo [Login History]
wsl -d "%fdistro%" -- last -20 2^>nul
echo.
echo ================================================================================
echo                        SHELL HISTORY
echo ================================================================================
echo.
echo [Bash History - Root]
wsl -d "%fdistro%" -u root -- cat /root/.bash_history 2^>nul
echo.
echo [Bash History - Default User]
wsl -d "%fdistro%" -- cat ~/.bash_history 2^>nul
echo.
echo [Zsh History - Root]
wsl -d "%fdistro%" -u root -- cat /root/.zsh_history 2^>nul
echo.
echo [Zsh History - Default User]
wsl -d "%fdistro%" -- cat ~/.zsh_history 2^>nul
echo.
echo ================================================================================
echo                        INSTALLED PACKAGES
echo ================================================================================
echo.
echo [APT Packages - Debian/Ubuntu]
wsl -d "%fdistro%" -- dpkg -l 2^>nul
echo.
echo [RPM Packages - RHEL/Fedora]
wsl -d "%fdistro%" -- rpm -qa 2^>nul
echo.
echo [Pip Packages]
wsl -d "%fdistro%" -- pip3 list 2^>nul
echo.
echo [NPM Global Packages]
wsl -d "%fdistro%" -- npm list -g --depth=0 2^>nul
echo.
echo ================================================================================
echo                        NETWORK CONFIGURATION
echo ================================================================================
echo.
echo [Network Interfaces]
wsl -d "%fdistro%" -- ip addr 2^>nul
echo.
echo [Routing Table]
wsl -d "%fdistro%" -- ip route 2^>nul
echo.
echo [DNS Configuration]
wsl -d "%fdistro%" -- cat /etc/resolv.conf 2^>nul
echo.
echo [Hosts File]
wsl -d "%fdistro%" -- cat /etc/hosts 2^>nul
echo.
echo [Open Ports]
wsl -d "%fdistro%" -- ss -tuln 2^>nul
echo.
echo ================================================================================
echo                        FILESYSTEM INFORMATION
echo ================================================================================
echo.
echo [Disk Usage]
wsl -d "%fdistro%" -- df -h 2^>nul
echo.
echo [Mount Points]
wsl -d "%fdistro%" -- mount 2^>nul
echo.
echo [Home Directory Contents]
wsl -d "%fdistro%" -- ls -la ~ 2^>nul
echo.
echo ================================================================================
echo                        RUNNING PROCESSES
echo ================================================================================
echo.
wsl -d "%fdistro%" -- ps aux 2^>nul
echo.
echo ================================================================================
echo                        SCHEDULED TASKS
echo ================================================================================
echo.
echo [Crontab - Root]
wsl -d "%fdistro%" -u root -- crontab -l 2^>nul
echo.
echo [Crontab - User]
wsl -d "%fdistro%" -- crontab -l 2^>nul
echo.
echo ================================================================================
echo                        SECURITY INFORMATION
echo ================================================================================
echo.
echo [SSH Configuration]
wsl -d "%fdistro%" -- cat /etc/ssh/sshd_config 2^>nul
echo.
echo [SSH Authorized Keys - Root]
wsl -d "%fdistro%" -u root -- cat /root/.ssh/authorized_keys 2^>nul
echo.
echo [SSH Authorized Keys - User]
wsl -d "%fdistro%" -- cat ~/.ssh/authorized_keys 2^>nul
echo.
echo [Firewall Status - UFW]
wsl -d "%fdistro%" -- ufw status verbose 2^>nul
echo.
echo [SUID Files]
wsl -d "%fdistro%" -- find /usr -perm -4000 -type f 2^>nul
echo.
echo ================================================================================
echo                        DOCKER INFORMATION
echo ================================================================================
echo.
echo [Docker Version]
wsl -d "%fdistro%" -- docker --version 2^>nul
echo.
echo [Docker Containers]
wsl -d "%fdistro%" -- docker ps -a 2^>nul
echo.
echo [Docker Images]
wsl -d "%fdistro%" -- docker images 2^>nul
echo.
echo ================================================================================
echo                        SYSTEMD SERVICES
echo ================================================================================
echo.
echo [Enabled Services]
wsl -d "%fdistro%" -- systemctl list-unit-files --state=enabled 2^>nul
echo.
echo ================================================================================
echo                        WSL CONFIGURATION
echo ================================================================================
echo.
echo [/etc/wsl.conf]
wsl -d "%fdistro%" -- cat /etc/wsl.conf 2^>nul
echo.
echo ================================================================================
echo                        ENVIRONMENT VARIABLES
echo ================================================================================
echo.
wsl -d "%fdistro%" -- env 2^>nul
echo.
echo ================================================================================
echo                        AUTH LOGS - last 100 lines
echo ================================================================================
echo.
wsl -d "%fdistro%" -- tail -100 /var/log/auth.log 2^>nul
echo.
echo ================================================================================
echo                        SYSTEM LOGS - last 50 lines
echo ================================================================================
echo.
wsl -d "%fdistro%" -- tail -50 /var/log/syslog 2^>nul
echo.
echo ================================================================================
echo                        END OF FORENSIC REPORT
echo ================================================================================
echo.
echo Report completed: %date% %time%
) >> "%report_file%"

echo  Forensic report saved: %report_file%
goto :eof

:: ============================================================================
:: Create Final Removal Report
:: ============================================================================
:create_removal_report
set "timestamp=%date:~-4%%date:~3,2%%date:~0,2%_%time:~0,2%%time:~3,2%%time:~6,2%"
set "timestamp=%timestamp: =0%"
set "removal_report=%FORENSICS_DIR%\WSL_COMPLETE_REMOVAL_%timestamp%.txt"

(
echo ================================================================================
echo                    WSL COMPLETE REMOVAL REPORT
echo ================================================================================
echo.
echo Removal Date: %date% %time%
echo.
echo [System Information]
systeminfo | findstr /B /C:"OS Name" /C:"OS Version" /C:"Original Install Date"
echo.
echo [User Performing Removal]
whoami
echo.
echo [Distributions Removed]
dir /b "%FORENSICS_DIR%\*_forensic_*.txt" 2^>nul
echo.
echo [Actions Performed]
echo - All WSL distributions unregistered
echo - WSL feature disabled
echo - Virtual Machine Platform disabled
echo.
echo [Forensic Reports Location]
echo %FORENSICS_DIR%
echo.
echo ================================================================================
) > "%removal_report%"

echo  Removal report saved: %removal_report%
goto :eof
