#Requires -RunAsAdministrator

Clear-Host
Write-Host " _   _ _ _     ____        _    __ _ _`n| \ | (_| |___|  _ \  ___ | |_ / _(_| | ___ ___`n|  \| | | / __| | | |/ _ \| __| |_| | |/ _ / __|`n| |\  | | \__ | |_| | (_) | |_|  _| | |  __\__ \`n|_| \_|_|_|___|____/ \___/ \__|_| |_|_|\___|___/"
Write-Host "[declutter-contextmenu.ps1]`n"

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

Write-Host "Removing WinMerge from Context Menu"
$Keys = @(
	"HKCR:\*\shellex\ContextMenuHandlers\WinMerge"
	"HKCR:\Directory\shellex\ContextMenuHandlers\WinMerge"
	"HKCR:\Directory\shellex\DragDropHandlers\WinMerge"
	"HKCR:\Directory\Background\shellex\ContextMenuHandlers\WinMerge"
	"HKCR:\Directory\Background\shellex\DragDropHandlers\WinMerge"
	"HKCR:\Drive\shellex\ContextMenuHandlers\WinMerge"
	"HKCR:\Drive\shellex\DragDropHandlers\WinMerge"
)
ForEach ($Key in $Keys) {
	Remove-Item -LiteralPath $Key -Recurse -ErrorAction Ignore
}

Write-Host "Removing 7zip from Drag & Drop Context Menu"
Remove-Item -LiteralPath "HKCR:\Directory\shellex\DragDropHandlers\7-Zip" -Recurse -ErrorAction Ignore

Write-Host "Done!" -ForegroundColor Green
$Host.UI.ReadLine()
[Environment]::Exit(0)