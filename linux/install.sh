#!/bin/bash

clear
echo -e " _   _ _ _     ____        _    __ _ _\n| \ | (_| |___|  _ \  ___ | |_ / _(_| | ___ ___\n|  \| | | / __| | | |/ _ \| __| |_| | |/ _ / __|\n| |\  | | \__ | |_| | (_) | |_|  _| | |  __\__ \\n|_| \_|_|_|___|____/ \___/ \__|_| |_|_|\___|___/"
echo

force_symlink() {
  mkdir -p "$(dirname "$2")"
  rm -rf "$2" >/dev/null 2>&1
  ln -sf "$1" "$2"
}

ask_yn() {
  echo -n "$1? [y/n/q]: "
  old_stty_cfg=$(stty -g)
  stty raw -echo
  answer=$(while ! head -c 1 | grep -i "[nyq]"; do true; done)
  stty $old_stty_cfg
  if echo "$answer" | grep -iq "^y"; then
    echo y
    $2
  elif echo "$answer" | grep -iq "^n"; then
    echo n
    $3
  else
    echo q
    exit
  fi
}

install_pkgs() {
  if type "$1" >/dev/null 2>&1; then
    if type apt-get >/dev/null 2>&1; then
      sudo apt-get install "$@" -y
    elif type dnf >/dev/null 2>&1; then
      sudo dnf -y install "$@"
    elif type pacman >/dev/null 2>&1; then
      sudo pacman -S "$@"
    fi
  fi
}

uninstall_pkgs() {
  if type "$1" >/dev/null 2>&1; then
    if type apt-get >/dev/null 2>&1; then
      sudo apt-get remove "$@" -y
    elif type dnf >/dev/null 2>&1; then
      sudo dnf -y remove "$@"
    elif type pacman >/dev/null 2>&1; then
      sudo pacman -R "$@"
    fi
  fi
}

install_optional_flatpaks() {
  optional_flatpaks=""
  for var in "$@"; do
    echo -n "Install $var? [y/n]: "
    old_stty_cfg=$(stty -g)
    stty raw -echo
    answer=$(while ! head -c 1 | grep -i "[ny]"; do true; done)
    stty $old_stty_cfg
    if echo "$answer" | grep -iq "^y"; then
      echo y
      optional_flatpaks="$optional_flatpaks $var"
    else
      echo n
    fi
  done
  [ -z "$optional_flatpaks" ] || sudo flatpak -y install flathub$optional_flatpaks
}

configure_gpgsign() {
  enabled() {
    ask_yn "Change git signing key" "change_key"
  }
  change_key() {
    echo "Listing keys:"
    echo "gpg --list-secret-keys --keyid-format=long"
    gpg --list-secret-keys --keyid-format=long
    echo -n "GPG key ID: "
    read keyID
    git config --global user.signingkey "$keyID"
  }
  ask_yn "Disable git gpgsign" "git config --global commit.gpgsign false" "enabled"
}

prepare() {
  DOT="$HOME/.dotfiles"
  TMP="/tmp/ZG90ZmlsZXM"
  mkdir -p $TMP
  [[ -f /etc/os-release ]] && . /etc/os-release
}

