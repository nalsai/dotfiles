# Nalsai's Dotfiles

My dotfiles for Fedora Linux and Windows 10/11.  
Fedora Workstation and Fedora Silverblue are both supported.  
Arch Linux- and Debian-based distributions are partially supported.

## Installation

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
    - Enter `ncpa.cpl` to open the network connections control panel.
    - Right-click your Wi-Fi or Ethernet adapter and click "Disable". This will disconnect you from the Internet.
    - Close the settings and the command prompt and click the back arrow.
3. Set your username. Set your password later if you want to avoid having to give recovery questions.
4. Disable everything on the privacy screen and click "Accept".

#### Activating Windows

Buy a license from [Microsoft](https://www.microsoft.com/) and enter your product key in the settings.

You can also use [Microsoft Activation Scripts](https://github.com/massgravel/Microsoft-Activation-Scripts/releases) (`iwr -useb https://massgrave.dev/get | iex`), [KMS_VL_ALL_AIO](https://pastebin.com/cpdmr6HZ) or [kms.nils.moe](https://kms.nils.moe).

### Manual Steps - Linux

- Setup GPG keys
- Setup SSH keys
- Disable system sounds
- Install proprietary fonts if needed
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
  - Change skin to "Adwaita"
  - Disable "Notify me about ..."
  - Change default window to "Library"
  - Install games
- Sign in to VSCode (with GitHub) to enable settings sync
- Setup Deluge headless mode
- Setup bookmarks in files
- On Silverblue: reboot
- On Silverblue: `systemctl --user enable syncthing.service`
- Setup Syncthing
- Run "Setup distrobox" tool

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
  - Install games
- Sign in to VSCode (with GitHub) to enable settings sync
- Setup Deluge headless mode
- Setup FileZilla
- Setup Syncthing
- Setup favorites in explorer

## Thanks to

- ![LightArrowsEXE Profile Picture](https://avatars.githubusercontent.com/LightArrowsEXE?s=12) LightArrowsEXE's [dotfiles](https://github.com/LightArrowsEXE/dotfiles) (mpv config)
