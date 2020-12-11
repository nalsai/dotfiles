#Requires -RunAsAdministrator

Write-Host "Installing Fonts..." -ForegroundColor Green

$fontsPath = "$HOME\Downloads\Fonts"

New-Item -ItemType directory -Force -Path $fontsPath -ErrorAction SilentlyContinue > $null

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
	wget.exe -O $fontsPath\$font.zip "https://fonts.google.com/download?family=$font"
}

wget.exe -O "$fontsPath\Fira Code.zip" ((Invoke-RestMethod -Method GET -Uri "https://api.github.com/repos/tonsky/FiraCode/releases/latest").assets | Where-Object name -like Fira*.zip ).browser_download_url
wget.exe -O "$fontsPath\Cascadia Code.zip" ((Invoke-RestMethod -Method GET -Uri "https://api.github.com/repos/microsoft/cascadia-code/releases/latest").assets | Where-Object name -like Cascadia*.zip ).browser_download_url
wget.exe -O "$fontsPath\Gandhi Sans.zip" https://www.fontsquirrel.com/fonts/download/gandhi-sans

Expand-Archive -Path "$fontsPath\Fira Code.zip" -DestinationPath $fontsPath -Force
Copy-Item -r  $fontsPath\variable_ttf\* $fontsPath -ErrorAction SilentlyContinue
Remove-Item "$fontsPath\ttf" -Recurse -Force
Remove-Item "$fontsPath\Fira Code.zip" -Force

foreach ($font in $fonts) {
	Expand-Archive -Path $fontsPath\$font.zip -DestinationPath $fontsPath -Force
	Remove-Item $fontsPath\$font.zip -Force
}

Expand-Archive -Path "$fontsPath\Cascadia Code.zip" -DestinationPath $fontsPath -Force
Expand-Archive -Path "$fontsPath\Gandhi Sans.zip" -DestinationPath $fontsPath -Force
Remove-Item "$fontsPath\Cascadia Code.zip" -Force
Remove-Item "$fontsPath\Gandhi Sans.zip" -Force
Remove-Item "$fontsPath\ttf\static\" -Recurse -Force
Copy-Item -r  $fontsPath\ttf\* $fontsPath -ErrorAction SilentlyContinue
Remove-Item "$fontsPath\otf" -Recurse -Force
Remove-Item "$fontsPath\static" -Recurse -Force
Remove-Item "$fontsPath\ttf" -Recurse -Force
Remove-Item "$fontsPath\woff2" -Recurse -Force
Remove-Item "$fontsPath\*.txt" -Force

foreach ($File in $(Get-ChildItem -Path $fontsPath -Include ('*.otf', '*.ttf') -Recurse)) {
	if (!(Test-Path "C:\Windows\Fonts\$($File.Name)")) {
		Copy-Item $File.FullName C:\Windows\Fonts\$($File.Name)
		New-ItemProperty -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Fonts" -Name $File.Name -PropertyType string -Value $File.Name
	}
}

Remove-Item $fontsPath -Recurse -Force -ErrorAction SilentlyContinue

Write-Host "Done Installing Fonts" -ForegroundColor Green
