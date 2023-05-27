
# minimal stuff

Write-Output "Setting standby times"
powercfg /change /monitor-timeout-ac 240    # 4h
powercfg /change /standby-timeout-ac 720    # 12h
powercfg /change /monitor-timeout-dc 30     # 30m
powercfg /change /standby-timeout-dc 60     # 1h

Write-Host "Enabling Developer Mode"
Set-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\AppModelUnlock" "AllowDevelopmentWithoutDevLicense" 1

Write-Host "Enabling WSL"
Enable-WindowsOptionalFeature -Online -All -FeatureName "Microsoft-Windows-Subsystem-Linux" -NoRestart -WarningAction SilentlyContinue > $null

Write-Host "Change hardware clock to UTC [Y/n]: " -ForegroundColor Yellow -NoNewline
$host.UI.RawUI.FlushInputBuffer()
$key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
while(-Not($key.Character -eq "Y" -Or $key.Character -eq "N" -Or $key.VirtualKeyCode -eq 13)) {
	$key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}
Write-Host $key.Character
Switch ($key.Character) {
	Default {
		Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\TimeZoneInformation" "RealTimeIsUniversal" 1
	}
	N {}
}
