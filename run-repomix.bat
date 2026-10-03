@echo off
setlocal EnableExtensions
title Repomix Setup
chcp 65001 >nul

:: Get ESC character for ANSI colors
for /f %%a in ('echo prompt $E ^| cmd') do set "ESC=%%a"

echo Checking environment...

:: 1. Check if Repomix is installed
where repomix >nul 2>&1
if not errorlevel 1 (
    echo [INFO] Repomix already installed.
    goto RUN_REPOMIX
)

:: 2. Check if npm is installed
where npm >nul 2>&1
if not errorlevel 1 (
    echo [INFO] Repomix not found. Installing globally via npm...
    call npm install -g repomix
    if errorlevel 1 (
        echo [ERROR] Failed to install Repomix via npm.
        pause
        exit /b 1
    )
    goto UPDATE_PATH_AND_RUN
)

:: 3. If npm is missing, check for winget and install Node.js
where winget >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Neither Node.js nor winget were found on this system.
    echo Please install Node.js manually: https://nodejs.org/
    pause
    exit /b 1
)

echo [INFO] Node.js is not installed. Installing Node.js LTS via winget...
echo.
winget install --id OpenJS.NodeJS.LTS --exact --accept-source-agreements --accept-package-agreements
if errorlevel 1 (
    echo [ERROR] Failed to install Node.js via winget.
    pause
    exit /b 1
)

set "PATH=%ProgramFiles%\nodejs;%APPDATA%\npm;%PATH%"

echo.
echo [INFO] Installing Repomix globally via npm...
call npm install -g repomix
if errorlevel 1 (
    echo [ERROR] Failed to install Repomix via npm.
    pause
    exit /b 1
)

:UPDATE_PATH_AND_RUN
for /f "delims=" %%I in ('npm config get prefix 2^>nul') do set "NPM_PREFIX=%%I"
if defined NPM_PREFIX (
    set "PATH=%NPM_PREFIX%;%PATH%"
)

where repomix >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Repomix is still not available in PATH.
    pause
    exit /b 1
)

:RUN_REPOMIX
echo.
echo Building repository context with Repomix...
echo.
call repomix
if errorlevel 1 (
    echo [ERROR] Repomix execution failed.
    pause
    exit /b 1
)

:: ============ SUCCESS BANNER ============
call :SHOW_BANNER
echo   Output saved to repomix-output.xml
echo.
pause
exit /b 0

:SHOW_BANNER
echo.
echo.
echo.
echo.
echo     %ESC%[38;5;39m███████╗██╗ ██████╗ %ESC%[0m  %ESC%[38;5;208m██████╗  █████╗ ██████╗ ██╗  ██╗███████╗%ESC%[0m
echo     %ESC%[38;5;39m╚══███╔╝██║██╔════╝ %ESC%[0m  %ESC%[38;5;208m██╔══██╗██╔══██╗██╔══██╗██║ ██╔╝██╔════╝%ESC%[0m
echo     %ESC%[38;5;39m  ███╔╝ ██║██║  ███╗%ESC%[0m  %ESC%[38;5;208m██║  ██║███████║██████╔╝█████╔╝ ███████╗%ESC%[0m
echo     %ESC%[38;5;39m ███╔╝  ██║██║   ██║%ESC%[0m  %ESC%[38;5;208m██║  ██║██╔══██║██╔══██╗██╔═██╗ ╚════██║%ESC%[0m
echo     %ESC%[38;5;39m███████╗██║╚██████╔╝%ESC%[0m  %ESC%[38;5;208m██████╔╝██║  ██║██║  ██║██║  ██╗███████║%ESC%[0m
echo     %ESC%[38;5;39m╚══════╝╚═╝ ╚═════╝ %ESC%[0m  %ESC%[38;5;208m╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝%ESC%[0m
echo.
echo.
echo %ESC%[97m                                DONE%ESC%[0m
echo.
echo.
exit /b 0
endlocal