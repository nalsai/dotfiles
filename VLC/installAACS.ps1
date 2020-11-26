#Requires -RunAsAdministrator

Write-Host "Press Enter to install AACS decryption for VLC`nPlease note that you can (and should) use MakeMKV to play Blu-rays instead"
Switch (Read-Host) { 
	Default {
		if (!(Test-Path "C:\ProgramData\aacs\")) {
			New-Item "C:\ProgramData\aacs\" -ItemType directory
		}
		try {
			Remove-Item "C:\ProgramData\aacs\KEYDB.cfg" -Force -ErrorAction SilentlyContinue
			wget.exe -O "C:\ProgramData\aacs\KEYDB.cfg" "https://vlc-bluray.whoknowsmy.name/files/KEYDB.cfg" --no-check-certificate
			Remove-Item "C:\Program Files\VideoLAN\VLC\libaacs.dll" -Force -ErrorAction SilentlyContinue
			wget.exe -O "C:\Program Files\VideoLAN\VLC\libaacs.dll" "https://vlc-bluray.whoknowsmy.name/files/win64/libaacs.dll" --no-check-certificate
		}
		catch {
			Remove-Item "C:\ProgramData\aacs\KEYDB.cfg" -Force -ErrorAction SilentlyContinue
			wget.exe -O "C:\ProgramData\aacs\KEYDB.cfg" "https://vlc-aacs.whoknowsmy.name/files/KEYDB.cfg" --no-check-certificate
			Remove-Item "C:\Program Files\VideoLAN\VLC\libaacs.dll" -Force -ErrorAction SilentlyContinue
			wget.exe -O "C:\Program Files\VideoLAN\VLC\libaacs.dll" "https://vlc-aacs.whoknowsmy.name/files/win64/libaacs.dll" --no-check-certificate
		}
		Write-Output "Done installing libaacs.dll and KEYDB.cfg for VLC"
	}
}