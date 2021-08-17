#Requires -RunAsAdministrator
$DOT = "$HOME\.dotfiles"

Write-Host "Making Symlinks..." -ForegroundColor Green

# Windows Terminal config
New-Item -Force -ItemType SymbolicLink -Path $HOME\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState -Target $PSScriptRoot\WindowsTerminal

# PowerShell
$documents = [Environment]::GetFolderPath("MyDocuments")
New-Item -Force -ItemType SymbolicLink -Path $documents\PowerShell -Target $PSScriptRoot\PowerShell
New-Item -Force -ItemType SymbolicLink -Path $documents\WindowsPowerShell -Target $PSScriptRoot\PowerShell

# mpv config
New-Item -Force -ItemType SymbolicLink -Path $HOME\AppData\Roaming\mpv -Target $PSScriptRoot\mpv

# Notepad2
New-Item -Force -ItemType SymbolicLink -Path $HOME\AppData\Roaming\Notepad2 -Target $PSScriptRoot\Notepad2

# MediaInfo.NET
New-Item -Force -ItemType SymbolicLink -Path $HOME\AppData\Roaming\MediaInfo.NET -Target $PSScriptRoot\MediaInfo.NET

# Visual Studio Code settings.json and keybindings.json
New-Item -Force -ItemType SymbolicLink -Path $HOME\AppData\Roaming\Code\User\settings.json -Target $PSScriptRoot\vscode\settings.json
New-Item -Force -ItemType SymbolicLink -Path $HOME\AppData\Roaming\Code\User\keybindings.json -Target $PSScriptRoot\vscode\keybindings.json

# .gitconfig
New-Item -Force -ItemType SymbolicLink -Path $HOME\.gitconfig -Target $PSScriptRoot\git\.gitconfig

# AutoHotkey
New-Item -Force -ItemType SymbolicLink -Path "$env:appdata\Microsoft\Windows\Start Menu\Programs\Startup\myAhk.ahk" -Target $PSScriptRoot\ahk\myAhk.ahk

# reload profile
. $profile

Write-Host "Done Making Symlinks" -ForegroundColor Green
