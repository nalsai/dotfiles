# Self-elevate the script if required
if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
	$CommandLine = "-File `"" + $MyInvocation.MyCommand.Path + "`" " + $MyInvocation.UnboundArguments
	Start-Process -FilePath PowerShell.exe -Verb Runas -ArgumentList $CommandLine
	Exit
}

Write-Host "Install app settings? [Y/n]: " -ForegroundColor Yellow -NoNewline
$key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown").Character
while(-Not($key -eq "Y" -Or $key -eq "N" -Or $key -eq "Q")) {
	$key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown").Character
}
Write-Host "$key";
Switch ($key) {
	Y {
		. $PSScriptRoot\install-symlinks.ps1
	}
	N {}
	Q {}
}

Write-Host "Install Windows settings? [Y/n]: " -ForegroundColor Yellow -NoNewline
$key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown").Character
while(-Not($key -eq "Y" -Or $key -eq "N" -Or $key -eq "Q")) {
	$key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown").Character
}
Write-Host "$key";
Switch ($key) {
	Y {
		. $PSScriptRoot\install-settings.ps1
	}
	N {}
	Q {}
}

Write-Host "Install apps? [Y/n]: " -ForegroundColor Yellow -NoNewline
$key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown").Character
while(-Not($key -eq "Y" -Or $key -eq "N" -Or $key -eq "Q")) {
	$key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown").Character
}
Write-Host "$key";
Switch ($key) {
	Y {
		. $PSScriptRoot\install-apps.ps1
	}
	N {}
	Q {}
}

Write-Host "Install fonts? [Y/n]: " -ForegroundColor Yellow -NoNewline
$key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown").Character
while(-Not($key -eq "Y" -Or $key -eq "N" -Or $key -eq "Q")) {
	$key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown").Character
}
Write-Host "$key";
Switch ($key) {
	Y {
		. $PSScriptRoot\install-fonts.ps1
	}
	N {}
	Q {}
}

Write-Host "Done! Note that some changes may require a restart to take effect." -ForegroundColor Green
