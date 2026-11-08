# ====================================================================
# Windows Post-Install Automation Script (Amethyst / Gaming Edition)
# 
# Features:
# 1. Dual-Boot Fixes (Hardware Clock UTC, Fast Startup disabled)
# 2. Bibata Modern Classic Cursors & Raw 1:1 Mouse Input (No Accel)
# 3. CS2 / Rust Gaming Tweaks (High Performance, No GameDVR, No Sticky Keys)
# 4. Windows 11 Usability (Classic Context Menu, File Extensions, Dark Theme)
# 5. NVIDIA RTX 5060 Drivers & Visual C++ Runtimes
# 6. Silent App Install (Zen Browser, Steam, Epic Games, FACEIT)
# 7. Rustcord (Native Discord Client in Rust) Auto-Setup
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
Write-Host "[1/9] Applying Dual-Boot Fixes (Clock Sync & Fast Startup)..." -ForegroundColor Yellow

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
Write-Host "[2/9] Disabling Mouse Acceleration & Configuring Raw Input..." -ForegroundColor Yellow

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
Write-Host "[3/9] Installing Bibata-Modern-Classic Cursor Theme..." -ForegroundColor Yellow

$BibataUrl = "https://github.com/ful1e5/Bibata_Cursor/releases/download/v2.0.7/Bibata-Modern-Classic-Windows.zip"
$LocalBibataZip = Join-Path $PSScriptRoot "Bibata-Modern-Classic-Windows.zip"
$BibataZip = "$env:TEMP\bibata.zip"
$BibataTempDir = "$env:TEMP\bibata_extracted"
$SystemCursorsDir = "$env:WINDIR\Cursors\Bibata-Modern-Classic"

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
    If (!(Test-Path $SystemCursorsDir)) { New-Item -ItemType Directory -Path $SystemCursorsDir -Force | Out-Null }
    Copy-Item -Path "$SourceDir\*" -Destination $SystemCursorsDir -Recurse -Force

    # Register Cursor Scheme in Windows Registry
    $CursorsSchemePath = "HKCU:\Control Panel\Cursors\Schemes"
    If (!(Test-Path $CursorsSchemePath)) { New-Item -Path $CursorsSchemePath -Force | Out-Null }
    
    $SchemeData = "$SystemCursorsDir\Pointer.cur,$SystemCursorsDir\Help.cur,$SystemCursorsDir\Work.ani,$SystemCursorsDir\Busy.ani,$SystemCursorsDir\Cross.cur,$SystemCursorsDir\Text.cur,$SystemCursorsDir\Handwriting.cur,$SystemCursorsDir\Unavailable.cur,$SystemCursorsDir\Vert.cur,$SystemCursorsDir\Horz.cur,$SystemCursorsDir\Dgn1.cur,$SystemCursorsDir\Dgn2.cur,$SystemCursorsDir\Move.cur,$SystemCursorsDir\Alternate.cur,$SystemCursorsDir\Link.cur,$SystemCursorsDir\Pin.cur,$SystemCursorsDir\Person.cur"
    Set-ItemProperty -Path $CursorsSchemePath -Name "Bibata Modern Classic" -Value $SchemeData -Type String -Force

    # Apply to current user
    $CursorsPath = "HKCU:\Control Panel\Cursors"
    Set-ItemProperty -Path $CursorsPath -Name "(Default)" -Value "Bibata Modern Classic" -Type String -Force
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
    public class User32 {
        [DllImport("user32.dll", SetLastError = true)]
        public static extern bool SystemParametersInfo(uint uiAction, uint uiParam, IntPtr pvParam, uint fWinIni);
    }
"@ -ErrorAction SilentlyContinue
    [User32]::SystemParametersInfo(0x0057, 0, [IntPtr]::Zero, 0x01 -bor 0x02) | Out-Null

    # Cleanup temp
    If ($BibataZip -ne $LocalBibataZip) { Remove-Item $BibataZip -Force -ErrorAction SilentlyContinue }
    Remove-Item $BibataTempDir -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "  Bibata-Modern-Classic installed and activated!" -ForegroundColor Green
} Catch {
    Write-Host "  Bibata cursor install error: $_" -ForegroundColor DarkGray
}

