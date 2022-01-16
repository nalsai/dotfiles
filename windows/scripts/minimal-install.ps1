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

Write-Host "Uninstall Windows Media Player? [Y/n]: " -ForegroundColor Yellow -NoNewline
$host.UI.RawUI.FlushInputBuffer()
$key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
while(-Not($key.Character -eq "Y" -Or $key.Character -eq "N" -Or $key.VirtualKeyCode -eq 13)) {
	$key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}
Write-Host $key.Character
Switch ($key.Character) {
	Default {
		Disable-WindowsOptionalFeature -Online -FeatureName "WindowsMediaPlayer" -NoRestart -WarningAction SilentlyContinue > $null	
	}
	N {}
}

Write-Output "Disabling Diagnostics Tracking Service"
Set-Service "DiagTrack" -StartupType Disabled

Write-Output "Removing unnecessary AppxPackages"
$AppXApps = @(
#	"Microsoft.3DBuilder"
	"Microsoft.BingWeather"
	"Microsoft.GetHelp"
	"Microsoft.Getstarted"
	"Microsoft.Messaging"
	"Microsoft.MicrosoftOfficeHub"
	"Microsoft.MicrosoftSolitaireCollection"
#	"Microsoft.MSPaint"
	"Microsoft.Office.OneNote"
	"Microsoft.OneConnect"
#	"Microsoft.People"
	"Microsoft.Print3D"
#	"microsoft.windowscommunicationsapps"
	"Microsoft.WindowsFeedbackHub"
	"Microsoft.WindowsMaps"
	"Microsoft.YourPhone"
#	"Microsoft.ZuneMusic"
#	"Microsoft.ZuneVideo"
	"Microsoft.BingNews"
	"Microsoft.Office.Sway"
	"*EclipseManager*"
	"*ActiproSoftwareLLC*"
	"*AdobeSystemsIncorporated.AdobePhotoshop*"
	"*Duolingo-LearnLanguagesforFree*"
	"*PandoraMediaInc*"
	"*CandyCrush*"
	"*Wunderlist*"
	"*Flipboard*"
	"*Twitter*"
	"*Facebook*"
	"*Spotify*"
)
foreach ($App in $AppXApps) {
	try { Get-AppxPackage -Name $App | Remove-AppxPackage > $null } catch {}
	try { Get-AppxPackage -Name $App -AllUsers | Remove-AppxPackage -AllUsers > $null } catch {}
	try { Get-AppxProvisionedPackage -Online | Where-Object DisplayName -like $App | Remove-AppxProvisionedPackage -Online > $null } catch {}
}

