#Requires -RunAsAdministrator

Write-Host "Configuring System..." -ForegroundColor Green

Write-Host "Enabling Dark Mode"
$Theme = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize"
Set-ItemProperty $Theme SystemUsesLightTheme -Value 0
Set-ItemProperty $Theme AppsUseLightTheme -Value 0
Start-Sleep 1

Write-Host "Removing Bloatware RegKeys"
$Keys = @(
    #Remove Background Tasks
    "HKCR:\Extensions\ContractId\Windows.BackgroundTasks\PackageId\46928bounde.EclipseManager_2.2.4.51_neutral__a5h4egax66k6y"
    "HKCR:\Extensions\ContractId\Windows.BackgroundTasks\PackageId\ActiproSoftwareLLC.562882FEEB491_2.6.18.18_neutral__24pqs290vpjk0"
    "HKCR:\Extensions\ContractId\Windows.BackgroundTasks\PackageId\Microsoft.MicrosoftOfficeHub_17.7909.7600.0_x64__8wekyb3d8bbwe"
    "HKCR:\Extensions\ContractId\Windows.BackgroundTasks\PackageId\Microsoft.PPIProjection_10.0.15063.0_neutral_neutral_cw5n1h2txyewy"
    "HKCR:\Extensions\ContractId\Windows.BackgroundTasks\PackageId\Microsoft.XboxGameCallableUI_1000.15063.0.0_neutral_neutral_cw5n1h2txyewy"
    "HKCR:\Extensions\ContractId\Windows.BackgroundTasks\PackageId\Microsoft.XboxGameCallableUI_1000.16299.15.0_neutral_neutral_cw5n1h2txyewy"
        
    #Windows File
    "HKCR:\Extensions\ContractId\Windows.File\PackageId\ActiproSoftwareLLC.562882FEEB491_2.6.18.18_neutral__24pqs290vpjk0"
        
    #Registry keys to delete if they aren't uninstalled by RemoveAppXPackage/RemoveAppXProvisionedPackage
    "HKCR:\Extensions\ContractId\Windows.Launch\PackageId\46928bounde.EclipseManager_2.2.4.51_neutral__a5h4egax66k6y"
    "HKCR:\Extensions\ContractId\Windows.Launch\PackageId\ActiproSoftwareLLC.562882FEEB491_2.6.18.18_neutral__24pqs290vpjk0"
    "HKCR:\Extensions\ContractId\Windows.Launch\PackageId\Microsoft.PPIProjection_10.0.15063.0_neutral_neutral_cw5n1h2txyewy"
    "HKCR:\Extensions\ContractId\Windows.Launch\PackageId\Microsoft.XboxGameCallableUI_1000.15063.0.0_neutral_neutral_cw5n1h2txyewy"
    "HKCR:\Extensions\ContractId\Windows.Launch\PackageId\Microsoft.XboxGameCallableUI_1000.16299.15.0_neutral_neutral_cw5n1h2txyewy"
        
    #Scheduled Tasks to delete
    "HKCR:\Extensions\ContractId\Windows.PreInstalledConfigTask\PackageId\Microsoft.MicrosoftOfficeHub_17.7909.7600.0_x64__8wekyb3d8bbwe"
        
    #Windows Protocol Keys
    "HKCR:\Extensions\ContractId\Windows.Protocol\PackageId\ActiproSoftwareLLC.562882FEEB491_2.6.18.18_neutral__24pqs290vpjk0"
    "HKCR:\Extensions\ContractId\Windows.Protocol\PackageId\Microsoft.PPIProjection_10.0.15063.0_neutral_neutral_cw5n1h2txyewy"
    "HKCR:\Extensions\ContractId\Windows.Protocol\PackageId\Microsoft.XboxGameCallableUI_1000.15063.0.0_neutral_neutral_cw5n1h2txyewy"
    "HKCR:\Extensions\ContractId\Windows.Protocol\PackageId\Microsoft.XboxGameCallableUI_1000.16299.15.0_neutral_neutral_cw5n1h2txyewy"
            
    #Windows Share Target
    "HKCR:\Extensions\ContractId\Windows.ShareTarget\PackageId\ActiproSoftwareLLC.562882FEEB491_2.6.18.18_neutral__24pqs290vpjk0"
)
ForEach ($Key in $Keys) {
    Remove-Item $Key -Recurse -ErrorAction Ignore
}

