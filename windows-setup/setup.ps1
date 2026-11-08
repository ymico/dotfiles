# ====================================================================
# Windows Post-Install Automation Script (Amethyst / Gaming Edition)
# 
# Features:
# 1. Dual-Boot Fixes (Hardware Clock UTC, Fast Startup disabled)
# 2. Bibata Modern Classic Cursors & Raw 1:1 Mouse Input (No Accel)
# 3. CS2 / Rust Gaming Tweaks (High Performance, No GameDVR, No Sticky Keys)
# 4. Windows 11 Usability (Classic Context Menu, File Extensions, Explorer PC)
# 5. Clean Minimal Taskbar (No Widgets/Weather, No Searchbox, No Copilot, No Edge)
# 6. Debloat & Edge Shortcut Removal (Public + User + OneDrive Desktops)
# 7. Amethyst Dark Theme & Pixel Wallpaper
# 8. Visual C++ Runtimes & NVIDIA RTX 5060 App
# 9. Silent App Install (Zen Browser, Steam, Epic Games, FACEIT Client)
# 10. Rustcord (Native Discord in Rust) & 1-Click Game Launchers
# 11. Permanent HWID Activation via MAS
# 12. Explorer Auto-Restart for Live Apply
# ====================================================================

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$Host.UI.RawUI.WindowTitle = "Windows Post-Install Automation — Amethyst Setup"

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "   Windows Post-Install Setup (CS2 / Rust / FACEIT / Zen) " -ForegroundColor Magenta
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host ""

# --------------------------------------------------------------------
# 1. DUAL-BOOT FIXES (CRITICAL FOR LINUX + WINDOWS)
# --------------------------------------------------------------------
Write-Host "[1/12] Applying Dual-Boot Fixes (Clock Sync & Fast Startup)..." -ForegroundColor Yellow

# Hardware Clock UTC (prevents clock desync when switching between Fedora and Windows)
$TimeZonePath = "HKLM:\SYSTEM\CurrentControlSet\Control\TimeZoneInformation"
If (!(Test-Path $TimeZonePath)) { New-Item -Path $TimeZonePath -Force | Out-Null }
Set-ItemProperty -Path $TimeZonePath -Name "RealTimeIsUniversal" -Value 1 -Type DWord -Force

# Disable Fast Startup / Hibernation (prevents locked drives and disk corruption in Linux)
powercfg /h off 2>$null
$SessionMgr = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power"
If (Test-Path $SessionMgr) {
    Set-ItemProperty -Path $SessionMgr -Name "HiberbootEnabled" -Value 0 -Type DWord -Force
}

# --------------------------------------------------------------------
# 2. MOUSE ACCELERATION & CURSOR TWEAKS (1:1 RAW INPUT)
# --------------------------------------------------------------------
Write-Host "[2/12] Disabling Mouse Acceleration & Configuring Raw Input..." -ForegroundColor Yellow

# Disable "Enhance Pointer Precision" (kills mouse accel in CS2/Rust)
$MousePath = "HKCU:\Control Panel\Mouse"
If (!(Test-Path $MousePath)) { New-Item -Path $MousePath -Force | Out-Null }
Set-ItemProperty -Path $MousePath -Name "MouseSpeed" -Value "0" -Type String -Force
Set-ItemProperty -Path $MousePath -Name "MouseThreshold1" -Value "0" -Type String -Force
Set-ItemProperty -Path $MousePath -Name "MouseThreshold2" -Value "0" -Type String -Force
Set-ItemProperty -Path $MousePath -Name "MouseSensitivity" -Value "10" -Type String -Force # 6/11 default (1:1)

# --------------------------------------------------------------------
# 3. BIBATA MODERN CLASSIC CURSOR THEME
# --------------------------------------------------------------------
Write-Host "[3/12] Installing Bibata-Modern-Classic Cursor Theme..." -ForegroundColor Yellow

