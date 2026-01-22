@echo off
setlocal EnableDelayedExpansion
chcp 65001 >nul 2>&1
title WSL Scheduled Tasks Manager

set "SCRIPT_DIR=%~dp0"

cls
echo.
echo ========================================================================
echo                    WSL SCHEDULED TASKS MANAGER
echo ========================================================================
echo.

echo  [1] Create scheduled backup
echo  [2] Create scheduled update
echo  [3] Create startup task
echo  [4] View existing tasks
echo  [5] Delete scheduled task
echo  [6] Cancel
echo.
set /p "choice=Select [1-6]: "

if "%choice%"=="6" goto :eof

if "%choice%"=="1" (
    echo.
    set /p "taskname=Task name (e.g., WSL-Daily-Backup): "
    set /p "schedule=Schedule (DAILY/WEEKLY/MONTHLY): "
    set /p "time=Time (HH:MM, e.g., 02:00): "
    
    schtasks /create /tn "!taskname!" /tr "\"%SCRIPT_DIR%backup.bat\"" /sc !schedule! /st !time! /rl HIGHEST
    echo  Scheduled backup created!
)

if "%choice%"=="2" (
    echo.
    set /p "taskname=Task name (e.g., WSL-Weekly-Update): "
    set /p "day=Day (MON/TUE/WED/THU/FRI/SAT/SUN): "
    set /p "time=Time (HH:MM): "
    
    schtasks /create /tn "!taskname!" /tr "\"%SCRIPT_DIR%update.bat\"" /sc WEEKLY /d !day! /st !time! /rl HIGHEST
    echo  Scheduled update created!
)

if "%choice%"=="3" (
    echo.
    wsl --list --quiet 2>nul
    set /p "distro=Distribution to start at login: "
    set /p "taskname=Task name: "
    
    schtasks /create /tn "!taskname!" /tr "wsl -d !distro! exit" /sc ONLOGON /rl HIGHEST
    echo  Startup task created!
)

if "%choice%"=="4" (
    echo.
    echo  WSL Related Scheduled Tasks:
    schtasks /query /fo TABLE | findstr /i "wsl"
)

if "%choice%"=="5" (
    echo.
    schtasks /query /fo TABLE | findstr /i "wsl"
    echo.
    set /p "taskname=Task name to delete: "
    schtasks /delete /tn "!taskname!" /f
    echo  Task deleted.
)

echo.
pause
