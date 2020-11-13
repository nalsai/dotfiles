#Requires -RunAsAdministrator

##############
# Install Apps
##############

Write-Host "Installing Apps..." -ForegroundColor Green

### Chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
choco feature enable -n=allowGlobalConfirmation
& $profile  # Refresh Profile

choco install git --params '"/GitAndUnixToolsOnPath /NoShellIntegration"' --limit-output
choco install googlechrome nomacs spotify autohotkey curl wget --ignore-checksums --limit-output

refreshenv
& $profile

Write-Host "Please open Spotify and close it again, then press enter" -ForegroundColor Yellow -NoNewline
Read-Host

# Customize Spotify using spicetify
choco install spicetify-cli --limit-output
spicetify
spicetify backup enable-devtool
git clone https://github.com/morpheusthewhite/spicetify-themes
Set-Location spicetify-themes
Copy-Item -r * $HOME\.spicetify\Themes\
Set-Location ../
Remove-Item .\spicetify-themes\ -Recurse -Force
spicetify config current_theme CherryBlossom
git clone https://github.com/khanhas/spicetify-cli
Set-Location .\spicetify-cli\Extensions\
Copy-Item -r * $HOME\.spicetify\Extensions\
Set-Location ..\..\
Remove-Item .\spicetify-cli\ -Recurse -Force
spicetify config extensions fullAppDisplay.js 
spicetify config extensions keyboardShortcut.js
spicetify config extensions shuffle+.js
spicetify apply

Write-Host "Installing .NET 3.5"
Enable-WindowsOptionalFeature -Online -FeatureName "NetFx3"

choco install powershell-core --install-arguments='"ADD_EXPLORER_CONTEXT_MENU_OPENPOWERSHELL=1"' --limit-output
choco install winmerge --install-arguments='"/NoShellIntegration"' --limit-output
choco install mp3tag --package-parameters='"/NoDesktopShortcut /NoContextMenu"' --limit-output
choco install plex golang hugo python openjdk unity-hub mpv ffmpeg youtube-dl mkvtoolnix aegisub subtitleedit makemkv mediainfo mediainfo-cli eac audacity audacity-lame cdburnerxp burnawarefree etcher obs-studio openssl.light filezilla windirstat libreoffice-fresh exiftool flacsquisher authy-desktop paint.net linkshellextension image-composite-editor icaros figma discord deluge renamer 7zip wireshark --ignore-checksums --limit-output

# prevent choco upgrade of automatically upgrading packages that upgrade themselves
choco pin add --name googlechrome
choco pin add --name unity-hub
choco pin add --name authy-desktop
choco pin add --name figma
choco pin add --name discord
choco pin add --name spotify

refreshenv
& $profile

#################
# Install VS Code
#################
wget -O VSCode-Setup.exe -L "https://aka.ms/win32-x64-user-stable"
.\VSCode-Setup.exe /VERYSILENT /MERGETASKS=!runcode /NoDesktopIcon /NoQuicklaunchIcon /NoAddContextMenuFiles /AssociateWithFiles

$extensions =
    'bungcip.better-toml',
    'DavidAnson.vscode-markdownlint',
    'DotJoshJohnson.xml',
    'ecmel.vscode-html-css',
    'golang.go',
    'MikuroXina.cherry-petals-theme',
    'ms-dotnettools.csharp',
    'ms-vscode-remote.remote-wsl',
    'ms-vscode.cpptools',
    'ms-vscode.powershell',
    'PKief.material-icon-theme',
    'platformio.platformio-ide',
    'ritwickdey.LiveServer',
    'slevesque.vscode-autohotkey',
    'Yummygum.city-lights-icon-vsc',
    'yummygum.city-lights-theme',
    'Zignd.html-css-class-completion'

foreach($extension in $extensions)
{
    code --install-extension $extension
}

wget -O CrystalDiskInfo-Setup.exe "https://crystalmark.info/redirect.php?product=CrystalDiskInfoInstallerShizuku"
.\CrystalDiskInfo-Setup.exe /SP- /VERYSILENT /NORESTART

wget -O CrystalDiskMark-Setup.exe "https://crystalmark.info/redirect.php?product=CrystalDiskMarkInstallerShizuku"
.\CrystalDiskMark-Setup.exe /SP- /VERYSILENT /NORESTART

wget -O ImgReName-Setup.exe "https://nalsai.de/imgrename/download/Setup.exe"
.\ImgReName-Setup.exe --silent

Write-Host "Install itunes? (y/N): " -ForegroundColor Yellow -NoNewline
Switch (Read-Host) 
{ 
    Y {choco install itunes --limit-output}
} 
Write-Host "Install h2testw? (y/N): " -ForegroundColor Yellow -NoNewline
Switch (Read-Host) 
{ 
    Y {choco install h2testw --limit-output}
} 
Write-Host "Install xmind? (y/N): " -ForegroundColor Yellow -NoNewline
Switch (Read-Host) 
{ 
    Y {choco install xmind --limit-output}
} 
Write-Host "Install assaultcube? (y/N): " -ForegroundColor Yellow -NoNewline
Switch (Read-Host) 
{ 
    Y {choco install assaultcube --limit-output}
} 
Write-Host "Install steam? (y/N): " -ForegroundColor Yellow -NoNewline
Switch (Read-Host) 
{ 
    Y {choco install steam --limit-output}
} 
Write-Host "Install bethesdanet? (y/N): " -ForegroundColor Yellow -NoNewline
Switch (Read-Host) 
{ 
    Y {choco install bethesdanet --ignore-checksums --limit-output}
} 

# Remove remaining setup files
Remove-Item ImgReName-Setup.exe
Remove-Item CrystalDiskInfo-Setup.exe
Remove-Item CrystalDiskMark-Setup.exe

#winget install --id=Microsoft.WindowsTerminal -e
#winget install notepads

Write-Host "Done Installing Apps" -ForegroundColor Green
Write-Host "You still need to install Windows Terminal & Notepads from the Microsoft Store`nand Visual Studio, Davinci Resolve, Minion, ESO, TTC from the Internet`nand setup apps like Chrome, Icaros, Authy..." -ForegroundColor Cyan
