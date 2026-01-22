@echo off
setlocal EnableDelayedExpansion
chcp 65001 >nul 2>&1
title WSL Enterprise Manager v2.0

:: ============================================================================
:: WSL Enterprise Manager - Production Ready One-Click WSL Setup
:: Version: 2.0.0
:: ============================================================================

:: Enable ANSI colors in Windows 10+
for /f "tokens=3" %%a in ('reg query HKCU\Console /v VirtualTerminalLevel 2^>nul') do set "VT=%%a"
if not defined VT (
    reg add HKCU\Console /v VirtualTerminalLevel /t REG_DWORD /d 1 /f >nul 2>&1
)

:: Configuration
set "SCRIPT_DIR=%~dp0"
set "CONFIG_DIR=%SCRIPT_DIR%config"
set "LOGS_DIR=%SCRIPT_DIR%logs"
set "BACKUPS_DIR=%SCRIPT_DIR%backups"
set "EXPORTS_DIR=%SCRIPT_DIR%exports"
set "FORENSICS_DIR=%SCRIPT_DIR%forensics"
set "LOG_FILE=%LOGS_DIR%\wsl-manager_%date:~-4%%date:~3,2%%date:~0,2%.log"

:: Create required directories
for %%d in ("%CONFIG_DIR%" "%LOGS_DIR%" "%BACKUPS_DIR%" "%EXPORTS_DIR%" "%FORENSICS_DIR%") do (
    if not exist %%d mkdir %%d 2>nul
)

call :log "WSL Enterprise Manager started"

:main_menu
cls
echo.
echo ========================================================================
echo                    WSL ENTERPRISE MANAGER v2.0
echo           Enterprise-Grade Production Ready WSL Management
echo ========================================================================
echo.
echo  QUICK ACTIONS
echo  ------------------------------------------------------------------------
echo   [1]  Quick Install (GUI/Headless)    [2]  List All Installations
echo   [3]  Advanced Installation           [4]  Manage Existing WSL
echo.
echo  SYSTEM OPERATIONS
echo  ------------------------------------------------------------------------
echo   [5]  Backup and Export               [6]  Import and Restore
echo   [7]  Uninstall and Cleanup           [8]  Update All Distributions
echo.
echo  ADVANCED FEATURES
echo  ------------------------------------------------------------------------
echo   [9]  GUI Desktop Environments        [10] Docker Integration
echo   [11] Security and Hardening          [12] Resource Monitor
echo.
echo  CONFIGURATION
echo  ------------------------------------------------------------------------
echo   [13] WSL Global Settings             [14] Network Configuration
echo   [15] Storage Management              [16] View Logs
echo   [17] Health Check
echo.
echo   [0]  Exit
echo.
set /p "choice=Select an option [0-17]: "

if "%choice%"=="1" goto quick_install
if "%choice%"=="2" goto list_installations
if "%choice%"=="3" goto advanced_install
if "%choice%"=="4" goto manage_wsl
if "%choice%"=="5" goto backup_export
if "%choice%"=="6" goto import_restore
if "%choice%"=="7" goto uninstall_cleanup
if "%choice%"=="8" goto update_all
if "%choice%"=="9" goto gui_environments
if "%choice%"=="10" goto docker_integration
if "%choice%"=="11" goto security_hardening
if "%choice%"=="12" goto resource_monitor
if "%choice%"=="13" goto global_settings
if "%choice%"=="14" goto network_config
if "%choice%"=="15" goto storage_management
if "%choice%"=="16" goto view_logs
if "%choice%"=="17" call "%SCRIPT_DIR%scripts\healthcheck.bat" & goto main_menu
if "%choice%"=="0" goto exit_script

echo Invalid option. Please try again.
timeout /t 2 >nul
goto main_menu

:: ============================================================================
:: Quick Install
:: ============================================================================
:quick_install
cls
echo.
echo ========================================================================
echo           QUICK INSTALL - WSL Distribution (GUI or Headless)
echo ========================================================================
echo.
echo  Select your preferred Linux distribution:
echo  ------------------------------------------------------------------------
echo   [1]  Ubuntu 22.04 LTS (Recommended)
echo   [2]  Ubuntu 24.04 LTS (Latest)
echo   [3]  Debian 12 (Bookworm)
echo   [4]  Kali Linux (Security/Pentest)
echo   [5]  openSUSE Leap 15.5
echo   [6]  Alpine Linux (Lightweight)
echo   [7]  Arch Linux
echo   [8]  Fedora Remix
echo   [9]  Oracle Linux 9
echo   [10] AlmaLinux 9
echo.
echo   [0]  Back to Main Menu
echo.
set /p "distro_choice=Select distribution [0-10]: "

