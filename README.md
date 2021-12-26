# Nalsai's Dotfiles

Dotfiles for my installations of Linux and Windows.  
The folder *windows* includes a collection of PowerShell files for Windows to install applications and configure them, as well as dotfiles for applications that are Windows exclusive. 
The folder *linux* has the same things except for Linux.
Config files for cross-platform application are in their respective folders at the root of this repository.


## Installation

`Linux:` To install these dotfiles, run this command:

```bash
bash <(curl -Ss https://raw.githubusercontent.com/Nalsai/dotfiles/main/linux/install.sh)
```

`Windows:` Copy this into PowerShell:

```ps1
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Nalsai/dotfiles/main/windows/install.ps1'))
```


## Thanks to

- ![LightArrowsEXE Profile Picture](https://avatars.githubusercontent.com/LightArrowsEXE?s=12) LightArrowsEXE's [dotfiles](https://github.com/LightArrowsEXE/dotfiles) (mpv config)
- ![Sycnex Profile Picture](https://avatars.githubusercontent.com/Sycnex?s=12) Sycnex's [Windows10Debloater](https://github.com/Sycnex/Windows10Debloater)
