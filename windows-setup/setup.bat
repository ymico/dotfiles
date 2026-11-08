@echo off
:: ====================================================================
:: Windows Post-Install Setup Launcher
:: Automatically requests Administrator privileges and runs setup.ps1
:: ====================================================================

title Windows Post-Install Automation (Amethyst)
cd /d "%~dp0"

:: Check for administrative privileges
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Requesting Administrator privileges...
    powershell -Command "Start-Process cmd -ArgumentList '/c \"\"%~f0\"\"' -Verb RunAs"
    exit /b
)

:: Run the PowerShell automation script
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0setup.ps1"

pause