# --------------------------------------------------------------------
# 4. GAMING PERFORMANCE & USABILITY TWEAKS
# --------------------------------------------------------------------
Write-Host "[4/9] Applying Gaming Performance & Windows 11 Usability..." -ForegroundColor Yellow

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
# 5. THEME & AMETHYST ACCENT
# --------------------------------------------------------------------
Write-Host "[5/9] Applying Amethyst Dark Theme..." -ForegroundColor Yellow

$PersonalizePath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize"
If (!(Test-Path $PersonalizePath)) { New-Item -Path $PersonalizePath -Force | Out-Null }
Set-ItemProperty -Path $PersonalizePath -Name "AppsUseLightTheme" -Value 0 -Type DWord -Force
Set-ItemProperty -Path $PersonalizePath -Name "SystemUsesLightTheme" -Value 0 -Type DWord -Force
Set-ItemProperty -Path $PersonalizePath -Name "EnableTransparency" -Value 1 -Type DWord -Force

$DWMPath = "HKCU:\Software\Microsoft\Windows\DWM"
If (!(Test-Path $DWMPath)) { New-Item -Path $DWMPath -Force | Out-Null }
Set-ItemProperty -Path $DWMPath -Name "AccentColor" -Value 0xFFD87C9D -Type DWord -Force # Amethyst Purple
Set-ItemProperty -Path $DWMPath -Name "ColorPrevalence" -Value 1 -Type DWord -Force

# --------------------------------------------------------------------
# 6. DEBLOAT & REMOVE JUNK
# --------------------------------------------------------------------
Write-Host "[6/9] Removing Bloatware & Disabling Edge Background Tasks..." -ForegroundColor Yellow

# Disable Bing Search in Start Menu & Cortana
$SearchPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search"
If (!(Test-Path $SearchPath)) { New-Item -Path $SearchPath -Force | Out-Null }
Set-ItemProperty -Path $SearchPath -Name "BingSearchEnabled" -Value 0 -Type DWord -Force
Set-ItemProperty -Path $SearchPath -Name "CortanaConsent" -Value 0 -Type DWord -Force

# Disable Edge Background Mode & Startup Boost
$EdgePolicy = "HKLM:\SOFTWARE\Policies\Microsoft\Edge"
If (!(Test-Path $EdgePolicy)) { New-Item -Path $EdgePolicy -Force | Out-Null }
Set-ItemProperty -Path $EdgePolicy -Name "StartupBoostEnabled" -Value 0 -Type DWord -Force
Set-ItemProperty -Path $EdgePolicy -Name "BackgroundModeEnabled" -Value 0 -Type DWord -Force

# Remove Junk UWP Bloatware
$Bloatware = @(
    "Microsoft.549981C3F5F10", # Cortana
    "Microsoft.BingNews",
    "Microsoft.BingWeather",
    "Microsoft.GetHelp",
    "Microsoft.Getstarted",
    "Microsoft.MicrosoftSolitaireCollection",
    "Microsoft.People",
    "Microsoft.Todos",
    "Microsoft.WindowsFeedbackHub",
    "Microsoft.YourPhone",
    "Microsoft.ZuneVideo"
)

ForEach ($App in $Bloatware) {
    Get-AppxPackage -Name $App -AllUsers -ErrorAction SilentlyContinue | Remove-AppxPackage -ErrorAction SilentlyContinue
}

# Remove Edge desktop shortcut
$EdgeDesktop = "$([Environment]::GetFolderPath('Desktop'))\Microsoft Edge.lnk"
If (Test-Path $EdgeDesktop) { Remove-Item $EdgeDesktop -Force -ErrorAction SilentlyContinue }