$BibataUrl = "https://github.com/ful1e5/Bibata_Cursor/releases/download/v2.0.7/Bibata-Modern-Classic-Windows.zip"
$LocalBibataZip = Join-Path $PSScriptRoot "Bibata-Modern-Classic-Windows.zip"
$BibataZip = "$env:TEMP\bibata.zip"
$BibataTempDir = "$env:TEMP\bibata_extracted"

Try {
    If (Test-Path $LocalBibataZip) {
        Write-Host "  Using local offline Bibata package..." -ForegroundColor Cyan
        $BibataZip = $LocalBibataZip
    } Else {
        Write-Host "  Downloading Bibata package from GitHub..." -ForegroundColor Cyan
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls13
        Invoke-WebRequest -Uri $BibataUrl -OutFile $BibataZip -UseBasicParsing
    }
    
    Expand-Archive -Path $BibataZip -DestinationPath $BibataTempDir -Force

    $SourceDir = "$BibataTempDir\Bibata-Modern-Classic-Regular-Windows"
    $InstallInf = Join-Path $SourceDir "install.inf"
    
    If (Test-Path $InstallInf) {
        # Native Windows INF driver installer for cursors
        rundll32.exe setupapi,InstallHinfSection DefaultInstall 128 $InstallInf
    }
    
    # Register and activate scheme for Current User
    $SystemCursorsDir = "$env:WINDIR\Cursors\Bibata-Modern-Classic-Regular Cursors"
    If (!(Test-Path $SystemCursorsDir)) {
        $SystemCursorsDir = "$env:WINDIR\Cursors\Bibata-Modern-Classic"
        If (!(Test-Path $SystemCursorsDir)) { New-Item -ItemType Directory -Path $SystemCursorsDir -Force | Out-Null }
        Copy-Item -Path "$SourceDir\*" -Destination $SystemCursorsDir -Recurse -Force
    }

    $CursorsPath = "HKCU:\Control Panel\Cursors"
    Set-ItemProperty -Path $CursorsPath -Name "(Default)" -Value "Bibata-Modern-Classic-Regular Cursors" -Type String -Force
    Set-ItemProperty -Path $CursorsPath -Name "Scheme Source" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $CursorsPath -Name "Arrow" -Value "$SystemCursorsDir\Pointer.cur" -Type String -Force
    Set-ItemProperty -Path $CursorsPath -Name "Help" -Value "$SystemCursorsDir\Help.cur" -Type String -Force
    Set-ItemProperty -Path $CursorsPath -Name "AppStarting" -Value "$SystemCursorsDir\Work.ani" -Type String -Force
    Set-ItemProperty -Path $CursorsPath -Name "Wait" -Value "$SystemCursorsDir\Busy.ani" -Type String -Force
    Set-ItemProperty -Path $CursorsPath -Name "Crosshair" -Value "$SystemCursorsDir\Cross.cur" -Type String -Force
    Set-ItemProperty -Path $CursorsPath -Name "IBeam" -Value "$SystemCursorsDir\Text.cur" -Type String -Force
    Set-ItemProperty -Path $CursorsPath -Name "NWPen" -Value "$SystemCursorsDir\Handwriting.cur" -Type String -Force
    Set-ItemProperty -Path $CursorsPath -Name "No" -Value "$SystemCursorsDir\Unavailable.cur" -Type String -Force
    Set-ItemProperty -Path $CursorsPath -Name "SizeNS" -Value "$SystemCursorsDir\Vert.cur" -Type String -Force
    Set-ItemProperty -Path $CursorsPath -Name "SizeWE" -Value "$SystemCursorsDir\Horz.cur" -Type String -Force
    Set-ItemProperty -Path $CursorsPath -Name "SizeNWSE" -Value "$SystemCursorsDir\Dgn1.cur" -Type String -Force
    Set-ItemProperty -Path $CursorsPath -Name "SizeNESW" -Value "$SystemCursorsDir\Dgn2.cur" -Type String -Force
    Set-ItemProperty -Path $CursorsPath -Name "SizeAll" -Value "$SystemCursorsDir\Move.cur" -Type String -Force
    Set-ItemProperty -Path $CursorsPath -Name "UpArrow" -Value "$SystemCursorsDir\Alternate.cur" -Type String -Force
    Set-ItemProperty -Path $CursorsPath -Name "Hand" -Value "$SystemCursorsDir\Link.cur" -Type String -Force

    # Trigger live reload of cursors via user32.dll
    Add-Type -TypeDefinition @"
    using System;
    using System.Runtime.InteropServices;
    public class CursorManager {
        [DllImport("user32.dll", SetLastError = true)]
        public static extern bool SystemParametersInfo(uint uiAction, uint uiParam, IntPtr pvParam, uint fWinIni);
    }
"@ -ErrorAction SilentlyContinue
    [CursorManager]::SystemParametersInfo(0x0057, 0, [IntPtr]::Zero, 0x01 -bor 0x02) | Out-Null

    If ($BibataZip -ne $LocalBibataZip) { Remove-Item $BibataZip -Force -ErrorAction SilentlyContinue }
    Remove-Item $BibataTempDir -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "  Bibata-Modern-Classic installed and registered!" -ForegroundColor Green
} Catch {
    Write-Host "  Bibata cursor install notice: $_" -ForegroundColor DarkGray
}