Write-Host "Disabling Cortana"
$Cortana1 = "HKCU:\SOFTWARE\Microsoft\Personalization\Settings"
$Cortana2 = "HKCU:\SOFTWARE\Microsoft\InputPersonalization"
$Cortana3 = "HKCU:\SOFTWARE\Microsoft\InputPersonalization\TrainedDataStore"
If (!(Test-Path $Cortana1)) {
    New-Item $Cortana1
}
Set-ItemProperty $Cortana1 AcceptedPrivacyPolicy -Value 0 
If (!(Test-Path $Cortana2)) {
    New-Item $Cortana2
}
Set-ItemProperty $Cortana2 RestrictImplicitTextCollection -Value 1 
Set-ItemProperty $Cortana2 RestrictImplicitInkCollection -Value 1 
If (!(Test-Path $Cortana3)) {
    New-Item $Cortana3
}
Set-ItemProperty $Cortana3 HarvestContacts -Value 0


Write-Output "Uninstalling OneDrive"
New-PSDrive HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT > $null
$onedrive = "$env:SYSTEMROOT\SysWOW64\OneDriveSetup.exe"
$ExplorerReg1 = "HKCR:\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}"
$ExplorerReg2 = "HKCR:\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}"
Stop-Process -Name "OneDrive*"
Start-Sleep 2
If (!(Test-Path $onedrive)) {
    $onedrive = "$env:SYSTEMROOT\System32\OneDriveSetup.exe"
}
Start-Process $onedrive "/uninstall" -NoNewWindow -Wait
Stop-Process -name explorer
Remove-Item "$env:USERPROFILE\OneDrive" -Force -Recurse -ErrorAction Ignore
Remove-Item "$env:LOCALAPPDATA\Microsoft\OneDrive" -Force -Recurse -ErrorAction Ignore
Remove-Item "$env:PROGRAMDATA\Microsoft OneDrive" -Force -Recurse -ErrorAction Ignore
If (Test-Path "$env:SYSTEMDRIVE\OneDriveTemp") {
    Remove-Item "$env:SYSTEMDRIVE\OneDriveTemp" -Force -Recurse
}
Write-Output "Removing OneDrive from windows explorer"
If (!(Test-Path $ExplorerReg1)) {
    New-Item $ExplorerReg1 > $null
}
Set-ItemProperty $ExplorerReg1 System.IsPinnedToNameSpaceTree -Value 0 
If (!(Test-Path $ExplorerReg2)) {
    New-Item $ExplorerReg2 > $null
}
Set-ItemProperty $ExplorerReg2 System.IsPinnedToNameSpaceTree -Value 0


Write-Output "Unpinning all tiles from the start menu"
$START_MENU_LAYOUT = @"
<LayoutModificationTemplate xmlns:defaultlayout="http://schemas.microsoft.com/Start/2014/FullDefaultLayout" xmlns:start="http://schemas.microsoft.com/Start/2014/StartLayout" Version="1" xmlns:taskbar="http://schemas.microsoft.com/Start/2014/TaskbarLayout" xmlns="http://schemas.microsoft.com/Start/2014/LayoutModification">
    <LayoutOptions StartTileGroupCellWidth="6" />
    <DefaultLayoutOverride>
        <StartLayoutCollection>
            <defaultlayout:StartLayout GroupCellWidth="6" />
        </StartLayoutCollection>
    </DefaultLayoutOverride>
