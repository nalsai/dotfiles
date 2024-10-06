${function:~} = { Set-Location ~ }
${function:Set-ParentLocation} = { Set-Location .. };
Set-Alias ".."			Set-ParentLocation
Set-Alias "../"			Set-ParentLocation
Set-Alias "../.."		Set-ParentLocation ; Set-ParentLocation
Set-Alias "../../"		Set-ParentLocation ; Set-ParentLocation
Set-Alias "../../.." 	Set-ParentLocation ; Set-ParentLocation ; Set-ParentLocation
Set-Alias "../../../" 	Set-ParentLocation ; Set-ParentLocation ; Set-ParentLocation

Set-Alias time Measure-Command

if (Get-Command bat -ErrorAction SilentlyContinue | Test-Path) {
	${function:cat} = { bat @args }
}
if (Get-Command curl.exe -ErrorAction SilentlyContinue | Test-Path) {
	Remove-Item Alias:curl -ErrorAction SilentlyContinue
	${function:curl} = { curl.exe @args }
}
if (Get-Command wget.exe -ErrorAction SilentlyContinue | Test-Path) {
	Remove-Item Alias:wget -ErrorAction SilentlyContinue
	${function:wget} = { wget.exe @args }
}
elseif (Get-Command wget2.exe -ErrorAction SilentlyContinue | Test-Path) {
	Remove-Item Alias:wget -ErrorAction SilentlyContinue
	${function:wget} = { wget2.exe @args }
}
if (Get-Command eza -ErrorAction SilentlyContinue | Test-Path) {
	Remove-Item Alias:ls -ErrorAction SilentlyContinue
	${function:ls} = { eza @args }
	${function:ll} = { eza -l @args }
	${function:la} = { eza -la @args }
}
elseif (Get-Command ls.exe -ErrorAction SilentlyContinue | Test-Path) {
	Remove-Item Alias:ls -ErrorAction SilentlyContinue
	${function:ls} = { ls.exe --color @args }
	${function:ll} = { ls -lF @args }
	${function:la} = { ls -laF @args }
}
else {
	${function:la} = { ls -Force @args }
}

function which($name) {
	Get-Command $name -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Definition
}

$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
	Import-Module "$ChocolateyProfile"
}

if (Get-Command git -ErrorAction SilentlyContinue | Test-Path) {
	${function:gst} = { git status @args }
	${function:ga} = { git add @args }
	${function:gc} = { git commit -v @args }
	${function:gcl} = { git clone @args }
	#${function:gl} = { git pull @args } # Already permanently Aliased to Get-Location
	#${function:gp} = { git push @args } # Already permanently Aliased to Get-ItemProperty
}

Set-Alias c Clear-Host
Set-Alias ^D exit	# exit with Ctrl+D
function e { exit }

function c { Clear-Host }

function u {
	$DOT = "$HOME\.dotfiles"

	if (Test-Path "$DOT/.git") {
		Write-Host "Updating dotfiles with git"
		git -C $DOT pull origin main
	}
	elseif (Test-Path "$DOT") {
		Write-Host "Updating dotfiles"
		$TMP = "$env:TEMP\ZG90ZmlsZXM"
		wget -O $TMP\dotfiles.zip "https://github.com/nalsai/dotfiles/archive/refs/heads/main.zip"
		if ($?) {
			Expand-Archive $TMP\dotfiles.zip $TMP
			Remove-Item $DOT -Recurse -Force -ErrorAction SilentlyContinue  # delete old dotfiles
			Move-Item $TMP\dotfiles-main $DOT
		}
		else { Write-Host "Error downloading dotfiles" }
		Remove-Item $TMP -Recurse -Force -ErrorAction SilentlyContinue  # clean up temp files
	}

	if (Get-Command choco -ErrorAction SilentlyContinue | Test-Path) {
		choco upgrade all -y
	}

	if (Get-Command winget -ErrorAction SilentlyContinue | Test-Path) {
		winget upgrade --all
	}
}
