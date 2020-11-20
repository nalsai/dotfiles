#Requires -RunAsAdministrator

Write-Host "Installing Apps..." -ForegroundColor Green

# install chocolatey if not already installed
if ($null -eq (which cinst)) {
    Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
    . $profile
    choco feature enable -n=allowGlobalConfirmation
}

choco install git --params '"/GitAndUnixToolsOnPath /NoShellIntegration"' --limit-output
choco install googlechrome nomacs spotify autohotkey curl wget --ignore-checksums --limit-output
refreshenv
Start-Process choco -ArgumentList "install powershell-core --install-arguments='`"ADD_EXPLORER_CONTEXT_MENU_OPENPOWERSHELL=1`"' --limit-output" -WindowStyle Minimized
Start-Process choco -ArgumentList "install mp3tag --package-parameters='`"/NoDesktopShortcut /NoContextMenu`"' --limit-output" -WindowStyle Minimized
$installProcess = Start-Process choco -ArgumentList "install synctrayzor plex golang hugo python openjdk unity-hub mpv ffmpeg youtube-dl mkvtoolnix aegisub subtitleedit makemkv eac audacity audacity-lame cdburnerxp burnawarefree etcher obs-studio openssl.light filezilla windirstat libreoffice-fresh exiftool flacsquisher authy-desktop paint.net linkshellextension image-composite-editor icaros figma discord deluge renamer 7zip wireshark winmerge --ignore-checksums --limit-output" -PassThru

# customize Spotify using spicetify
if (!(Test-Path $HOME\.spicetify)) {
    Start-Process $env:APPDATA\Spotify\Spotify.exe
    Start-Sleep 3
    Stop-Process -Name Spotify
    choco install spicetify-cli --limit-output
    spicetify
    spicetify backup enable-devtool
    wget -O $HOME\spicetify-themes.zip "https://github.com/morpheusthewhite/spicetify-themes/archive/master.zip"
    Expand-Archive -Path $HOME\spicetify-themes.zip  -DestinationPath $HOME -Force;
    Copy-Item -r $HOME\spicetify-themes-master\* $HOME\.spicetify\Themes\ -ErrorAction SilentlyContinue
    Remove-Item $HOME\spicetify-themes-master -Recurse -Force
    spicetify config current_theme CherryBlossom
    wget -O $HOME\spicetify-cli.zip "https://github.com/khanhas/spicetify-cli/archive/master.zip"
    Expand-Archive -Path $HOME\spicetify-cli.zip  -DestinationPath $HOME -Force;
    Copy-Item -r $HOME\spicetify-cli-master\Extensions\* $HOME\.spicetify\Extensions\ -ErrorAction SilentlyContinue
    Remove-Item $HOME\spicetify-cli-master -Recurse -Force
    spicetify config extensions fullAppDisplay.js 
    spicetify config extensions keyboardShortcut.js
    spicetify config extensions shuffle+.js
    spicetify apply
}

