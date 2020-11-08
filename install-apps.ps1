#Requires -RunAsAdministrator

##############
# Install Apps
##############

Write-Host "Installing Apps..." -ForegroundColor Green

### Chocolatey
if ($null -eq (which choco)) {
    Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
    choco feature enable -n=allowGlobalConfirmation
    & $profile  # Refresh Profile
}

choco install git -params '"/GitAndUnixToolsOnPath /NoShellIntegration"' --limit-output
choco install googlechrome nomacs spotify autohotkey curl wget --limit-output

refreshenv
& $profile

Write-Host "Please open Spotify and close it again, then press any key" -ForegroundColor Yellow -NoNewline
Read-Host

# Customize Spotify using spicetify
choco install spicetify-cli --limit-output
spicetify
spicetify backup apply enable-devtool
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

Write-Host "Initializing the installation of .NET 3.5..."
DISM /Online /Enable-Feature /FeatureName:NetFx3 /All
Write-Host ".NET 3.5 has been successfully installed!"

choco install plex powershell-core golang hugo python openjdk unity-hub mpv ffmpeg youtube-dl mkvtoolnix aegisub subtitleedit makemkv mediainfo mediainfo-cli eac audacity audacity-lame cdburnerxp mp3tag burnawarefree etcher obs-studio openssl.light filezilla windirstat libreoffice-fresh exiftool flacsquisher authy-desktop paint.net linkshellextension image-composite-editor icaros figma discord deluge renamer 7zip wireshark winmerge --ignore-checksums --limit-output

# prevent choco upgrade of automatically upgrading packages that upgrade themselves
choco pin add --name googlechrome
choco pin add --name vscodium
choco pin add --name unity-hub
choco pin add --name authy-desktop
choco pin add --name figma
choco pin add --name discord
choco pin add --name spotify

############################
# Install VS Code with Extensions
############################
choco install vscodium -params '"/AssociateWithFiles /NoAddContextMenuFiles"' --limit-output
refreshenv
codium --install-extension bungcip.better-toml
codium --install-extension DavidAnson.vscode-markdownlint
codium --install-extension DotJoshJohnson.xml
codium --install-extension ecmel.vscode-html-css
codium --install-extension golang.go
codium --install-extension MikuroXina.cherry-petals-theme
codium --install-extension ms-dotnettools.csharp
codium --install-extension ms-vscode-remote.remote-wsl
codium --install-extension ms-vscode.cpptools
codium --install-extension ms-vscode.powershell
codium --install-extension PKief.material-icon-theme
codium --install-extension platformio.platformio-ide
codium --install-extension ritwickdey.LiveServer
codium --install-extension slevesque.vscode-autohotkey
codium --install-extension Yummygum.city-lights-icon-vsc
codium --install-extension yummygum.city-lights-theme
codium --install-extension Zignd.html-css-class-completion

wget -O vs_community-Setup.exe "https://visualstudio.microsoft.com/thank-you-downloading-visual-studio/?sku=community&rel=16&utm_medium=microsoft&utm_source=docs.microsoft.com&utm_campaign=link+cta&utm_content=download+commandline+parameters+vs2019+rc"
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


# install Windows Terminal & Notepads
# needs updated Windows App Installer
# https://github.com/microsoft/winget-cli
# Apps can alternatively be installed from the Microsoft Store
#winget install --id=Microsoft.WindowsTerminal -e
#choco install microsoft-windows-terminal
#winget install notepads

# TODO: Davinci Resolve, Minion, ESO, TTC
Write-Host "Done Installing Apps" -ForegroundColor Green