Write-Host "Removing Bloatware Registry Keys"
$keys = @(
	"HKCR:\Extensions\ContractId\Windows.BackgroundTasks\PackageId\46928bounde.EclipseManager_2.2.4.51_neutral__a5h4egax66k6y"
	"HKCR:\Extensions\ContractId\Windows.BackgroundTasks\PackageId\ActiproSoftwareLLC.562882FEEB491_2.6.18.18_neutral__24pqs290vpjk0"
	"HKCR:\Extensions\ContractId\Windows.BackgroundTasks\PackageId\Microsoft.MicrosoftOfficeHub_17.7909.7600.0_x64__8wekyb3d8bbwe"
	"HKCR:\Extensions\ContractId\Windows.BackgroundTasks\PackageId\Microsoft.PPIProjection_10.0.15063.0_neutral_neutral_cw5n1h2txyewy"
	"HKCR:\Extensions\ContractId\Windows.BackgroundTasks\PackageId\Microsoft.XboxGameCallableUI_1000.15063.0.0_neutral_neutral_cw5n1h2txyewy"
	"HKCR:\Extensions\ContractId\Windows.BackgroundTasks\PackageId\Microsoft.XboxGameCallableUI_1000.16299.15.0_neutral_neutral_cw5n1h2txyewy"
	"HKCR:\Extensions\ContractId\Windows.File\PackageId\ActiproSoftwareLLC.562882FEEB491_2.6.18.18_neutral__24pqs290vpjk0"
	"HKCR:\Extensions\ContractId\Windows.Launch\PackageId\46928bounde.EclipseManager_2.2.4.51_neutral__a5h4egax66k6y"
	"HKCR:\Extensions\ContractId\Windows.Launch\PackageId\ActiproSoftwareLLC.562882FEEB491_2.6.18.18_neutral__24pqs290vpjk0"
	"HKCR:\Extensions\ContractId\Windows.Launch\PackageId\Microsoft.PPIProjection_10.0.15063.0_neutral_neutral_cw5n1h2txyewy"
	"HKCR:\Extensions\ContractId\Windows.Launch\PackageId\Microsoft.XboxGameCallableUI_1000.15063.0.0_neutral_neutral_cw5n1h2txyewy"
	"HKCR:\Extensions\ContractId\Windows.Launch\PackageId\Microsoft.XboxGameCallableUI_1000.16299.15.0_neutral_neutral_cw5n1h2txyewy"
	"HKCR:\Extensions\ContractId\Windows.PreInstalledConfigTask\PackageId\Microsoft.MicrosoftOfficeHub_17.7909.7600.0_x64__8wekyb3d8bbwe"
	"HKCR:\Extensions\ContractId\Windows.Protocol\PackageId\ActiproSoftwareLLC.562882FEEB491_2.6.18.18_neutral__24pqs290vpjk0"
	"HKCR:\Extensions\ContractId\Windows.Protocol\PackageId\Microsoft.PPIProjection_10.0.15063.0_neutral_neutral_cw5n1h2txyewy"
	"HKCR:\Extensions\ContractId\Windows.Protocol\PackageId\Microsoft.XboxGameCallableUI_1000.15063.0.0_neutral_neutral_cw5n1h2txyewy"
	"HKCR:\Extensions\ContractId\Windows.Protocol\PackageId\Microsoft.XboxGameCallableUI_1000.16299.15.0_neutral_neutral_cw5n1h2txyewy"
	"HKCR:\Extensions\ContractId\Windows.ShareTarget\PackageId\ActiproSoftwareLLC.562882FEEB491_2.6.18.18_neutral__24pqs290vpjk0"

	# Context Menu
	"HKLM:\Software\Classes\SystemFileAssociations\.bmp\Shell\3D Edit"
	"HKLM:\Software\Classes\SystemFileAssociations\.gif\Shell\3D Edit"
	"HKLM:\Software\Classes\SystemFileAssociations\.jpg\Shell\3D Edit"
	"HKLM:\Software\Classes\SystemFileAssociations\.jpeg\Shell\3D Edit"
	"HKLM:\Software\Classes\SystemFileAssociations\.png\Shell\3D Edit"
	"HKLM:\Software\Classes\SystemFileAssociations\.tif\Shell\3D Edit"
	"HKLM:\Software\Classes\SystemFileAssociations\.tiff\Shell\3D Edit"
#	"HKLM:\Software\Classes\SystemFileAssociations\.bmp\Shell\setdesktopwallpaper"
#	"HKLM:\Software\Classes\SystemFileAssociations\.gif\Shell\setdesktopwallpaper"
#	"HKLM:\Software\Classes\SystemFileAssociations\.jpg\Shell\setdesktopwallpaper"
#	"HKLM:\Software\Classes\SystemFileAssociations\.jpeg\Shell\setdesktopwallpaper"
#	"HKLM:\Software\Classes\SystemFileAssociations\.png\Shell\setdesktopwallpaper"
#	"HKLM:\Software\Classes\SystemFileAssociations\.tif\Shell\setdesktopwallpaper"
#	"HKLM:\Software\Classes\SystemFileAssociations\.tiff\Shell\setdesktopwallpaper"
	"HKCR:\SystemFileAssociations\.bmp\ShellEx\ContextMenuHandlers\ShellImagePreview"   # Rotate Left and Rotate Right in Context Menu
	"HKCR:\SystemFileAssociations\.dib\ShellEx\ContextMenuHandlers\ShellImagePreview"
	"HKCR:\SystemFileAssociations\.gif\ShellEx\ContextMenuHandlers\ShellImagePreview"
	"HKCR:\SystemFileAssociations\.heic\ShellEx\ContextMenuHandlers\ShellImagePreview"
	"HKCR:\SystemFileAssociations\.heif\ShellEx\ContextMenuHandlers\ShellImagePreview"
	"HKCR:\SystemFileAssociations\.ico\ShellEx\ContextMenuHandlers\ShellImagePreview"
	"HKCR:\SystemFileAssociations\.jfif\ShellEx\ContextMenuHandlers\ShellImagePreview"
	"HKCR:\SystemFileAssociations\.jpe\ShellEx\ContextMenuHandlers\ShellImagePreview"
	"HKCR:\SystemFileAssociations\.jpeg\ShellEx\ContextMenuHandlers\ShellImagePreview"
	"HKCR:\SystemFileAssociations\.jpg\ShellEx\ContextMenuHandlers\ShellImagePreview"
	"HKCR:\SystemFileAssociations\.png\ShellEx\ContextMenuHandlers\ShellImagePreview"
	"HKCR:\SystemFileAssociations\.rle\ShellEx\ContextMenuHandlers\ShellImagePreview"
	"HKCR:\SystemFileAssociations\.tif\ShellEx\ContextMenuHandlers\ShellImagePreview"
	"HKCR:\SystemFileAssociations\.tiff\ShellEx\ContextMenuHandlers\ShellImagePreview"
	"HKCR:\SystemFileAssociations\.webp\ShellEx\ContextMenuHandlers\ShellImagePreview"
	"HKCR:\*\shellex\ContextMenuHandlers\ModernSharing"                                 # Share
	"HKCR:\*\shellex\ContextMenuHandlers\{90AA3A4E-1CBA-4233-B8BB-535773D48449}"        # Pin To Taskbar
#	"HKCR:\CLSID\{09A47860-11B0-4DA5-AFA5-26D86198A780}"                                # Scan with Microsoft Defender
	"HKCR:\Folder\ShellEx\ContextMenuHandlers\Library Location"
	"HKLM:\Software\Classes\SystemFileAssociations\image\shell\edit"
)
foreach ($key in $keys) {
	Remove-Item -LiteralPath $key -Recurse -ErrorAction SilentlyContinue
}

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
	"HKCU:\Software\Microsoft\Windows\CurrentVersion\SettingSync"
	"HKCU:\Software\Microsoft\Windows\CurrentVersion\SettingSync\Groups"
	"HKCU:\Software\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Accessibility"
	"HKCU:\Software\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Credentials"
	"HKCU:\Software\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Language"
	"HKCU:\Software\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Personalization"
	"HKCU:\Software\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Windows"
	"HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Sensor\Overrides\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}"
	"HKLM:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo"
	"HKLM:\Software\Microsoft\Windows\CurrentVersion\AppModelUnlock"
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