download() {
  echo "Downloading Dotfiles..."

  download_git() {
    install_pkgs git
    if [ -d "$DOT/.git" ]; then
      echo "Found existing git repository: running git pull"
      echo "To prevent data loss this script won't change the git repo."
      echo "You need to resolve any issues yourself,"
      echo "or delete the folder $HOME/.dotfiles and rerun this script."
      cd $DOT
      git pull origin main
    else
      rm -rf $DOT >/dev/null 2>&1
      echo -n "Clone using ssh or https? [s/h]: "
      old_stty_cfg=$(stty -g)
      stty raw -echo
      answer=$(while ! head -c 1 | grep -i "[sh]"; do true; done)
      stty $old_stty_cfg
      if echo "$answer" | grep -iq "^s"; then
        echo s
        rm -rf $DOT >/dev/null 2>&1
        if ! git clone git@github.com:Nalsai/dotfiles.git $DOT; then
          echo "An error occured while cloning!"
          echo "Did you setup your git ssh key?"
          exit 1
        fi
      else
        echo h
        rm -rf $DOT >/dev/null 2>&1
        if ! git clone https://github.com/Nalsai/dotfiles.git $DOT; then
          echo "An error occured while cloning!"
          exit 1
        fi
      fi
    fi
  }

  download_zip() {
    install_pkgs curl unzip

    if ! curl -SL "https://github.com/Nalsai/dotfiles/archive/refs/heads/main.zip" -o $TMP/dotfiles.zip; then
      echo "An error occured while downloading!"
      exit 1
    fi
    if ! unzip -u -d $TMP $TMP/dotfiles.zip; then
      echo "An error occured while unzipping!"
      exit 1
    fi
    rm -rf $DOT >/dev/null 2>&1
    if ! mv $TMP/dotfiles-main $DOT; then
      echo "An error occured while moving the dotfiles into place!"
      exit 1
    fi
  }

  ask_yn "Download with git" "download_git" "download_zip"

  symlink_documents() {
    install_pkgs xdg-user-dirs
    force_symlink $DOT "$(xdg-user-dir DOCUMENTS)/dotfiles"
  }
  ask_yn "Install symlink to Documents" "symlink_documents"

  chmod +x $DOT/linux/connect-ssh.sh
  chmod +x $DOT/linux/install.sh
  chmod +x $DOT/linux/update-system.sh
  chmod +x $DOT/linux/scripts/install_docker.sh
  chmod +x $DOT/linux/scripts/install_gotop.sh
}

update() {
  echo Updating System...
  $DOT/linux/update-system.sh
}

end() {
  rm -rf $TMP >/dev/null 2>&1
  echo Done!
}