# --------------------------------------------------------------------
# 4. GAMING PERFORMANCE & USABILITY TWEAKS
# --------------------------------------------------------------------
Write-Host "[4/12] Applying Gaming Tweaks (High Performance & Anti-Lag)..." -ForegroundColor Yellow

# Set High Performance Power Plan
powercfg /s 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c 2>$null

# Enable Game Mode
$GameMode = "HKCU:\Software\Microsoft\GameBar"
If (!(Test-Path $GameMode)) { New-Item -Path $GameMode -Force | Out-Null }
Set-ItemProperty -Path $GameMode -Name "AutoGameModeEnabled" -Value 1 -Type DWord -Force

# Disable GameDVR Background Recording Lag
$GameConfig = "HKCU:\System\GameConfigStore"
If (Test-Path $GameConfig) {
    Set-ItemProperty -Path $GameConfig -Name "GameDVR_Enabled" -Value 0 -Type DWord -Force
    Set-ItemProperty -Path $GameConfig -Name "GameDVR_FSEBehaviorMode" -Value 2 -Type DWord -Force
}
$GameDVRPolicy = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR"
If (!(Test-Path $GameDVRPolicy)) { New-Item -Path $GameDVRPolicy -Force | Out-Null }
Set-ItemProperty -Path $GameDVRPolicy -Name "AllowGameDVR" -Value 0 -Type DWord -Force

# Disable Sticky Keys (No Shift x5 desktop tab-outs during gameplay)
$StickyKeys = "HKCU:\Control Panel\Accessibility\StickyKeys"
If (!(Test-Path $StickyKeys)) { New-Item -Path $StickyKeys -Force | Out-Null }
Set-ItemProperty -Path $StickyKeys -Name "Flags" -Value "506" -Type String -Force

# Restore Windows 10 Classic Context Menu (No annoying 'Show more options')
$ClsidPath = "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32"
If (!(Test-Path $ClsidPath)) { New-Item -Path $ClsidPath -Force | Out-Null }
Set-ItemProperty -Path $ClsidPath -Name "(Default)" -Value "" -Type String -Force

# File Explorer: Show File Extensions and Hidden Files, Open to "This PC"
$AdvancedExplorer = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
If (!(Test-Path $AdvancedExplorer)) { New-Item -Path $AdvancedExplorer -Force | Out-Null }
Set-ItemProperty -Path $AdvancedExplorer -Name "HideFileExt" -Value 0 -Type DWord -Force
Set-ItemProperty -Path $AdvancedExplorer -Name "Hidden" -Value 1 -Type DWord -Force
Set-ItemProperty -Path $AdvancedExplorer -Name "LaunchTo" -Value 1 -Type DWord -Force