if "%distro_choice%"=="0" goto main_menu
if "%distro_choice%"=="1" set "DISTRO=Ubuntu-22.04" & set "DISTRO_NAME=Ubuntu 22.04 LTS"
if "%distro_choice%"=="2" set "DISTRO=Ubuntu-24.04" & set "DISTRO_NAME=Ubuntu 24.04 LTS"
if "%distro_choice%"=="3" set "DISTRO=Debian" & set "DISTRO_NAME=Debian"
if "%distro_choice%"=="4" set "DISTRO=kali-linux" & set "DISTRO_NAME=Kali Linux"
if "%distro_choice%"=="5" set "DISTRO=openSUSE-Leap-15.5" & set "DISTRO_NAME=openSUSE Leap"
if "%distro_choice%"=="6" set "DISTRO=Alpine" & set "DISTRO_NAME=Alpine Linux"
if "%distro_choice%"=="7" set "DISTRO=Arch" & set "DISTRO_NAME=Arch Linux"
if "%distro_choice%"=="8" set "DISTRO=FedoraRemix" & set "DISTRO_NAME=Fedora Remix"
if "%distro_choice%"=="9" set "DISTRO=OracleLinux_9_1" & set "DISTRO_NAME=Oracle Linux"
if "%distro_choice%"=="10" set "DISTRO=AlmaLinux-9" & set "DISTRO_NAME=AlmaLinux"

if not defined DISTRO (
    echo Invalid selection.
    timeout /t 2 >nul
    goto quick_install
)

echo.
echo  Installation Type for %DISTRO_NAME%:
echo  ------------------------------------------------------------------------
echo   [1]  Headless / CLI Only
echo        Minimal installation, command-line interface only.
echo        Best for: Servers, development, Docker hosts
echo.
echo   [2]  With GUI Desktop
echo        Full desktop environment with graphical interface.
echo        Best for: Desktop usage, GUI applications
echo.
set /p "gui_choice=Select installation type [1-2]: "

if "%gui_choice%"=="1" set "GUI=none" & set "GUI_NAME=Headless"
if "%gui_choice%"=="2" set "GUI=gui" & set "GUI_NAME=With GUI"

if not defined GUI (
    echo Invalid selection.
    timeout /t 2 >nul
    goto quick_install
)

echo.
echo  Installing %DISTRO_NAME% (%GUI_NAME%)...
echo.
wsl --install -d %DISTRO%

call :log "Installed %DISTRO_NAME% (%GUI_NAME%)"

if "%gui_choice%"=="2" (
    echo.
    echo  After first boot, run scripts\install-gui.bat to add desktop.
)
echo.
pause
goto main_menu

:: ============================================================================
:: List All Installations
:: ============================================================================
:list_installations
cls
echo.
echo ========================================================================
echo                    WSL INSTALLATIONS OVERVIEW
echo ========================================================================
echo.
echo  Currently Installed WSL Distributions:
echo  ------------------------------------------------------------------------
wsl --list --verbose 2>nul
if errorlevel 1 (
    echo  No WSL distributions installed or WSL not enabled.
    echo.
    set /p "enable_wsl=Would you like to enable WSL now? [Y/N]: "
    if /i "!enable_wsl!"=="Y" call :enable_wsl
)
echo.
echo  Available Distributions from Microsoft Store:
echo  ------------------------------------------------------------------------
wsl --list --online 2>nul
echo.
pause
goto main_menu

:: ============================================================================
:: Advanced Installation
:: ============================================================================
:advanced_install
cls
echo.
echo ========================================================================
echo                    ADVANCED INSTALLATION OPTIONS
echo ========================================================================
echo.
echo   [1]  Custom Installation Location
echo   [2]  Clone Existing Distribution
echo   [3]  Multi-Instance Setup
echo   [4]  Development Environment Preset
echo   [5]  DevOps/CI-CD Environment
echo   [6]  Server Environment Preset
echo.
echo   [0]  Back to Main Menu
echo.
set /p "adv_choice=Select option [0-6]: "

