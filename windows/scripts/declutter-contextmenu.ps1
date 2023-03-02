# Self-elevate the script if required
if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
	$CommandLine = "-NoExit -File `"" + $MyInvocation.MyCommand.Path + "`" " + $MyInvocation.UnboundArguments
	Start-Process -FilePath PowerShell.exe -Verb Runas -ArgumentList $CommandLine
	Exit
}

if (-Not ($args[0] -eq "script")){
	Clear-Host
	Write-Host " _   _ _ _     ____        _    __ _ _`n| \ | (_| |___|  _ \  ___ | |_ / _(_| | ___ ___`n|  \| | | / __| | | |/ _ \| __| |_| | |/ _ / __|`n| |\  | | \__ | |_| | (_) | |_|  _| | |  __\__ \`n|_| \_|_|_|___|____/ \___/ \__|_| |_|_|\___|___/"
	Write-Host "[declutter-contextmenu.ps1]`n"
}

New-PSDrive HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT -ErrorAction SilentlyContinue > $null

Write-Host "Removing VLC from Context Menu"
$Keys = @(
	"HKCR:\Directory\shell\AddToPlaylistVLC\"
	"HKCR:\Directory\shell\PlayWithVLC\"
	"HKCR:\VLC.*\shell\AddToPlaylistVLC\"
	"HKCR:\VLC.*\shell\PlayWithVLC\"
)
ForEach ($Key in $Keys) {
	Remove-Item $Key -Recurse -ErrorAction Ignore
}

Write-Host "Done!" -ForegroundColor Green
if (-Not ($args[0] -eq "script")){
	$Host.UI.ReadLine()
	[Environment]::Exit(0)
}