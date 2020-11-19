#Requires -RunAsAdministrator

Write-Host "Installing Fonts..." -ForegroundColor Green

$fontsPath = "$HOME\Downloads\Fonts"

New-Item -ItemType directory -Force -Path $fontsPath -ErrorAction SilentlyContinue > $null

$fonts =
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

foreach($font in $fonts)
{
    wget -O $fontsPath\$font.zip "https://fonts.google.com/download?family=$font"
}
wget -O "$fontsPath\Cascadia Code.zip" ((Invoke-RestMethod -Method GET -Uri "https://api.github.com/repos/microsoft/cascadia-code/releases/latest").assets | Where-Object name -like CascadiaCode-*.zip ).browser_download_url
wget -O "$fontsPath\Gandhi Sans.zip" https://www.fontsquirrel.com/fonts/download/gandhi-sans

foreach($font in $fonts)
{
    Expand-Archive -Path $fontsPath\$font.zip -DestinationPath $fontsPath -Force
    Remove-Item $fontsPath\$font.zip -Force
}
Remove-Item "$fontsPath\static\" -Recurse -Force
Expand-Archive -Path "$fontsPath\Cascadia Code.zip" -DestinationPath $fontsPath -Force
Expand-Archive -Path "$fontsPath\Gandhi Sans.zip" -DestinationPath $fontsPath -Force
Remove-Item "$fontsPath\ttf\static\" -Recurse -Force
Copy-Item -r  $fontsPath\ttf\* $fontsPath -ErrorAction Ignore
Remove-Item "$fontsPath\Cascadia Code.zip" -Force
Remove-Item "$fontsPath\otf\" -Recurse -Force
Remove-Item "$fontsPath\woff2\" -Recurse -Force
Remove-Item "$fontsPath\ttf\" -Recurse -Force

foreach($File in $(Get-ChildItem -Path $fontsPath -Include ('*.otf','*.ttf') -Recurse)){
    If (!(Test-Path "C:\Windows\Fonts\$($File.Name)"))
    {
        Copy-Item $File.FullName C:\Windows\Fonts\$($File.Name)
        New-ItemProperty -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Fonts" -Name $File.Name -PropertyType string -Value $File.Name
    }
}

Remove-Item $fontsPath -Recurse -Force -ErrorAction SilentlyContinue

Write-Host "Done Installing Fonts" -ForegroundColor Green
