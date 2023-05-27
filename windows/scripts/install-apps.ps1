#Requires -RunAsAdministrator
$TMP = "$env:TEMP\ZG90ZmlsZXM"
New-Item -ItemType directory -Force -Path $TMP -ErrorAction SilentlyContinue > $null

function ask_yn() {
	$host.UI.RawUI.FlushInputBuffer()
	$key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
	while(-Not($key.Character -eq "Y" -Or $key.Character -eq "N" -Or $key.Character -eq "Q" -Or $key.VirtualKeyCode -eq 13)) {
		$key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
	}
	Write-Host $key.Character
	if ($key.Character -eq "Q") {
		exit
	}
	return $key.Character
}


if (!((Get-ChildItem -Path 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP' -Recurse | Get-ItemProperty -Name 'Version' -ErrorAction SilentlyContinue | ForEach-Object { $_.Version -as [System.Version] } | Where-Object { $_.Major -eq 3 -and $_.Minor -eq 5 }).Count -ge 1)) {
	Write-Host "Installing .NET 3.5"
	Enable-WindowsOptionalFeature -Online -FeatureName "NetFx3" -NoRestart
}

Write-Host "Installing Apps..." -ForegroundColor Green
winget install --id=AltSnap.AltSnap -e -h --scope "machine"
winget install --id=Audacity.Audacity -e -h --scope "machine"
winget install --id=BurntSushi.ripgrep.MSVC -e -h --scope "machine"
winget install --id=Canneverbe.CDBurnerXP -e -h --scope "machine"
winget install --id=cURL.cURL -e -h --scope "machine"
winget install --id=dotPDNLLC.paintdotnet -e -h --scope "machine"
winget install --id=GIMP.GIMP -e -h --scope "machine"
winget install --id=Git.Git -e -h --override "/GitAndUnixToolsOnPath /NoShellIntegration /WindowsTerminal" --scope "machine"
winget install --id=GNU.Wget2 -e -h --scope "machine"
winget install --id=Gyan.FFmpeg -e -h --scope "machine"
winget install --id=Microsoft.WindowsTerminal -e -h --scope "machine"
winget install --id=Mozilla.Firefox -e -h --scope "machine"
winget install --id=nomacs.nomacs -e -h --scope "machine"
winget install --id=REALiX.HWiNFO -e -h --scope "machine"
winget install --id=SomePythonThings.WingetUIStore -e -h --scope "machine"
winget install --id=stnkl.EverythingToolbar -e -h --scope "machine"
winget install --id=TheDocumentFoundation.LibreOffice -e -h --scope "machine"
winget install --id=tsl0922.ImPlay -e -h --scope "machine"
winget install --id=voidtools.Everything -e -h --scope "machine"
winget install --id=WinDirStat.WinDirStat -e -h --scope "machine"
winget install --id=Xanashi.Icaros -e -h --scope "machine"
winget install --id=yt-dlp.yt-dlp -e -h --scope "machine"

# minimal only:
#winget install --id=CrystalDewWorld.CrystalDiskInfo -e -h --scope "machine"
#winget install --id=EclipseAdoptium.Temurin.19.JDK -e -h --scope "machine"
#winget install --id=Google.Chrome -e -h --scope "machine"
#winget install --id=VideoLAN.VLC -e -h --scope "machine"

# full only:
winget install --id=AndreWiethoff.ExactAudioCopy -e -h --scope "machine"
winget install --id=AutoHotkey.AutoHotkey -e -h --scope "machine"
winget install --id=Balena.Etcher -e -h --scope "machine"
winget install --id=CrystalDewWorld.CrystalDiskInfo.ShizukuEdition -e -h --scope "machine"
winget install --id=CrystalDewWorld.CrystalDiskMark.ShizukuEdition -e -h --scope "machine"
winget install --id=DelugeTeam.DelugeBeta -e -h --scope "machine"
winget install --id=Discord.Discord -e -h --scope "machine"
winget install --id=EclipseAdoptium.Temurin.19.JDK -e -h --scope "machine"
winget install --id=eloston.ungoogled-chromium -e -h --scope "machine"
winget install --id=GuinpinSoft.MakeMKV -e -h --scope "machine"
winget install --id=HermannSchinagl.LinkShellExtension -e -h --scope "machine"
winget install --id=HeroicGamesLauncher.HeroicGamesLauncher -e -h --scope "machine"
winget install --id=Hugin.Hugin -e -h --scope "machine"
winget install --id=Hugo.Hugo -e -h --scope "machine"
winget install --id=M2Team.NanaZip -e -h --scope "machine"
winget install --id=MediaArea.MediaInfo -e -h --scope "machine"
winget install --id=MediaArea.MediaInfo.GUI -e -h --scope "machine"
winget install --id=Meld.Meld -e -h --scope "machine"
winget install --id=Microsoft.VisualStudioCode -e --override "/verysilent /suppressmsgboxes /tasks=!runCode,desktopicon,quicklaunchicon,addcontextmenufiles,addcontextmenufolders,associatewithfiles,addtopath" -h --scope "machine"
winget install --id=MoritzBunkus.MKVToolNix -e -h --scope "machine"
winget install --id=OBSProject.OBSStudio -e -h --scope "machine"
winget install --id=OliverBetz.ExifTool -e -h --scope "machine"
winget install --id=Peppy.Osu! -e -h --scope "machine"
winget install --id=Python.Python.3.12 -v "3.12.0a1" -e -h --scope "machine"
winget install --id=RabidViperProductions.AssaultCube -e -h --scope "machine"
winget install --id=Rufus.Rufus -e -h --scope "machine"
winget install --id=ShiningLight.OpenSSL -e -h --scope "machine"
winget install --id=SyncTrayzor.SyncTrayzor -e -h --scope "machine"
winget install --id=TimKosse.FileZilla.Client -e -h --scope "machine"
winget install --id=Unity.UnityHub -e -h --scope "machine"
winget install --id=Valve.Steam -e -h --scope "machine"

# TODO: Run AltDrag
Start-Process "$HOME\AppData\Roaming\AltDrag\AltDrag.exe" -ArgumentList "-h"
$action = New-ScheduledTaskAction -Execute $ExecutionContext.InvokeCommand.ExpandString('$HOME\AppData\Roaming\AltDrag\AltDrag.exe') -Argument '-h'
$trigger = New-ScheduledTaskTrigger -AtLogon
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries
Register-ScheduledTask -TaskName "AltDrag" -Action $action -Trigger $trigger -Settings $settings -RunLevel Highest -Force > $null

# Register Icaros
Set-ItemProperty "HKLM:\Software\Icaros" "Thumbnail Extensions" "3g2;3gp;3gp2;3gpp;amv;ape;asf;avi;bik;bmp;cb7;cbr;cbz;divx;dpg;dv;dvr-ms;epub;evo;f4v;flac;flv;gif;hdmov;jpg;k3g;m1v;m2t;m2ts;m2v;m4b;m4p;m4v;mk3d;mka;mkv;mov;mp2v;mp3;mp4;mp4v;mpc;mpe;mpeg;mpg;mpv2;mpv4;mqv;mts;mxf;nsv;ofr;ofs;ogg;ogm;ogv;opus;png;qt;ram;rm;rmvb;skm;spx;swf;tak;tif;tiff;tp;tpr;trp;ts;tta;vob;wav;webm;wm;wmv;wv;xvid"
RegSvr32.exe "C:\Program Files\Icaros\64-bit\IcarosThumbnailProvider.dll" /s
RegSvr32.exe "C:\Program Files\Icaros\64-bit\IcarosPropertyHandler.dll" /s

Write-Host "Disable git gpgsign? [y/N]: " -ForegroundColor Yellow -NoNewline
Switch (ask_yn) {
	Y {
		git config --global commit.gpgsign false
	}
	Default {
		Write-Host "Change git signingkey? [y/N]: " -ForegroundColor Yellow -NoNewline
		$host.UI.RawUI.FlushInputBuffer()
		$key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
		while(-Not($key.Character -eq "Y" -Or $key.Character -eq "N" -Or $key.VirtualKeyCode -eq 13)) {
			$key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
		}
		Write-Host $key.Character
		Switch ($key.Character) {
			Y {
				Write-Host "Listing keys:" -ForegroundColor Yellow
				Write-Host "gpg --list-secret-keys --keyid-format=long"
				gpg --list-secret-keys --keyid-format=long

				Write-Host "GPG key ID: " -ForegroundColor Cyan -NoNewline
				$keyID = Read-Host
				git config --global user.signingkey "$keyID"
			}
			Default {}
		}
	}
}

Write-Host "Done Installing Apps" -ForegroundColor Green
