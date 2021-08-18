# Nalsai's Dotfiles

Dotfiles for my installations of Linux and Windows.
The folder windows includes collection of PowerShell files for Windows to install application through Chocolatey and configure them aswell as dotfiles for application that are Windows exclusive. 
The folder linux has the same things except for Linux.
Config files for cross-platform application are at the root of this repository.


## Installation

Each application's dotfiles are kept in a folder with the name of the application. To use my dotfiles for that application just copy them to the corresponding location or create symlinks.

`Linux:` To install these dotfiles, run this command:

```bash
bash <(curl -Ss https://raw.githubusercontent.com/Nalsai/dotfiles/rework/linux/install.sh)
```

`Windows:` Copy this into PowerShell:

```ps1
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Nalsai/dotfiles/rework/windows/install.ps1'))
```


## Thanks to

- ![LightArrowsEXE Profile Picture](https://avatars.githubusercontent.com/LightArrowsEXE?s=12) LightArrowsEXE's [dotfiles](https://github.com/LightArrowsEXE/dotfiles) (mpv config)
- ![Sycnex Profile Picture](https://avatars.githubusercontent.com/Sycnex?s=12) Sycnex's [Windows10Debloater](https://github.com/Sycnex/Windows10Debloater)
