#Requires -RunAsAdministrator

##############
# Install Apps
##############

Write-Host "Installing Apps..." -ForegroundColor Green

### Chocolatey
if ($null -eq (which choco)) {
    Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
    choco feature enable -n=allowGlobalConfirmation
}

choco install git -params '"/GitAndUnixToolsOnPath /NoShellIntegration"' --limit-output
choco install googlechrome nomacs plex spotify powershell-core autohotkey curl wget --limit-output

# Customize Spotify using spicetify
choco install spicetify-cli --limit-output
spicetify
spicetify backup apply enable-devtool
git clone https://github.com/morpheusthewhite/spicetify-themes
Set-Location spicetify-themes
Copy-Item -r * $env:USERPROFILE\.spicetify\Themes\
Set-Location ../
Remove-Item .\spicetify-themes\ -Recurse -Force
spicetify config current_theme CherryBlossom
git clone https://github.com/khanhas/spicetify-cli
Set-Location .\spicetify-cli\Extensions\
Copy-Item -r * $env:USERPROFILE\.spicetify\Extensions\
Set-Location ..\..\
Remove-Item .\spicetify-cli\ -Recurse -Force
spicetify config extensions fullAppDisplay.js 
spicetify config extensions keyboardShortcut.js
spicetify config extensions shuffle+.js
spicetify apply

choco install vscodium -params '"/AssociateWithFiles /NoAddContextMenuFiles"' --limit-output
choco install golang hugo python openjdk unity-hub mpv ffmpeg youtube-dl mkvtoolnix gmkvextractgui aegisub subtitleedit makemkv mediainfo mediainfo-cli eac audacity audacity-lame cdburnerxp mp3tag burnawarefree etcher obs-studio openssl.light filezilla windirstat libreoffice-fresh exiftool flacsquisher authy-desktop paint.net linkshellextension image-composite-editor icaros figma discord deluge renamer 7zip wireshark winmerge --limit-output

# prevent choco upgrade of automatically upgrading packages that upgrade themselves
choco pin add --name googlechrome
choco pin add --name vscodium
choco pin add --name unity-hub
choco pin add --name authy-desktop
choco pin add --name figma
choco pin add --name discord
choco pin add --name spotify

############################
# Install VS Code Extensions
############################
code --install-extension bungcip.better-toml
code --install-extension DavidAnson.vscode-markdownlint
code --install-extension DotJoshJohnson.xml
code --install-extension ecmel.vscode-html-css
code --install-extension golang.go
code --install-extension MikuroXina.cherry-petals-theme
code --install-extension ms-dotnettools.csharp
code --install-extension ms-vscode-remote.remote-wsl
code --install-extension ms-vscode.cpptools
code --install-extension ms-vscode.powershell
code --install-extension PKief.material-icon-theme
code --install-extension platformio.platformio-ide
code --install-extension ritwickdey.LiveServer
code --install-extension slevesque.vscode-autohotkey
code --install-extension Yummygum.city-lights-icon-vsc
code --install-extension yummygum.city-lights-theme
code --install-extension Zignd.html-css-class-completion


# install Windows Terminal & Notepads
# needs updated Windows App Installer
# https://github.com/microsoft/winget-cli
# Apps can alternatively be installed from the Microsoft Store
#winget install --id=Microsoft.WindowsTerminal -e
#choco install microsoft-windows-terminal
#winget install notepads

# TODO: Davinci Resolve, Minion, ESO, TTC

wget -O vs_community-Setup.exe"https://visualstudio.microsoft.com/thank-you-downloading-visual-studio/?sku=community&rel=16&utm_medium=microsoft&utm_source=docs.microsoft.com&utm_campaign=link+cta&utm_content=download+commandline+parameters+vs2019+rc"
.\vs_community-Setup.exe --quiet

wget -O CrystalDiskInfo-Setup.exe "https://crystalmark.info/redirect.php?product=CrystalDiskInfoInstallerShizuku"
.\CrystalDiskInfo-Setup.exe /SP- /VERYSILENT /NORESTART

wget -O CrystalDiskMark-Setup.exe "https://crystalmark.info/redirect.php?product=CrystalDiskMarkInstallerShizuku"
.\CrystalDiskMark-Setup.exe /SP- /VERYSILENT /NORESTART

# install ImgReName
wget -O ImgReName-Setup.exe "https://nalsai.de/imgrename/download/Setup.exe"
.\ImgReName-Setup.exe --silent

# setup
# icaros,authy,

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
    Y {choco install bethesdanet --limit-output}
} 

# Remove remaining setup files
Remove-Item ImgReName-Setup.exe
Remove-Item CrystalDiskInfo-Setup.exe
Remove-Item CrystalDiskMark-Setup.exe

Write-Host "Done Installing Apps..." -ForegroundColor Green
