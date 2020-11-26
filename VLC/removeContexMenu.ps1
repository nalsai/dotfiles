#Requires -RunAsAdministrator

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