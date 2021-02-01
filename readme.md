# Nalsai's Dotfiles

A collection of PowerShell files for Windows, including application installation through Chocolatey, Windows configuration and configuration files.

## Installation

To install these dotfiles from PowerShell without any prerequisites, copy this command into your elevated PowerShell instance and run it:

```ps1
iwr "https://git.nalsai.de/dotfiles/archive/master.zip" -O $HOME\dotfiles.zip; if($?){Expand-Archive $HOME\dotfiles.zip $HOME; rm $HOME\dotfiles.zip; rm $HOME\.dotfiles -r -ErrorA Ignore; rni $HOME\dotfiles-master $HOME\.dotfiles; Set-ExecutionPolicy RemoteSigned; iex $HOME\.dotfiles\full-install.ps1}
```

To run minimal-install.ps1, use:

```ps1
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Nalsai/dotfiles/master/minimal-install.ps1'))
```

The command will download this repository to `$HOME` and run `full-install.ps1`

## Forking this repository

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

- ![LightArrowsEXE Profile Picture](https://avatars.githubusercontent.com/LightArrowsEXE?s=12) LightArrowsEXE's [dotfiles](https://github.com/LightArrowsEXE/dotfiles)
- ![jayharris Profile Picture](https://avatars.githubusercontent.com/jayharris?s=12) jayharris's [dotfiles-windows](https://github.com/jayharris/dotfiles-windows)
- <img src="https://avatars.githubusercontent.com/ndz-v?s=12" width="12" alt="ndz-v"> ndz-v's [windows-dotfiles](https://github.com/ndz-v/windows-dotfiles)
- ![Sycnex Profile Picture](https://avatars.githubusercontent.com/Sycnex?s=12) Sycnex's [Windows10Debloater](https://github.com/Sycnex/Windows10Debloater)
