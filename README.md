# Nalsai's Dotfiles

My dotfiles for Fedora Linux and Windows 10/11.  
Fedora Workstation and Fedora Silverblue are both supported.  
Arch Linux- and Debian-based distributions are partially supported.

## Installation

Make sure to update and restart your system first.

`Linux:` Run this command in bash:

```bash
bash <(curl -Ss https://raw.githubusercontent.com/Nalsai/dotfiles/main/linux/install.sh)
```

`Windows:` Run this in PowerShell:

```ps1
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Nalsai/dotfiles/main/windows/install.ps1'))
```

### Windows Setup

1. Select your region & keyboard
2. When presented the "Sign in with Microsoft" screen, select "Domain join instead" to avoid logging in.  
    If you have Windows 11 Home, do the following:
    - Press Shift+F10 to open the command prompt.
    - Enter `OOBE\BYPASSNRO`
    - Now you can select "I don't have internet" to setup a local account.
3. Set your username. Set your password later if you want to avoid having to give recovery questions.
4. Disable everything on the privacy screen and click "Accept".

#### Activating Windows

Buy a license from [Microsoft](https://www.microsoft.com/) and enter your product key in the settings.

You can also use [Microsoft Activation Scripts](https://github.com/massgravel/Microsoft-Activation-Scripts/releases) (`iwr -useb https://massgrave.dev/get | iex`), [KMS_VL_ALL_AIO](https://pastebin.com/cpdmr6HZ) or [kms.nils.moe](https://kms.nils.moe).

### Manual Steps - Linux

- Setup GPG keys
- Setup SSH keys
- Disable system sounds
- Setup Firefox
  - Sign in
  - Setup Extensions
    - Bitwarden: Sign in
    - uBlock Origin: enable cloud storage support, import from cloud storage
    - Translate Web Pages: disable popup and release notes
    - Enhancer for YouTube: set theme, disable controls, set quality, disable autoplay
    - Violent Monkey: Sync to Google Drive
    - Web Scrobbler: Sign in
  - Customize toolbar and shortcuts
  - `curl -s -o- https://raw.githubusercontent.com/rafaelmardojai/firefox-gnome-theme/master/scripts/install-by-curl.sh | bash`
- Setup Steam
  - Install Adwaita-for-Steam (using AdwSteamGtk)
  - Enable Steam Play (Proton)
  - Disable "Notify me about ..."
  - Change default window to "Library"
- Sign in to VSCode (with GitHub) to enable settings sync
- Setup Deluge headless mode
- Setup bookmarks in files
- On Silverblue:
  - reboot
  - `systemctl --user enable syncthing.service`
  - setup distrobox
- Setup Syncthing

### Manual Steps - Windows

- Setup GPG keys
- Setup SSH keys
- Disable system sounds
- Setup Firefox
  - Sign in
  - Setup Extensions
    - Bitwarden: Sign in
    - uBlock Origin: enable cloud storage support, import from cloud storage
    - Translate Web Pages: disable popup and release notes
    - Enhancer for YouTube: set theme, disable controls, set quality, disable autoplay
    - Violent Monkey: Sync to Google Drive
    - Web Scrobbler: Sign in
  - Customize toolbar and shortcuts
- Setup Steam
  - Disable "Notify me about ..."
  - Change default window to "Library"
- Sign in to VSCode (with GitHub) to enable settings sync
- Setup Deluge headless mode
- Setup favorites in explorer
- Setup FileZilla
- Setup Syncthing

## Thanks to

- ![LightArrowsEXE Profile Picture](https://avatars.githubusercontent.com/LightArrowsEXE?s=12) LightArrowsEXE's [dotfiles](https://github.com/LightArrowsEXE/dotfiles) (mpv config)
- I am Scum's [mpv.conf guide](https://iamscum.wordpress.com/guides/videoplayback-guide/mpv-conf/)
