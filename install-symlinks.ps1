#Requires -RunAsAdministrator

##################
# Install Symlinks
##################

Write-Host "Making Symlinks..." -ForegroundColor Green

# Windows Terminal config
New-Item -Force -ItemType SymbolicLink -Path $HOME\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState -Target $PSScriptRoot\WindowsTerminal > $null

# PowerShell
$documents = [Environment]::GetFolderPath("MyDocuments")
New-Item -Force -ItemType SymbolicLink -Path $documents\PowerShell -Target $PSScriptRoot\PowerShell > $null
New-Item -Force -ItemType SymbolicLink -Path $documents\WindowsPowerShell -Target $PSScriptRoot\PowerShell > $null

# mpv config
New-Item -Force -ItemType SymbolicLink -Path $HOME\AppData\Roaming\mpv -Target $PSScriptRoot\mpv > $null

# Visual Studio Code settings.json and keybindings.json
New-Item -Force -ItemType SymbolicLink -Path $HOME\AppData\Roaming\Code\User\settings.json -Target $PSScriptRoot\vscode\settings.json > $null
New-Item -Force -ItemType SymbolicLink -Path $HOME\AppData\Roaming\Code\User\keybindings.json -Target $PSScriptRoot\vscode\keybindings.json > $null

# .gitconfig
New-Item -Force -ItemType SymbolicLink -Path $HOME\.gitconfig -Target $PSScriptRoot\git\.gitconfig > $null

# AutoHotkey
New-Item -Force -ItemType SymbolicLink -Path "$env:appdata\Microsoft\Windows\Start Menu\Programs\Startup\myAhk.ahk" -Target $PSScriptRoot\ahk\myAhk.ahk > $null

# reload profile
& $profile

Write-Host "Done Making Symlinks" -ForegroundColor Green