</LayoutModificationTemplate>
"@
$layoutFile="C:\Windows\StartMenuLayout.xml"
If(Test-Path $layoutFile)
{
    Remove-Item $layoutFile
}
$START_MENU_LAYOUT | Out-File $layoutFile -Encoding ASCII
$regAliases = @("HKLM", "HKCU")
foreach ($regAlias in $regAliases){
    $basePath = $regAlias + ":\SOFTWARE\Policies\Microsoft\Windows"
    $keyPath = $basePath + "\Explorer" 
    IF(!(Test-Path -Path $keyPath)) { 
        New-Item -Path $basePath -Name "Explorer" > $null
    }
    Set-ItemProperty -Path $keyPath -Name "LockedStartLayout" -Value 1
    Set-ItemProperty -Path $keyPath -Name "StartLayoutFile" -Value $layoutFile
}
Stop-Process -name explorer
Start-Sleep -s 5
$wshell = New-Object -ComObject wscript.shell; $wshell.SendKeys('^{ESCAPE}')
Start-Sleep -s 5
foreach ($regAlias in $regAliases){
    $basePath = $regAlias + ":\SOFTWARE\Policies\Microsoft\Windows"
    $keyPath = $basePath + "\Explorer" 
    Set-ItemProperty -Path $keyPath -Name "LockedStartLayout" -Value 0
}
Stop-Process -name explorer
Remove-Item $layoutFile


Write-Output "Disabling Windows Feedback Experience program"
$Advertising = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo"
If (Test-Path $Advertising) {
    Set-ItemProperty $Advertising Enabled -Value 0
}


Write-Output "Stopping Cortana from being used as part of your Windows Search Function"
$Search = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"
If (Test-Path $Search) {
    Set-ItemProperty $Search AllowCortana -Value 0
}


Write-Output "Disabling Bing Search in Start Menu"
$WebSearch = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"
Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" BingSearchEnabled -Value 0
If (!(Test-Path $WebSearch)) {
    New-Item $WebSearch
}
Set-ItemProperty $WebSearch DisableWebSearch -Value 1


Write-Output "Adding Registry key to prevent bloatware apps from returning"
$registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent"
$registryOEM = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
If (!(Test-Path $registryPath)) { 
    New-Item $registryPath
}
Set-ItemProperty $registryPath DisableWindowsConsumerFeatures -Value 1 
If (!(Test-Path $registryOEM)) {
    New-Item $registryOEM
}
Set-ItemProperty $registryOEM  ContentDeliveryAllowed -Value 0 
Set-ItemProperty $registryOEM  OemPreInstalledAppsEnabled -Value 0 
Set-ItemProperty $registryOEM  PreInstalledAppsEnabled -Value 0 
Set-ItemProperty $registryOEM  PreInstalledAppsEverEnabled -Value 0 
Set-ItemProperty $registryOEM  SilentInstalledAppsEnabled -Value 0 
Set-ItemProperty $registryOEM  SystemPaneSuggestionsEnabled -Value 0          


Write-Output "Turning off Data Collection"
$DataCollection1 = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection"
$DataCollection2 = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"
$DataCollection3 = "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Policies\DataCollection"    
If (Test-Path $DataCollection1) {
    Set-ItemProperty $DataCollection1  AllowTelemetry -Value 0
}
If (Test-Path $DataCollection2) {
    Set-ItemProperty $DataCollection2  AllowTelemetry -Value 0
}
If (Test-Path $DataCollection3) {
    Set-ItemProperty $DataCollection3  AllowTelemetry -Value 0
}


Write-Output "Disabling Location Tracking"
$SensorState = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Sensor\Overrides\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}"
$LocationConfig = "HKLM:\SYSTEM\CurrentControlSet\Services\lfsvc\Service\Configuration"
If (!(Test-Path $SensorState)) {
    New-Item $SensorState
}
Set-ItemProperty $SensorState SensorPermissionState -Value 0
If (!(Test-Path $LocationConfig)) {
    New-Item $LocationConfig
}
Set-ItemProperty $LocationConfig Status -Value 0


Write-Output "Disabling People icon on Taskbar"
$People = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People"
If (!(Test-Path $People)) {
    New-Item $People > $null
}
Set-ItemProperty $People  PeopleBand -Value 0


Write-Output "Stopping and disabling WAP Push Service"
Stop-Service "dmwappushservice"
Set-Service "dmwappushservice" -StartupType Disabled


Write-Output "Stopping and disabling Diagnostics Tracking Service"
Stop-Service "DiagTrack"
Set-Service "DiagTrack" -StartupType Disabled