FullInstall() {
  prepare
  download
  update

  echo "Making symlinks and copying config files..."
  force_symlink $DOT/mpv/mpv $HOME/.var/app/io.mpv.Mpv/config/mpv
  force_symlink $DOT/linux/code-flags.conf $HOME/.config/code-flags.conf # Only works on arch
  force_symlink $DOT/linux/chromium-flags.conf $HOME/.var/app/com.github.Eloston.UngoogledChromium/config/chromium-flags.conf
  force_symlink $DOT/git/.gitconfig $HOME/.gitconfig
  force_symlink $DOT/linux/fish/ $HOME/.config/fish
  force_symlink $DOT/linux/bash/bash_aliases $HOME/.bash_aliases
  force_symlink $DOT/linux/nvim/ $HOME/.config/nvim
  force_symlink $DOT/windows/PowerShell/Microsoft.PowerShell_profile.ps1 $HOME/.config/powershell/Microsoft.PowerShell_profile.ps1

  # Make sure bash loads bash_aliases
  grep -q ". ~/.bash_aliases" $HOME/.bashrc || echo -e "\nif [ -f ~/.bash_aliases ]; then\n    . ~/.bash_aliases\nfi\n" >>$HOME/.bashrc

  # New File templates
  \cp -r $DOT/linux/templates/** $(xdg-user-dir TEMPLATES)

  # Flatpak app configs
  mkdir -p $HOME/.var/app/com.raggesilver.BlackBox/config/glib-2.0/settings/
  \cp -f $DOT/linux/com.raggesilver.BlackBox/keyfile $HOME/.var/app/com.raggesilver.BlackBox/config/glib-2.0/settings/keyfile
  mkdir -p $HOME/.var/app/io.github.Foldex.AdwSteamGtk/config/glib-2.0/settings/
  \cp -f $DOT/linux/io.github.Foldex.AdwSteamGtk/keyfile $HOME/.var/app/io.github.Foldex.AdwSteamGtk/config/glib-2.0/settings/keyfile
  mkdir -p $HOME/.var/app/org.gnome.TextEditor/config/glib-2.0/settings/
  \cp -f $DOT/linux/org.gnome.TextEditor/keyfile $HOME/.var/app/org.gnome.TextEditor/config/glib-2.0/settings/keyfile
  mkdir -p $HOME/.var/app/org.nomacs.ImageLounge/config/nomacs/
  \cp -f "$DOT/nomacs/Image Lounge.conf" "$HOME/.var/app/org.nomacs.ImageLounge/config/nomacs/Image Lounge.conf"

  # Fix cantarell steam variable font issue
  mkdir -p /var/home/nalsai/.var/app/com.valvesoftware.Steam/data/fonts
  cp /usr/share/fonts/abattis-cantarell-fonts/* /var/home/nalsai/.var/app/com.valvesoftware.Steam/data/fonts

  # TTC shortcut
  rm -f $HOME/.local/share/applications/tamrieltradecentre.desktop >/dev/null 2>&1
  ln -s $DOT/linux/shortcuts/tamrieltradecentre.desktop $HOME/.local/share/applications/tamrieltradecentre.desktop

  if [[ $ID == "fedora" && $VARIANT_ID == "silverblue" ]]; then
    echo "Uninstalling preinstalled Flatpaks..."
    sudo flatpak -y uninstall org.fedoraproject.MediaWriter org.gnome.baobab org.gnome.Connections org.gnome.Contacts org.gnome.Extensions org.gnome.TextEditor org.gnome.Weather org.gnome.eog org.gnome.font-viewer org.mozilla.firefox

    echo "Removing firefox rpm..."
    rpm-ostree override remove firefox firefox-langpacks
  fi

  echo "Installing Flatpaks..."
  install_pkgs flatpak
  [ type apt-get ] >/dev/null 2>&1 && apt-get install gnome-software-plugin-flatpak -y

  sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
  sudo flatpak remote-modify --enable flathub    # Enable flathub on fedora
  sudo flatpak remote-modify --no-filter flathub # And remove filter
  sudo flatpak remote-modify --title=Flathub flathub
  sudo flatpak remote-modify --comment="Central repository of Flatpak applications" flathub
  sudo flatpak remote-modify --description="Central repository of Flatpak applications" flathub

  sudo flatpak -y install flathub com.github.tchx84.Flatseal io.mpv.Mpv org.gimp.GIMP org.gnome.TextEditor org.gnome.eog \
    org.libreoffice.LibreOffice org.mozilla.firefox com.raggesilver.BlackBox

  sudo flatpak -y install flathub com.belmoussaoui.Decoder com.discordapp.Discord com.github.Eloston.UngoogledChromium \
    com.github.iwalton3.jellyfin-media-player com.github.jeromerobert.pdfarranger com.github.liferooter.textpieces com.github.qarmin.czkawka \
    com.github.qarmin.szyszka com.heroicgameslauncher.hgl com.leinardi.gst com.mattjakeman.ExtensionManager com.rawtherapee.RawTherapee \
    com.skype.Client com.usebottles.bottles fr.romainvigier.MetadataCleaner io.github.f3d_app.f3d io.github.Foldex.AdwSteamGtk \
    io.github.seadve.Kooha

  sudo flatpak -y install flathub net.ankiweb.Anki net.mediaarea.MediaInfo net.sourceforge.Hugin nl.hjdskes.gcolor3 \
    org.blender.Blender org.bunkus.mkvtoolnix-gui org.deluge_torrent.deluge org.freedesktop.Piper org.gnome.baobab org.gnome.Firmware \
    org.gnome.World.PikaBackup org.gnome.font-viewer org.gnome.meld org.gnome.seahorse.Application org.gnome.SimpleScan \
    org.inkscape.Inkscape org.nomacs.ImageLounge re.sonny.Commit sh.ppy.osu

  sudo flatpak -y install --reinstall flathub org.freedesktop.Platform.Locale//22.08    # Reinstall org.freedesktop.Platform.Locale for spell checking in different languages
  sudo flatpak override com.usebottles.bottles --filesystem="$HOME/Apps/Bottles"        # Allow Bottles to access $HOME/Apps/Bottles
  sudo flatpak override --socket=wayland --env=MOZ_ENABLE_WAYLAND=1 org.mozilla.firefox # Firefox Wayland
  sudo flatpak override --device=all org.mozilla.firefox                                # Firefox U2F access

  sudo flatpak remote-add --if-not-exists NilsFlatpakRepo https://flatpak.nils.moe/repo/NilsFlatpakRepo.flatpakrepo
  sudo flatpak -y install NilsFlatpakRepo org.wangqr.Aegisub cc.spek.Spek com.github.mkv-extractor-qt5 gg.minion.Minion net.sourceforge.gMKVExtractGUI
  sudo flatpak -y install flathub org.freedesktop.Sdk.Extension.mono6//22.08 # Required for net.sourceforge.gMKVExtractGUI

  sudo flatpak remote-add --if-not-exists launcher.moe https://gol.launcher.moe/gol.launcher.moe.flatpakrepo
  sudo flatpak -y install launcher.moe moe.launcher.an-anime-game-launcher-gtk

  install_optional_flatpaks com.prusa3d.PrusaSlicer com.rafaelmardojai.WebfontKitGenerator org.gnome.Evolution org.gnome.Builder \
    com.wps.Office com.unity.UnityHub com.calibre_ebook.calibre rocks.koreader.KOReader com.makemkv.MakeMKV \
    com.parsecgaming.parsec net.cubers.assault.AssaultCube net.supertuxkart.SuperTuxKart com.github.Anuken.Mindustry

  install_ensembles() {
    sudo flatpak remote-add --if-not-exists ElementaryAppCenter https://flatpak.elementary.io/repo.flatpakrepo
    sudo flatpak -y install ElementaryAppCenter com.github.subhadeepjasu.ensembles
  }
  #ask_yn "Add Elementary AppCenter flatpak remote and install Ensembles" "install_ensembles"
  ask_yn "Install Mothership Defender 2 and Tactical Math Returns" "sudo flatpak -y install NilsFlatpakRepo com.DaRealRoyal.TacticalMathReturns de.Nalsai.MothershipDefender2"

  echo "Installing other packages..."
  if [[ $ID == "fedora" && $VARIANT_ID == "silverblue" ]]; then
    sudo rpm-ostree install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
    if rpm-ostree install fish; then sudo usermod --shell /bin/fish $USER; fi
    rpm-ostree install bat distrobox exa gnome-shell-extension-caffeine libratbag-ratbagd ripgrep syncthing
    sudo flatpak -y install flathub com.valvesoftware.Steam io.neovim.nvim org.gnome.Boxes org.gnome.Cheese
  else
    if type dnf >/dev/null 2>&1; then
      sudo dnf -y install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
      sudo dnf -y groupupdate core

      sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
      sudo sh -c "echo -e '[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc' > /etc/yum.repos.d/vscode.repo"
      sudo dnf -y install code

      sudo dnf -y install gnome-shell-extension-appindicator gnome-shell-extension-caffeine gnome-shell-extension-gsconnect --setopt=install_weak_deps=false
      sudo dnf -y install cargo flatpak-builder gnome-tweaks hugo mangohud ocrmypdf openssl libratbag-ratbagd librsvg2-tools pandoc perl-Image-ExifTool radeontop rust rustfmt steam syncthing tesseract-langpack-deu texlive wireguard-tools yt-dlp
      sudo dnf -y group install "Virtualization"
    fi
    install_pkgs bat curl dconf exa fastfetch ffmpeg fish git ripgrep htop neovim unzip
    if install_pkgs fish; then sudo usermod --shell /bin/fish $USER; fi

    echo "Uninstalling replaced packages..."
    uninstall_pkgs firefox eog gnome-font-viewer libreoffice libreoffice-*

    if type dnf >/dev/null 2>&1; then
      sudo dnf -y group remove LibreOffice
    fi

    $DOT/linux/scripts/install_gotop.sh
  fi

  if systemctl --user list-unit-files "syncthing.service" --state=disabled >/dev/null 2>&1; then
    systemctl --user enable syncthing.service
  fi

  echo "Configuring Gnome..."
  dconf write /org/gnome/desktop/interface/gtk-theme "'Adwaita-dark'"
  dconf write /org/gnome/desktop/interface/color-scheme "'prefer-dark'"
  dconf write /org/gnome/desktop/interface/enable-hot-corners "false"
  dconf write /org/gnome/desktop/interface/gtk-enable-primary-paste "false"
  dconf write /org/gnome/desktop/privacy/recent-files-max-age "1"
  dconf write /org/gnome/desktop/privacy/remove-old-trash-files "true"
  dconf write /org/gnome/desktop/privacy/remove-old-temp-files "true"
  dconf write /org/gnome/desktop/privacy/old-files-age "uint32 7"
  dconf write /org/gnome/desktop/input-sources/xkb-options "['lv3:ralt_switch', 'compose:caps', 'caps:escape_shifted_capslock']"
  dconf write /org/gnome/desktop/peripherals/mouse/accel-profile "'flat'"
  dconf write /org/gnome/desktop/wm/keybindings/show-desktop "['<Super>d']"
  dconf write /org/gnome/shell/keybindings/show-screenshot-ui "['<Shift><Super>s']"
  dconf write /org/gnome/shell/keybindings/screenshot "['Print']"
  dconf write /org/gnome/desktop/wm/preferences/button-layout "'appmenu:minimize,close'"
  dconf write /org/gnome/mutter/center-new-windows "true"
  dconf write /org/gnome/mutter/experimental-features "['scale-monitor-framebuffer']"
  dconf write /org/gnome/nautilus/preferences/default-folder-viewer "'list-view'"
  dconf write /org/gnome/shell/favorite-apps "['org.mozilla.firefox.desktop', 'org.gnome.Nautilus.desktop', 'org.gnome.TextEditor.desktop', 'org.gnome.Terminal.desktop']"
  dconf write /org/gtk/settings/file-chooser/sort-directories-first "true"
  dconf write /org/gnome/desktop/input-sources/mru-sources "[('xkb', 'us'), ('ibus', 'anthy'), ('xkb', 'de'), ('xkb', 'jp')]"
  dconf write /org/gnome/desktop/session/idle-delay "uint32 900"                          # Blank screen after 15 minutes inactivity
  dconf write /org/gnome/settings-daemon/plugins/power/sleep-inactive-ac-type "'suspend'" # Suspend after 2 hours idle
  dconf write /org/gnome/settings-daemon/plugins/power/sleep-inactive-ac-timeout "7200"
  dconf write /org/gnome/settings-daemon/plugins/color/night-light-temperature "uint32 4700"
  dconf write /org/gnome/settings-daemon/plugins/color/night-light-schedule-automatic "true"

  # Extensions
  dconf write /org/gnome/shell/disabled-extensions "['background-logo@fedorahosted.org']"
  dconf write /org/gnome/shell/enabled-extensions "['gsconnect@andyholmes.github.io', 'appindicatorsupport@rgcjonas.gmail.com', 'caffeine@patapon.info']"
  dconf write /org/gnome/shell/extensions/caffeine/show-notifications "false"
  dconf write /org/gnome/shell/extensions/caffeine/enable-fullscreen "false"

  # Defaults
  xdg-settings set default-web-browser org.mozilla.firefox.desktop

  echo "Making discord rpc work..."
  mkdir -p ~/.config/user-tmpfiles.d
  echo "L %t/discord-ipc-0 - - - - app/com.discordapp.Discord/discord-ipc-0" >$HOME/.config/user-tmpfiles.d/discord-rpc.conf
  systemctl --user enable --now systemd-tmpfiles-setup.service

  fcc_unlock() {
    sudo mkdir -p /etc/ModemManager/fcc-unlock.d
    sudo ln -sft /etc/ModemManager/fcc-unlock.d /usr/share/ModemManager/fcc-unlock.available.d/*
  }
  ask_yn "Activate fcc-unlock (needed for WWAN)" "fcc_unlock"

  configure_gpgsign

  echo "Installing Fonts..."
  mkdir -p $TMP/fonts

  curl -SL "https://www.fontsquirrel.com/fonts/download/gandhi-sans" -o $TMP/fonts/gandhi-sans.zip
  unzip -u -d $TMP/fonts $TMP/fonts/gandhi-sans.zip
  sudo mkdir -p $HOME/.local/share/fonts/gandhi-sans
  sudo cp $TMP/fonts/GandhiSans-*.otf $HOME/.local/share/fonts/gandhi-sans

  if [[ "$ID" == "fedora" ]]; then
    if [[ $VARIANT_ID == "silverblue" ]]; then
      sudo wget -P /etc/yum.repos.d/ https://copr.fedorainfracloud.org/coprs/hyperreal/better_fonts/repo/fedora-$(rpm -E %fedora)/dawid-better_fonts-fedora-$(rpm -E %fedora).repo
      rpm-ostree install fontconfig-font-replacements
    else
      sudo dnf -y copr enable hyperreal/better_fonts
      sudo dnf -y install fontconfig-font-replacements
    fi
  fi

  sudo fc-cache -v

  end
}

ServerInstall() {
  prepare
  download
  update

  echo "Making Symlinks..."
  force_symlink $DOT/git/.gitconfig $HOME/.gitconfig
  force_symlink $DOT/linux/fish/ $HOME/.config/fish
  force_symlink $DOT/linux/bash/bash_aliases $HOME/.bash_aliases
  force_symlink $DOT/linux/nvim/ $HOME/.config/nvim

  # Make sure bash loads bash_aliases
  grep -q ". ~/.bash_aliases" $HOME/.bashrc || echo -e "\nif [ -f ~/.bash_aliases ]; then\n    . ~/.bash_aliases\nfi\n" >>$HOME/.bashrc

  if [[ "$ID" == "rocky" ]]; then
    echo "Configuring ip_tables and iptable_mangle kernel modules to load at boot"
    echo ip_tables >/etc/modules-load.d/ip_tables.conf
    echo iptable_mangle >/etc/modules-load.d/iptable_mangle.conf
  fi

  echo "Installing packages..."

  install_pkgs ca-certificates cockpit cockpit-networkmanager cockpit-packagekit cockpit-pcp cockpit-storaged curl fastfetch fish git gnupg htop pcp unzip
  if install_pkgs fish; then sudo usermod --shell /bin/fish $USER; fi

  if type apt-get >/dev/null 2>&1; then
    sudo apt-get install libblockdev-crypto2 lsb-release neovim packagekit xfsprogs -y

  elif type dnf >/dev/null 2>&1; then
    if [[ $ID == "rocky" ]]; then
      echo "Installing EPEL, ELRepo and RPM Fusion"
      sudo dnf -y install epel-release
      sudo dnf -y install elrepo-release
      sudo dnf -y install https://mirrors.rpmfusion.org/free/el/rpmfusion-free-release-$(rpm -E %rocky).noarch.rpmhttps://mirrors.rpmfusion.org/nonfree/el/rpmfusion-nonfree-release-$(rpm -E %rocky).noarch.rpm

    elif [[ $ID == "ol" ]]; then
      echo "Installing EPEL and RPM Fusion"
      sudo dnf -y install epel-release
      sudo rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
      #sudo dnf -y install https://www.elrepo.org/elrepo-release-$(rpm -E %rhel).el$(rpm -E %rhel).elrepo.noarch.rpm # Broken on Oracle Linux
      sudo dnf -y install --nogpgcheck https://dl.fedoraproject.org/pub/epel/epel-release-latest-$(rpm -E %rhel).noarch.rpm
      sudo dnf -y install --nogpgcheck https://mirrors.rpmfusion.org/free/el/rpmfusion-free-release-$(rpm -E %rhel).noarch.rpm https://mirrors.rpmfusion.org/nonfree/el/rpmfusion-nonfree-release-$(rpm -E %rhel).noarch.rpm

    elif [[ $ID == "fedora" ]]; then
      echo "Installing RPM Fusion"
      sudo dnf -y install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
    fi

    sudo dnf -y groupupdate core
    sudo dnf -y install dnf-automatic dnf-plugins-core dnf-utils PackageKit wireguard-tools
    sudo dnf -y install neovim

    if sudo dnf -y install fish; then
      sudo usermod --shell /bin/fish $USER
    fi
  fi

  configure_gpgsign

  end
}

Tools() {
  while true; do
    clear
    echo -e " _   _ _ _     ____        _    __ _ _\n| \ | (_| |___|  _ \  ___ | |_ / _(_| | ___ ___\n|  \| | | / __| | | |/ _ \| __| |_| | |/ _ / __|\n| |\  | | \__ | |_| | (_) | |_|  _| | |  __\__ \\n|_| \_|_|_|___|____/ \___/ \__|_| |_|_|\___|___/"
    echo
    select s in "Setup distrobox" "Install docker" "Install gotop" "Install ESO symlink" "Install MBTL symlink" "Install osu symlinks" "Exit"; do
      case $s in
      "Setup distrobox")
        echo "Creating distroboxes..."
        ask_yn "Continue" "" "exit"
        distrobox create -Y -n my-distrobox -i fedora-toolbox:37 --init-hooks "curl -s -o- https://raw.githubusercontent.com/Nalsai/dotfiles/main/linux/scripts/distrobox-fedora.sh | bash"
        distrobox create -Y -n arch -i archlinux --init-hooks "curl -s -o- https://raw.githubusercontent.com/Nalsai/dotfiles/main/linux/scripts/distrobox-arch.sh | bash"
        read -t 3 -p "Done!"
        break
        ;;
      "Install docker")
        echo "Installing docker..."
        ask_yn "Continue" "" "exit"
        bash <(curl -Ss https://raw.githubusercontent.com/Nalsai/dotfiles/main/linux/scripts/install_docker.sh) -c
        $DOT/linux/scripts/install_docker.sh
        ask_yn "Enable Docker service" "sudo systemctl enable docker --now"
        read -t 3 -p "Done!"
        break
        ;;
      "Install gotop")
        echo "Installing gotop..."
        ask_yn "Continue" "" "exit"
        bash <(curl -Ss https://raw.githubusercontent.com/Nalsai/dotfiles/main/linux/scripts/install_gotop.sh) -c
        read -t 3 -p "Done!"
        break
        ;;
      "Install ESO symlink")
        echo "Installing ESO symlink..."
        echo "Make sure you opened steam at least once."
        ask_yn "Continue" "" "exit"
        STEAMSHARE=$HOME/.local/share/Steam
        if [[ $ID == "fedora" && $VARIANT_ID == "silverblue" ]]; then STEAMSHARE=$HOME/.var/app/com.valvesoftware.Steam/.local/share/Steam; fi
        mkdir -p "$STEAMSHARE/steamapps/compatdata/306130/pfx/drive_c/users/steamuser/Documents/Elder Scrolls Online"
        force_symlink "$STEAMSHARE/steamapps/compatdata/306130/pfx/drive_c/users/steamuser/Documents/Elder Scrolls Online" "$HOME/Documents/Elder Scrolls Online"
        read -t 3 -p "Done!"
        break
        ;;
      "Install MBTL symlink")
        echo "Installing MBTL symlink..."
        echo "Make sure you opened steam at least once."
        ask_yn "Continue" "" "exit"
        STEAMSHARE=$HOME/.local/share/Steam
        if [[ $ID == "fedora" && $VARIANT_ID == "silverblue" ]]; then STEAMSHARE=$HOME/.var/app/com.valvesoftware.Steam/.local/share/Steam; fi
        force_symlink "$HOME/Sync/Files/Documents/Melty Blood Type Lumina Save" "$STEAMSHARE/steamapps/common/MELTY BLOOD TYPE LUMINA/winsave/228783925"
        read -t 3 -p "Done!"
        break
        ;;
      "Install osu symlinks")
        echo "Installing osu symlinks..."
        ask_yn "Continue" "" "exit"
        echo "Giving osu access to $HOME/Sync/Files/osu..."
        sudo flatpak override sh.ppy.osu --filesystem="$HOME/Sync/Files/osu"
        echo "Installing symlinks..."
        force_symlink $HOME/Sync/Files/osu/files $HOME/.var/app/sh.ppy.osu/data/osu/files
        force_symlink $HOME/Sync/Files/osu/client.realm $HOME/.var/app/sh.ppy.osu/data/osu/client.realm
        read -t 3 -p "Done!"
        break
        ;;
      "Exit")
        break 2
        ;;
      esac
    done
  done
}

while true; do
  clear
  echo -e " _   _ _ _     ____        _    __ _ _\n| \ | (_| |___|  _ \  ___ | |_ / _(_| | ___ ___\n|  \| | | / __| | | |/ _ \| __| |_| | |/ _ / __|\n| |\  | | \__ | |_| | (_) | |_|  _| | |  __\__ \\n|_| \_|_|_|___|____/ \___/ \__|_| |_|_|\___|___/"
  echo
  select s in "Desktop" "Server" "Tools" "Exit"; do
    case $s in
    "Desktop")
      FullInstall
      exit
      ;;
    "Server")
      ServerInstall
      exit
      ;;
    "Tools")
      Tools
      break
      ;;
    "Exit")
      exit
      ;;
    esac
  done
done
