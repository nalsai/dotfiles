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

foreach($font in $fonts)
{
    Expand-Archive -Path $fontsPath\$font.zip -DestinationPath $fontsPath -Force
    Remove-Item $fontsPath\$font.zip -Force
}
Remove-Item "$fontsPath\static\" -Recurse -Force

Expand-Archive -Path "$fontsPath\Cascadia Code.zip" -DestinationPath $fontsPath -Force
Remove-Item "$fontsPath\ttf\static\" -Recurse -Force
Copy-Item -r  $fontsPath\ttf\* $fontsPath -ErrorAction Ignore
Remove-Item "$fontsPath\Cascadia Code.zip" -Force
Remove-Item "$fontsPath\otf\" -Recurse -Force
Remove-Item "$fontsPath\woff2\" -Recurse -Force
Remove-Item "$fontsPath\ttf\" -Recurse -Force

# install font files
foreach($file in $(Get-ChildItem -Path $fontsPath -Include ('*.otf','*.ttf') -Recurse)){
    If (!(Test-Path "c:\windows\fonts\$($File.name)"))
    {
        $(New-Object -ComObject Shell.Application).Namespace(0x14).CopyHere($file.fullname,  4 + 16);
        New-ItemProperty -Name $file.fullname -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Fonts" -PropertyType string -Value $file 
    }
}

Start-Sleep 3

Remove-Item $fontsPath -Recurse -Force -ErrorAction SilentlyContinue

Write-Host "Done Installing Fonts" -ForegroundColor Green
Write-Host "The folder $HOME\Downloads\Fonts may still be left and can be deleted." -ForegroundColor Cyan