Write-Output "Removing unnecessary AppxPackages"
$AppXApps = @(
    #Unnecessary Windows 10 AppX Apps
    "*Microsoft.BingNews*"
    "*Microsoft.GetHelp*"
    "*Microsoft.Getstarted*"
    "*Microsoft.Messaging*"
    "*Microsoft.MicrosoftOfficeHub*"
    "*Microsoft.MicrosoftSolitaireCollection*"
    "*Microsoft.Office.Sway*"
    "*Microsoft.OneConnect*"
    "*Microsoft.People*"
    "*Microsoft.Print3D*"
    "*microsoft.windowscommunicationsapps*"
    "*Microsoft.WindowsFeedbackHub*"
    "*Microsoft.WindowsMaps*"
    "*Microsoft.ZuneMusic*"
    "*Microsoft.ZuneVideo*"

    #Sponsored Windows 10 AppX Apps
    #Add sponsored/featured apps to remove in the "*AppName*" format
    "*EclipseManager*"
    "*ActiproSoftwareLLC*"
    "*AdobeSystemsIncorporated.AdobePhotoshopExpress*"
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
    Get-AppxPackage -Name $App | Remove-AppxPackage
    Get-AppxPackage -Name $App -AllUsers | Remove-AppxPackage -AllUsers
    Get-AppxProvisionedPackage -Online | Where-Object DisplayName -like $App | Remove-AppxProvisionedPackage -Online
}

Write-Output "Setting standby times"
powercfg /change /monitor-timeout-ac 240    # 4h
powercfg /change /standby-timeout-ac 720    # 12h
powercfg /change /monitor-timeout-dc 30     # 30m
powercfg /change /standby-timeout-dc 60     # 1h

