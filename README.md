# Nalsai's Dotfiles

Dotfiles for my installations of Linux and Windows.  
The folder *windows* includes a collection of PowerShell files for Windows to install applications and configure them, as well as dotfiles for applications that are Windows exclusive.
The folder *linux* has the same things except for Linux. I mainly use Fedora. Other (arch- or debian-based) distros are partially supported.
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

## Installing Windows

You can download Windows and Office directly from Microsoft using <https://tb.rg-adguard.net/>.

Flash the Windows ISO to a USB stick using [Rufus](https://rufus.ie/), or install [Ventoy](https://www.ventoy.net/) on an USB stick and copy the ISO to it.

Boot from the USB Stick and follow the prompts to install Windows (When asked for a product key select "I don't have a product key"; select "Custom: Install Windows only (advanced)" to do a fresh install). Windows should install and then reboot.

### First Time Setup

1. Select your region & keyboard
2. When presented the Sign in with Microsoft screen, select Domain join instead to avoid logging in. If you have Windows 11 Home, do the following instead:
    - Press Shift+F10 to open the command prompt.
    - Enter `ncpa.cpl` to open the network connections control panel.
    - Right-click your Wi-Fi or Ethernet adapter and click Disable. This will disconnect you from the Internet.
    - Close the settings and the command prompt, and click the back arrow.
3. Set your username. If you want to avoid having to give recovery questions, don't set a password here, do that later.
4. Disable everything on the privacy screen and click Accept

### Activating Windows

Buy a license from [Microsoft](https://www.microsoft.com/) and enter your product key in the settings.

You can also use [Microsoft Activation Scripts](https://github.com/massgravel/Microsoft-Activation-Scripts/releases) (run `iwr -useb https://massgrave.dev/get | iex` in PowerShell), [KMS_VL_ALL_AIO](https://pastebin.com/cpdmr6HZ) or <https://kms.nils.moe>.

### Manual Steps - Windows

TODO

### Manual Steps - Linux

- Setup GPG keys
- Setup SSH keys
- Copy proprietary fonts from Windows, if needed
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
  - Change skin to "Adwaita"
  - Install games
- Sign in to VSCode (with GitHub) to enable settings sync
- Setup Deluge headless mode
- On Silverblue: reboot
- On Silverblue: `systemctl --user enable syncthing.service`

## Thanks to

- ![LightArrowsEXE Profile Picture](https://avatars.githubusercontent.com/LightArrowsEXE?s=12) LightArrowsEXE's [dotfiles](https://github.com/LightArrowsEXE/dotfiles) (mpv config)
- ![Sycnex Profile Picture](https://avatars.githubusercontent.com/Sycnex?s=12) Sycnex's [Windows10Debloater](https://github.com/Sycnex/Windows10Debloater)
- <https://rentry.co/windows_for_retards>
