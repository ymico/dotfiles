@echo off
title Restart Explorer
echo Restarting Windows Explorer to apply themes, taskbar and icons...
taskkill /f /im explorer.exe
start explorer.exe
echo Done!
