# Nalsai's Dotfiles

A collection of PowerShell files for Windows, including application installation through Chocolatey, Windows configuration and configuration files.

## Installation

To install these dotfiles from PowerShell without any prerequisites, copy this command into your elevated PowerShell instance and run it:

```ps1
Set-ExecutionPolicy Bypass; Invoke-WebRequest "https://git.nalsai.de/dotfiles/archive/master.zip" -OutFile $HOME\dotfiles.zip; Expand-Archive -Path $HOME\dotfiles.zip  -DestinationPath "$HOME" -Force; Move-Item -Force -Path $HOME\dotfiles-master -Destination $HOME\.dotfiles; Remove-Item $HOME\dotfiles.zip; Invoke-Expression -Command $HOME\.dotfiles\full-install.ps1
```

The command will download this repository to `$HOME` and run `full-install.ps1`

## Forking this repo

Because dotfiles can be highly personalized, you should never just copy them from someone else.

If you still want to clone this repo you at least need to change the following:

`git/.gitconfig`

```gitconfig
[username]
        name = YourName
        email = YourEmail
```

The list of Terminals in `WindowsTerminal/settings.json`

Additionally, you should change what apps get installed in `install-apps.ps1` because you probably use different things than me.

## Thanks to

- ![](https://avatars.githubusercontent.com/LightArrowsEXE?s=12)
LightArrowsEXE's [dotfiles](https://github.com/LightArrowsEXE/dotfiles)
- ![](https://avatars.githubusercontent.com/jayharris?s=12)
jayharris's [dotfiles-windows](https://github.com/jayharris/dotfiles-windows)
- <img src="https://avatars.githubusercontent.com/ndz-v?s=12" width="12"> ndz-v's [windows-dotfiles](https://github.com/ndz-v/windows-dotfiles)
- ![](https://avatars.githubusercontent.com/Sycnex?s=12)
Sycnex's [Windows10Debloater](https://github.com/Sycnex/Windows10Debloater)
