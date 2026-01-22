@echo off
setlocal EnableDelayedExpansion
chcp 65001 >nul 2>&1
title WSL Health Check

set "SCRIPT_DIR=%~dp0"

cls
echo.
echo ========================================================================
echo                    WSL HEALTH CHECK AND DIAGNOSTICS
echo ========================================================================
echo.

echo  [1] System Status
echo  ----------------------------------------------------------------

:: Check WSL feature
echo  Checking WSL feature...
dism /online /get-featureinfo /featurename:Microsoft-Windows-Subsystem-Linux 2>nul | findstr "State" | findstr "Enabled" >nul
if errorlevel 1 (
    echo    [X] WSL feature not enabled
) else (
    echo    [OK] WSL feature enabled
)

:: Check Virtual Machine Platform
dism /online /get-featureinfo /featurename:VirtualMachinePlatform 2>nul | findstr "State" | findstr "Enabled" >nul
if errorlevel 1 (
    echo    [X] Virtual Machine Platform not enabled
) else (
    echo    [OK] Virtual Machine Platform enabled
)

:: Check WSL version
echo.
echo  WSL Version:
wsl --version 2>nul

echo.
echo  [2] Installed Distributions
echo  ----------------------------------------------------------------
wsl --list --verbose 2>nul
if errorlevel 1 (
    echo  No distributions installed
)

echo.
echo  [3] Network Connectivity
echo  ----------------------------------------------------------------
echo  Testing from default distribution...
wsl -- ping -c 1 8.8.8.8 >nul 2>&1
if errorlevel 1 (
    echo    [X] No internet connectivity
) else (
    echo    [OK] Internet connectivity OK
)

wsl -- ping -c 1 google.com >nul 2>&1
if errorlevel 1 (
    echo    [X] DNS resolution failed
) else (
    echo    [OK] DNS resolution OK
)

echo.
echo  WSL IP Address:
wsl -- hostname -I 2>nul

echo.
echo  [4] Storage Status
echo  ----------------------------------------------------------------
set "totalsize=0"
for /r "%LOCALAPPDATA%\Packages" %%f in (ext4.vhdx) do (
    for %%a in ("%%f") do (
        set /a "sizemb=%%~za/1048576"
        echo  !sizemb! MB - %%~dpf
        set /a "totalsize+=!sizemb!"
    )
)
echo.
echo  Total VHD usage: !totalsize! MB

echo.
echo  [5] Memory Status
echo  ----------------------------------------------------------------
for /f "usebackq tokens=*" %%a in (`powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%get-distros.ps1" -Running`) do (
    echo  %%a:
    wsl -d "%%a" -- free -m 2>nul | findstr "Mem:"
)

echo.
echo  [6] Configuration
echo  ----------------------------------------------------------------
if exist "%USERPROFILE%\.wslconfig" (
    echo  .wslconfig found:
    type "%USERPROFILE%\.wslconfig"
) else (
    echo  No .wslconfig file
)

echo.
echo  ================================================================
echo                    Health Check Complete
echo  ================================================================
echo.

set /p "action=Run repairs? [Y/N]: "
if /i "%action%"=="Y" (
    echo.
    echo  Running repairs...
    
    echo  [1/3] Updating WSL...
    wsl --update
    
    echo  [2/3] Shutting down WSL...
    wsl --shutdown
    
    echo  [3/3] Resetting network...
    netsh winsock reset >nul 2>&1
    
    echo.
    echo  Repairs complete. Please restart if issues persist.
)

echo.
pause
