#Requires -RunAsAdministrator
$DOT = "$HOME\.dotfiles"

Write-Host "Making Symlinks..." -ForegroundColor Green

function Make-Symlink {
	[CmdletBinding()]
	param(
		[Parameter(Mandatory)]
		[string] $Path,

		[Parameter(Mandatory)]
		[string] $Target
	)
	if(Test-Path $Path)
	{
		Write-Host "$Path already exists overwrite? [Y/n]: " -ForegroundColor Yellow -NoNewline
		$host.UI.RawUI.FlushInputBuffer()
		$key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
		while(-Not($key.Character -eq "Y" -Or $key.Character -eq "N" -Or $key.VirtualKeyCode -eq 13)) {
			$key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
		}
		Write-Host $key.Character
		Switch ($key.Character) {
			Default {
				try {
					Remove-Item -Force -Recurse -Path $Path
				} catch {
					Write-Host "Error deleting, this is probably because there is already a symlink here and there's a bug in PowerShell"
					Write-Host "Deleting it another way"
					(Get-Item $Path).Delete()
				}

				New-Item -Force -ItemType SymbolicLink -Path $Path -Target $Target > $null
			}
			N {}
		}
	} else {
		New-Item -Force -ItemType SymbolicLink -Path $Path -Target $Target > $null
	}
}


# Windows Terminal
Make-Symlink -Path "$HOME\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState" -Target "$DOT\windows\WindowsTerminal"

# PowerShell
$documents = [Environment]::GetFolderPath("MyDocuments")
Make-Symlink -Path $documents\PowerShell -Target $DOT\windows\PowerShell
Make-Symlink -Path $documents\WindowsPowerShell -Target $DOT\windows\PowerShell

# mpv
Make-Symlink -Path $HOME\AppData\Roaming\mpv -Target $DOT\mpv\mpv

# Notepad2
Make-Symlink -Path $HOME\AppData\Roaming\Notepad2 -Target $DOT\windows\Notepad2

# MediaInfo.NET
Make-Symlink -Path $HOME\AppData\Roaming\MediaInfo.NET -Target $DOT\windows\MediaInfo.NET

# .gitconfig
Make-Symlink -Path $HOME\.gitconfig -Target $DOT\git\.gitconfig

# AutoHotkey
Make-Symlink -Path "$env:appdata\Microsoft\Windows\Start Menu\Programs\Startup\myAhk.ahk" -Target $DOT\windows\ahk\myAhk.ahk

# AltDrag
Make-Symlink -Path $HOME\AppData\Roaming\AltDrag\AltDrag.ini -Target $DOT\windows\AltDrag\AltDrag.ini

# reload profile
. $profile

Write-Host "Done Making Symlinks" -ForegroundColor Green
