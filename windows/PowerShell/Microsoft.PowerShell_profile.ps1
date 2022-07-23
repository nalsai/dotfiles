# Easier Navigation: .., ..., ...., ....., and ~
${function:~} = { Set-Location ~ }
# PoSh won't allow ${function:..} because of an invalid path error, so...
${function:Set-ParentLocation} = { Set-Location .. }; Set-Alias ".." Set-ParentLocation
${function:...} = { Set-Location ..\.. }
${function:....} = { Set-Location ..\..\.. }
${function:.....} = { Set-Location ..\..\..\.. }
${function:......} = { Set-Location ..\..\..\..\.. }

# Missing Bash aliases
Set-Alias time Measure-Command

# Correct PowerShell Aliases if tools are available (aliases win if set)
# WGet: Use `wget.exe` if available
if (Get-Command wget.exe -ErrorAction SilentlyContinue | Test-Path) {
	rm alias:wget -ErrorAction SilentlyContinue
}

# Directory Listing: Use `ls.exe` if available
if (Get-Command ls.exe -ErrorAction SilentlyContinue | Test-Path) {
	rm alias:ls -ErrorAction SilentlyContinue
	# Set `ls` to call `ls.exe` and always use --color
	${function:ls} = { ls.exe --color @args }
	# List all files in long format
	${function:l} = { ls -lF @args }
	# List all files in long format, including hidden files
	${function:la} = { ls -laF @args }
	# List only directories
	${function:lsd} = { Get-ChildItem -Directory -Force @args }
}
else {
	# List all files, including hidden files
	${function:la} = { ls -Force @args }
	# List only directories
	${function:lsd} = { Get-ChildItem -Directory -Force @args }
}

# curl: Use `curl.exe` if available
if (Get-Command curl.exe -ErrorAction SilentlyContinue | Test-Path) {
	rm alias:curl -ErrorAction SilentlyContinue
	# Set `ls` to call `ls.exe` and always use --color
	${function:curl} = { curl.exe @args }
	# Gzip-enabled `curl`
	${function:gurl} = { curl --compressed @args }
}
else {
	# Gzip-enabled `curl`
	${function:gurl} = { curl -TransferEncoding GZip }
}

function which($name) {
	Get-Command $name -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Definition
}

# Chocolatey profile
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
	Import-Module "$ChocolateyProfile"
}

Set-Alias c Clear-Host
function e {exit}
new-alias ^D e		# exit with Ctrl+D