# --------------------------------------------------------------------
# 5. CLEAN MINIMAL TASKBAR (BAR CONFIGURATION)
# --------------------------------------------------------------------
Write-Host "[5/12] Configuring Clean Minimal Taskbar..." -ForegroundColor Yellow

# 1. Turn off Widgets / Weather Ticker (USD/CAD)
Set-ItemProperty -Path $AdvancedExplorer -Name "TaskbarDa" -Value 0 -Type DWord -Force

# 2. Turn off Chat / Teams icon
Set-ItemProperty -Path $AdvancedExplorer -Name "TaskbarMn" -Value 0 -Type DWord -Force

# 3. Turn off Task View button
Set-ItemProperty -Path $AdvancedExplorer -Name "ShowTaskViewButton" -Value 0 -Type DWord -Force

# 4. Turn off Copilot button
Set-ItemProperty -Path $AdvancedExplorer -Name "ShowCopilotButton" -Value 0 -Type DWord -Force
$CopilotPolicy = "HKCU:\Software\Policies\Microsoft\Windows\WindowsCopilot"
If (!(Test-Path $CopilotPolicy)) { New-Item -Path $CopilotPolicy -Force | Out-Null }
Set-ItemProperty -Path $CopilotPolicy -Name "TurnOffWindowsCopilot" -Value 1 -Type DWord -Force

# 5. Hide large Searchbox (Clean bar; Search still works instantly by typing in Start)
$SearchPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search"
If (!(Test-Path $SearchPath)) { New-Item -Path $SearchPath -Force | Out-Null }
Set-ItemProperty -Path $SearchPath -Name "SearchboxTaskbarMode" -Value 0 -Type DWord -Force

# 6. Unpin Edge & Store from taskbar
$TaskbarPinnedDir = "$env:APPDATA\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar"
If (Test-Path $TaskbarPinnedDir) {
    Get-ChildItem -Path $TaskbarPinnedDir -Filter "*Edge*.lnk" | Remove-Item -Force -ErrorAction SilentlyContinue
    Get-ChildItem -Path $TaskbarPinnedDir -Filter "*Store*.lnk" | Remove-Item -Force -ErrorAction SilentlyContinue
    Get-ChildItem -Path $TaskbarPinnedDir -Filter "*Mail*.lnk" | Remove-Item -Force -ErrorAction SilentlyContinue
}

# --------------------------------------------------------------------
# 6. DEBLOAT & REMOVE JUNK SHORTCUTS
# --------------------------------------------------------------------
Write-Host "[6/12] Removing Bloatware, Edge Shortcuts & Telemetry..." -ForegroundColor Yellow

# Disable Bing Search in Start Menu & Cortana
Set-ItemProperty -Path $SearchPath -Name "BingSearchEnabled" -Value 0 -Type DWord -Force
Set-ItemProperty -Path $SearchPath -Name "CortanaConsent" -Value 0 -Type DWord -Force

# Disable Edge Background Mode & Startup Boost
$EdgePolicy = "HKLM:\SOFTWARE\Policies\Microsoft\Edge"
If (!(Test-Path $EdgePolicy)) { New-Item -Path $EdgePolicy -Force | Out-Null }
Set-ItemProperty -Path $EdgePolicy -Name "StartupBoostEnabled" -Value 0 -Type DWord -Force
Set-ItemProperty -Path $EdgePolicy -Name "BackgroundModeEnabled" -Value 0 -Type DWord -Force

# Remove Edge desktop shortcuts from all locations
$EdgeShortcuts = @(
    "C:\Users\Public\Desktop\Microsoft Edge.lnk",
    "$env:USERPROFILE\Desktop\Microsoft Edge.lnk",
    "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Microsoft Edge.lnk",
    "$([Environment]::GetFolderPath('Desktop'))\Microsoft Edge.lnk",
    "$env:ALLUSERSPROFILE\Desktop\Microsoft Edge.lnk"
)
ForEach ($sc in $EdgeShortcuts) {
    If (Test-Path $sc) { Remove-Item $sc -Force -ErrorAction SilentlyContinue }
}

