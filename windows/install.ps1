Clear-Host
Write-Host " _   _ _ _     ____        _    __ _ _`n| \ | (_| |___|  _ \  ___ | |_ / _(_| | ___ ___`n|  \| | | / __| | | |/ _ \| __| |_| | |/ _ / __|`n| |\  | | \__ | |_| | (_) | |_|  _| | |  __\__ \`n|_| \_|_|_|___|____/ \___/ \__|_| |_|_|\___|___/"
Write-Host "`n"
Write-Host "[1] minimal install - only sets up windows, some apps and fonts"
Write-Host "[2] full install - sets up more stuff, downloads dotfiles and installs them"
Write-Host "[3] declutter context menu apps"
Write-Host "Select Installation [1/2/3/q]): " -ForegroundColor Yellow -NoNewline

$key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown").Character
while(-Not($key -eq "1" -Or $key -eq "2" -Or $key -eq "3" -Or $key -eq "Q")) {
	$key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown").Character
}
Write-Host "$key";

$TMP = "$env:TEMP\ZG90ZmlsZXM"
New-Item -ItemType directory -Force -Path $TMP -ErrorAction SilentlyContinue > $null

Switch ($key) {
	1 {
		Write-Host "Executing minimal-install.ps1"
		Start-Process -FilePath PowerShell.exe -Verb Runas -ArgumentList "-NoExit `"Set-ExecutionPolicy RemoteSigned -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Nalsai/dotfiles/main/windows/scripts/minimal-install.ps1'))`""
	}
	2 {
		Write-Host "Downloading dotfiles"
		iwr "https://github.com/Nalsai/dotfiles/archive/refs/heads/main.zip" -O $TMP\dotfiles.zip
		if(-Not $?){throw "Error downloading dotfiles"}
		$DOT = "$HOME\.dotfiles"
		Expand-Archive $TMP\dotfiles.zip $TMP
		Remove-Item $DOT -Recurse -Force -ErrorAction SilentlyContinue # delete old dotfiles
		Move-Item $TMP\dotfiles-main $DOT
		Write-Host "Installing dotfiles"

		Start-Process -FilePath PowerShell.exe -Verb Runas -ArgumentList "-NoExit `"Set-ExecutionPolicy RemoteSigned -Force; $DOT\windows\scripts\full-install.ps1`""
	}
	3 {
		Write-Host "Executing declutter-contextmenu.ps1"
		Start-Process -FilePath PowerShell.exe -Verb Runas -ArgumentList "-NoExit `"Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Nalsai/dotfiles/main/windows/scripts/declutter-contextmenu.ps1'))`""
	}
	Q {}
}

Write-Host "Done!"
[Environment]::Exit(0)