# ====================================================================
# Windows Post-Install Automation Script (Amethyst / Gaming Edition)
# Sets up Dark/Amethyst Theme, Debloats, Installs Launchers & Rustcord
# ====================================================================

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$Host.UI.RawUI.WindowTitle = "Windows Post-Install Automation — Amethyst Setup"

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "  Windows Post-Install Setup (CS2 / Rust / Fortnite / Zen)" -ForegroundColor Magenta
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host ""

# --- 1. Dark Theme & Amethyst Accent ---
Write-Host "[1/6] Applying Amethyst Dark Theme & Accent..." -ForegroundColor Yellow

$PersonalizePath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize"
If (!(Test-Path $PersonalizePath)) { New-Item -Path $PersonalizePath -Force | Out-Null }
Set-ItemProperty -Path $PersonalizePath -Name "AppsUseLightTheme" -Value 0 -Type DWord
Set-ItemProperty -Path $PersonalizePath -Name "SystemUsesLightTheme" -Value 0 -Type DWord
Set-ItemProperty -Path $PersonalizePath -Name "EnableTransparency" -Value 1 -Type DWord

$DWMPath = "HKCU:\Software\Microsoft\Windows\DWM"
If (!(Test-Path $DWMPath)) { New-Item -Path $DWMPath -Force | Out-Null }
# Amethyst Purple (0xFFD87C9D in ABGR)
Set-ItemProperty -Path $DWMPath -Name "AccentColor" -Value 0xFFD87C9D -Type DWord
Set-ItemProperty -Path $DWMPath -Name "ColorPrevalence" -Value 1 -Type DWord

# --- 2. Debloat & Performance Tweaks ---
Write-Host "[2/6] Debloating Windows & Disabling Background Lag..." -ForegroundColor Yellow

# Disable Bing Search in Start Menu & Telemetry
$SearchPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search"
If (!(Test-Path $SearchPath)) { New-Item -Path $SearchPath -Force | Out-Null }
Set-ItemProperty -Path $SearchPath -Name "BingSearchEnabled" -Value 0 -Type DWord
Set-ItemProperty -Path $SearchPath -Name "CortanaConsent" -Value 0 -Type DWord
Set-ItemProperty -Path $SearchPath -Name "SearchboxTaskbarMode" -Value 1 -Type DWord

# Disable GameDVR background capture lag (improves FPS in CS2/Rust)
$GameConfig = "HKCU:\System\GameConfigStore"
If (Test-Path $GameConfig) {
    Set-ItemProperty -Path $GameConfig -Name "GameDVR_Enabled" -Value 0 -Type DWord
}

# Remove Edge startup background processes
$EdgePolicy = "HKLM:\SOFTWARE\Policies\Microsoft\Edge"
If (!(Test-Path $EdgePolicy)) { New-Item -Path $EdgePolicy -Force | Out-Null }
Set-ItemProperty -Path $EdgePolicy -Name "StartupBoostEnabled" -Value 0 -Type DWord
Set-ItemProperty -Path $EdgePolicy -Name "BackgroundModeEnabled" -Value 0 -Type DWord

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

# Clean Edge desktop shortcut if present
$EdgeDesktop = "$([Environment]::GetFolderPath('Desktop'))\Microsoft Edge.lnk"
If (Test-Path $EdgeDesktop) { Remove-Item $EdgeDesktop -Force -ErrorAction SilentlyContinue }

# --- 3. Install Gaming & System Runtimes ---
Write-Host "[3/6] Installing Visual C++ Runtimes & Dependencies..." -ForegroundColor Yellow
winget install --id Microsoft.VCRedist.2015+.x64 --silent --accept-package-agreements --accept-source-agreements --disable-interactivity 2>$null

# --- 4. Install Main Applications via Winget ---
Write-Host "[4/6] Installing Zen Browser, Steam, Epic Games & FACEIT..." -ForegroundColor Yellow

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

# --- 5. Download and Install Rustcord ---
Write-Host "[5/6] Installing Rustcord (Native Discord Client in Rust)..." -ForegroundColor Yellow

$RustcordDir = "$env:LOCALAPPDATA\Rustcord"
$RustcordZip = "$env:TEMP\rustcord-windows-x86_64.zip"
$RustcordUrl = "https://github.com/ymico/rustcord/releases/download/v0.1.0/rustcord-windows-x86_64.zip"

Try {
    If (!(Test-Path $RustcordDir)) { New-Item -ItemType Directory -Path $RustcordDir -Force | Out-Null }
    Write-Host "  Downloading Rustcord from GitHub..." -ForegroundColor Cyan
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls13
    Invoke-WebRequest -Uri $RustcordUrl -OutFile $RustcordZip -UseBasicParsing
    
    Write-Host "  Extracting to $RustcordDir..." -ForegroundColor Cyan
    Expand-Archive -Path $RustcordZip -DestinationPath $RustcordDir -Force
    Remove-Item $RustcordZip -Force -ErrorAction SilentlyContinue
    
    # Create Shortcuts
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
    Write-Host "  Failed to install Rustcord automatically: $_" -ForegroundColor Red
}

# --- 6. Quick Game Install Links ---
Write-Host "[6/6] Generating 1-Click Game Installers on Desktop..." -ForegroundColor Yellow

$DesktopPath = [Environment]::GetFolderPath('Desktop')
$WshShell = New-Object -ComObject WScript.Shell

# CS2 Installer Link
$CS2Link = $WshShell.CreateShortcut("$DesktopPath\Install CS2 (Steam).lnk")
$CS2Link.TargetPath = "steam://install/730"
$CS2Link.Save()

# Rust Installer Link
$RustLink = $WshShell.CreateShortcut("$DesktopPath\Install Rust (Steam).lnk")
$RustLink.TargetPath = "steam://install/252490"
$RustLink.Save()

Write-Host ""
Write-Host "==========================================================" -ForegroundColor Green
Write-Host "  Setup Complete! System is debloated and ready." -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Green
Write-Host ""
Write-Host "To activate Windows, run this standard command in PowerShell:" -ForegroundColor Magenta
Write-Host "  irm https://get.msl.io | iex" -ForegroundColor White
Write-Host ""
Read-Host -Prompt "Press Enter to exit"