if "%adv_choice%"=="0" goto main_menu
if "%adv_choice%"=="1" goto custom_location
if "%adv_choice%"=="2" goto clone_distro
if "%adv_choice%"=="3" call "%SCRIPT_DIR%scripts\multi-instance.bat" & goto advanced_install
if "%adv_choice%"=="4" call "%SCRIPT_DIR%scripts\dev-setup.bat" & goto advanced_install
if "%adv_choice%"=="5" goto devops_preset
if "%adv_choice%"=="6" goto server_preset
goto advanced_install

:custom_location
echo.
wsl --list --quiet 2>nul
set /p "source_distro=Enter source distribution name: "
set /p "new_name=Enter new instance name: "
set /p "custom_path=Enter installation path (e.g., D:\WSL\): "

if not exist "%custom_path%" mkdir "%custom_path%" 2>nul
echo  Exporting %source_distro%...
wsl --export "%source_distro%" "%TEMP%\wsl_custom.tar"
echo  Importing to %custom_path%%new_name%...
wsl --import "%new_name%" "%custom_path%%new_name%" "%TEMP%\wsl_custom.tar"
del "%TEMP%\wsl_custom.tar" 2>nul
echo  Done!
call :log "Created %new_name% at %custom_path%"
pause
goto advanced_install

:clone_distro
echo.
wsl --list --quiet 2>nul
set /p "source_distro=Enter source distribution name: "
set /p "clone_name=Enter new clone name: "
set /p "clone_path=Enter clone path: "

if not exist "%clone_path%" mkdir "%clone_path%" 2>nul
echo  Cloning %source_distro%...
wsl --export "%source_distro%" "%EXPORTS_DIR%\%source_distro%_clone.tar"
wsl --import "%clone_name%" "%clone_path%" "%EXPORTS_DIR%\%source_distro%_clone.tar"
echo  Clone created!
call :log "Cloned %source_distro% to %clone_name%"
pause
goto advanced_install

:devops_preset
echo.
echo  DevOps Environment includes:
echo   - Docker and Docker Compose
echo   - Kubernetes tools (kubectl, helm, k9s)
echo   - Terraform and Ansible
echo   - AWS CLI / Azure CLI
echo.
set /p "confirm=Install DevOps preset? [Y/N]: "
if /i "%confirm%"=="Y" (
    echo  Installing Ubuntu for DevOps...
    wsl --install -d Ubuntu-22.04
    echo.
    echo  After setup, run: scripts\dev-setup.bat and select DevOps
)
pause
goto advanced_install

:server_preset
echo.
echo  Server Environment includes:
echo   - Security hardening
echo   - Firewall configuration
echo   - SSH setup
echo   - Monitoring tools
echo.
set /p "confirm=Install Server preset? [Y/N]: "
if /i "%confirm%"=="Y" (
    wsl --install -d Ubuntu-22.04
    echo.
    echo  After setup, run: scripts\security.bat
)
pause
goto advanced_install

:: ============================================================================
:: Manage Existing WSL
:: ============================================================================
:manage_wsl
cls
echo.
echo ========================================================================
echo                    MANAGE WSL DISTRIBUTIONS
echo ========================================================================
echo.
echo  Available distributions:
wsl --list --verbose 2>nul
echo.
echo   [1]  Start Distribution          [5]  Open Shell
echo   [2]  Stop Distribution           [6]  Run Command
echo   [3]  Restart Distribution        [7]  View Distribution Info
echo   [4]  Set Default Distribution    [8]  Shutdown All WSL
echo.
echo   [0]  Back to Main Menu
echo.
set /p "manage_choice=Select option [0-8]: "

if "%manage_choice%"=="0" goto main_menu

set /p "distro=Enter distribution name: "

