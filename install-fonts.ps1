#Requires -RunAsAdministrator

###############
# Install Fonts
###############

Write-Host "Installing Fonts..." -ForegroundColor Green

$fontsPath = "$HOME\Fonts"

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

foreach($font in $fonts)
{
    Expand-Archive -Path $fontsPath\$font.zip -DestinationPath $fontsPath -Force
    Remove-Item $fontsPath\$font.zip -Force
}
Remove-Item "$fontsPath\static\" -Recurse -Force

Expand-Archive -Path "$fontsPath\Cascadia Code.zip" -DestinationPath $fontsPath -Force
Remove-Item "$fontsPath\otf\" -Recurse -Force
Remove-Item "$fontsPath\woff2\" -Recurse -Force
Remove-Item "$fontsPath\ttf\static\" -Recurse -Force
Remove-Item "$fontsPath\Cascadia Code.zip" -Force

# install font files
foreach($file in $(Get-ChildItem -Path $fontsPath -Include ('*.otf','*.ttf') -Recurse)){
    If (-Not (Test-Path "c:\windows\fonts\$($File.name)"))
    {
        $(New-Object -ComObject Shell.Application).Namespace(0x14).CopyHere($file.fullname,  4 + 16);
        New-ItemProperty -Name $file.fullname -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Fonts" -PropertyType string -Value $file 
    }
}

Remove-Item $fontsPath -Recurse -Force

Write-Host "Done Installing Fonts" -ForegroundColor Green
