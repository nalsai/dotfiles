#Requires -RunAsAdministrator
$TMP = "$env:TEMP\ZG90ZmlsZXM"
New-Item -ItemType directory -Force -Path $TMP -ErrorAction SilentlyContinue > $null

Write-Host "Installing Apps..." -ForegroundColor Green

# Install chocolatey if not already installed
if (!(which choco)) {
	Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
	choco feature enable -n=allowGlobalConfirmation
	choco feature enable -n=useRememberedArgumentsForUpgrades
}

choco install git --params "/GitAndUnixToolsOnPath /NoShellIntegration /WindowsTerminal" --limit-output
choco install vscode --params "/NoDesktopIcon /NoQuicklaunchIcon /NoContextMenuFiles" --limit-output

# Windows Terminal is included in Windows 11 and only needs to be installed on Windows 10
if ([Environment]::OSVersion.Version.Major -eq "10" -and -not ((Get-WmiObject Win32_OperatingSystem).Caption -contains " 11 ")) {
	choco install microsoft-windows-terminal --limit-output
}

choco install 7zip temurin altdrag audacity audacity-ffmpeg audacity-lame authy-desktop autohotkey cdburnerxp curl discord eac eartrumpet etcher everything exiftool ffmpeg-full filezilla firefox flacsquisher gimp goggalaxy golang googlechrome hugin hugo hwinfo icaros laragon.portable libreoffice-fresh linkshellextension makemkv meld mkvtoolnix mpv nomacs notepad2-mod obs-studio openssl paint.net partitionwizard powershell-core python rclone renamer rufus steam-client synctrayzor unity-hub vlc wget winbtrfs windirstat wireshark youtube-dl --limit-output
choco install figma --ignore-checksums --limit-output

if ((Get-WmiObject Win32_OperatingSystem).Caption -contains " 11 ") {
	choco install taskbarx --limit-output

	# Run TaskbarX and add to Startup
	Start-Process "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\TaskbarX\TaskbarX.lnk"
	Copy-Item "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\TaskbarX\TaskbarX.lnk" "$HOME\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\TaskbarX.lnk"  -ErrorAction SilentlyContinue
}

# Run AltDrag
Start-Process "$HOME\AppData\Roaming\AltDrag\AltDrag.exe" -ArgumentList "-h"
$action = New-ScheduledTaskAction -Execute $ExecutionContext.InvokeCommand.ExpandString('$HOME\AppData\Roaming\AltDrag\AltDrag.exe') -Argument '-h'
$trigger = New-ScheduledTaskTrigger -AtLogon
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries
Register-ScheduledTask -TaskName "AltDrag" -Action $action -Trigger $trigger -Settings $settings -RunLevel Highest -Force > $null

# Register Icaros
Set-ItemProperty "HKLM:\Software\Icaros" "Thumbnail Extensions" "3g2;3gp;3gp2;3gpp;amv;ape;asf;avi;bik;bmp;cb7;cbr;cbz;divx;dpg;dv;dvr-ms;epub;evo;f4v;flac;flv;gif;hdmov;jpg;k3g;m1v;m2t;m2ts;m2v;m4b;m4p;m4v;mk3d;mka;mkv;mov;mp2v;mp3;mp4;mp4v;mpc;mpe;mpeg;mpg;mpv2;mpv4;mqv;mts;mxf;nsv;ofr;ofs;ogg;ogm;ogv;opus;png;qt;ram;rm;rmvb;skm;spx;swf;tak;tif;tiff;tp;tpr;trp;ts;tta;vob;wav;webm;wm;wmv;wv;xvid"
RegSvr32.exe "C:\Program Files\Icaros\64-bit\IcarosThumbnailProvider.dll" /s
RegSvr32.exe "C:\Program Files\Icaros\64-bit\IcarosPropertyHandler.dll" /s


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
#	'goggalaxy'
#	'googlechrome',
	'steam-client'
#	'unity-hub'
	for ($i = 0; $i -lt $apps.Count; $i++) {
		choco pin add --name $apps[$i]
	}
}
Start-Process powershell -ArgumentList "-command $pin_block" -WindowStyle Minimized

. $PSScriptRoot\declutter-contextmenu.ps1 script

Write-Host "Install Cinebench, Furmark, Prime95? [y/N]: " -ForegroundColor Yellow -NoNewline
$host.UI.RawUI.FlushInputBuffer()
$key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
while(-Not($key.Character -eq "Y" -Or $key.Character -eq "N" -Or $key.VirtualKeyCode -eq 13)) {
	$key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}
Write-Host $key.Character
Switch ($key.Character) {
	Y {
		choco install cinebench furmark prime95 --limit-output
	}
	Default {}
}

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

git config --global core.editor "code --wait"

Write-Host "Disable git gpgsign? [y/N]: " -ForegroundColor Yellow -NoNewline
$host.UI.RawUI.FlushInputBuffer()
$key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
while(-Not($key.Character -eq "Y" -Or $key.Character -eq "N" -Or $key.VirtualKeyCode -eq 13)) {
	$key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}
Write-Host $key.Character
Switch ($key.Character) {
	Y {
		git config --global commit.gpgsign false
	}
	Default {
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
	}
}

Write-Host "Done Installing Apps" -ForegroundColor Green
Write-Host "You still need to install Visual Studio, Davinci Resolve, Deluge, Minion, ESO, TTC yourself," -ForegroundColor Cyan
Write-Host "deactivate auto startup for a lot of Apps in Task Manager" -ForegroundColor Cyan
Write-Host "and configure apps like Icaros and SyncTrayzor" -ForegroundColor Cyan
