Write-Host "[1] minimal-install.ps1 - only sets up windows minimally"
Write-Host "[2] full-install.ps1 - downloads dotfiles and lets you choose what to install (symlinks/settings/apps/fonts)"
Write-Host "Select Installation [1/2/q]): " -ForegroundColor Yellow -NoNewline

$key = $Host.UI.RawUI.ReadKey().Character
while($key -ne 1 -Or key -ne 2 -Or key -ne Q) {
}
	$key = $Host.UI.RawUI.ReadKey().Character
}

Switch ($key) {
	1 {
		. $PSScriptRoot\minimal-install.ps1
	}
	2 {
		. $PSScriptRoot\full-install.ps1
	}
	Q {}
}

Write-Host "Done!"