# Remove UWP Bloatware (All users & Provisioned)
$BloatApps = @(
    "*Microsoft.BingNews*",
    "*Microsoft.BingWeather*",
    "*Microsoft.GetHelp*",
    "*Microsoft.Getstarted*",
    "*Microsoft.MicrosoftSolitaireCollection*",
    "*Microsoft.People*",
    "*Microsoft.Todos*",
    "*Microsoft.WindowsFeedbackHub*",
    "*Microsoft.YourPhone*",
    "*Microsoft.ZuneVideo*",
    "*Microsoft.ZuneMusic*",
    "*Microsoft.MicrosoftOfficeHub*",
    "*Microsoft.OutlookForWindows*",
    "*Microsoft.SkypeApp*",
    "*Microsoft.549981C3F5F10*",
    "*Clipchamp.Clipchamp*",
    "*Microsoft.WindowsCommunicationsApps*",
    "*Microsoft.PowerAutomateDesktop*",
    "*Microsoft.WindowsMaps*"
)

ForEach ($App in $BloatApps) {
    Get-AppxPackage -AllUsers -Name $App -ErrorAction SilentlyContinue | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
    Get-AppxProvisionedPackage -Online | Where-Object { $_.DisplayName -like $App -or $_.PackageName -like $App } | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
}

# --------------------------------------------------------------------
# 7. AMETHYST DARK THEME & WALLPAPER
# --------------------------------------------------------------------
Write-Host "[7/12] Applying Dark Theme, Amethyst Accent & Wallpaper..." -ForegroundColor Yellow

$PersonalizePath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize"
If (!(Test-Path $PersonalizePath)) { New-Item -Path $PersonalizePath -Force | Out-Null }
Set-ItemProperty -Path $PersonalizePath -Name "AppsUseLightTheme" -Value 0 -Type DWord -Force
Set-ItemProperty -Path $PersonalizePath -Name "SystemUsesLightTheme" -Value 0 -Type DWord -Force
Set-ItemProperty -Path $PersonalizePath -Name "EnableTransparency" -Value 1 -Type DWord -Force

# Amethyst Accent Color
$DWMPath = "HKCU:\Software\Microsoft\Windows\DWM"
If (!(Test-Path $DWMPath)) { New-Item -Path $DWMPath -Force | Out-Null }
Set-ItemProperty -Path $DWMPath -Name "AccentColor" -Value 0xFFD87C9D -Type DWord -Force
Set-ItemProperty -Path $DWMPath -Name "ColorPrevalence" -Value 1 -Type DWord -Force

# Apply Amethyst Wallpaper if present
$LocalWallpaper = Join-Path $PSScriptRoot "wallpaper.png"
If (Test-Path $LocalWallpaper) {
    Try {
        $WallpaperDir = "$env:APPDATA\Microsoft\Windows\Themes"
        If (!(Test-Path $WallpaperDir)) { New-Item -ItemType Directory -Path $WallpaperDir -Force | Out-Null }
        $TargetWallpaper = "$WallpaperDir\AmethystWallpaper.png"
        Copy-Item -Path $LocalWallpaper -Destination $TargetWallpaper -Force
        
        Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "Wallpaper" -Value $TargetWallpaper -Type String -Force
        Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "WallpaperStyle" -Value "10" -Type String -Force
        Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "TileWallpaper" -Value "0" -Type String -Force
        
        Add-Type -TypeDefinition @"
        using System;
        using System.Runtime.InteropServices;
        public class WallpaperHelper {
            [DllImport("user32.dll", SetLastError = true, CharSet = CharSet.Auto)]
            public static extern int SystemParametersInfo(uint uAction, uint uParam, string lpvParam, uint fuWinIni);
        }
"@ -ErrorAction SilentlyContinue
        [WallpaperHelper]::SystemParametersInfo(0x0014, 0, $TargetWallpaper, 0x01 -bor 0x02) | Out-Null
        Write-Host "  Amethyst pixel wallpaper applied!" -ForegroundColor Green
    } Catch {
        Write-Host "  Wallpaper notice: $_" -ForegroundColor DarkGray
    }
}

