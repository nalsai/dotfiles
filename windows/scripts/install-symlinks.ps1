#Requires -RunAsAdministrator
$DOT = "$HOME\.dotfiles"

Write-Host "Making Symlinks..." -ForegroundColor Green

# Windows Terminal config
Remove-Item -Force -Recurse $HOME\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState -ErrorAction Ignore
New-Item -Force -ItemType SymbolicLink -Path $HOME\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState -Target $DOT\windows\WindowsTerminal > $null

# PowerShell
$documents = [Environment]::GetFolderPath("MyDocuments")
New-Item -Force -ItemType SymbolicLink -Path $documents\PowerShell -Target $DOT\windows\PowerShell > $null
New-Item -Force -ItemType SymbolicLink -Path $documents\WindowsPowerShell -Target $DOT\windows\PowerShell > $null

# mpv config
New-Item -Force -ItemType SymbolicLink -Path $HOME\AppData\Roaming\mpv -Target $DOT\mpv > $null

# Notepad2
New-Item -Force -ItemType SymbolicLink -Path $HOME\AppData\Roaming\Notepad2 -Target $DOT\windows\Notepad2 > $null

# MediaInfo.NET
New-Item -Force -ItemType SymbolicLink -Path $HOME\AppData\Roaming\MediaInfo.NET -Target $DOT\windows\MediaInfo.NET > $null

# Visual Studio Code settings.json and keybindings.json
New-Item -Force -ItemType SymbolicLink -Path $HOME\AppData\Roaming\Code\User\settings.json -Target $DOT\vscode\settings.json > $null
New-Item -Force -ItemType SymbolicLink -Path $HOME\AppData\Roaming\Code\User\keybindings.json -Target $DOT\vscode\keybindings.json > $null

# .gitconfig
New-Item -Force -ItemType SymbolicLink -Path $HOME\.gitconfig -Target $DOT\git\.gitconfig > $null

# AutoHotkey
New-Item -Force -ItemType SymbolicLink -Path "$env:appdata\Microsoft\Windows\Start Menu\Programs\Startup\myAhk.ahk" -Target $DOT\windows\ahk\myAhk.ahk > $null

# reload profile
. $profile

Write-Host "Done Making Symlinks" -ForegroundColor Green
