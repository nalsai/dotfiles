# Self-elevate the script if required
if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
	$CommandLine = "-NoExit -File `"" + $MyInvocation.MyCommand.Path + "`" " + $MyInvocation.UnboundArguments
	Start-Process -FilePath PowerShell.exe -Verb Runas -ArgumentList $CommandLine
	Exit
}

Clear-Host
Write-Host " _   _ _ _     ____        _    __ _ _`n| \ | (_| |___|  _ \  ___ | |_ / _(_| | ___ ___`n|  \| | | / __| | | |/ _ \| __| |_| | |/ _ / __|`n| |\  | | \__ | |_| | (_) | |_|  _| | |  __\__ \`n|_| \_|_|_|___|____/ \___/ \__|_| |_|_|\___|___/"
Write-Host "[minimal-install.ps1]`n"

$TMP = "$env:TEMP\ZG90ZmlsZXM"
New-Item -ItemType directory -Force -Path $TMP -ErrorAction SilentlyContinue > $null
$OriginalPref = $ProgressPreference
$ProgressPreference = "SilentlyContinue"

Write-Host "Configuring System..." -ForegroundColor Green

New-PSDrive HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT -ErrorAction SilentlyContinue > $null

if ((Get-Process OneDrive -ErrorAction SilentlyContinue) -Or (Test-Path "$env:LOCALAPPDATA\Microsoft\OneDrive")) {
	Write-Host "Uninstall OneDrive? [Y/n]: " -ForegroundColor Yellow -NoNewline
	$host.UI.RawUI.FlushInputBuffer()
	$key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
	while(-Not($key.Character -eq "Y" -Or $key.Character -eq "N" -Or $key.VirtualKeyCode -eq 13)) {
		$key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
	}
	Write-Host $key.Character
	Switch ($key.Character) {
		Default {
			$onedrive = "$env:SYSTEMROOT\SysWOW64\OneDriveSetup.exe"
			if (!(Test-Path $onedrive)) { $onedrive = "$env:SYSTEMROOT\System32\OneDriveSetup.exe"}
			$ExplorerReg1 = "HKCR:\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}"
			$ExplorerReg2 = "HKCR:\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}"
			if (!(Test-Path $ExplorerReg1)) { New-Item $ExplorerReg1 -Type Folder > $null }
			if (!(Test-Path $ExplorerReg2)) { New-Item $ExplorerReg2 -Type Folder > $null }
			Stop-Process -Name "OneDrive*"
			Start-Sleep 1
			Start-Process $onedrive "/uninstall" -NoNewWindow -Wait
			Stop-Process -Name explorer
			Remove-Item "$env:USERPROFILE\OneDrive" -Force -Recurse -ErrorAction SilentlyContinue
			Remove-Item "$env:LOCALAPPDATA\Microsoft\OneDrive" -Force -Recurse -ErrorAction SilentlyContinue
			Remove-Item "$env:PROGRAMDATA\Microsoft OneDrive" -Force -Recurse -ErrorAction SilentlyContinue
			Remove-Item "$env:SYSTEMDRIVE\OneDriveTemp" -Force -Recurse -ErrorAction SilentlyContinue
			Set-ItemProperty $ExplorerReg1 "System.IsPinnedToNameSpaceTree" 0 -ErrorAction SilentlyContinue
			Set-ItemProperty $ExplorerReg2 "System.IsPinnedToNameSpaceTree" 0 -ErrorAction SilentlyContinue
			if (!(Get-Process explorer -ErrorAction SilentlyContinue)) {
				Start-Process explorer
			}
		}
		N {}
	}
}

Write-Output "Disabling Diagnostics Tracking Service"
Set-Service "DiagTrack" -StartupType Disabled

Write-Output "Creating Registry Folders"
$folders = @(
	"HKCU:\Software\Microsoft\InputPersonalization"
	"HKCU:\Software\Microsoft\InputPersonalization\TrainedDataStore"
	"HKCU:\Software\Microsoft\Personalization\Settings"
	"HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
	"HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
	"HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People"
	"HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer"
	"HKCU:\Software\Microsoft\Windows\CurrentVersion\Search"
	"HKLM:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo"
	"HKCU:\Software\Microsoft\Windows\CurrentVersion\Feeds"
	"HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\Attachments"
	"HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\DataCollection"
	"HKLM:\Software\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked"
	"HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"
	"HKLM:\Software\Microsoft\Windows\CurrentVersion\UserProfileEngagement"
	"HKLM:\Software\Policies\Microsoft\Windows\CloudContent"
	"HKLM:\Software\Policies\Microsoft\Windows\DataCollection"
	"HKLM:\Software\Policies\Microsoft\Windows\Explorer"
	"HKLM:\Software\Policies\Microsoft\Windows\System"
	"HKLM:\Software\Policies\Microsoft\Windows\Windows Search"
	"HKLM:\Software\Policies\Microsoft\Windows\Explorer"
	"HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate"
	"HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU"
	"HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Policies\DataCollection"
	"HKLM:\SYSTEM\CurrentControlSet\Services\lfsvc\Service\Configuration"
)
foreach ($folder in $folders) {
	if (!(Test-Path $folder)) { New-Item $folder -Type Folder > $null }
}
Write-Host "Enable Dark Mode? [Y/n]: " -ForegroundColor Yellow -NoNewline
$host.UI.RawUI.FlushInputBuffer()
$key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
while(-Not($key.Character -eq "Y" -Or $key.Character -eq "N" -Or $key.VirtualKeyCode -eq 13)) {
	$key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}
Write-Host $key.Character
Switch ($key.Character) {
	Default {
		Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" "SystemUsesLightTheme" 0
		Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" "AppsUseLightTheme" 0
	}
	N {}
}

Write-Host "Disabling Enhance Pointer Precision"
Set-ItemProperty "HKCU:\Control Panel\Mouse" "MouseSpeed" 0
Set-ItemProperty "HKCU:\Control Panel\Mouse" "MouseThreshold1" 0
Set-ItemProperty "HKCU:\Control Panel\Mouse" "MouseThreshold2" 0

Set-ItemProperty "HKCU:\Software\Microsoft\InputPersonalization" "RestrictImplicitInkCollection" 1
Set-ItemProperty "HKCU:\Software\Microsoft\InputPersonalization\TrainedDataStore" "HarvestContacts" 0
Set-ItemProperty "HKCU:\Software\Microsoft\Personalization\Settings" "AcceptedPrivacyPolicy" 0
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" "BingSearchEnabled" 0
Set-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" "Enabled" 0
Set-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\DataCollection" "AllowTelemetry" 0
Set-ItemProperty "HKLM:\Software\Policies\Microsoft\Windows\DataCollection" "AllowTelemetry" 0
Set-ItemProperty "HKLM:\Software\Policies\Microsoft\Windows\Explorer" "DisableSearchBoxSuggestions" 1
Set-ItemProperty "HKLM:\Software\Policies\Microsoft\Windows\Windows Search" "AllowCortana" 0
Set-ItemProperty "HKLM:\Software\Policies\Microsoft\Windows\Windows Search" "DisableWebSearch" 1
Set-ItemProperty "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Policies\DataCollection" "AllowTelemetry" 0
Write-Host "Disabling Cortana, Bing Search, Windows Feedback Experience program, Data Collection"

Write-Output "Disabling bloatware returning, Start Menu Suggestions, Get Even More Out of Windows, notifications"
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "ContentDeliveryAllowed" 0
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "ContentDeliveryManager" 0
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "OemPreInstalledAppsEnabled" 0
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "PreInstalledAppsEnabled" 0
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "PreInstalledAppsEverEnabled" 0
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "SilentInstalledAppsEnabled" 0
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "SubscribedContent-310093Enabled" 0
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "SubscribedContent-314563Enabled" 0
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "SubscribedContent-338388Enabled" 0
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "SubscribedContent-338389Enabled" 0
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "SubscribedContent-338393Enabled" 0
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "SubscribedContent-353698Enabled" 0
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "SystemPaneSuggestionsEnabled" 0
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "SystemPaneSuggestionsEnabled" 0
Set-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\UserProfileEngagement" "ScoobeSystemSettingEnabled" 0
Set-ItemProperty "HKLM:\Software\Policies\Microsoft\Windows\CloudContent" "DisableWindowsConsumerFeatures" 1

Write-Output "Applying Explorer tweaks"
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "HideFileExt" 0
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "Start_TrackDocs" 0
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer" "ShowRecent" 0
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer" "ShowFrequent" 0
Set-ItemProperty "HKLM:\Software\Policies\Microsoft\Windows\Explorer" "NoUseStoreOpenWith" 1

Write-Output "Hiding stuff in the SysTray"
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "ShowTaskViewButton" 0	# Task view
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" "SearchboxTaskbarMode" 0			# Search
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Feeds" "ShellFeedsTaskbarViewMode" 2		# News and weather (Windows 10)
Set-ItemProperty "HKLM:\Software\Policies\Microsoft\Windows\System" "EnableActivityFeed" 0					# Timeline (Windows 10)
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People" "PeopleBand" 0	# People (Windows 10)
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "TaskbarDa" 0			# Widgets (Windows 11)
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "TaskbarMn" 0			# Chat (Windows 11)

Write-Host "Configuring Windows Update"
Set-ItemProperty "HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate" "NoAutoRebootWithLoggedOnUsers" 1
Set-ItemProperty "HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU" "AUOptions" 3
Set-ItemProperty "HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU" "IncludeRecommendedUpdates" 1
Set-ItemProperty "HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU" "NoAutoRebootWithLoggedOnUsers" 1
Set-ItemProperty "HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU" "NoAutoUpdate" 0
(New-Object -ComObject Microsoft.Update.ServiceManager -Strict).AddService2("7971f918-a847-4430-9279-4a52d1efe18d", 7, "") > $null

Write-Host "Disable Hiberboot (Fast Startup)? [y/N]: " -ForegroundColor Yellow -NoNewline
$host.UI.RawUI.FlushInputBuffer()
$key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
while(-Not($key.Character -eq "Y" -Or $key.Character -eq "N" -Or $key.VirtualKeyCode -eq 13)) {
	$key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}
Write-Host $key.Character
Switch ($key.Character) {
	Y {
		powercfg.exe /hibernate off
	}
	Default {}
}

Write-Host "Done Configuring System" -ForegroundColor Green


Write-Host "Installing Apps..." -ForegroundColor Green
winget install --id=AltSnap.AltSnap -e -h --scope "machine"
winget install --id=Audacity.Audacity -e -h --scope "machine"
winget install --id=BurntSushi.ripgrep.MSVC -e -h --scope "machine"
winget install --id=Canneverbe.CDBurnerXP -e -h --scope "machine"
winget install --id=cURL.cURL -e -h --scope "machine"
winget install --id=dotPDNLLC.paintdotnet -e -h --scope "machine"
winget install --id=GIMP.GIMP -e -h --scope "machine"
winget install --id=Git.Git -e -h --override "/GitAndUnixToolsOnPath /NoShellIntegration /WindowsTerminal" --scope "machine"
winget install --id=GNU.Wget2 -e -h --scope "machine"
winget install --id=Gyan.FFmpeg -e -h --scope "machine"
winget install --id=Microsoft.WindowsTerminal -e -h --scope "machine"
winget install --id=Mozilla.Firefox -e -h --scope "machine"
winget install --id=nomacs.nomacs -e -h --scope "machine"
winget install --id=REALiX.HWiNFO -e -h --scope "machine"
winget install --id=SomePythonThings.WingetUIStore -e -h --scope "machine"
winget install --id=stnkl.EverythingToolbar -e -h --scope "machine"
winget install --id=TheDocumentFoundation.LibreOffice -e -h --scope "machine"
winget install --id=tsl0922.ImPlay -e -h --scope "machine"
winget install --id=voidtools.Everything -e -h --scope "machine"
winget install --id=WinDirStat.WinDirStat -e -h --scope "machine"
winget install --id=Xanashi.Icaros -e -h --scope "machine"
winget install --id=yt-dlp.yt-dlp -e -h --scope "machine"

# minimal only:
winget install --id=CrystalDewWorld.CrystalDiskInfo -e -h --scope "machine"
winget install --id=EclipseAdoptium.Temurin.19.JDK -e -h --scope "machine"
winget install --id=Google.Chrome -e -h --scope "machine"
winget install --id=VideoLAN.VLC -e -h --scope "machine"

Write-Host "Done Installing Apps" -ForegroundColor Green


Write-Host "Configuring Apps..." -ForegroundColor Green

# mpv
#New-Item -ItemType directory -Force -Path "$HOME\AppData\Roaming\mpv" -ErrorAction SilentlyContinue > $null
#wget.exe -O "$HOME\AppData\Roaming\mpv\mpv.conf" "https://raw.githubusercontent.com/Nalsai/dotfiles/main/mpv/mpv-minimal/mpv.conf"
#wget.exe -O "$HOME\AppData\Roaming\mpv\input.conf" "https://raw.githubusercontent.com/Nalsai/dotfiles/main/mpv/mpv-minimal/input.conf"

# AltDrag
wget.exe -O "$HOME\AppData\Roaming\AltSnap\AltSnap.ini" "https://raw.githubusercontent.com/Nalsai/dotfiles/main/windows/AltSnap/AltSnap.ini"
Start-Process "$HOME\AppData\Roaming\AltSnap\AltSnap.exe" -ArgumentList "-h"
$action = New-ScheduledTaskAction -Execute $ExecutionContext.InvokeCommand.ExpandString('$HOME\AppData\Roaming\AltSnap\AltSnap.exe') -Argument '-h'
$trigger = New-ScheduledTaskTrigger -AtLogon
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries
Register-ScheduledTask -TaskName "AltSnap" -Action $action -Trigger $trigger -Settings $settings -RunLevel Highest -Force > $null

# Icaros
Set-ItemProperty "HKLM:\Software\Icaros" "Thumbnail Extensions" "3g2;3gp;3gp2;3gpp;amv;ape;asf;avi;bik;bmp;cb7;cbr;cbz;divx;dpg;dv;dvr-ms;epub;evo;f4v;flac;flv;gif;hdmov;jpg;k3g;m1v;m2t;m2ts;m2v;m4b;m4p;m4v;mk3d;mka;mkv;mov;mp2v;mp3;mp4;mp4v;mpc;mpe;mpeg;mpg;mpv2;mpv4;mqv;mts;mxf;nsv;ofr;ofs;ogg;ogm;ogv;opus;png;qt;ram;rm;rmvb;skm;spx;swf;tak;tif;tiff;tp;tpr;trp;ts;tta;vob;wav;webm;wm;wmv;wv;xvid"
RegSvr32.exe "C:\Program Files\Icaros\64-bit\IcarosThumbnailProvider.dll" /s
RegSvr32.exe "C:\Program Files\Icaros\64-bit\IcarosPropertyHandler.dll" /s

#PowerShell
$documents = [Environment]::GetFolderPath("MyDocuments")
New-Item -ItemType directory -Force -Path "$documents\PowerShell" -ErrorAction SilentlyContinue > $null
New-Item -ItemType SymbolicLink -Force -Path "$documents\WindowsPowerShell" -Target "$documents\PowerShell"  > $null
wget.exe -O "$documents\PowerShell\Microsoft.PowerShell_profile.ps1" "https://raw.githubusercontent.com/Nalsai/dotfiles/main/windows/PowerShell/Microsoft.PowerShell_profile.ps1"

Write-Host "Done Configuring Apps" -ForegroundColor Green


Write-Host "Installing Fonts..." -ForegroundColor Green

New-Item -ItemType directory -Force -Path "$TMP\Fonts" -ErrorAction SilentlyContinue > $null
$fonts =
'Alice',
'Lato',
'Montserrat',
'Quicksand',
'Merriweather',
'Comfortaa',
'Roboto',
'Noto Sans',
'Noto Serif',
'Source Code Pro'
foreach ($font in $fonts) {
	wget.exe -O $TMP\Fonts\$font.zip "https://fonts.google.com/download?family=$font"
	Expand-Archive -Path $TMP\Fonts\$font.zip -DestinationPath $TMP\Fonts -Force
}
Remove-Item "$TMP\Fonts\static\" -Recurse -Force

wget.exe -O "$TMP\Fonts\Gandhi Sans.zip" https://www.fontsquirrel.com/fonts/download/gandhi-sans
Expand-Archive -Path "$TMP\Fonts\Gandhi Sans.zip" -DestinationPath $TMP\Fonts -Force

wget.exe -O "$TMP\Fonts\Fira Code.zip" ((Invoke-RestMethod -Method GET -Uri "https://api.github.com/repos/tonsky/FiraCode/releases/latest").assets | Where-Object name -like Fira*.zip ).browser_download_url
Expand-Archive -Path "$TMP\Fonts\Fira Code.zip" -DestinationPath "$TMP\Fonts\Fira Code" -Force
Copy-Item -r "$TMP\Fonts\Fira Code\variable_ttf\*" $TMP\Fonts -ErrorAction SilentlyContinue
Remove-Item "$TMP\Fonts\Fira Code" -Recurse -Force

wget.exe -O "$TMP\Fonts\Cascadia Code.zip" ((Invoke-RestMethod -Method GET -Uri "https://api.github.com/repos/microsoft/cascadia-code/releases/latest").assets | Where-Object name -like Cascadia*.zip ).browser_download_url
Expand-Archive -Path "$TMP\Fonts\Cascadia Code.zip" -DestinationPath "$TMP\Fonts\Cascadia Code" -Force
Remove-Item "$TMP\Fonts\Cascadia Code\ttf\static" -Recurse -Force
Copy-Item -r  "$TMP\Fonts\Cascadia Code\ttf\*" $TMP\Fonts -ErrorAction SilentlyContinue
Remove-Item "$TMP\Fonts\Cascadia Code" -Recurse -Force

foreach ($File in $(Get-ChildItem -Path $TMP\Fonts -Include ('*.otf', '*.ttf') -Recurse)) {
	if (!(Test-Path "C:\Windows\Fonts\$($File.Name)")) {
		Copy-Item $File.FullName C:\Windows\Fonts\$($File.Name)
		New-ItemProperty -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Fonts" -Name $File.Name -PropertyType string -Value $File.Name
	}
}

Write-Host "Done Installing Fonts" -ForegroundColor Green


$ProgressPreference = $OriginalPref
Remove-Item $TMP -Recurse -Force -ErrorAction SilentlyContinue
Write-Host "Done! Note that some changes require a restart to take effect." -ForegroundColor Green
$host.UI.RawUI.FlushInputBuffer()
$Host.UI.ReadLine()
[Environment]::Exit(0)
