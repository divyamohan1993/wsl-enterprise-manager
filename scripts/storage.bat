@echo off
setlocal EnableDelayedExpansion
chcp 65001 >nul 2>&1
title WSL Storage Manager

set "SCRIPT_DIR=%~dp0"

cls
echo.
echo ========================================================================
echo                    WSL STORAGE MANAGEMENT
echo ========================================================================
echo.

echo  [1] View disk usage
echo  [2] Compact VHD files
echo  [3] Move distribution
echo  [4] Resize VHD
echo  [5] Clean package caches
echo  [6] Find large files
echo  [7] Cancel
echo.
set /p "choice=Select [1-7]: "

if "%choice%"=="7" goto :eof

if "%choice%"=="1" (
    echo.
    echo  VHD File Sizes:
    echo  ----------------------------------------------------------------
    for /r "%LOCALAPPDATA%\Packages" %%f in (ext4.vhdx) do (
        for %%a in ("%%f") do (
            set /a "size=%%~za/1048576"
            echo  !size! MB - %%~dpf
        )
    )
    echo.
    echo  WSL Disk Usage:
    echo  ----------------------------------------------------------------
    for /f "usebackq tokens=*" %%a in (`powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%get-distros.ps1"`) do (
        echo  %%a:
        wsl -d "%%a" -- df -h / 2>nul
        echo.
    )
    pause
    goto :eof
)

if "%choice%"=="2" (
    echo.
    echo  Shutting down WSL for compaction...
    wsl --shutdown
    timeout /t 3 >nul
    
    echo  Compacting VHD files...
    for /r "%LOCALAPPDATA%\Packages" %%f in (ext4.vhdx) do (
        echo  Processing: %%f
        powershell -Command "Optimize-VHD -Path '%%f' -Mode Full" 2>nul
        if errorlevel 1 (
            echo  Using diskpart fallback...
            (
                echo select vdisk file="%%f"
                echo attach vdisk readonly
                echo compact vdisk
                echo detach vdisk
            ) > "%TEMP%\compact.txt"
            diskpart /s "%TEMP%\compact.txt" >nul 2>&1
        )
    )
    echo  Compaction complete!
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

if "%choice%"=="3" (
    set /p "newpath=Enter new location path: "
    
    if not exist "!newpath!" mkdir "!newpath!"
    
    echo  Exporting !DISTRO!...
    wsl --export "!DISTRO!" "%TEMP%\wsl_move.tar"
    
    echo  Unregistering !DISTRO!...
    wsl --unregister "!DISTRO!"
    
    echo  Importing to new location...
    wsl --import "!DISTRO!" "!newpath!" "%TEMP%\wsl_move.tar"
    
    del "%TEMP%\wsl_move.tar"
    echo  Distribution moved!
)

if "%choice%"=="4" (
    echo.
    echo  Note: Resize only increases, cannot shrink.
    set /p "size=Enter new size in GB: "
    
    set /a "sizeMB=!size!*1024"
    
    for /r "%LOCALAPPDATA%\Packages" %%f in (ext4.vhdx) do (
        echo %%f | findstr "!DISTRO!" >nul
        if not errorlevel 1 (
            wsl --shutdown
            (
                echo select vdisk file="%%f"
                echo expand vdisk maximum=!sizeMB!
            ) > "%TEMP%\resize.txt"
            diskpart /s "%TEMP%\resize.txt"
            echo  VHD resized. Now resize filesystem inside WSL.
        )
    )
)

if "%choice%"=="5" (
    echo  Cleaning caches on !DISTRO!...
    wsl -d "!DISTRO!" -u root -- bash -c "apt clean && apt autoclean && apt autoremove -y" 2>nul
    wsl -d "!DISTRO!" -u root -- bash -c "rm -rf /var/cache/apt/archives/*" 2>nul
    wsl -d "!DISTRO!" -u root -- bash -c "rm -rf /tmp/*" 2>nul
    echo  Caches cleaned!
)

if "%choice%"=="6" (
    echo  Finding large files (>100MB) on !DISTRO!...
    wsl -d "!DISTRO!" -- find / -type f -size +100M -exec ls -lh {} \; 2^>/dev/null
)

echo.
pause
