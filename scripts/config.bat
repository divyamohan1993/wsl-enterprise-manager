@echo off
setlocal EnableDelayedExpansion
chcp 65001 >nul 2>&1
title WSL Global Configuration

set "CONFIG_FILE=%USERPROFILE%\.wslconfig"

cls
echo.
echo ========================================================================
echo                    WSL GLOBAL CONFIGURATION
echo ========================================================================
echo.

echo  [1] View current configuration
echo  [2] Configure memory limit
echo  [3] Configure processor count
echo  [4] Configure swap
echo  [5] Configure network
echo  [6] Set WSL version for distribution
echo  [7] Apply recommended settings
echo  [8] Edit .wslconfig manually
echo  [9] Cancel
echo.
set /p "choice=Select [1-9]: "

if "%choice%"=="9" goto :eof

if "%choice%"=="1" (
    echo.
    echo  Current .wslconfig:
    if exist "%CONFIG_FILE%" (
        type "%CONFIG_FILE%"
    ) else (
        echo  No .wslconfig found.
    )
    echo.
    echo  WSL Status:
    wsl --status 2>nul
)

if "%choice%"=="2" (
    echo.
    echo  Current host memory:
    for /f "tokens=2 delims==" %%a in ('wmic os get TotalVisibleMemorySize /value 2^>nul') do (
        set /a "totalgb=%%a/1048576"
        echo    !totalgb! GB
    )
    set /p "mem=Enter memory limit (e.g., 4GB): "
    call :update_config "memory" "!mem!"
    echo  Memory configured to !mem!
)

if "%choice%"=="3" (
    echo.
    echo  Available processors: %NUMBER_OF_PROCESSORS%
    set /p "proc=Enter processor count (1-%NUMBER_OF_PROCESSORS%): "
    call :update_config "processors" "!proc!"
    echo  Processors configured to !proc!
)

if "%choice%"=="4" (
    echo.
    set /p "swap=Enter swap size (e.g., 8GB, or 0 to disable): "
    call :update_config "swap" "!swap!"
    echo  Swap configured to !swap!
)

if "%choice%"=="5" (
    echo.
    echo  Network Options:
    echo   [1] Default networking
    echo   [2] NAT mode
    echo   [3] Mirrored networking (Windows 11)
    set /p "netmode=Select: "
    if "!netmode!"=="2" call :update_config "networkingMode" "NAT"
    if "!netmode!"=="3" call :update_config "networkingMode" "mirrored"
    echo  Network mode configured.
)

if "%choice%"=="6" (
    echo.
    wsl --list --verbose 2>nul
    set /p "distro=Enter distribution: "
    set /p "ver=Enter WSL version (1 or 2): "
    wsl --set-version "!distro!" !ver!
)

if "%choice%"=="7" (
    echo.
    echo  Applying recommended settings...
    (
        echo [wsl2]
        echo memory=4GB
        echo processors=2
        echo swap=4GB
        echo localhostForwarding=true
        echo guiApplications=true
    ) > "%CONFIG_FILE%"
    echo  Recommended settings applied!
    echo  Restart WSL for changes to take effect.
)

if "%choice%"=="8" (
    if not exist "%CONFIG_FILE%" (
        echo [wsl2] > "%CONFIG_FILE%"
    )
    notepad "%CONFIG_FILE%"
)

echo.
echo  Run 'wsl --shutdown' to apply changes.
pause
goto :eof

:update_config
if not exist "%CONFIG_FILE%" (
    echo [wsl2] > "%CONFIG_FILE%"
)
findstr /i "%~1=" "%CONFIG_FILE%" >nul 2>&1
if errorlevel 1 (
    echo %~1=%~2 >> "%CONFIG_FILE%"
) else (
    powershell -Command "(Get-Content '%CONFIG_FILE%') -replace '%~1=.*', '%~1=%~2' | Set-Content '%CONFIG_FILE%'"
)
goto :eof
