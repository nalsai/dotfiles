#Requires -RunAsAdministrator

Set-ExecutionPolicy RemoteSigned

Invoke-Expression -Command "$PSScriptRoot\install-symlinks.ps1"
Invoke-Expression -Command "$PSScriptRoot\install-apps.ps1"
Invoke-Expression -Command "$PSScriptRoot\install-fonts.ps1"
Invoke-Expression -Command "$PSScriptRoot\install-settings.ps1"

Write-Host "Done! Note that some changes require a restart to take effect." -ForegroundColor Green