# --------------------------------------------------------------------
# 8. RUNTIMES & NVIDIA DRIVERS
# --------------------------------------------------------------------
Write-Host "[8/12] Installing Visual C++ Runtimes & NVIDIA App (RTX 5060)..." -ForegroundColor Yellow

winget install --id Microsoft.VCRedist.2015+.x64 --silent --accept-package-agreements --accept-source-agreements --disable-interactivity 2>$null
winget install --id Microsoft.VCRedist.2015+.x86 --silent --accept-package-agreements --accept-source-agreements --disable-interactivity 2>$null

# NVIDIA App: Local installer first, then winget ID Nvidia.App
$LocalNvidiaExe = Join-Path $PSScriptRoot "NVIDIA_app_installer.exe"
If (Test-Path $LocalNvidiaExe) {
    Write-Host "  Installing NVIDIA App from local package..." -ForegroundColor Cyan
    Start-Process -FilePath $LocalNvidiaExe -ArgumentList "-s" -Wait
} Else {
    Write-Host "  Installing NVIDIA App via winget..." -ForegroundColor Cyan
    winget install --id Nvidia.App --silent --accept-package-agreements --accept-source-agreements --disable-interactivity 2>$null
}

# --------------------------------------------------------------------
# 9. LAUNCHERS & APPLICATIONS
# --------------------------------------------------------------------
Write-Host "[9/12] Installing Zen Browser, Steam, Epic Games & FACEIT..." -ForegroundColor Yellow

$Apps = @(
    @{ Name = "Zen Browser"; Id = "Zen-Team.Zen-Browser" },
    @{ Name = "Steam"; Id = "Valve.Steam" },
    @{ Name = "Epic Games Launcher"; Id = "EpicGames.EpicGamesLauncher" },
    @{ Name = "FACEIT Client"; Id = "FACEITLTD.FACEITClient" }
)

ForEach ($App in $Apps) {
    Write-Host "  Installing $($App.Name)..." -ForegroundColor Cyan
    winget install --id $App.Id --silent --accept-package-agreements --accept-source-agreements --disable-interactivity 2>$null
}

# --------------------------------------------------------------------
# 10. RUSTCORD & GAME SHORTCUTS (ROBUST DESKTOP HANDLING)
# --------------------------------------------------------------------
Write-Host "[10/12] Installing Rustcord & Desktop Game Launchers..." -ForegroundColor Yellow

# Identify all valid Desktop folders (Local profile, Public, OneDrive)
$TargetDesktops = @()
$LocalDesk = "$env:USERPROFILE\Desktop"
If (Test-Path $LocalDesk) { $TargetDesktops += $LocalDesk }
If (Test-Path "C:\Users\Public\Desktop") { $TargetDesktops += "C:\Users\Public\Desktop" }
Try {
    $EnvDesk = [Environment]::GetFolderPath('Desktop')
    If ($EnvDesk -and (Test-Path $EnvDesk) -and ($TargetDesktops -notcontains $EnvDesk)) {
        $TargetDesktops += $EnvDesk
    }
} Catch {}

# Install Rustcord
$RustcordDir = "$env:LOCALAPPDATA\Rustcord"
$LocalRustcordZip = Join-Path $PSScriptRoot "rustcord-windows-x86_64.zip"
$RustcordZip = "$env:TEMP\rustcord-windows-x86_64.zip"
$RustcordUrl = "https://github.com/ymico/rustcord/releases/download/v0.1.0/rustcord-windows-x86_64.zip"

