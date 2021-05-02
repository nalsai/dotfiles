# Nalsai's Dotfiles

Dotfiles I use for my Linux and Windows installations.
Including application installation through Chocolatey, apt, flathub & pacman (depending on what is available).

## Linux

### Installation

Each application's dotfiles are kept in a folder of the same name. Each application's folder has the same tree structure as a user's `$HOME` directory, so to use my dotfiles for that application just copy them to the corresponding location in `$HOME` or create symlinks in the corresponding locations. If you have `stow` (& `make`) installed, you can do this with:

```
make <application name>
```

This will also handle any dependencies between my dotfiles. To use my default configuration, just run `make`. To use all my dotfiles, run `make all`.


## Windows

### Installation

To install these dotfiles from PowerShell without any prerequisites, copy this command into an elevated PowerShell instance and run it:

```ps1
iwr "https://git.nalsai.de/dotfiles/archive/master.zip" -O $HOME\dotfiles.zip; if($?){Expand-Archive $HOME\dotfiles.zip $HOME; rm $HOME\dotfiles.zip; rm $HOME\.dotfiles -r -ErrorA Ignore; rni $HOME\dotfiles-master $HOME\.dotfiles; Set-ExecutionPolicy RemoteSigned; iex $HOME\.dotfiles\full-install.ps1}
```
The command will download this repository to `$HOME` and run `full-install.ps1`

To only run `minimal-install.ps1`, use:

```ps1
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Nalsai/dotfiles/master/_windows/minimal-install.ps1'))
```

## Thanks to

- ![LightArrowsEXE Profile Picture](https://avatars.githubusercontent.com/LightArrowsEXE?s=12) LightArrowsEXE's [dotfiles](https://github.com/LightArrowsEXE/dotfiles)
- ![jayharris Profile Picture](https://avatars.githubusercontent.com/jayharris?s=12) jayharris's [dotfiles-windows](https://github.com/jayharris/dotfiles-windows)
- <img src="https://avatars.githubusercontent.com/ndz-v?s=12" width="12" alt="ndz-v"> ndz-v's [windows-dotfiles](https://github.com/ndz-v/windows-dotfiles)
- ![Sycnex Profile Picture](https://avatars.githubusercontent.com/Sycnex?s=12) Sycnex's [Windows10Debloater](https://github.com/Sycnex/Windows10Debloater)
- ![ngenisis Profile Picture](https://avatars.githubusercontent.com/ngenisis?s=12) ngenisis's [dotfiles](https://github.com/ngenisis/dotfiles/)
