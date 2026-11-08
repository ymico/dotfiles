@echo off
title Activate High Performance Power Plan
net session >nul 2>&1 || (powershell -Command "Start-Process cmd -ArgumentList '/c \"\"%~f0\"\"' -Verb RunAs" & exit /b)

echo Activating High Performance power plan...
powercfg /s 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c

echo.
echo High Performance power plan activated.
echo.
pause
