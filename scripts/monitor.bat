@echo off
setlocal EnableDelayedExpansion
chcp 65001 >nul 2>&1
title WSL Resource Monitor

set "SCRIPT_DIR=%~dp0"

:monitor_loop
cls
echo.
echo ========================================================================
echo                    WSL RESOURCE MONITOR
echo ========================================================================
echo  Press Ctrl+C to exit
echo.
echo  Running WSL Instances:
echo  ----------------------------------------------------------------
wsl --list --running --verbose 2>nul
echo.

echo  System Memory (Host):
for /f "tokens=2 delims==" %%a in ('wmic os get FreePhysicalMemory /value 2^>nul') do (
    set /a "free=%%a/1024"
    echo  Free Memory: !free! MB
)
for /f "tokens=2 delims==" %%a in ('wmic os get TotalVisibleMemorySize /value 2^>nul') do (
    set /a "total=%%a/1024"
    echo  Total Memory: !total! MB
)
echo.

echo  WSL Memory Usage:
for /f "usebackq tokens=*" %%a in (`powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%get-distros.ps1" -Running`) do (
    echo  %%a:
    wsl -d "%%a" -- free -h 2>nul | findstr "Mem:"
)
echo.

echo  WSL Disk Usage:
for /f "usebackq tokens=*" %%a in (`powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%get-distros.ps1" -Running`) do (
    echo  %%a:
    wsl -d "%%a" -- df -h / 2>nul | findstr "/"
)
echo.

echo  VHD File Sizes:
for /r "%LOCALAPPDATA%\Packages" %%f in (ext4.vhdx) do (
    for %%a in ("%%f") do (
        set /a "size=%%~za/1048576"
        echo  !size! MB - %%~nxf
    )
)
echo.

echo  Refreshing in 5 seconds...
timeout /t 5 >nul
goto monitor_loop
