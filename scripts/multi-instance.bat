@echo off
setlocal EnableDelayedExpansion
chcp 65001 >nul 2>&1
title WSL Multi-Instance Manager

set "SCRIPT_DIR=%~dp0"
set "EXPORTS_DIR=%SCRIPT_DIR%..\exports"

cls
echo.
echo ========================================================================
echo                    WSL MULTI-INSTANCE MANAGER
echo ========================================================================
echo.
echo  Create multiple instances of the same distribution
echo  for different projects or environments.
echo.

echo  [1] Create new instance from existing distribution
echo  [2] Create instance from template
echo  [3] List all instances
echo  [4] Delete instance
echo  [5] Clone instance
echo  [6] Cancel
echo.
set /p "choice=Select [1-6]: "

if "%choice%"=="6" goto :eof

if "%choice%"=="3" (
    echo.
    echo  All WSL Instances:
    echo  ------------------
    wsl --list --verbose
    pause
    goto :eof
)

:: For other options, need to select or show distributions
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

if "%choice%"=="1" (
    if !count!==0 (
        echo  No WSL distributions found!
        pause
        goto :eof
    )
    
    set /p "selection=Select source distribution [1-!count!]: "
    set "SOURCE=!distro_%selection%!"
    
    set /p "name=New instance name: "
    set /p "path=Installation path: "
    
    if not exist "!path!" mkdir "!path!"
    
    echo.
    echo  Exporting !SOURCE!...
    wsl --export "!SOURCE!" "%TEMP%\wsl_instance.tar"
    
    echo  Creating instance !name!...
    wsl --import "!name!" "!path!" "%TEMP%\wsl_instance.tar"
    
    del "%TEMP%\wsl_instance.tar"
    echo  Instance created!
    
    echo.
    set /p "user=Default username (press Enter to skip): "
    if not "!user!"=="" (
        wsl -d "!name!" -u root -- bash -c "echo '[user]' > /etc/wsl.conf && echo 'default=!user!' >> /etc/wsl.conf"
        wsl --terminate "!name!" >nul 2>&1
        echo  Default user set to !user!
    )
)

if "%choice%"=="2" (
    echo.
    echo  Templates:
    echo   [1] Development - Dev tools pre-installed
    echo   [2] DevOps - Container/cloud tools
    echo   [3] GUI - Desktop environment
    echo   [4] Minimal - Base system only
    echo.
    set /p "template=Select template: "
    set /p "name=Instance name: "
    set /p "path=Installation path: "
    
    if not exist "!path!" mkdir "!path!"
    
    echo  Installing base Ubuntu...
    wsl --install Ubuntu-22.04 --no-launch
    timeout /t 5 >nul
    
    echo  Creating instance...
    wsl --export Ubuntu-22.04 "%TEMP%\base.tar"
    wsl --import "!name!" "!path!" "%TEMP%\base.tar"
    del "%TEMP%\base.tar"
    
    if "!template!"=="1" (
        echo  Applying development template...
        wsl -d "!name!" -u root -- bash /mnt/r/wsl-gui/linux-scripts/dev-setup.sh
    )
    if "!template!"=="2" (
        echo  Applying DevOps template...
        wsl -d "!name!" -u root -- bash /mnt/r/wsl-gui/linux-scripts/devops-setup.sh
    )
    if "!template!"=="3" (
        echo  Applying GUI template...
        wsl -d "!name!" -u root -- bash /mnt/r/wsl-gui/linux-scripts/gui-setup.sh
    )
    
    echo  Instance created from template!
)

if "%choice%"=="4" (
    if !count!==0 (
        echo  No WSL distributions found!
        pause
        goto :eof
    )
    
    set /p "selection=Select instance to delete [1-!count!]: "
    set "DISTRO=!distro_%selection%!"
    
    echo.
    echo  This will permanently delete !DISTRO!!
    set /p "confirm=Type 'DELETE' to confirm: "
    if "!confirm!"=="DELETE" (
        wsl --unregister "!DISTRO!"
        echo  Instance deleted.
    )
)

if "%choice%"=="5" (
    if !count!==0 (
        echo  No WSL distributions found!
        pause
        goto :eof
    )
    
    set /p "selection=Select source instance [1-!count!]: "
    set "SOURCE=!distro_%selection%!"
    
    set /p "name=Clone name: "
    set /p "path=Clone path: "
    
    if not exist "!path!" mkdir "!path!"
    
    echo  Cloning !SOURCE! to !name!...
    wsl --export "!SOURCE!" "%TEMP%\clone.tar"
    wsl --import "!name!" "!path!" "%TEMP%\clone.tar"
    del "%TEMP%\clone.tar"
    echo  Clone created!
)

echo.
pause