Write-Host "Turning Off Enhance Pointer Precision"
Set-ItemProperty "HKCU:\Control Panel\Mouse" "MouseSpeed" 0
Set-ItemProperty "HKCU:\Control Panel\Mouse" "MouseThreshold1" 0
Set-ItemProperty "HKCU:\Control Panel\Mouse" "MouseThreshold2" 0

Write-Host "Disabling Cortana and Bing Search in Start Menu"
Set-ItemProperty "HKCU:\Software\Microsoft\InputPersonalization" "RestrictImplicitInkCollection" 1
Set-ItemProperty "HKCU:\Software\Microsoft\InputPersonalization\TrainedDataStore" "HarvestContacts" 0
Set-ItemProperty "HKCU:\Software\Microsoft\Personalization\Settings" "AcceptedPrivacyPolicy" 0
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" "BingSearchEnabled" 0
Set-ItemProperty "HKLM:\Software\Policies\Microsoft\Windows\Windows Search" "AllowCortana" 0
Set-ItemProperty "HKLM:\Software\Policies\Microsoft\Windows\Windows Search" "DisableWebSearch" 1

Write-Output "Disabling Windows Feedback Experience program"
Set-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" "Enabled" 0

Write-Output "Disabling Location Tracking"
Set-ItemProperty "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Sensor\Overrides\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}" "SensorPermissionState" 0
Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Services\lfsvc\Service\Configuration" "Status" 0

Write-Output "Turning off Data Collection"
Set-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\DataCollection" "AllowTelemetry" 0
Set-ItemProperty "HKLM:\Software\Policies\Microsoft\Windows\DataCollection" "AllowTelemetry" 0
Set-ItemProperty "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Policies\DataCollection" "AllowTelemetry" 0

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
#Set-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\Attachments" "SaveZoneInformation" 1		# Disable downloaded files from being blocked

