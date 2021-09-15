#Requires -RunAsAdministrator
$TMP = "$env:TEMP\ZG90ZmlsZXM"
New-Item -ItemType directory -Force -Path $TMP -ErrorAction SilentlyContinue > $null

Write-Host "Installing Apps..." -ForegroundColor Green

# install chocolatey if not already installed
if (!(which choco)) {
	Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
	choco feature enable -n=allowGlobalConfirmation
}

choco install git --params "/GitAndUnixToolsOnPath /NoShellIntegration /WindowsTerminal" --limit-output
choco install vscode --params "/NoDesktopIcon /NoQuicklaunchIcon /NoContextMenuFiles" --limit-output
choco install 7zip adoptopenjdk altdrag audacity audacity-ffmpeg audacity-lame authy-desktop autohotkey cdburnerxp curl discord eac eartrumpet etcher everything exiftool ffmpeg filezilla firefox flacsquisher gimp golang googlechrome hugin hugo hwinfo icaros laragon.portable libreoffice-fresh linkshellextension makemkv meld microsoft-windows-terminal mkvtoolnix mpv nomacs notepad2-mod obs-studio openssl paint.net partitionwizard powershell-core python rclone renamer rufus spotify steam-client synctrayzor taskbarx unity-hub vlc wget windirstat wireshark youtube-dl --limit-output
choco install figma --ignore-checksums --limit-output

# Run TaskbarX and add to Startup
Start-Process "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\TaskbarX\TaskbarX.lnk"
Copy-Item "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\TaskbarX\TaskbarX.lnk" "C:\Users\Nalsai\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\TaskbarX.lnk"  -ErrorAction SilentlyContinue

# https://stackoverflow.com/a/46760714
$env:ChocolateyInstall = Convert-Path "$((Get-Command choco).Path)\..\.."
Import-Module "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
refreshenv
. $profile

#if (!((Get-ChildItem -Path 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP' -Recurse | Get-ItemProperty -Name 'Version' -ErrorAction SilentlyContinue | ForEach-Object { $_.Version -as [System.Version] } | Where-Object { $_.Major -eq 3 -and $_.Minor -eq 5 }).Count -ge 1)) {
#	Write-Host "Installing .NET 3.5"
#	Enable-WindowsOptionalFeature -Online -FeatureName "NetFx3" -NoRestart
#}

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

# stop choco upgrading packages that upgrade themselves
$pin_block = {
	$apps =
#	'authy-desktop',
#	'discord',
#	'figma',
#	'firefox',
#	'googlechrome',
#	'spotify',
	'steam-client'
#	'unity-hub'
	for ($i = 0; $i -lt $apps.Count; $i++) {
		choco pin add --name $apps[$i]
	}
}
Start-Process powershell -ArgumentList "-command $pin_block" -WindowStyle Minimized

. $PSScriptRoot\declutter-contextmenu.ps1 script

Write-Host "Installing VSCode Extensions"
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
$host.UI.RawUI.FlushInputBuffer()
$key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
while(-Not($key.Character -eq "Y" -Or $key.Character -eq "N" -Or $key.VirtualKeyCode -eq 13)) {
	$key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}
Write-Host $key.Character
Switch ($key.Character) {
	Y {
		choco install itunes --limit-output
	}
	Default {}
}

Write-Host "Install assaultcube? [y/N]: " -ForegroundColor Yellow -NoNewline
$host.UI.RawUI.FlushInputBuffer()
$key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
while(-Not($key.Character -eq "Y" -Or $key.Character -eq "N" -Or $key.VirtualKeyCode -eq 13)) {
	$key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}
Write-Host $key.Character
Switch ($key.Character) {
	Y {
		choco install assaultcube --limit-output
	}
	Default {}
}

Write-Host "Install bethesdanet, goggalaxy? [y/N]: " -ForegroundColor Yellow -NoNewline
$host.UI.RawUI.FlushInputBuffer()
$key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
while(-Not($key.Character -eq "Y" -Or $key.Character -eq "N" -Or $key.VirtualKeyCode -eq 13)) {
	$key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}
Write-Host $key.Character
Switch ($key.Character) {
	Y {
		choco install bethesdanet goggalaxy --limit-output
		choco pin add --name bethesdanet
		choco pin add --name goggalaxy
	}
	Default {}
}

Write-Host "Change git signingkey? [y/N]: " -ForegroundColor Yellow -NoNewline
$host.UI.RawUI.FlushInputBuffer()
$key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
while(-Not($key.Character -eq "Y" -Or $key.Character -eq "N" -Or $key.VirtualKeyCode -eq 13)) {
	$key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}
Write-Host $key.Character
Switch ($key.Character) {
	Y {
		Write-Host "Listing keys:" -ForegroundColor Yellow
		Write-Host "gpg --list-secret-keys --keyid-format=long"
		gpg --list-secret-keys --keyid-format=long

		Write-Host "GPG key ID: " -ForegroundColor Cyan -NoNewline
		$keyID = Read-Host
		git config --global user.signingkey "$keyID"
	}
	Default {}
}

Write-Host "Done Installing Apps" -ForegroundColor Green
Write-Host "You still need to install Visual Studio, Davinci Resolve, Deluge, Minion, ESO, TTC yourself," -ForegroundColor Cyan
Write-Host "deactivate auto startup for a lot of Apps in Task Manager" -ForegroundColor Cyan
Write-Host "and configure apps like AltDrag, Icaros and SyncTrayzor" -ForegroundColor Cyan
