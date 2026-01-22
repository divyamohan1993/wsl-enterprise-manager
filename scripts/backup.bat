@echo off
setlocal EnableDelayedExpansion
chcp 65001 >nul 2>&1
title WSL Backup Manager

set "SCRIPT_DIR=%~dp0"
set "EXPORTS_DIR=%SCRIPT_DIR%..\exports"

if not exist "%EXPORTS_DIR%" mkdir "%EXPORTS_DIR%"

cls
echo.
echo ========================================================================
echo                    WSL BACKUP AND EXPORT MANAGER
echo ========================================================================
echo.

echo  [1] Export single distribution
echo  [2] Export all distributions
echo  [3] Import from backup
echo  [4] List available backups
echo  [5] Delete old backups
echo  [6] Cancel
echo.
set /p "choice=Select [1-6]: "

if "%choice%"=="6" goto :eof

if "%choice%"=="1" (
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
    
    if !count!==0 (
        echo  No WSL distributions found!
        pause
        goto :eof
    )
    
    set /p "selection=Select distribution [1-!count!]: "
    set "DISTRO=!distro_%selection%!"
    
    set "ts=%date:~-4%%date:~3,2%%date:~0,2%_%time:~0,2%%time:~3,2%"
    set "ts=!ts: =0!"
    set "file=%EXPORTS_DIR%\!DISTRO!_!ts!.tar"
    echo.
    echo  Exporting !DISTRO! to !file!...
    wsl --export "!DISTRO!" "!file!"
    echo  Export complete!
    for %%A in ("!file!") do echo  Size: %%~zA bytes
)

if "%choice%"=="2" (
    echo.
    echo  Exporting all distributions...
    for /f "usebackq tokens=*" %%a in (`powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%get-distros.ps1"`) do (
        set "ts=%date:~-4%%date:~3,2%%date:~0,2%"
        echo  Exporting %%a...
        wsl --export "%%a" "%EXPORTS_DIR%\%%a_!ts!.tar" 2>nul
    )
    echo  All exports complete!
)

if "%choice%"=="3" (
    echo.
    echo  Available backups:
    echo  ----------------------------------------------------------------
    set "bcount=0"
    for %%f in ("%EXPORTS_DIR%\*.tar") do (
        set /a "bcount+=1"
        set "backup_!bcount!=%%~nxf"
        echo   [!bcount!]  %%~nxf - %%~zf bytes
    )
    echo  ----------------------------------------------------------------
    echo.
    
    if !bcount!==0 (
        echo  No backups found!
        pause
        goto :eof
    )
    
    set /p "bselection=Select backup [1-!bcount!]: "
    set "file=!backup_%bselection%!"
    
    set /p "name=Enter new distribution name: "
    set /p "path=Enter install path: "
    if not exist "!path!" mkdir "!path!"
    echo  Importing !file! as !name!...
    wsl --import "!name!" "!path!" "%EXPORTS_DIR%\!file!"
    echo  Import complete!
)

if "%choice%"=="4" (
    echo.
    echo  Available Backups:
    echo  ----------------------------------------------------------------
    for %%f in ("%EXPORTS_DIR%\*.tar") do (
        echo  %%~nxf - %%~zf bytes
    )
    echo  ----------------------------------------------------------------
)

if "%choice%"=="5" (
    echo.
    set /p "days=Delete backups older than (days): "
    forfiles /p "%EXPORTS_DIR%" /m *.tar /d -!days! /c "cmd /c del @path" 2>nul
    echo  Old backups deleted.
)

echo.
pause