Write-Output "Disabling Context Menu bloat"
Set-ItemProperty "HKCR:\AppX43hnxtbyyps62jhe9sqpdzxn1790zetc\Shell\ShellEdit" "ProgrammaticAccessOnly" "" -ErrorAction SilentlyContinue # Edit with Photos
Set-ItemProperty "HKCR:\AppXk0g4vb8gvt7b93tg50ybcy892pge6jmt\Shell\ShellEdit" "ProgrammaticAccessOnly" "" -ErrorAction SilentlyContinue # Edit with Photos
Set-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked" "{470C0EBD-5D73-4d58-9CED-E91E22E23282}" "" # Pin To Start
Set-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked" "{596AB062-B4D2-4215-9F74-E9109B0A8153}" "" # Restore Previous Versions
Set-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked" "{7AD84985-87B4-4a16-BE58-8B72A5B390F7}" "" # Cast to Device
Set-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked" "{8A734961-C4AA-4741-AC1E-791ACEBF5B39}" "" # Shop for music online
Set-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked" "{e2bf9676-5f8f-435c-97eb-11607a5bedf7}" "" # Share
Set-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked" "{f81e9010-6ea4-11ce-a7ff-00aa003ca9f6}" "" # Give Access To

Write-Output "Hiding stuff in the SysTray"
#Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "ShowTaskViewButton" 0			# Task view
#Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" "SearchboxTaskbarMode" 0						# Search
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Feeds" "ShellFeedsTaskbarViewMode" 2					# News and weather (Windows 10)
Set-ItemProperty "HKLM:\Software\Policies\Microsoft\Windows\System" "EnableActivityFeed" 0								# Timeline (Windows 10)
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People" "PeopleBand" 0				# People (Windows 10)
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "TaskbarDa" 0						# Widgets (Windows 11)
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "TaskbarMn" 0						# Chat (Windows 11)

Write-Output "Disabling automatic syncing of settings"
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Accessibility" "Enabled" 0
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Credentials" "Enabled" 0
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Language" "Enabled" 0
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Personalization" "Enabled" 0
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Windows" "Enabled" 0

Write-Host "Configuring Windows Update"
Set-ItemProperty "HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate" "NoAutoRebootWithLoggedOnUsers" 1
Set-ItemProperty "HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU" "AUOptions" 3
Set-ItemProperty "HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU" "IncludeRecommendedUpdates" 1
Set-ItemProperty "HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU" "NoAutoRebootWithLoggedOnUsers" 1
Set-ItemProperty "HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU" "NoAutoUpdate" 0
(New-Object -ComObject Microsoft.Update.ServiceManager -Strict).AddService2("7971f918-a847-4430-9279-4a52d1efe18d", 7, "") > $null

Write-Host "Current Name of Computer: " -NoNewline
Write-Host (Get-CimInstance -ClassName Win32_ComputerSystem).Name
Write-Host "Change Name of Computer? [y/N]: " -ForegroundColor Yellow -NoNewline
$host.UI.RawUI.FlushInputBuffer()
$key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
while(-Not($key.Character -eq "Y" -Or $key.Character -eq "N" -Or $key.VirtualKeyCode -eq 13)) {
	$key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}
Write-Host $key.Character
Switch ($key.Character) {
	Y {
		Write-Host "Name: " -ForegroundColor Cyan -NoNewline
		$computerName = Read-Host
		(Get-WmiObject Win32_ComputerSystem).Rename("$computerName") > $null
	}
	Default {}
}

Write-Host "Done Configuring System" -ForegroundColor Green


Write-Host "Installing Apps..." -ForegroundColor Green

# Install chocolatey if not already installed
if (!(Get-Command choco -ErrorAction SilentlyContinue | Test-Path)) {
	Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
	choco feature enable -n=allowGlobalConfirmation
	choco feature enable -n=useRememberedArgumentsForUpgrades
}

choco install git --params "/GitAndUnixToolsOnPath /NoShellIntegration /WindowsTerminal" --limit-output
choco install 7zip adoptopenjdkjre altdrag cdburnerxp crystaldiskinfo curl edgedeflector everything ffmpeg firefox gimp googlechrome hwinfo icaros libreoffice-fresh microsoft-windows-terminal mpv nomacs notepad2-mod paint.net rclone vlc wget winbtrfs windirstat youtube-dl --limit-output

