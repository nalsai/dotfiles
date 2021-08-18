#Requires -RunAsAdministrator
$TMP = "$env:TEMP\ZG90ZmlsZXM"

Write-Host "Installing Apps..." -ForegroundColor Green

# install chocolatey if not already installed
if (!(which choco)) {
	Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
	choco feature enable -n=allowGlobalConfirmation
}

choco install git --params '"/GitAndUnixToolsOnPath /NoShellIntegration"' --limit-output
choco install firefox googlechrome nomacs curl wget 7zip notepad2-mod spotify --ignore-checksums --limit-output

# https://stackoverflow.com/a/46760714
$env:ChocolateyInstall = Convert-Path "$((Get-Command choco).Path)\..\.."
Import-Module "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
refreshenv

$installProcess = Start-Process choco -ArgumentList "install adoptopenjdk aegisub audacity audacity-ffmpeg audacity-lame authy-desktop autohotkey burnawarefree cdburnerxp discord eac eartrumpet etcher everything exiftool ffmpeg figma filezilla flacsquisher golang hugin hugo hwinfo icaros laragon.portable libreoffice-fresh linkshellextension makemkv microsoft-windows-terminal mkvtoolnix mpv obs-studio openssl paint.net partitionwizard powershell-core python rclone renamer rufus synctrayzor unity-hub vlc windirstat winmerge wireshark youtube-dl --ignore-checksums --limit-output" -PassThru
#TODO:
# gimp 
# add question:  subtitleedit 
# winmerge/meld?
# partition software?
#removed: h2testw

#if (!((Get-ChildItem -Path 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP' -Recurse | Get-ItemProperty -Name 'Version' -ErrorAction SilentlyContinue | ForEach-Object { $_.Version -as [System.Version] } | Where-Object { $_.Major -eq 3 -and $_.Minor -eq 5 }).Count -ge 1)) {
#	Write-Host "Installing .NET 3.5"
#	Enable-WindowsOptionalFeature -Online -FeatureName "NetFx3" -NoRestart
#}

if (!(which code)) {
	wget.exe -O $TMP\VSCode-Setup.exe https://aka.ms/win32-x64-user-stable
	Start-Process $TMP\VSCode-Setup.exe -ArgumentList "/VERYSILENT /MERGETASKS=!runcode /NoDesktopIcon /NoQuicklaunchIcon /NoAddContextMenuFiles /AssociateWithFiles"
}
if (!(Test-Path "C:\Program Files\CrystalDiskInfo*")) {
	wget.exe -O $TMP\CrystalDiskInfo-Setup.exe https://crystalmark.info/redirect.php?product=CrystalDiskInfoInstallerShizuku --no-check-certificate
	Start-Process $TMP\CrystalDiskInfo-Setup.exe -ArgumentList "/SP- /VERYSILENT /NORESTART"
}
if (!(Test-Path "C:\Program Files\CrystalDiskMark*")) {
	wget.exe -O $TMP\CrystalDiskMark-Setup.exe https://crystalmark.info/redirect.php?product=CrystalDiskMarkInstallerShizuku --no-check-certificate
	Start-Process $TMP\CrystalDiskMark-Setup.exe -ArgumentList "/SP- /VERYSILENT /NORESTART"
}
if (!(Test-Path "$env:LOCALAPPDATA\MediaInfo.NET")) {
	wget.exe -O $TMP\MediaInfoNET.zip ((Invoke-RestMethod -Method GET -Uri "https://api.github.com/repos/stax76/MediaInfo.NET/releases/latest").assets | Where-Object name -like MediaInfo.NET-*.zip).browser_download_url
	7z x $TMP\MediaInfoNET.zip -o"$env:LOCALAPPDATA\MediaInfo.NET" -y
	Start-Process $env:LOCALAPPDATA\MediaInfo.NET\MediaInfoNET.exe --install
}

$installProcess.WaitForExit()

choco install mp3tag --package-parameters='"/NoDesktopShortcut /NoContextMenu"' --limit-output

# stop choco upgrading packages that upgrade themselves
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

. $PSScriptRoot\declutter-contextmenu.ps1

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

Write-Host "Install itunes? [y/N]: " -ForegroundColor Yellow -NoNewline
$key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown").Character
while(-Not($key -eq "Y" -Or $key -eq "N")) {$key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown").Character}
Write-Host "$key";
Switch ($key) {
	Y { choco install itunes --limit-output }
	N {}
}

Write-Host "Install assaultcube? [y/N]: " -ForegroundColor Yellow -NoNewline
$key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown").Character
while(-Not($key -eq "Y" -Or $key -eq "N")) {$key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown").Character}
Write-Host "$key";
Switch ($key) {
	Y { choco install assaultcube --limit-output }
	N {}
}

Write-Host "Install steam? [y/N]: " -ForegroundColor Yellow -NoNewline
$key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown").Character
while(-Not($key -eq "Y" -Or $key -eq "N")) {$key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown").Character}
Write-Host "$key";
Switch ($key) {
	Y {
		choco install steam --limit-output
		choco pin add --name steam
	}
	N {}
}

Write-Host "Install bethesdanet, goggalaxy? [y/N]: " -ForegroundColor Yellow -NoNewline
$key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown").Character
while(-Not($key -eq "Y" -Or $key -eq "N")) {$key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown").Character}
Write-Host "$key";
Switch ($key) {
	Y {
		choco install bethesdanet goggalaxy --limit-output
		choco pin add --name bethesdanet
		choco pin add --name goggalaxy
	}
	N {}
}

Write-Host "Done Installing Apps" -ForegroundColor Green
Write-Host "You still need to install Visual Studio, Davinci Resolve, Deluge, Minion, ESO, TTC from the Internet`nand setup apps like Chrome, Icaros, Authy..." -ForegroundColor Cyan
