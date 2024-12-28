# Nalsai's Dotfiles

My dotfiles for Fedora Linux and Windows 10/11.  
Fedora Workstation and Fedora Silverblue are both supported.  
Arch Linux and Debian based distributions are partially supported.

## Installation

Make sure to update and restart your system first.

**Linux**: Run this command in bash:

```bash
bash <(curl -Ss https://raw.githubusercontent.com/nalsai/dotfiles/main/linux/install.sh)
```

**Windows**: Run this in PowerShell:

```ps1
irm https://raw.githubusercontent.com/nalsai/dotfiles/main/windows/install.ps1 | iex
```

### Activating Windows


### Steps: Linux

- Setup GPG and SSH keys
- Setup Firefox
  - Setup Extensions
    - Bitwarden: Sign in
    - uBlock Origin, Violent Monkey: Sync from Google Drive
    - Translate Web Pages: disable popup and release notes
    - Enhancer for YouTube: set theme, hide extra controls, set quality, disable autoplay
  - `curl -s -o- https://raw.githubusercontent.com/rafaelmardojai/firefox-gnome-theme/master/scripts/install-by-curl.sh | bash`
- Setup Steam
  - Install Adwaita-for-Steam (using AdwSteamGtk)
  - Enable Steam Play (Proton)
  - Disable "Notify me about ..."
  - Change default window to "Library"
- Install "Disable unredirect fullscreen windows" GNOME extension if needed
- On Silverblue: reboot, `systemctl --user enable syncthing.service`, setup distrobox
- Setup Syncthing

### Steps: Windows

- Create your installation media with Rufus to remove the Microsoft Account requirement
- Install Windows without an internet connection
- Connect to the internet and let Windows install drivers and updates
- [Microsoft Activation Scripts](https://github.com/massgravel/Microsoft-Activation-Scripts): `irm https://get.activated.win | iex`
- Install dotfiles
- Reboot
- Setup GPG and SSH keys if needed
- Setup Firefox
  - Setup Extensions
    - Bitwarden: Sign in
    - uBlock Origin, Violent Monkey: Sync from Google Drive
    - Translate Web Pages: disable popup and release notes
    - Enhancer for YouTube: set theme, hide extra controls, set quality, disable autoplay
- Setup Steam
  - Disable "Notify me about ..."
  - Change default window to "Library"
- Setup Syncthing

## Thanks to

- ![LightArrowsEXE Profile Picture](https://avatars.githubusercontent.com/LightArrowsEXE?s=12) LightArrowsEXE's [dotfiles](https://github.com/LightArrowsEXE/dotfiles)
- I am Scum's [mpv.conf guide](https://iamscum.wordpress.com/guides/videoplayback-guide/mpv-conf/)