Try {
    If (!(Test-Path $RustcordDir)) { New-Item -ItemType Directory -Path $RustcordDir -Force | Out-Null }
    
    If (Test-Path $LocalRustcordZip) {
        Write-Host "  Using local offline Rustcord package..." -ForegroundColor Cyan
        $RustcordZip = $LocalRustcordZip
    } Else {
        Write-Host "  Downloading Rustcord v0.1.0 from GitHub..." -ForegroundColor Cyan
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls13
        Invoke-WebRequest -Uri $RustcordUrl -OutFile $RustcordZip -UseBasicParsing
    }
    
    Expand-Archive -Path $RustcordZip -DestinationPath $RustcordDir -Force
    If ($RustcordZip -ne $LocalRustcordZip) { Remove-Item $RustcordZip -Force -ErrorAction SilentlyContinue }
    
    # Create Rustcord shortcuts in all detected desktop paths
    ForEach ($Desk in $TargetDesktops) {
        Try {
            $WshShell = New-Object -ComObject WScript.Shell
            $Shortcut = $WshShell.CreateShortcut((Join-Path $Desk "Rustcord.lnk"))
            $Shortcut.TargetPath = "$RustcordDir\rustcord.exe"
            $Shortcut.WorkingDirectory = $RustcordDir
            $Shortcut.Description = "Rustcord - Native Discord Client"
            $Shortcut.Save()
        } Catch {}
    }
    
    # Start Menu Shortcut
    $StartMenuDir = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs"
    If (Test-Path $StartMenuDir) {
        Try {
            $WshShell = New-Object -ComObject WScript.Shell
            $StartShortcut = $WshShell.CreateShortcut((Join-Path $StartMenuDir "Rustcord.lnk"))
            $StartShortcut.TargetPath = "$RustcordDir\rustcord.exe"
            $StartShortcut.WorkingDirectory = $RustcordDir
            $StartShortcut.Description = "Rustcord - Native Discord Client"
            $StartShortcut.Save()
        } Catch {}
    }
    Write-Host "  Rustcord installed successfully!" -ForegroundColor Green
} Catch {
    Write-Host "  Rustcord install notice: $_" -ForegroundColor DarkGray
}

# 1-Click Game Installers (.url internet shortcuts: 100% reliable, zero COM errors)
ForEach ($Desk in $TargetDesktops) {
    Try {
        $CS2Content = "[InternetShortcut]`r`nURL=steam://install/730`r`nIconIndex=0`r`n"
        [IO.File]::WriteAllText((Join-Path $Desk "Install CS2 (Steam).url"), $CS2Content, [Text.Encoding]::ASCII)
        
        $RustContent = "[InternetShortcut]`r`nURL=steam://install/252490`r`nIconIndex=0`r`n"
        [IO.File]::WriteAllText((Join-Path $Desk "Install Rust (Steam).url"), $RustContent, [Text.Encoding]::ASCII)
    } Catch {}
}

# --------------------------------------------------------------------
# 11. AUTOMATIC PERMANENT HWID ACTIVATION (MAS)
# --------------------------------------------------------------------
Write-Host "[11/12] Activating Windows via Microsoft Activation Scripts (HWID)..." -ForegroundColor Magenta
Try {
    & ([ScriptBlock]::Create((irm https://get.activated.win))) /HWID /S
    Write-Host "  Windows digital license activated!" -ForegroundColor Green
} Catch {
    Write-Host "  MAS activation notice: $_" -ForegroundColor DarkGray
}

# --------------------------------------------------------------------
# 12. RESTART EXPLORER TO APPLY ALL THEMES, TASKBAR & ICONS
# --------------------------------------------------------------------
Write-Host "[12/12] Restarting Windows Explorer to apply all changes..." -ForegroundColor Yellow
Stop-Process -Name explorer -Force

Write-Host ""
Write-Host "==========================================================" -ForegroundColor Green
Write-Host "  Setup Complete! System is debloated, themed & ready.    " -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Green
Write-Host ""
Write-Host "Reminder: In Windows Display Settings, set your MSI monitor to 180 Hz!" -ForegroundColor Cyan
Write-Host ""
Read-Host -Prompt "Press Enter to finish"
