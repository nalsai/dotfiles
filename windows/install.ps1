# Self-elevate the script if required
if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
	Start-Process -FilePath PowerShell.exe -Verb Runas -ArgumentList "-NoExit `"Set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Nalsai/dotfiles/main/windows/install.ps1'))`""
	Exit
}

Clear-Host
Write-Host " _   _ _ _     ____        _    __ _ _`n| \ | (_| |___|  _ \  ___ | |_ / _(_| | ___ ___`n|  \| | | / __| | | |/ _ \| __| |_| | |/ _ / __|`n| |\  | | \__ | |_| | (_) | |_|  _| | |  __\__ \`n|_| \_|_|_|___|____/ \___/ \__|_| |_|_|\___|___/"
Write-Host "`n"
Write-Host "[1] full:    download dotfiles, set up symlinks, windows, apps and fonts"
Write-Host "[2] minimal: set up windows, some apps and fonts"
Write-Host "Select Installation [1/2/q]): " -ForegroundColor Yellow -NoNewline

$key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown").Character
while (-Not($key -eq "1" -Or $key -eq "2" -Or $key -eq "Q")) {
	$key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown").Character
}
Write-Host "$key";


Switch ($key) {
	1 {
		Set-ExecutionPolicy RemoteSigned -Scope LocalMachine -Force
		$TMP = "$env:TEMP\ZG90ZmlsZXM"
		New-Item -ItemType directory -Force -Path $TMP -ErrorAction SilentlyContinue > $null
		$OriginalPref = $ProgressPreference
		$ProgressPreference = "SilentlyContinue"

		Write-Host "Downloading dotfiles"
		Invoke-WebRequest "https://github.com/nalsai/dotfiles/archive/refs/heads/main.zip" -O $TMP\dotfiles.zip
		if (-Not $?) { throw "Error downloading dotfiles" }
		$DOT = "$HOME\.dotfiles"
		Expand-Archive $TMP\dotfiles.zip $TMP
		Remove-Item $DOT -Recurse -Force -ErrorAction SilentlyContinue # delete old dotfiles
		Move-Item $TMP\dotfiles-main $DOT
	}
	2 {
		$TMP = "$env:TEMP\ZG90ZmlsZXM"
		New-Item -ItemType directory -Force -Path $TMP -ErrorAction SilentlyContinue > $null
		$OriginalPref = $ProgressPreference
		$ProgressPreference = "SilentlyContinue"
	}
	Q { [Environment]::Exit(0) }
}

function Set-Symlink {
	[CmdletBinding()]
	param(
		[Parameter(Mandatory)]
		[string] $Path,

		[Parameter(Mandatory)]
		[string] $Target
	)
	if (Test-Path $Path) {
		Write-Host "$Path already exists overwrite? [Y/n]: " -ForegroundColor Yellow -NoNewline
		$host.UI.RawUI.FlushInputBuffer()
		$key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
		while (-Not($key.Character -eq "Y" -Or $key.Character -eq "N" -Or $key.VirtualKeyCode -eq 13)) {
			$key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
		}
		Write-Host $key.Character
		Switch ($key.Character) {
			Default {
				try {
					Remove-Item -Force -Recurse -Path $Path
				}
				catch {
					(Get-Item $Path).Delete() # workaround bug in PowerShell
				}
				New-Item -Force -ItemType SymbolicLink -Path $Path -Target $Target > $null
			}
			N {}
		}
	}
	else {
		New-Item -Force -ItemType SymbolicLink -Path $Path -Target $Target > $null
	}
}

if ($DOT) {
	Write-Host "Making Symlinks..." -ForegroundColor Green

	# PowerShell
	$documents = [Environment]::GetFolderPath("MyDocuments")
	Set-Symlink -Path $documents\PowerShell -Target $DOT\windows\PowerShell
	Set-Symlink -Path $documents\WindowsPowerShell -Target $DOT\windows\PowerShell
	
	# mpv
	Set-Symlink -Path $HOME\AppData\Roaming\mpv -Target $DOT\mpv\mpv
	
	# Notepad2
	#Set-Symlink -Path $HOME\AppData\Roaming\Notepad2 -Target $DOT\windows\Notepad2
	
	# MediaInfo.NET
	Set-Symlink -Path $HOME\AppData\Roaming\MediaInfo.NET -Target $DOT\windows\MediaInfo.NET
	
	# .gitconfig
	Set-Symlink -Path $HOME\.gitconfig -Target $DOT\git\.gitconfig
	
	# AutoHotkey
	#Set-Symlink -Path "$env:appdata\Microsoft\Windows\Start Menu\Programs\Startup\myAhk.ahk" -Target $DOT\windows\ahk\myAhk.ahk
	
	# AltSnap
	Set-Symlink -Path $HOME\AppData\Roaming\AltSnap\AltSnap.ini -Target $DOT\windows\AltSnap\AltSnap.ini
	
	# reload profile
	. $profile
	
	Write-Host "Done Making Symlinks" -ForegroundColor Green	
}


