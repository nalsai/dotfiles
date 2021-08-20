# Self-elevate the script if required
if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
	$CommandLine = "-NoExit -File `"" + $MyInvocation.MyCommand.Path + "`" " + $MyInvocation.UnboundArguments
	Start-Process -FilePath PowerShell.exe -Verb Runas -ArgumentList $CommandLine
	Exit
}

Clear-Host
Write-Host " _   _ _ _     ____        _    __ _ _`n| \ | (_| |___|  _ \  ___ | |_ / _(_| | ___ ___`n|  \| | | / __| | | |/ _ \| __| |_| | |/ _ / __|`n| |\  | | \__ | |_| | (_) | |_|  _| | |  __\__ \`n|_| \_|_|_|___|____/ \___/ \__|_| |_|_|\___|___/"
Write-Host "[minimal-install.ps1]`n"

$DOT = "$HOME\.dotfiles"
$TMP = "$env:TEMP\ZG90ZmlsZXM"
New-Item -ItemType directory -Force -Path $TMP -ErrorAction SilentlyContinue > $null
$OriginalPref = $ProgressPreference
$ProgressPreference = "SilentlyContinue"

Write-Host "Configuring System..." -ForegroundColor Green

New-PSDrive HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT -ErrorAction SilentlyContinue > $null

Write-Output "Disabling WAP Push Service & Diagnostics Tracking Service"
Set-Service "dmwappushservice" -StartupType Disabled
Set-Service "DiagTrack" -StartupType Disabled

Write-Output "Removing unnecessary AppxPackages"
$AppXApps = @(
	"Microsoft.GetHelp"
	"Microsoft.Getstarted"
	"Microsoft.MicrosoftOfficeHub"
	"Microsoft.OneConnect"
	"Microsoft.Print3D"
	"Microsoft.WindowsFeedbackHub"
	"Microsoft.YourPhone"
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
	try { Get-AppxPackage -Name $App | Remove-AppxPackage } catch {}
	try { Get-AppxPackage -Name $App -AllUsers | Remove-AppxPackage -AllUsers } catch {}
	try { Get-AppxProvisionedPackage -Online | Where-Object DisplayName -like $App | Remove-AppxProvisionedPackage -Online } catch {}
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
	"HKLM:\SOFTWARE\Classes\SystemFileAssociations\.bmp\Shell\3D Edit"
	"HKLM:\SOFTWARE\Classes\SystemFileAssociations\.gif\Shell\3D Edit"
	"HKLM:\SOFTWARE\Classes\SystemFileAssociations\.jpg\Shell\3D Edit"
	"HKLM:\SOFTWARE\Classes\SystemFileAssociations\.jpeg\Shell\3D Edit"
	"HKLM:\SOFTWARE\Classes\SystemFileAssociations\.png\Shell\3D Edit"
	"HKLM:\SOFTWARE\Classes\SystemFileAssociations\.tif\Shell\3D Edit"
	"HKLM:\SOFTWARE\Classes\SystemFileAssociations\.tiff\Shell\3D Edit"
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
	"HKCR:\Folder\ShellEx\ContextMenuHandlers\Library Location"
	"HKLM:\SOFTWARE\Classes\SystemFileAssociations\image\shell\edit"
)
foreach ($key in $keys) {
	Remove-Item -LiteralPath $key -Recurse -ErrorAction SilentlyContinue
}

Write-Output "Creating Registry Folders"
$folders = @(
	"HKCU:\SOFTWARE\Microsoft\InputPersonalization"
	"HKCU:\SOFTWARE\Microsoft\InputPersonalization\TrainedDataStore"
	"HKCU:\SOFTWARE\Microsoft\Personalization\Settings"
	"HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
	"HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
	"HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People"
	"HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer"
	"HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search"
	"HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\SettingSync"
	"HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\SettingSync\Groups"
	"HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Accessibility"
	"HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Credentials"
	"HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Language"
	"HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Personalization"
	"HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Windows"
	"HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Sensor\Overrides\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}"
	"HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo"
	"HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock"
	"HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Attachments"
	"HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection"
	"HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked"
	"HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize"
	"HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\UserProfileEngagement"
	"HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent"
	"HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"
	"HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer"
	"HKLM:\SOFTWARE\Policies\Microsoft\Windows\System"
	"HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"
	"HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"
	"HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"
	"HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Policies\DataCollection"
	"HKLM:\SYSTEM\CurrentControlSet\Services\lfsvc\Service\Configuration"
)
foreach ($folder in $folders) {
	if (!(Test-Path $folder)) { New-Item $folder -Type Folder > $null }
}

Write-Host "Disabling Cortana and Bing Search in Start Menu"
Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\InputPersonalization" "RestrictImplicitInkCollection" 1
Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\InputPersonalization\TrainedDataStore" "HarvestContacts" 0
Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Personalization\Settings" "AcceptedPrivacyPolicy" 0
Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" "BingSearchEnabled" 0
Set-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" "AllowCortana" 0
Set-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" "DisableWebSearch" 1

Write-Output "Disabling Windows Feedback Experience program"
Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo" "Enabled" 0

Write-Output "Disabling Location Tracking"
Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Sensor\Overrides\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}" "SensorPermissionState" 0
Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Services\lfsvc\Service\Configuration" "Status" 0

Write-Output "Turning off Data Collection"
Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" "AllowTelemetry" 0
Set-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" "AllowTelemetry" 0
Set-ItemProperty "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Policies\DataCollection" "AllowTelemetry" 0

Write-Output "Disabling bloatware apps from returning, Start Menu Suggestions, Get Even More Out of Windows screen and notifications"
Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "ContentDeliveryAllowed" 0
Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "ContentDeliveryManager" 0
Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "OemPreInstalledAppsEnabled" 0
Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "PreInstalledAppsEnabled" 0
Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "PreInstalledAppsEverEnabled" 0
Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "SilentInstalledAppsEnabled" 0
Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "SubscribedContent-310093Enabled" 0
Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "SubscribedContent-314563Enabled" 0
Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "SubscribedContent-338388Enabled" 0
Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "SubscribedContent-338389Enabled" 0
Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "SubscribedContent-338393Enabled" 0
Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "SubscribedContent-353698Enabled" 0
Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "SystemPaneSuggestionsEnabled" 0
Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "SystemPaneSuggestionsEnabled" 0
Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\UserProfileEngagement" "ScoobeSystemSettingEnabled" 0
Set-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" "DisableWindowsConsumerFeatures" 1

Write-Output "Applying Explorer tweaks"
Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "HideFileExt" 0
Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "Start_TrackDocs" 0
Set-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" "NoUseStoreOpenWith" 1

Write-Output "Disabling Context Menu bloat"
Set-ItemProperty "HKCR:\AppX43hnxtbyyps62jhe9sqpdzxn1790zetc\Shell\ShellEdit" "ProgrammaticAccessOnly" "" -ErrorAction SilentlyContinue # Edit with Photos
Set-ItemProperty "HKCR:\AppXk0g4vb8gvt7b93tg50ybcy892pge6jmt\Shell\ShellEdit" "ProgrammaticAccessOnly" "" -ErrorAction SilentlyContinue # Edit with Photos
Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked" "{470C0EBD-5D73-4d58-9CED-E91E22E23282}" "" # Pin To Start
Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked" "{596AB062-B4D2-4215-9F74-E9109B0A8153}" "" # Restore Previous Versions
Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked" "{7AD84985-87B4-4a16-BE58-8B72A5B390F7}" "" # Cast to Device
Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked" "{8A734961-C4AA-4741-AC1E-791ACEBF5B39}" "" # Shop for music online
Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked" "{e2bf9676-5f8f-435c-97eb-11607a5bedf7}" "" # Share
Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked" "{f81e9010-6ea4-11ce-a7ff-00aa003ca9f6}" "" # Give Access To

Write-Output "Hiding stuff in the SysTray"
Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People" "PeopleBand" 0

Write-Output "Disabling automatic syncing of settings"
Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Accessibility" "Enabled" 0
Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Credentials" "Enabled" 0
Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Language" "Enabled" 0
Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Personalization" "Enabled" 0
Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Windows" "Enabled" 0

Write-Host "Configuring Windows Update"
Set-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" "NoAutoRebootWithLoggedOnUsers" 1
Set-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" "AUOptions" 3
Set-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" "IncludeRecommendedUpdates" 1
Set-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" "NoAutoRebootWithLoggedOnUsers" 1
Set-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" "NoAutoUpdate" 0
(New-Object -ComObject Microsoft.Update.ServiceManager -Strict).AddService2("7971f918-a847-4430-9279-4a52d1efe18d", 7, "") > $null

Write-Host "Done Configuring System" -ForegroundColor Green


Write-Host "Installing Apps..." -ForegroundColor Green

# install chocolatey if not already installed
if (!(Get-Command choco -ErrorAction SilentlyContinue | Test-Path)) {
	Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
	choco feature enable -n=allowGlobalConfirmation
}

choco install 7zip adoptopenjdkjre curl ffmpeg firefox gimp googlechrome libreoffice-fresh mpv nomacs notepad2-mod paint.net rclone vlc wget windirstat youtube-dl --limit-output

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


Write-Host "Installing Fonts..." -ForegroundColor Green

$fontsPath = "$HOME\Downloads\Fonts"
New-Item -ItemType directory -Force -Path $fontsPath -ErrorAction SilentlyContinue > $null
$fonts =
'Alice',
'Lato',
'Montserrat',
'Quicksand',
'Merriweather',
'Comfortaa',
'Roboto',
'Noto Sans',
'Noto Serif'
foreach ($font in $fonts) {
	wget.exe -O $fontsPath\$font.zip "https://fonts.google.com/download?family=$font"
	Expand-Archive -Path $fontsPath\$font.zip -DestinationPath $fontsPath -Force
}
Remove-Item "$fontsPath\static\" -Recurse -Force

wget.exe -O "$fontsPath\Gandhi Sans.zip" https://www.fontsquirrel.com/fonts/download/gandhi-sans
Expand-Archive -Path "$fontsPath\Gandhi Sans.zip" -DestinationPath $fontsPath -Force

wget.exe -O "$fontsPath\Fira Code.zip" ((Invoke-RestMethod -Method GET -Uri "https://api.github.com/repos/tonsky/FiraCode/releases/latest").assets | Where-Object name -like Fira*.zip ).browser_download_url
Expand-Archive -Path "$fontsPath\Fira Code.zip" -DestinationPath "$fontsPath\Fira Code" -Force
Copy-Item -r "$fontsPath\Fira Code\variable_ttf\*" $fontsPath -ErrorAction SilentlyContinue
Remove-Item "$fontsPath\Fira Code" -Recurse -Force

wget.exe -O "$fontsPath\Cascadia Code.zip" ((Invoke-RestMethod -Method GET -Uri "https://api.github.com/repos/microsoft/cascadia-code/releases/latest").assets | Where-Object name -like Cascadia*.zip ).browser_download_url
Expand-Archive -Path "$fontsPath\Cascadia Code.zip" -DestinationPath "$fontsPath\Cascadia Code" -Force
Remove-Item "$fontsPath\Cascadia Code\ttf\static" -Recurse -Force
Copy-Item -r  "$fontsPath\Cascadia Code\ttf\*" $fontsPath -ErrorAction SilentlyContinue
Remove-Item "$fontsPath\Cascadia Code" -Recurse -Force

foreach ($File in $(Get-ChildItem -Path $fontsPath -Include ('*.otf', '*.ttf') -Recurse)) {
	if (!(Test-Path "C:\Windows\Fonts\$($File.Name)")) {
		Copy-Item $File.FullName C:\Windows\Fonts\$($File.Name)
		New-ItemProperty -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Fonts" -Name $File.Name -PropertyType string -Value $File.Name
	}
}

Remove-Item $fontsPath -Recurse -Force -ErrorAction SilentlyContinue

Write-Host "Done Installing Fonts" -ForegroundColor Green


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

$ProgressPreference = $OriginalPref
Remove-Item $TMP -Recurse -Force -ErrorAction SilentlyContinue
Write-Host "Done! Note that some changes require a restart to take effect." -ForegroundColor Green
$host.UI.RawUI.FlushInputBuffer()
$Host.UI.ReadLine()
[Environment]::Exit(0)