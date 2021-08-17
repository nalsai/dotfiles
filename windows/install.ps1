Clear-Host
Write-Host " _   _ _ _     ____        _    __ _ _`n| \ | (_| |___|  _ \  ___ | |_ / _(_| | ___ ___`n|  \| | | / __| | | |/ _ \| __| |_| | |/ _ / __|`n| |\  | | \__ | |_| | (_) | |_|  _| | |  __\__ \`n|_| \_|_|_|___|____/ \___/ \__|_| |_|_|\___|___/`n`n"
Write-Host "[1] minimal install - only sets up windows, some apps and fonts"
Write-Host "[2] full install - sets up more stuff, downloads dotfiles and installs them" # (symlinks/settings/apps/fonts)
Write-Host "Select Installation [1/2/q]): " -ForegroundColor Yellow -NoNewline

$key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown").Character
while(-Not($key -eq "1" -Or $key -eq "2" -Or $key -eq "Q")) {
	$key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown").Character
}
Write-Host "$key";

$TMP = "$env:TEMP\ZG90ZmlsZXM"
New-Item -ItemType directory -Force -Path $TMP -ErrorAction SilentlyContinue > $null

Switch ($key) {
	1 {
		iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Nalsai/dotfiles/master/windows/minimal-install.ps1'))
	}
	2 {
		Write-Host "Downloading dotfiles"
		iwr "https://git.nalsai.de/dotfiles/archive/master.zip" -O $TMP\dotfiles.zip
		$DOT = "$HOME\.dotfiles"
		#if(-Not $?){throw "Error Downloading"}	# TODO test if needed
		Expand-Archive $TMP\dotfiles.zip $TMP$TMP
		rm $DOT -r -ErrorAction Ignore	# delete old dotfiles
		mv $TMP\dotfiles-master $DOT

		Set-ExecutionPolicy RemoteSigned

		Write-Host "Installing dotfiles"
		. $DOT\windows\full-install.ps1
	}
	Q {}
}

Remove-Item $TMP -Recurse -Force -ErrorAction SilentlyContinue

Write-Host "Done!"
