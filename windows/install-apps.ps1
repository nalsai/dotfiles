#Requires -RunAsAdministrator

Write-Host "Installing Apps..." -ForegroundColor Green

# install chocolatey if not already installed
if (!(which choco)) {
	Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
	choco feature enable -n=allowGlobalConfirmation
}

choco install git --params '"/GitAndUnixToolsOnPath /NoShellIntegration"' --limit-output
choco install firefox googlechrome nomacs curl wget 7zip notepad2-mod spotify --ignore-checksums --limit-output
# https://stackoverflow.com/a/46760714
# Make `refreshenv` available right away, by defining the $env:ChocolateyInstall
# variable and importing the Chocolatey profile module.
# Note: Using `. $PROFILE` instead *may* work, but isn't guaranteed to.
$env:ChocolateyInstall = Convert-Path "$((Get-Command choco).Path)\..\.."
Import-Module "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
# refreshenv is now an alias for Update-SessionEnvironment
# (rather than invoking refreshenv.cmd, the *batch file* for use with cmd.exe)
refreshenv

$installProcess = Start-Process choco -ArgumentList "install aegisub audacity audacity-lame authy-desktop autohotkey burnawarefree cdburnerxp discord eac eartrumpet etcher everything exiftool ffmpeg figma filezilla flacsquisher golang h2testw hugo hwinfo icaros image-composite-editor laragon.portable libreoffice-fresh linkshellextension makemkv microsoft-windows-terminal mkvtoolnix mpv obs-studio openjdk openssl paint.net partitionwizard plex python rclone renamer rufus subtitleedit synctrayzor unity-hub vlc windirstat winmerge wireshark youtube-dl --ignore-checksums --limit-output" -PassThru

if (!((Get-ChildItem -Path 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP' -Recurse | Get-ItemProperty -Name 'Version' -ErrorAction SilentlyContinue | ForEach-Object { $_.Version -as [System.Version] } | Where-Object { $_.Major -eq 3 -and $_.Minor -eq 5 }).Count -ge 1)) {
	Write-Host "Installing .NET 3.5"
	Enable-WindowsOptionalFeature -Online -FeatureName "NetFx3" -NoRestart
}

if (!(which code)) {
	wget.exe -O $HOME\VSCode-Setup.exe https://aka.ms/win32-x64-user-stable
	Start-Process $HOME\VSCode-Setup.exe -ArgumentList "/VERYSILENT /MERGETASKS=!runcode /NoDesktopIcon /NoQuicklaunchIcon /NoAddContextMenuFiles /AssociateWithFiles"
}
if (!(Test-Path "$env:LOCALAPPDATA\ImgReName")) {
	wget.exe -O $HOME\ImgReName-Setup.exe https://nalsai.de/imgrename/download/Setup.exe
	Start-Process $HOME\ImgReName-Setup.exe -ArgumentList "--silent"
}
if (!(Test-Path "C:\Program Files\CrystalDiskInfo*")) {
	wget.exe -O $HOME\CrystalDiskInfo-Setup.exe https://crystalmark.info/redirect.php?product=CrystalDiskInfoInstallerShizuku --no-check-certificate
	Start-Process $HOME\CrystalDiskInfo-Setup.exe -ArgumentList "/SP- /VERYSILENT /NORESTART"
}
if (!(Test-Path "C:\Program Files\CrystalDiskMark*")) {
	wget.exe -O $HOME\CrystalDiskMark-Setup.exe https://crystalmark.info/redirect.php?product=CrystalDiskMarkInstallerShizuku --no-check-certificate
	Start-Process $HOME\CrystalDiskMark-Setup.exe -ArgumentList "/SP- /VERYSILENT /NORESTART"
}
if (!(Test-Path "$env:LOCALAPPDATA\MediaInfo.NET")) {
	wget.exe -O $HOME\MediaInfoNET.zip ((Invoke-RestMethod -Method GET -Uri "https://api.github.com/repos/stax76/MediaInfo.NET/releases/latest").assets | Where-Object name -like MediaInfo.NET-*.zip).browser_download_url
	7z x $HOME\MediaInfoNET.zip -o"$env:LOCALAPPDATA\MediaInfo.NET" -y
	Start-Process $env:LOCALAPPDATA\MediaInfo.NET\MediaInfoNET.exe --install
}

$installProcess.WaitForExit()

choco install powershell-core --install-arguments='"ADD_EXPLORER_CONTEXT_MENU_OPENPOWERSHELL=1"' --limit-output
choco install mp3tag --package-parameters='"/NoDesktopShortcut /NoContextMenu"' --limit-output

# prevent choco from upgrading packages that upgrade themselves
#$pin_block = {
#	$apps =
#	'authy-desktop',
#	'discord',
#	'figma',
#	'firefox',
#	'googlechrome',
#	'spotify',
#	'unity-hub'
#	for ($i = 0; $i -lt $apps.Count; $i++) {
#		choco pin add --name $apps[$i]
#	}
#}
#Start-Process powershell -ArgumentList "-command $pin_block" -WindowStyle Minimized

Invoke-Expression $PSScriptRoot\VLC\removeContexMenu.ps1

Write-Output "removing WinMerge from Context Menu & 7zip from Drag & Drop Context Menu"
New-PSDrive HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT -ErrorAction SilentlyContinue > $null
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

refreshenv
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
		code.cmd --install-extension $extensions[$i]
	}
}
Start-Process powershell -ArgumentList "-command refreshenv $installation_block"

Write-Host "Install itunes? (y/N): " -ForegroundColor Yellow -NoNewline
Switch (Read-Host) {
	Y { choco install itunes --limit-output }
}
Write-Host "Install assaultcube? (y/N): " -ForegroundColor Yellow -NoNewline
Switch (Read-Host) {
	Y { choco install assaultcube --limit-output }
}
Write-Host "Install steam, bethesdanet, goggalaxy? (y/N): " -ForegroundColor Yellow -NoNewline
Switch (Read-Host) {
	Y {
		choco install steam bethesdanet goggalaxy --ignore-checksums --limit-output
		choco pin add --name steam
		choco pin add --name bethesdanet
		choco pin add --name goggalaxy
	}
}

# Remove remaining setup files
Remove-Item $HOME\VSCode-Setup.exe -ErrorAction SilentlyContinue
Remove-Item $HOME\ImgReName-Setup.exe -ErrorAction SilentlyContinue
Remove-Item $HOME\CrystalDiskInfo-Setup.exe -ErrorAction SilentlyContinue
Remove-Item $HOME\CrystalDiskMark-Setup.exe -ErrorAction SilentlyContinue
Remove-Item $HOME\MediaInfoNET.zip -ErrorAction SilentlyContinue

Write-Host "Done Installing Apps" -ForegroundColor Green
Write-Host "You still need to install Visual Studio, Davinci Resolve, Deluge, Minion, ESO, TTC from the Internet`nand setup apps like Chrome, Icaros, Authy..." -ForegroundColor Cyan