if(!((Get-ChildItem -Path 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP' -Recurse | Get-ItemProperty -Name 'Version' -ErrorAction SilentlyContinue | ForEach-Object {$_.Version -as [System.Version]} | Where-Object {$_.Major -eq 3 -and $_.Minor -eq 5}).Count -ge 1)) {
    Write-Host "Installing .NET 3.5"
    Enable-WindowsOptionalFeature -Online -FeatureName "NetFx3" -NoRestart
}

wget -O $HOME\VSCode-Setup.exe https://aka.ms/win32-x64-user-stable
Start-Process $HOME\VSCode-Setup.exe -ArgumentList "/VERYSILENT /MERGETASKS=!runcode /NoDesktopIcon /NoQuicklaunchIcon /NoAddContextMenuFiles /AssociateWithFiles"

wget -O $HOME\ImgReName-Setup.exe https://nalsai.de/imgrename/download/Setup.exe
Start-Process $HOME\ImgReName-Setup.exe -ArgumentList "--silent"

wget -O $HOME\CrystalDiskInfo-Setup.exe https://crystalmark.info/redirect.php?product=CrystalDiskInfoInstallerShizuku --no-check-certificate
Start-Process $HOME\CrystalDiskInfo-Setup.exe -ArgumentList "/SP- /VERYSILENT /NORESTART"

wget -O $HOME\CrystalDiskMark-Setup.exe https://crystalmark.info/redirect.php?product=CrystalDiskMarkInstallerShizuku --no-check-certificate
Start-Process $HOME\CrystalDiskMark-Setup.exe -ArgumentList "/SP- /VERYSILENT /NORESTART"

wget -O $HOME\MediaInfoNET.7z ((Invoke-RestMethod -Method GET -Uri "https://api.github.com/repos/stax76/MediaInfo.NET/releases/latest").assets | Where-Object name -like MediaInfo.NET-*.7z).browser_download_url
7z x $HOME\MediaInfoNET.7z -o"$env:LOCALAPPDATA\MediaInfo.NET" -y
Start-Process $env:LOCALAPPDATA\MediaInfo.NET\MediaInfoNET.exe --install

# prevent choco from upgrading packages that upgrade themselves
$pin_block = {
    $apps =
    'googlechrome',
    'unity-hub',
    'authy-desktop',
    'figma',
    'discord',
    'spotify'
    for ($i = 0; $i -lt $apps.Count; $i++) {
        choco pin add --name $apps[$i]
    } 
}
$installProcess.WaitForExit()
Start-Process powershell -ArgumentList "-command $pin_block" -WindowStyle Minimized

# remove WinMerge from Context Menu & 7zip from Drag & Drop Context Menu
New-PSDrive HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT > $null
$Keys = @(
    "HKCR:\*\shellex\ContextMenuHandlers\WinMerge"
    "HKCR:\Directory\shellex\ContextMenuHandlers\WinMerge"
    "HKCR:\Directory\shellex\DragDropHandlers\WinMerge"
    "HKCR:\Directory\Background\shellex\ContextMenuHandlers\WinMerge"
    "HKCR:\Directory\Background\shellex\DragDropHandlers\WinMerge"
    "HKCR:\Drive\shellex\ContextMenuHandlers\WinMerge"
    "HKCR:\Drive\shellex\DragDropHandlers\WinMerge"
    "HKCR:\Directory\shellex\DragDropHandlers\7-Zip"
)
ForEach ($Key in $Keys) {
    Remove-Item -LiteralPath $Key -Recurse -ErrorAction SilentlyContinue
}

$installation_block = {
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
    for ($i = 0; $i -lt $extensions.Count; $i++) {
        code --install-extension $extensions[$i]
    } 
}
Start-Process powershell -ArgumentList "-command $installation_block" -WindowStyle Minimized    # Invoke new poweshell instance so code is in path


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
    Y {
        choco install steam --limit-output
        choco pin add --name steam
    }
} 
Write-Host "Install bethesdanet? (y/N): " -ForegroundColor Yellow -NoNewline
Switch (Read-Host) 
{ 
    Y {
        choco install bethesdanet --ignore-checksums --limit-output
        choco pin add --name bethesdanet
    }
} 

# Remove remaining setup files
Remove-Item $HOME\VSCode-Setup.exe -ErrorAction SilentlyContinue
Remove-Item $HOME\ImgReName-Setup.exe -ErrorAction SilentlyContinue
Remove-Item $HOME\CrystalDiskInfo-Setup.exe -ErrorAction SilentlyContinue
Remove-Item $HOME\CrystalDiskMark-Setup.exe -ErrorAction SilentlyContinue
Remove-Item $HOME\MediaInfoNET.7z -ErrorAction SilentlyContinue

#winget install --id=Microsoft.WindowsTerminal -e
#winget install notepads

Write-Host "Done Installing Apps" -ForegroundColor Green
Write-Host "You still need to install Windows Terminal & Notepads from the Microsoft Store`nand Visual Studio, Davinci Resolve, Minion, ESO, TTC from the Internet`nand setup apps like Chrome, Icaros, Authy..." -ForegroundColor Cyan