if "%manage_choice%"=="1" wsl -d "%distro%" exit & echo Started %distro%.
if "%manage_choice%"=="2" wsl --terminate "%distro%" & echo Stopped %distro%.
if "%manage_choice%"=="3" wsl --terminate "%distro%" & timeout /t 1 >nul & wsl -d "%distro%" exit & echo Restarted %distro%.
if "%manage_choice%"=="4" wsl --set-default "%distro%" & echo Default set to %distro%.
if "%manage_choice%"=="5" start wsl -d "%distro%"
if "%manage_choice%"=="6" (
    set /p "cmd=Enter command: "
    wsl -d "%distro%" !cmd!
)
if "%manage_choice%"=="7" (
    echo.
    wsl -d "%distro%" cat /etc/os-release
    echo.
    wsl -d "%distro%" df -h /
    echo.
    wsl -d "%distro%" free -h
)
if "%manage_choice%"=="8" wsl --shutdown & echo All WSL shut down.

pause
goto manage_wsl

:: ============================================================================
:: Backup and Export
:: ============================================================================
:backup_export
cls
echo.
echo ========================================================================
echo                    BACKUP AND EXPORT
echo ========================================================================
echo.
wsl --list --quiet 2>nul
echo.
echo   [1]  Export Single Distribution
echo   [2]  Export All Distributions
echo   [3]  Schedule Backup
echo.
echo   [0]  Back to Main Menu
echo.
set /p "backup_choice=Select option [0-3]: "

if "%backup_choice%"=="0" goto main_menu

if "%backup_choice%"=="1" (
    set /p "distro=Enter distribution name: "
    set "ts=%date:~-4%%date:~3,2%%date:~0,2%_%time:~0,2%%time:~3,2%"
    set "ts=!ts: =0!"
    echo  Exporting !distro!...
    wsl --export "!distro!" "%EXPORTS_DIR%\!distro!_!ts!.tar"
    echo  Saved to: %EXPORTS_DIR%\!distro!_!ts!.tar
    call :log "Exported !distro!"
)

if "%backup_choice%"=="2" (
    echo  Exporting all distributions...
    for /f "tokens=*" %%a in ('wsl --list --quiet 2^>nul') do (
        set "d=%%a"
        set "d=!d: =!"
        if not "!d!"=="" (
            set "ts=%date:~-4%%date:~3,2%%date:~0,2%"
            echo  Exporting !d!...
            wsl --export "!d!" "%EXPORTS_DIR%\!d!_!ts!.tar" 2>nul
        )
    )
    echo  All exports complete!
    call :log "Exported all distributions"
)

if "%backup_choice%"=="3" call "%SCRIPT_DIR%scripts\scheduler.bat"

pause
goto backup_export

:: ============================================================================
:: Import and Restore
:: ============================================================================
:import_restore
cls
echo.
echo ========================================================================
echo                    IMPORT AND RESTORE
echo ========================================================================
echo.
echo  Available Backups:
dir /b "%EXPORTS_DIR%\*.tar" 2>nul
echo.
echo   [1]  Import from TAR file
echo   [2]  List Available Backups
echo.
echo   [0]  Back to Main Menu
echo.
set /p "import_choice=Select option [0-2]: "

if "%import_choice%"=="0" goto main_menu

if "%import_choice%"=="1" (
    set /p "tar_file=Enter TAR filename: "
    set /p "distro_name=Enter new distribution name: "
    set /p "install_path=Enter installation path: "
    if not exist "!install_path!" mkdir "!install_path!" 2>nul
    echo  Importing...
    wsl --import "!distro_name!" "!install_path!" "%EXPORTS_DIR%\!tar_file!"
    echo  Import complete!
    call :log "Imported !tar_file! as !distro_name!"
)

if "%import_choice%"=="2" (
    echo.
    for %%f in ("%EXPORTS_DIR%\*.tar") do (
        echo  %%~nxf - %%~zf bytes
    )
)

pause
goto import_restore

:: ============================================================================
:: Uninstall and Cleanup (Forensic Mode)
:: ============================================================================
:uninstall_cleanup
cls
echo.
echo ========================================================================
echo             UNINSTALL AND CLEANUP (Forensic Mode)
echo ========================================================================
echo.
echo  NOTE: Forensic data is collected before destruction.
echo  WARNING: These operations are destructive!
echo.
wsl --list --verbose 2>nul
echo.
echo   [1]  Unregister Single Distribution (with forensics)
echo   [2]  Unregister All Distributions (with forensics)
echo   [3]  Clean Temporary Files
echo   [4]  Compact VHD Files
echo   [5]  Complete WSL Removal (with full forensics)
echo   [6]  View Forensic Reports
echo.
echo   [0]  Back to Main Menu
echo.
set /p "uninstall_choice=Select option [0-6]: "

