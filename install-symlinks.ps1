#Requires -RunAsAdministrator

##################
# Install Symlinks
##################

Write-Host "Making Symlinks..." -ForegroundColor Green

# Windows Terminal config
New-Item -Force -ItemType SymbolicLink $HOME\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\ -LocalState settings.json -Value $PSScriptRoot\WindowsTerminal

# PowerShell
$documents = [Environment]::GetFolderPath("MyDocuments")
New-Item -Force -ItemType SymbolicLink $documents\PowerShell -LocalState Microsoft.PowerShell_profile.ps1 -Value $PSScriptRoot\PowerShell
New-Item -Force -ItemType SymbolicLink $documents\WindowsPowerShell -LocalState Microsoft.PowerShell_profile.ps1 -Value $PSScriptRoot\PowerShell

# mpv config
New-Item -Force -ItemType SymbolicLink $HOME\AppData\Roaming\ -Name mpv -Value $PSScriptRoot\mpv

# Visual Studio Code settings.json and keybindings.json
New-Item -Force -ItemType SymbolicLink $HOME\AppData\Roaming\Code\User\ -Name settings.json -Value $PSScriptRoot\vscode\settings.json
New-Item -Force -ItemType SymbolicLink $HOME\AppData\Roaming\Code\User\ -Name keybindings.json -Value $PSScriptRoot\vscode\keybindings.json

# .gitconfig
New-Item -Force -ItemType SymbolicLink $HOME\ -Name .gitconfig -Value $PSScriptRoot\git\.gitconfig

# AutoHotkey
New-Item -Force -ItemType SymbolicLink $env:appdata\Microsoft\Windows\Start Menu\Programs\Startup\ -Name myAhk.ahk -Value $PSScriptRoot\ahk\myAhk.ahk

Write-Host "Done Making Symlinks" -ForegroundColor Green
