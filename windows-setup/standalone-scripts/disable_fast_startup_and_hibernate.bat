@echo off
title Disable Fast Startup and Hibernation (Dual-Boot Fix)
net session >nul 2>&1 || (powershell -Command "Start-Process cmd -ArgumentList '/c \"\"%~f0\"\"' -Verb RunAs" & exit /b)

echo Disabling Fast Startup and Hibernation...
powercfg /h off
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Power" /v HiberbootEnabled /t REG_DWORD /d 0 /f

echo.
echo Dual-Boot protection active: Windows will not lock drives upon shutdown.
echo.
pause