if "%uninstall_choice%"=="0" goto main_menu
if "%uninstall_choice%"=="1" call "%SCRIPT_DIR%scripts\destructor.bat" & goto uninstall_cleanup
if "%uninstall_choice%"=="2" call "%SCRIPT_DIR%scripts\destructor.bat" & goto uninstall_cleanup
if "%uninstall_choice%"=="3" (
    del /q "%TEMP%\wsl-*" 2>nul
    del /q "%EXPORTS_DIR%\*.tmp" 2>nul
    echo  Temporary files cleaned.
)
if "%uninstall_choice%"=="4" call "%SCRIPT_DIR%scripts\storage.bat" & goto uninstall_cleanup
if "%uninstall_choice%"=="5" call "%SCRIPT_DIR%scripts\destructor.bat" & goto uninstall_cleanup
if "%uninstall_choice%"=="6" (
    echo.
    echo  Forensic Reports:
    if exist "%FORENSICS_DIR%" (
        dir /b /o-d "%FORENSICS_DIR%\*.txt" 2>nul
    ) else (
        echo  No reports found.
    )
)
pause
goto uninstall_cleanup

:: ============================================================================
:: Update All Distributions
:: ============================================================================
:update_all
cls
echo.
echo ========================================================================
echo                    UPDATE ALL DISTRIBUTIONS
echo ========================================================================
echo.
echo  Updating all distributions...
for /f "tokens=*" %%d in ('wsl --list --quiet 2^>nul') do (
    set "dist=%%d"
    set "dist=!dist: =!"
    if not "!dist!"=="" (
        echo.
        echo  Updating !dist!...
        wsl -d "!dist!" -u root -- bash -c "apt update && apt upgrade -y 2>/dev/null || yum update -y 2>/dev/null || dnf update -y 2>/dev/null"
    )
)
echo.
echo  All distributions updated!
call :log "Updated all distributions"
pause
goto main_menu

:: ============================================================================
:: GUI Desktop Environments
:: ============================================================================
:gui_environments
call "%SCRIPT_DIR%scripts\install-gui.bat"
goto main_menu

:: ============================================================================
:: Docker Integration
:: ============================================================================
:docker_integration
call "%SCRIPT_DIR%scripts\docker-setup.bat"
goto main_menu

:: ============================================================================
:: Security and Hardening
:: ============================================================================
:security_hardening
call "%SCRIPT_DIR%scripts\security.bat"
goto main_menu

:: ============================================================================
:: Resource Monitor
:: ============================================================================
:resource_monitor
call "%SCRIPT_DIR%scripts\monitor.bat"
goto main_menu

:: ============================================================================
:: Global Settings
:: ============================================================================
:global_settings
call "%SCRIPT_DIR%scripts\config.bat"
goto main_menu

:: ============================================================================
:: Network Configuration
:: ============================================================================
:network_config
call "%SCRIPT_DIR%scripts\network.bat"
goto main_menu

:: ============================================================================
:: Storage Management
:: ============================================================================
:storage_management
call "%SCRIPT_DIR%scripts\storage.bat"
goto main_menu

:: ============================================================================
:: View Logs
:: ============================================================================
:view_logs
cls
echo.
echo ========================================================================
echo                    WSL MANAGER LOGS
echo ========================================================================
echo.
if exist "%LOG_FILE%" (
    type "%LOG_FILE%"
) else (
    echo  No logs found for today.
)
echo.
echo  Log files:
dir /b "%LOGS_DIR%\*.log" 2>nul
echo.
pause
goto main_menu

:: ============================================================================
:: Helper Functions
:: ============================================================================

:log
echo [%date% %time%] %~1 >> "%LOG_FILE%"
goto :eof

:enable_wsl
echo.
echo  Enabling WSL feature...
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
echo  Enabling Virtual Machine Platform...
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
wsl --set-default-version 2 >nul 2>&1
echo.
echo  Please restart your computer to complete WSL installation.
call :log "Enabled WSL feature"
pause
goto :eof

:exit_script
call :log "WSL Enterprise Manager closed"
echo.
echo  Thank you for using WSL Enterprise Manager!
echo.
endlocal
exit /b 0
