# Self-elevate the script if required
if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
	$CommandLine = "-NoExit -File `"" + $MyInvocation.MyCommand.Path + "`" " + $MyInvocation.UnboundArguments
	Start-Process -FilePath PowerShell.exe -Verb Runas -ArgumentList $CommandLine
	Exit
}

Clear-Host
Write-Host " _   _ _ _     ____        _    __ _ _`n| \ | (_| |___|  _ \  ___ | |_ / _(_| | ___ ___`n|  \| | | / __| | | |/ _ \| __| |_| | |/ _ / __|`n| |\  | | \__ | |_| | (_) | |_|  _| | |  __\__ \`n|_| \_|_|_|___|____/ \___/ \__|_| |_|_|\___|___/"
Write-Host "`n"

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

Remove-Item $TMP -Recurse -Force -ErrorAction SilentlyContinue
Read-Host "Done! Note that some changes may require a restart to take effect." -ForegroundColor Green
Exit