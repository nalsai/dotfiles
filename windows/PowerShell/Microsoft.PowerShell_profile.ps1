
${function:~} = { Set-Location ~ }

${function:Set-ParentLocation} = { Set-Location .. };
Set-Alias ".."			Set-ParentLocation
Set-Alias "../"			Set-ParentLocation
Set-Alias "../.."		Set-ParentLocation ; Set-ParentLocation
Set-Alias "../../"		Set-ParentLocation ; Set-ParentLocation
Set-Alias "../../.." 	Set-ParentLocation ; Set-ParentLocation ; Set-ParentLocation
Set-Alias "../../../" 	Set-ParentLocation ; Set-ParentLocation ; Set-ParentLocation

Set-Alias time Measure-Command

if (Get-Command wget.exe -ErrorAction SilentlyContinue | Test-Path) {
	Remove-Alias wget -ErrorAction SilentlyContinue
}

if (Get-Command exa -ErrorAction SilentlyContinue | Test-Path) {
	Remove-Alias ls -ErrorAction SilentlyContinue
	${function:ls} = { exa @args }
	${function:ll} = { exa -l @args }
	${function:la} = { exa -la @args }
}
elseif (Get-Command ls.exe -ErrorAction SilentlyContinue | Test-Path) {
	Remove-Alias ls -ErrorAction SilentlyContinue
	${function:ls} = { ls.exe --color @args }
	${function:ll} = { ls -lF @args }
	${function:la} = { ls -laF @args }
}
else {
	${function:la} = { ls -Force @args }
}

if (Get-Command curl.exe -ErrorAction SilentlyContinue | Test-Path) {
	Remove-Alias curl -ErrorAction SilentlyContinue
	${function:curl} = { curl.exe @args }
}

if (Get-Command bat -ErrorAction SilentlyContinue | Test-Path) {
	${function:cat} = { bat @args }
}

function which($name) {
	Get-Command $name -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Definition
}

# Chocolatey profile
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
	Import-Module "$ChocolateyProfile"
}

function e { exit }
Set-Alias ^D e		# exit with Ctrl+D
Set-Alias c Clear-Host

if (Get-Command git -ErrorAction SilentlyContinue | Test-Path) {
	${function:gst} = { git status @args }
	${function:ga} = { git add @args }
	${function:gc} = { git commit -v @args }
	${function:gcl} = { git clone @args }
	#${function:gl} = { git pull @args } # Already permanently aliased to Get-Location
	#${function:gp} = { git push @args } # Already permanently aliased to Get-ItemProperty
}