Write-Host "Install Cinebench, CrystalDiskMark, Furmark, Prime95? [y/N]: " -ForegroundColor Yellow -NoNewline
$host.UI.RawUI.FlushInputBuffer()
$key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
while(-Not($key.Character -eq "Y" -Or $key.Character -eq "N" -Or $key.VirtualKeyCode -eq 13)) {
	$key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}
Write-Host $key.Character
Switch ($key.Character) {
	Y {
		choco install cinebench crystaldiskmark furmark prime95 --limit-output
	}
	Default {}
}

#if (!((Get-ChildItem -Path 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP' -Recurse | Get-ItemProperty -Name 'Version' -ErrorAction SilentlyContinue | ForEach-Object { $_.Version -as [System.Version] } | Where-Object { $_.Major -eq 3 -and $_.Minor -eq 5 }).Count -ge 1)) {
#	Write-Host "Installing .NET 3.5"
#	Enable-WindowsOptionalFeature -Online -FeatureName "NetFx3" -NoRestart > $null
#}

Write-Output "Removing VLC from Context Menu"
New-PSDrive HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT -ErrorAction SilentlyContinue > $null
$Keys = @(
	"HKCR:\Directory\shell\AddToPlaylistVLC\"
	"HKCR:\Directory\shell\PlayWithVLC\"
	"HKCR:\VLC.*\shell\AddToPlaylistVLC\"
	"HKCR:\VLC.*\shell\PlayWithVLC\"
)
ForEach ($Key in $Keys) {
	Remove-Item $Key -Recurse -ErrorAction SilentlyContinue
}

Write-Host "Done Installing Apps" -ForegroundColor Green


Write-Host "Configuring Apps..." -ForegroundColor Green

# mpv
New-Item -ItemType directory -Force -Path "$HOME\AppData\Roaming\mpv" -ErrorAction SilentlyContinue > $null
wget.exe -O "$HOME\AppData\Roaming\mpv\mpv.conf" "https://raw.githubusercontent.com/Nalsai/dotfiles/main/mpv/mpv-minimal/mpv.conf"
wget.exe -O "$HOME\AppData\Roaming\mpv\input.conf" "https://raw.githubusercontent.com/Nalsai/dotfiles/main/mpv/mpv-minimal/input.conf"

# Notepad2
New-Item -ItemType directory -Force -Path "$HOME\AppData\Roaming\Notepad2" -ErrorAction SilentlyContinue > $null
wget.exe -O "$HOME\AppData\Roaming\Notepad2\Notepad2.ini" "https://raw.githubusercontent.com/Nalsai/dotfiles/main/windows/Notepad2/Notepad2.ini"

# AltDrag
wget.exe -O "$HOME\AppData\Roaming\AltDrag\AltDrag.ini" "https://raw.githubusercontent.com/Nalsai/dotfiles/main/windows/AltDrag/AltDrag.ini"
Start-Process "$HOME\AppData\Roaming\AltDrag\AltDrag.exe" -ArgumentList "-h"
$action = New-ScheduledTaskAction -Execute $ExecutionContext.InvokeCommand.ExpandString('$HOME\AppData\Roaming\AltDrag\AltDrag.exe') -Argument '-h'
$trigger = New-ScheduledTaskTrigger -AtLogon
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries
Register-ScheduledTask -TaskName "AltDrag" -Action $action -Trigger $trigger -Settings $settings -RunLevel Highest -Force > $null

# Icaros
Set-ItemProperty "HKLM:\Software\Icaros" "Thumbnail Extensions" "3g2;3gp;3gp2;3gpp;amv;ape;asf;avi;bik;bmp;cb7;cbr;cbz;divx;dpg;dv;dvr-ms;epub;evo;f4v;flac;flv;gif;hdmov;jpg;k3g;m1v;m2t;m2ts;m2v;m4b;m4p;m4v;mk3d;mka;mkv;mov;mp2v;mp3;mp4;mp4v;mpc;mpe;mpeg;mpg;mpv2;mpv4﻿﻿;mqv;mts;mxf;nsv;ofr;ofs;ogg;ogm;ogv;opus;png;qt;ram;rm;rmvb;skm;spx;swf;tak;tif;tiff;tp;tpr;trp;ts;tta;vob;wav;webm;wm;wmv;wv;xvid"
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
