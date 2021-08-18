# Self-elevate the script if required
if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
	$CommandLine = "-File `"" + $MyInvocation.MyCommand.Path + "`" " + $MyInvocation.UnboundArguments
	Start-Process -FilePath PowerShell.exe -Verb Runas -ArgumentList $CommandLine
	Exit
}

# remove VLC from Context Menu
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
Write-Output "Done removing VLC from Context Menu"

Write-Output "removing WinMerge from Context Menu & 7zip from Drag & Drop Context Menu"
New-PSDrive HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT -ErrorAction SilentlyContinue > $null
$Keys = @(
	"HKCR:\*\shellex\ContextMenuHandlers\WinMerge"
	"HKCR:\Directory\shellex\ContextMenuHandlers\WinMerge"
	"HKCR:\Directory\shellex\DragDropHandlers\WinMerge"
	"HKCR:\Directory\Background\shellex\ContextMenuHandlers\WinMerge"
	"HKCR:\Directory\Background\shellex\DragDropHandlers\WinMerge"
	"HKCR:\Drive\shellex\ContextMenuHandlers\WinMerge"
	"HKCR:\Drive\shellex\DragDropHandlers\WinMerge"
	"HKCR:\Directory\shellex\DragDropHandlers\7-Zip"
)
ForEach ($Key in $Keys) {
	Remove-Item -LiteralPath $Key -Recurse -ErrorAction SilentlyContinue
}
