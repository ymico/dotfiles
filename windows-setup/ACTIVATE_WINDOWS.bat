@echo off
title Microsoft Activation Scripts (MAS)
echo ========================================================
echo    Windows 11 / Office Activation Script (MAS)
echo ========================================================
echo.
echo Launching official MAS activation...
echo When the menu appears, press [1] to activate Windows permanently via HWID.
echo.
powershell -NoProfile -ExecutionPolicy Bypass -Command "irm https://get.activated.win | iex"
pause
