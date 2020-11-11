#Requires -RunAsAdministrator

Set-ExecutionPolicy RemoteSigned

Write-Host "Install settings? (y/N): " -ForegroundColor Yellow -NoNewline
Switch (Read-Host) 
{ 
    Y {Invoke-Expression -Command "$PSScriptRoot\install-settings.ps1"}
}

Write-Host "Install symlinks? (y/N): " -ForegroundColor Yellow -NoNewline
Switch (Read-Host) 
{ 
    Y {Invoke-Expression -Command "$PSScriptRoot\install-symlinks.ps1"}
}

Write-Host "Install apps? (y/N): " -ForegroundColor Yellow -NoNewline
Switch (Read-Host) 
{ 
    Y {Invoke-Expression -Command "$PSScriptRoot\install-apps.ps1"}
}

Write-Host "Install fonts? (y/N): " -ForegroundColor Yellow -NoNewline
Switch (Read-Host) 
{ 
    Y {Invoke-Expression -Command "$PSScriptRoot\install-fonts.ps1"}
}

Write-Host "Done! Note that some changes require a restart to take effect." -ForegroundColor Green
