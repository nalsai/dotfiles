# Self-elevate the script if required
if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
	$CommandLine = "-File `"" + $MyInvocation.MyCommand.Path + "`" " + $MyInvocation.UnboundArguments
	Start-Process -FilePath PowerShell.exe -Verb Runas -ArgumentList $CommandLine
	Exit
}


Write-Host "Install symlinks? (Y/n): " -ForegroundColor Yellow -NoNewline
Switch (Read-Host) {
	Default { . $PSScriptRoot\install-symlinks.ps1 }
	N {}
}

Write-Host "Install settings? (Y/n): " -ForegroundColor Yellow -NoNewline
Switch (Read-Host) {
	Default { . $PSScriptRoot\install-settings.ps1 }
	N {}
}

Write-Host "Install apps? (Y/n): " -ForegroundColor Yellow -NoNewline
Switch (Read-Host) {
	Default { . $PSScriptRoot\install-apps.ps1 }
	N {}
}

Write-Host "Install fonts? (Y/n): " -ForegroundColor Yellow -NoNewline
Switch (Read-Host) {
	Default { . $PSScriptRoot\install-fonts.ps1 }
	N {}
}

Write-Host "Done! Note that some changes require a restart to take effect." -ForegroundColor Green