Write-Host "Configuring System..." -ForegroundColor Green

New-PSDrive HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT -ErrorAction SilentlyContinue > $null

if ((Get-Process OneDrive -ErrorAction SilentlyContinue) -Or (Test-Path "$env:LOCALAPPDATA\Microsoft\OneDrive")) {
	Write-Host "Uninstall OneDrive? [Y/n]: " -ForegroundColor Yellow -NoNewline
	$host.UI.RawUI.FlushInputBuffer()
	$key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
	while (-Not($key.Character -eq "Y" -Or $key.Character -eq "N" -Or $key.VirtualKeyCode -eq 13)) {
		$key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
	}
	Write-Host $key.Character
	Switch ($key.Character) {
		Default {
			$onedrive = "$env:SYSTEMROOT\SysWOW64\OneDriveSetup.exe"
			if (!(Test-Path $onedrive)) { $onedrive = "$env:SYSTEMROOT\System32\OneDriveSetup.exe" }
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
)
foreach ($folder in $folders) {
	if (!(Test-Path $folder)) { New-Item $folder -Type Folder > $null }
}

Write-Host "Disabling Enhance Pointer Precision"
Set-ItemProperty "HKCU:\Control Panel\Mouse" "MouseSpeed" 0
Set-ItemProperty "HKCU:\Control Panel\Mouse" "MouseThreshold1" 0
Set-ItemProperty "HKCU:\Control Panel\Mouse" "MouseThreshold2" 0

Write-Host "Disabling Bloatware Installation, Start Menu Suggestions, Get Even More Out of Windows, Cortana, Bing, Feedback Experience, Data Collection"
Set-ItemProperty "HKCU:\Software\Microsoft\InputPersonalization" "RestrictImplicitInkCollection" 1
Set-ItemProperty "HKCU:\Software\Microsoft\InputPersonalization\TrainedDataStore" "HarvestContacts" 0
Set-ItemProperty "HKCU:\Software\Microsoft\Personalization\Settings" "AcceptedPrivacyPolicy" 0
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
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" "BingSearchEnabled" 0
Set-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" "Enabled" 0
Set-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\DataCollection" "AllowTelemetry" 0
Set-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\UserProfileEngagement" "ScoobeSystemSettingEnabled" 0
Set-ItemProperty "HKLM:\Software\Policies\Microsoft\Windows\CloudContent" "DisableWindowsConsumerFeatures" 1
Set-ItemProperty "HKLM:\Software\Policies\Microsoft\Windows\DataCollection" "AllowTelemetry" 0
Set-ItemProperty "HKLM:\Software\Policies\Microsoft\Windows\Explorer" "DisableSearchBoxSuggestions" 1
Set-ItemProperty "HKLM:\Software\Policies\Microsoft\Windows\Windows Search" "AllowCortana" 0
Set-ItemProperty "HKLM:\Software\Policies\Microsoft\Windows\Windows Search" "DisableWebSearch" 1
Set-ItemProperty "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Policies\DataCollection" "AllowTelemetry" 0

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

Write-Host "Enable Dark Mode? [Y/n]: " -ForegroundColor Yellow -NoNewline
$host.UI.RawUI.FlushInputBuffer()
$key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
while (-Not($key.Character -eq "Y" -Or $key.Character -eq "N" -Or $key.VirtualKeyCode -eq 13)) {
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

Write-Host "Disable Hiberboot (Fast Startup)? [y/N]: " -ForegroundColor Yellow -NoNewline
$host.UI.RawUI.FlushInputBuffer()
$key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
while (-Not($key.Character -eq "Y" -Or $key.Character -eq "N" -Or $key.VirtualKeyCode -eq 13)) {
	$key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}
Write-Host $key.Character
Switch ($key.Character) {
	Y {
		powercfg.exe /hibernate off
	}
	Default {}
}

if ($DOT) {
	Write-Output "Setting standby times"
	powercfg /change /monitor-timeout-ac 240    # 4h
	powercfg /change /standby-timeout-ac 720    # 12h
	powercfg /change /monitor-timeout-dc 30     # 30m
	powercfg /change /standby-timeout-dc 60     # 1h

	Write-Host "Enabling Developer Mode"
	Set-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\AppModelUnlock" "AllowDevelopmentWithoutDevLicense" 1

	Write-Host "Enabling WSL"
	Enable-WindowsOptionalFeature -Online -All -FeatureName "Microsoft-Windows-Subsystem-Linux" -NoRestart -WarningAction SilentlyContinue > $null

	Write-Host "Change hardware clock to UTC [Y/n]: " -ForegroundColor Yellow -NoNewline
	$host.UI.RawUI.FlushInputBuffer()
	$key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
	while (-Not($key.Character -eq "Y" -Or $key.Character -eq "N" -Or $key.VirtualKeyCode -eq 13)) {
		$key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
	}
	Write-Host $key.Character
	Switch ($key.Character) {
		Default {
			Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\TimeZoneInformation" "RealTimeIsUniversal" 1
		}
		N {}
	}
}
Write-Host "Done Configuring System" -ForegroundColor Green


Write-Host "Installing Apps..." -ForegroundColor Green
if (!(Get-Command choco -ErrorAction SilentlyContinue)) {
	Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
	choco feature enable -n=allowGlobalConfirmation
	choco feature enable -n=useRememberedArgumentsForUpgrades
}
choco install curl czkawka ffmpeg mpvio msedgeredirect wget --limit-output
winget install --id=AltSnap.AltSnap -e -h --source "winget" --accept-package-agreements # can't be installed globally
winget install --id=AntibodySoftware.WizTree -e -h --source "winget" --accept-package-agreements # can't be installed globally
winget install --id=Cyanfish.NAPS2 -e -h --scope "machine" --source "winget" --accept-package-agreements
winget install --id=GIMP.GIMP -e -h --scope "machine" --source "winget" --accept-package-agreements
winget install --id=Git.Git -e -h --override "/verysilent /suppressmsgboxes /norestart /GitAndUnixToolsOnPath /NoShellIntegration /WindowsTerminal" --scope "machine" --source "winget" --accept-package-agreements
winget install --id=M2Team.NanaZip -e -h --source "winget" --accept-package-agreements # can't be installed globally
winget install --id=MartiCliment.UniGetUI -e -h --source "winget" --accept-package-agreements # can't be installed globally
winget install --id=Microsoft.PowerShell -e -h --scope "machine" --source "winget" --accept-package-agreements
winget install --id=Microsoft.WindowsTerminal -e -h --accept-package-agreements
winget install --id=Mozilla.Firefox -e -h --scope "machine" --source "winget" --accept-package-agreements
winget install --id=nomacs.nomacs -e -h --scope "machine" --source "winget" --accept-package-agreements
winget install --id=PDFArranger.PDFArranger -e -h --scope "machine" --source "winget" --accept-package-agreements
winget install --id=rcmaehl.MSEdgeRedirect -e -h --scope "machine" --source "winget" --accept-package-agreements
winget install --id=REALiX.HWiNFO -e -h --scope "machine" --source "winget" --accept-package-agreements; Get-Process | Where-Object -Property Name -Match 'HWiNFO\d{2}' | Stop-Process # Kill the HWiNFO process after it starts, there is no way to prevent autostart after install
winget install --id=SumatraPDF.SumatraPDF -e -h --scope "machine" --source "winget" --accept-package-agreements
winget install --id=TenacityTeam.Tenacity -e -h --scope "machine" --source "winget" --accept-package-agreements
winget install --id=TheDocumentFoundation.LibreOffice -e -h --source "winget" --accept-package-agreements # can't be installed globally
winget install --id=voidtools.Everything -e -h --source "winget" --accept-package-agreements # can't be installed globally
winget install --id=Xanashi.Icaros -e -h --scope "machine" --source "winget" --accept-package-agreements

if ($DOT) {
	choco install less --params "/DefaultPager" --limit-output
	choco install bat filezilla temurin cdburnerxp ripgrep ripgrep-all wget yt-dlp --limit-output
	#winget install --id=AutoHotkey.AutoHotkey -e -h --scope "machine" --source "winget" --accept-package-agreements
	#winget install --id=Balena.Etcher -e -h --scope "machine" --source "winget" --accept-package-agreements
	#winget install --id=DelugeTeam.DelugeBeta -e -h --source "winget" --accept-package-agreements # can't be installed globally
	#winget install --id=EpicGames.EpicGamesLauncher -e -h --scope "machine" --source "winget" --accept-package-agreements
	#winget install --id=HeroicGamesLauncher.HeroicGamesLauncher -e -h --scope "machine" --source "winget" --accept-package-agreements
	#winget install --id=Hugin.Hugin -e -h --source "winget" --accept-package-agreements # can't be installed globally
	#winget install --id=Hugo.Hugo -e -h --scope "machine" --source "winget" --accept-package-agreements
	#winget install --id=MoritzBunkus.MKVToolNix -e -h --scope "machine" --source "winget" --accept-package-agreements
	#winget install --id=OliverBetz.ExifTool -e -h --scope "machine" --source "winget" --accept-package-agreements
	#winget install --id=Peppy.Osu! -e -h --source "winget" --accept-package-agreements # can't be installed globally
	#winget install --id=Python.Python.3.12 -v "3.12.0a1" -e -h --scope "machine" --source "winget" --accept-package-agreements
	#winget install --id=RabidViperProductions.AssaultCube -e -h --scope "machine" --source "winget" --accept-package-agreements
	#winget install --id=ShiningLight.OpenSSL -e -h --scope "machine" --source "winget" --accept-package-agreements
	#winget install --id=Unity.UnityHub -e -h --scope "machine" --source "winget" --accept-package-agreements
	#winget install --id=Valve.Steam -e -h --scope "machine" --source "winget" --accept-package-agreements
	winget install --id=AndreWiethoff.ExactAudioCopy -e -h --scope "machine" --source "winget" --accept-package-agreements
	winget install --id=CrystalDewWorld.CrystalDiskInfo.ShizukuEdition -e -h --scope "machine" --source "winget" --accept-package-agreements
	winget install --id=CrystalDewWorld.CrystalDiskMark.ShizukuEdition -e -h --scope "machine" --source "winget" --accept-package-agreements
	winget install --id=eloston.ungoogled-chromium -e -h --scope "machine" --source "winget" --accept-package-agreements
	winget install --id=eza-community.eza -e -h --scope "machine" --source "winget" --accept-package-agreements
	winget install --id=GuinpinSoft.MakeMKV -e -h --scope "machine" --source "winget" --accept-package-agreements
	winget install --id=HermannSchinagl.LinkShellExtension -e -h --scope "machine" --source "winget" --accept-package-agreements
	winget install --id=MediaArea.MediaInfo.GUI -e -h --scope "machine" --source "winget" --accept-package-agreements
	winget install --id=Meld.Meld -e -h --scope "machine" --source "winget" --accept-package-agreements
	winget install --id=Microsoft.VisualStudioCode -e --override "/verysilent /suppressmsgboxes /norestart /tasks=!runCode,desktopicon,quicklaunchicon,addcontextmenufiles,addcontextmenufolders,associatewithfiles,addtopath" -h --scope "machine" --source "winget" --accept-package-agreements
	winget install --id=OBSProject.OBSStudio -e -h --scope "machine" --source "winget" --accept-package-agreements
	winget install --id=Rufus.Rufus -e -h --scope "machine" --source "winget" --accept-package-agreements
	winget install --id=sharkdp.bat -e -h --source "winget" --accept-package-agreements # can't be installed globally
	winget install --id=SyncTrayzor.SyncTrayzor -e -h --scope "machine" --source "winget" --accept-package-agreements
	winget install --id=Vencord.Vesktop -e -h --source "winget" --accept-package-agreements # can't be installed globally
}
else {
	choco install temurinjre --limit-output
	winget install --id=CrystalDewWorld.CrystalDiskInfo -e -h --scope "machine" --source "winget" --accept-package-agreements
	winget install --id=Google.Chrome -e -h --scope "machine" --source "winget" --accept-package-agreements
	winget install --id=VideoLAN.VLC -e -h --scope "machine" --source "winget" --accept-package-agreements
}
Write-Host "Done Installing Apps" -ForegroundColor Green


Write-Host "Configuring Apps..." -ForegroundColor Green

if (!$DOT) {
	# PowerShell
	$documents = [Environment]::GetFolderPath("MyDocuments")
	New-Item -ItemType directory -Force -Path "$documents\PowerShell" -ErrorAction SilentlyContinue > $null
	New-Item -ItemType SymbolicLink -Force -Path "$documents\WindowsPowerShell" -Target "$documents\PowerShell"  > $null
	wget -O "$documents\PowerShell\Microsoft.PowerShell_profile.ps1" "https://raw.githubusercontent.com/Nalsai/dotfiles/main/windows/PowerShell/Microsoft.PowerShell_profile.ps1"

	# mpv
	New-Item -ItemType directory -Force -Path "$HOME\AppData\Roaming\mpv" -ErrorAction SilentlyContinue > $null
	wget -O "$HOME\AppData\Roaming\mpv\mpv.conf" "https://raw.githubusercontent.com/Nalsai/dotfiles/main/mpv/mpv-minimal/mpv.conf"
	wget -O "$HOME\AppData\Roaming\mpv\input.conf" "https://raw.githubusercontent.com/Nalsai/dotfiles/main/mpv/mpv-minimal/input.conf"

	# AltSnap
	wget -O "$HOME\AppData\Roaming\AltSnap\AltSnap.ini" "https://raw.githubusercontent.com/Nalsai/dotfiles/main/windows/AltSnap/AltSnap.ini"
}

# AltSnap
Start-Process "$HOME\AppData\Roaming\AltSnap\AltSnap.exe" -ArgumentList "-h"
$action = New-ScheduledTaskAction -Execute $ExecutionContext.InvokeCommand.ExpandString('$HOME\AppData\Roaming\AltSnap\AltSnap.exe') -Argument '-h'
$trigger = New-ScheduledTaskTrigger -AtLogon
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries
Register-ScheduledTask -TaskName "AltSnap" -Action $action -Trigger $trigger -Settings $settings -RunLevel Highest -Force > $null

# Icaros
Set-ItemProperty "HKLM:\Software\Icaros" "Thumbnail Extensions" "3g2;3gp;3gp2;3gpp;amv;ape;asf;avi;bik;bmp;cb7;cbr;cbz;divx;dpg;dv;dvr-ms;epub;evo;f4v;flac;flv;gif;hdmov;jpg;k3g;m1v;m2t;m2ts;m2v;m4b;m4p;m4v;mk3d;mka;mkv;mov;mp2v;mp3;mp4;mp4v;mpc;mpe;mpeg;mpg;mpv2;mpv4;mqv;mts;mxf;nsv;ofr;ofs;ogg;ogm;ogv;opus;png;qt;ram;rm;rmvb;skm;spx;swf;tak;tif;tiff;tp;tpr;trp;ts;tta;vob;wav;webm;wm;wmv;wv;xvid"
RegSvr32.exe "C:\Program Files\Icaros\64-bit\IcarosThumbnailProvider.dll" /s
RegSvr32.exe "C:\Program Files\Icaros\64-bit\IcarosPropertyHandler.dll" /s

Write-Host "Done Configuring Apps" -ForegroundColor Green


Write-Host "Installing Fonts..." -ForegroundColor Green

New-Item -ItemType directory -Force -Path "$TMP\Fonts" -ErrorAction SilentlyContinue > $null
$fonts =
'Alice',
'Cantarell',
'Fira Code',
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
	wget -O $TMP\Fonts\$font.zip "https://fonts.google.com/download?family=$font"
	Expand-Archive -Path $TMP\Fonts\$font.zip -DestinationPath $TMP\Fonts -Force
}

if ($DOT) {
	$fonts =
	'Sawarabi Gothic',
	'Sawarabi Mincho',
	'Noto Sans JP',
	'Noto Serif JP'
	foreach ($font in $fonts) {
		wget -O $TMP\Fonts\$font.zip "https://fonts.google.com/download?family=$font"
		Expand-Archive -Path $TMP\Fonts\$font.zip -DestinationPath $TMP\Fonts -Force
	}
	
}
Remove-Item "$TMP\Fonts\static\" -Recurse -Force -ErrorAction SilentlyContinue

wget -O "$TMP\Fonts\Gandhi Sans.zip" https://www.fontsquirrel.com/fonts/download/gandhi-sans
Expand-Archive -Path "$TMP\Fonts\Gandhi Sans.zip" -DestinationPath $TMP\Fonts -Force

wget -O "$TMP\Fonts\Cascadia Code.zip" ((Invoke-RestMethod -Method GET -Uri "https://api.github.com/repos/microsoft/cascadia-code/releases/latest").assets | Where-Object name -like Cascadia*.zip ).browser_download_url
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

if ($DOT) {
	Set-Symlink -Path "$HOME\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState" -Target "$DOT\windows\WindowsTerminal"
}

$ProgressPreference = $OriginalPref
Remove-Item $TMP -Recurse -Force -ErrorAction SilentlyContinue
Write-Host "Done! Please restart your computer." -ForegroundColor Green
$host.UI.RawUI.FlushInputBuffer()
$Host.UI.ReadLine()
[Environment]::Exit(0)