# --------------------------------------------------------------------
# 7. RUNTIMES & DRIVERS
# --------------------------------------------------------------------
Write-Host "[7/9] Installing Visual C++ Runtimes & NVIDIA App (RTX 5060)..." -ForegroundColor Yellow

winget install --id Microsoft.VCRedist.2015+.x64 --silent --accept-package-agreements --accept-source-agreements --disable-interactivity 2>$null
winget install --id Microsoft.VCRedist.2015+.x86 --silent --accept-package-agreements --accept-source-agreements --disable-interactivity 2>$null
winget install --id Nvidia.NvidiaApp --silent --accept-package-agreements --accept-source-agreements --disable-interactivity 2>$null

# --------------------------------------------------------------------
# 8. LAUNCHERS & APPLICATIONS
# --------------------------------------------------------------------
Write-Host "[8/9] Installing Zen Browser, Steam, Epic Games & FACEIT..." -ForegroundColor Yellow

$Apps = @(
    @{ Name = "Zen Browser"; Id = "Zen-Team.Zen-Browser" },
    @{ Name = "Steam"; Id = "Valve.Steam" },
    @{ Name = "Epic Games Launcher"; Id = "EpicGames.EpicGamesLauncher" },
    @{ Name = "FACEIT Client"; Id = "FACEIT.FACEIT" }
)

ForEach ($App in $Apps) {
    Write-Host "  Installing $($App.Name)..." -ForegroundColor Cyan
    winget install --id $App.Id --silent --accept-package-agreements --accept-source-agreements --disable-interactivity 2>$null
}

# --------------------------------------------------------------------
# 9. RUSTCORD & GAME SHORTCUTS
# --------------------------------------------------------------------
Write-Host "[9/9] Installing Rustcord (Native Discord Client in Rust)..." -ForegroundColor Yellow

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
    
    $WshShell = New-Object -ComObject WScript.Shell
    
    # Desktop Shortcut
    $DesktopShortcut = $WshShell.CreateShortcut("$([Environment]::GetFolderPath('Desktop'))\Rustcord.lnk")
    $DesktopShortcut.TargetPath = "$RustcordDir\rustcord.exe"
    $DesktopShortcut.WorkingDirectory = $RustcordDir
    $DesktopShortcut.Description = "Rustcord - Native Discord Client"
    $DesktopShortcut.Save()
    
    # Start Menu Shortcut
    $StartMenuDir = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs"
    $StartShortcut = $WshShell.CreateShortcut("$StartMenuDir\Rustcord.lnk")
    $StartShortcut.TargetPath = "$RustcordDir\rustcord.exe"
    $StartShortcut.WorkingDirectory = $RustcordDir
    $StartShortcut.Description = "Rustcord - Native Discord Client"
    $StartShortcut.Save()
    
    Write-Host "  Rustcord installed successfully!" -ForegroundColor Green
} Catch {
    Write-Host "  Rustcord install skipped or manual: $_" -ForegroundColor DarkGray
}

# 1-Click Game Installers on Desktop
$DesktopPath = [Environment]::GetFolderPath('Desktop')
$WshShell = New-Object -ComObject WScript.Shell

$CS2Link = $WshShell.CreateShortcut("$DesktopPath\Install CS2 (Steam).lnk")
$CS2Link.TargetPath = "steam://install/730"
$CS2Link.Save()

$RustLink = $WshShell.CreateShortcut("$DesktopPath\Install Rust (Steam).lnk")
$RustLink.TargetPath = "steam://install/252490"
$RustLink.Save()

Write-Host ""
Write-Host "==========================================================" -ForegroundColor Green
Write-Host "  Setup Complete! System is debloated, optimized & ready." -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Green
Write-Host ""
Write-Host "Reminder: To activate Windows, run this in PowerShell:" -ForegroundColor Magenta
Write-Host "  irm https://get.activated.win | iex" -ForegroundColor White
Write-Host ""
Write-Host "Reminder 2: In Windows Display Settings, set your MSI monitor to 180 Hz!" -ForegroundColor Cyan
Write-Host ""
Read-Host -Prompt "Press Enter to exit"