# Ensure necessary registry paths
if (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer")) {New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Type Folder > $null}

Write-Output "Explorer: Show file extensions by default"
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "HideFileExt" 0

Write-Output "Explorer: Avoid creating Thumbs.db files on network volumes"
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" "DisableThumbnailsOnNetworkFolders" 1

Write-Output "SysTray: Hide network icon"
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" "HideSCANetwork" 1 # Network

Write-Output "Disabling automatic syncing of settings"
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Personalization" "Enabled" 0
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Credentials" "Enabled" 0
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Language" "Enabled" 0
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Accessibility" "Enabled" 0
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Windows" "Enabled" 0

Write-Output "Uninstalling Windows Media Player"
Disable-WindowsOptionalFeature -Online -FeatureName "WindowsMediaPlayer" -NoRestart -WarningAction SilentlyContinue > $null

Write-Host "Configuring Windows Update"
if (!(Test-Path "HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate")) {New-Item -Path "HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate" -Type Folder > $null}
if (!(Test-Path "HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU")) {New-Item -Path "HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU" -Type Folder > $null}
Set-ItemProperty "HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU" "NoAutoUpdate" 0
Set-ItemProperty "HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate" "NoAutoRebootWithLoggedOnUsers" 1
Set-ItemProperty "HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU" "NoAutoRebootWithLoggedOnUsers" 1
Set-ItemProperty "HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU" "AUOptions" 3
Set-ItemProperty "HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU" "IncludeRecommendedUpdates" 1
$MU = New-Object -ComObject Microsoft.Update.ServiceManager -Strict
$MU.AddService2("7971f918-a847-4430-9279-4a52d1efe18d",7,"") > $null
Remove-Variable MU

Write-Output "Disabling Look for an app in the Store (open with... menu)"
Set-ItemProperty "HKLM:\Software\Policies\Microsoft\Windows\Explorer" "NoUseStoreOpenWith" 1

Write-Output "Disabling downloaded files from being blocked"
Set-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\Attachments" "SaveZoneInformation" 1

Write-Output "Disabling Timeline"
Set-ItemProperty "HKLM:\Software\Policies\Microsoft\Windows\System" "EnableActivityFeed" 0

Write-Output "Speeding up menus (changing the menu delay to 200ms)"
Set-ItemProperty "HKCU:\Control Panel\Desktop" "MenuShowDelay" "200"

Write-Output "Removing Context Menu bloat"
$Keys = @(
    "HKLM:\SOFTWARE\Classes\SystemFileAssociations\.bmp\Shell\3D Edit"
    "HKLM:\SOFTWARE\Classes\SystemFileAssociations\.gif\Shell\3D Edit"
    "HKLM:\SOFTWARE\Classes\SystemFileAssociations\.jpg\Shell\3D Edit"
    "HKLM:\SOFTWARE\Classes\SystemFileAssociations\.jpeg\Shell\3D Edit"
    "HKLM:\SOFTWARE\Classes\SystemFileAssociations\.png\Shell\3D Edit"
    "HKLM:\SOFTWARE\Classes\SystemFileAssociations\.tif\Shell\3D Edit"
    "HKLM:\SOFTWARE\Classes\SystemFileAssociations\.tiff\Shell\3D Edit"
    "HKLM:\SOFTWARE\Classes\SystemFileAssociations\.bmp\Shell\setdesktopwallpaper"
    "HKLM:\SOFTWARE\Classes\SystemFileAssociations\.gif\Shell\setdesktopwallpaper"
    "HKLM:\SOFTWARE\Classes\SystemFileAssociations\.jpg\Shell\setdesktopwallpaper"
    "HKLM:\SOFTWARE\Classes\SystemFileAssociations\.jpeg\Shell\setdesktopwallpaper"
    "HKLM:\SOFTWARE\Classes\SystemFileAssociations\.png\Shell\setdesktopwallpaper"
    "HKLM:\SOFTWARE\Classes\SystemFileAssociations\.tif\Shell\setdesktopwallpaper"
    "HKLM:\SOFTWARE\Classes\SystemFileAssociations\.tiff\Shell\setdesktopwallpaper"
    "HKLM:\SOFTWARE\Classes\SystemFileAssociations\image\shell\edit"
    "HKCR:\z\ContextMenuHandlers\ModernSharing"                                     # Share
    "HKCR:\*\shellex\ContextMenuHandlers\{90AA3A4E-1CBA-4233-B8BB-535773D48449}"    # Pin To Taskbar
    "HKCR:\CLSID\{09A47860-11B0-4DA5-AFA5-26D86198A780}"                            # Scan with Microsoft Defender
)
ForEach ($Key in $Keys) {
    Remove-Item -LiteralPath $Key -Recurse -ErrorAction Ignore
}
Write-Output "Clearing RegKey values"
Set-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked" "{596AB062-B4D2-4215-9F74-E9109B0A8153}" "" # Restore Previous Versions
Set-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked" "{7AD84985-87B4-4a16-BE58-8B72A5B390F7}" "" # Cast to Device
Set-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked" "{8A734961-C4AA-4741-AC1E-791ACEBF5B39}" "" # Shop for music online
Set-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked" "{e2bf9676-5f8f-435c-97eb-11607a5bedf7}" "" # Share
Set-ItemProperty "HKCR:\AppX43hnxtbyyps62jhe9sqpdzxn1790zetc\Shell\ShellEdit" "ProgrammaticAccessOnly" ""                               # Edit with Photos
Set-ItemProperty "HKCR:\exefile\shellex\ContextMenuHandlers\PintoStartScreen" "{470C0EBD-5D73-4d58-9CED-E91E22E23282}" ""               # Pin To Start

Write-Output "Disabling Start Menu Suggestions"
Set-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "ContentDeliveryManager" 0
Set-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "SilentInstalledAppsEnabled" 0

# Refresh Path & Profile
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User") 
& $profile

Write-Host "Name of Computer: " -ForegroundColor Yellow -NoNewline
$computerName = Read-Host
(Get-WmiObject Win32_ComputerSystem).Rename("$computerName") > $null


Write-Host "Enable Developer Mode? (y/N): " -ForegroundColor Yellow -NoNewline
Switch (Read-Host) 
{ 
    Y {
        Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" "AllowDevelopmentWithoutDevLicense" 1
    }
}

Write-Host "Enable WSL? (y/N): " -ForegroundColor Yellow -NoNewline
Switch (Read-Host) 
{ 
    Y {
        Enable-WindowsOptionalFeature -Online -All -FeatureName "Microsoft-Windows-Subsystem-Linux" -NoRestart -WarningAction SilentlyContinue > $null
    }
}

Write-Host "Done Configuring System" -ForegroundColor Green
