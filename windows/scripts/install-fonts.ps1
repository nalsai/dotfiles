#Requires -RunAsAdministrator
$TMP = "$env:TEMP\ZG90ZmlsZXM"
New-Item -ItemType directory -Force -Path "$TMP\Fonts" -ErrorAction SilentlyContinue > $null

Write-Host "Installing Fonts..." -ForegroundColor Green

$fonts =
'Alice',
'Lato',
'Montserrat',
'Quicksand',
'Merriweather',
'Comfortaa',
'Roboto',
'Noto Sans',
'Noto Serif',
'Source Code Pro',
'Sawarabi Gothic',
'Sawarabi Mincho',
'Noto Sans JP',
'Noto Serif JP'

foreach ($font in $fonts) {
	wget.exe -O $TMP\Fonts\$font.zip "https://fonts.google.com/download?family=$font"
	Expand-Archive -Path $TMP\Fonts\$font.zip -DestinationPath $TMP\Fonts -Force
}
Remove-Item "$TMP\Fonts\static\" -Recurse -Force

wget.exe -O "$TMP\Fonts\Gandhi Sans.zip" https://www.fontsquirrel.com/fonts/download/gandhi-sans
Expand-Archive -Path "$TMP\Fonts\Gandhi Sans.zip" -DestinationPath $TMP\Fonts -Force

wget.exe -O "$TMP\Fonts\Fira Code.zip" ((Invoke-RestMethod -Method GET -Uri "https://api.github.com/repos/tonsky/FiraCode/releases/latest").assets | Where-Object name -like Fira*.zip ).browser_download_url
Expand-Archive -Path "$TMP\Fonts\Fira Code.zip" -DestinationPath "$TMP\Fonts\Fira Code" -Force
Copy-Item -r "$TMP\Fonts\Fira Code\variable_ttf\*" $TMP\Fonts -ErrorAction SilentlyContinue
Remove-Item "$TMP\Fonts\Fira Code" -Recurse -Force

wget.exe -O "$TMP\Fonts\Cascadia Code.zip" ((Invoke-RestMethod -Method GET -Uri "https://api.github.com/repos/microsoft/cascadia-code/releases/latest").assets | Where-Object name -like Cascadia*.zip ).browser_download_url
Expand-Archive -Path "$TMP\Fonts\Cascadia Code.zip" -DestinationPath "$TMP\Fonts\Cascadia Code" -Force
Remove-Item "$TMP\Fonts\Cascadia Code\ttf\static" -Recurse -Force
Copy-Item -r  "$TMP\Fonts\Cascadia Code\ttf\*" $TMP\Fonts -ErrorAction SilentlyContinue
Remove-Item "$TMP\Fonts\Cascadia Code" -Recurse -Force

foreach ($File in $(Get-ChildItem -Path $TMP\Fonts -Include ('*.otf', '*.ttf') -Recurse)) {
	if (!(Test-Path "C:\Windows\Fonts\$($File.Name)")) {
		Copy-Item $File.FullName C:\Windows\Fonts\$($File.Name)
		New-ItemProperty -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Fonts" -Name $File.Name -PropertyType string -Value $File.Name > $null
	}
}

Write-Host "Done Installing Fonts" -ForegroundColor Green
