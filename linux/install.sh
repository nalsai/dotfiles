#!/bin/bash

clear
echo -e " _   _ _ _     ____        _    __ _ _\n| \ | (_| |___|  _ \  ___ | |_ / _(_| | ___ ___\n|  \| | | / __| | | |/ _ \| __| |_| | |/ _ / __|\n| |\  | | \__ | |_| | (_) | |_|  _| | |  __\__ \\n|_| \_|_|_|___|____/ \___/ \__|_| |_|_|\___|___/"
echo

force_symlink() {
  mkdir -p "$(dirname "$2")"
  rm -rf "$2" > /dev/null 2>&1
  ln -sf "$1" "$2"
}

ask_yn() {
  echo -n "$1? [y/n]: "
  old_stty_cfg=$(stty -g)
  stty raw -echo
  answer=$( while ! head -c 1 | grep -i "[ny]"; do true; done )
  stty $old_stty_cfg
  if echo "$answer" | grep -iq "^y" ;then
    echo y
    $2
  else
    echo n
    $3
  fi
}

install_pkgs() {
  if type "$1" >/dev/null 2>&1; then
    if   type apt-get >/dev/null 2>&1; then sudo apt-get install "$@" -y
    elif type dnf >/dev/null 2>&1;     then sudo dnf -y install "$@"
    elif type pacman >/dev/null 2>&1;  then sudo pacman -S "$@" fi
  fi
}

uninstall_pkgs() {
  if type "$1" >/dev/null 2>&1; then
    if   type apt-get >/dev/null 2>&1; then sudo apt-get remove "$@" -y
    elif type dnf >/dev/null 2>&1;     then sudo dnf -y remove "$@"
    elif type pacman >/dev/null 2>&1;  then sudo pacman -R "$@" fi
  fi
}

install_optional_flatpaks() {
  optional_flatpaks=""
  for var in "$@"; do
    echo -n "Install $var? [y/n]: "
    old_stty_cfg=$(stty -g)
    stty raw -echo
    answer=$( while ! head -c 1 | grep -i "[ny]"; do true; done )
    stty $old_stty_cfg
    if echo "$answer" | grep -iq "^y" ;then
      echo y
      optional_flatpaks="$optional_flatpaks $var"
    else
      echo n
    fi
  done
  [ -z "$optional_flatpaks" ] || sudo flatpak -y install flathub$optional_flatpaks
}

configure_gpgsign() {
  echo -n "Disable git gpgsign? [y/n]: "
  old_stty_cfg=$(stty -g)
  stty raw -echo
  answer=$( while ! head -c 1 | grep -i "[ny]"; do true; done )
  stty $old_stty_cfg
  if echo "$answer" | grep -iq "^y" ;then
    echo y
    git config --global commit.gpgsign false
  else
    echo n
      echo -n "Change git signingkey? [y/n]: "
      old_stty_cfg=$(stty -g)
      stty raw -echo
      answer=$( while ! head -c 1 | grep -i "[ny]"; do true; done )
      stty $old_stty_cfg
      if echo "$answer" | grep -iq "^y" ;then
        echo y
        echo "Listing keys:"
        echo "gpg --list-secret-keys --keyid-format=long"
        gpg --list-secret-keys --keyid-format=long
        echo -n "GPG key ID: "
        read keyID
        git config --global user.signingkey "$keyID"
      else
        echo n
      fi
  fi
}


prepare() {
  DOT="$HOME/.dotfiles"
  TMP="/tmp/ZG90ZmlsZXM"
  mkdir -p $TMP
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
      # TODO: git pull from main origin
    else
      rm -rf $DOT > /dev/null 2>&1
      echo -n "Clone using ssh or https? [s/h]: "
      old_stty_cfg=$(stty -g)
      stty raw -echo
      answer=$( while ! head -c 1 | grep -i "[sh]"; do true; done )
      stty $old_stty_cfg
      if echo "$answer" | grep -iq "^s" ;then
        echo s
        rm -rf $DOT > /dev/null 2>&1
        if ! git clone git@github.com:Nalsai/dotfiles.git $DOT; then
          echo "An error occured while cloning!"
          echo "Did you setup your git ssh key?"
          exit 1
        fi
      else
        echo h
        rm -rf $DOT > /dev/null 2>&1
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
    rm -rf $DOT > /dev/null 2>&1
    if ! mv $TMP/dotfiles-main $DOT; then
      echo "An error occured while moving the dotfiles into place!"
      exit 1
    fi
  }

  ask_yn "Download with git" "download_git" "download_zip"
  ask_yn "Install symlink to Documents" "install_pkgs xdg-user-dirs && force_symlink $DOT "$(xdg-user-dir DOCUMENTS)/dotfiles"" 

  chmod +x $DOT/linux/connect-ssh.sh
  chmod +x $DOT/linux/install.sh
  chmod +x $DOT/linux/update-system.sh
  chmod +x $DOT/linux/scripts/install_docker.sh
  chmod +x $DOT/linux/scripts/install_gotop.sh
  chmod +x $DOT/linux/shortcuts/install-shortcuts.sh
}

update() {
  echo Updating System...
  $DOT/linux/update-system.sh
}

end() {
  rm -rf $TMP > /dev/null 2>&1
  echo Done!
}

FullInstall()
{
  echo "This script is work in progress and supports Fedora."
  echo "It partially supports Arch, Debian and Derivatives."
  ask_yn "Continue" "" "exit 130"
  prepare
  download
  update

  echo "Making Symlinks..."
  force_symlink $DOT/mpv/mpv $HOME/.var/app/io.mpv.Mpv/config/mpv
  force_symlink $DOT/vscode/code-flags.conf $HOME/.config/code-flags.conf # sadly this only works on arch
  force_symlink $DOT/linux/chromium-flags.conf $HOME/.var/app/com.github.Eloston.UngoogledChromium/config/chromium-flags.conf
  force_symlink $DOT/git/.gitconfig $HOME/.gitconfig
  force_symlink $DOT/linux/fish/ $HOME/.config/fish
  force_symlink $DOT/linux/bash/bash_aliases $HOME/.bash_aliases
  force_symlink $DOT/linux/nvim/ $HOME/.config/nvim
  #force_symlink $DOT/mpv/mpv $HOME/.config/mpv
  #force_symlink $DOT/mpv/mpv-minimal $HOME/.var/app/io.github.celluloid_player.Celluloid/config/celluloid
  #force_symlink $DOT/mpv/jellyfin-mpv-shim $HOME/.config/plex-mpv-shim
  #force_symlink $DOT/mpv/jellyfin-mpv-shim $HOME/.var/app/com.github.iwalton3.jellyfin-mpv-shim/config/jellyfin-mpv-shim
  #force_symlink $DOT/linux/chromium-flags.conf $HOME/.var/app/com.google.Chrome/config/chrome-flags.conf
  #force_symlink $DOT/linux/chromium-flags.conf $HOME/.var/app/org.chromium.Chromium/config/chromium-flags.conf
  #force_symlink $DOT/vscode/settings.json $HOME/.config/Code/User/settings.json
  #force_symlink $DOT/vscode/keybindings.json $HOME/.config/Code/User/keybindings.json
  #force_symlink $DOT/vscode/settings.json $HOME/.config/code-oss/User/settings.json
  #force_symlink $DOT/vscode/keybindings.json $HOME/.config/code-oss/User/keybindings.json
  #force_symlink $DOT/vscode/settings.json "$HOME/.config/Code - OSS/User/settings.json"
  #force_symlink $DOT/vscode/keybindings.json "$HOME/.config/Code - OSS/User/keybindings.json"

  # make sure bash loads bash_aliases
  grep -q ". ~/.bash_aliases" $HOME/.bashrc || echo -e "\nif [ -f ~/.bash_aliases ]; then\n    . ~/.bash_aliases\nfi\n" >> $HOME/.bashrc

  # New File templates
  \cp -r $DOT/linux/templates/** $(xdg-user-dir TEMPLATES)

  # Flatpak app configs
  cp -f $DOT/linux/io.github.Foldex.AdwSteamGtk/keyfile $HOME/.var/app/io.github.Foldex.AdwSteamGtk/config/glib-2.0/settings/keyfile

  echo "Installing Flatpaks..."
  install_pkgs flatpak
  [ type apt-get >/dev/null 2>&1 ] && apt-get install gnome-software-plugin-flatpak -y

  sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
	sudo flatpak remote-modify --enable flathub         # enable flathub on fedora
  sudo flatpak remote-modify --no-filter flathub      # and remove filter
  sudo flatpak remote-modify --title=Flathub flathub
  sudo flatpak remote-modify --comment="Central repository of Flatpak applications" flathub
  sudo flatpak remote-modify --description="Central repository of Flatpak applications" flathub

  sudo flatpak -y install flathub com.github.tchx84.Flatseal io.mpv.Mpv org.gimp.GIMP org.gnome.TextEditor org.gnome.eog \
    org.libreoffice.LibreOffice org.mozilla.firefox

  sudo flatpak -y install flathub com.belmoussaoui.Decoder com.discordapp.Discord com.github.Eloston.UngoogledChromium \
    com.github.iwalton3.jellyfin-media-player com.github.jeromerobert.pdfarranger com.github.liferooter.textpieces com.github.qarmin.czkawka \
    com.github.qarmin.szyszka  com.leinardi.gst com.mattjakeman.ExtensionManager com.rawtherapee.RawTherapee \
    com.skype.Client com.usebottles.bottles fr.romainvigier.MetadataCleaner io.github.f3d_app.f3d io.github.Foldex.AdwSteamGtk io.github.seadve.Kooha

  sudo flatpak -y install flathub net.ankiw3eb.Anki net.mediaarea.MediaInfo net.sourceforge.Hugin nl.hjdskes.gcolor3 \
    org.blender.Blender org.bunkus.mkvtoolnix-gui org.deluge_torrent.deluge org.gnome.Builder org.gnome.Firmware \
    org.gnome.World.PikaBackup org.gnome.font-viewer org.gnome.gitlab.YaLTeR.Identity org.gnome.meld \
    org.gnome.seahorse.Application org.gtk.Gtk3theme.adw-gtk3-dark org.inkscape.Inkscape org.nomacs.ImageLounge re.sonny.Commit 

  sudo flatpak -y install --reinstall flathub org.freedesktop.Platform.Locale//22.08    # Reinstall org.freedesktop.Platform.Locale for spell checking in different languages 
  sudo flatpak override com.usebottles.bottles --filesystem="$HOME/Apps/Bottles"        # allow Bottles to access $HOME/Apps/Bottles
  sudo flatpak override --socket=wayland --env=MOZ_ENABLE_WAYLAND=1 org.mozilla.firefox # Firefox Wayland
  sudo flatpak override --device=all org.mozilla.firefox                                # Firefox U2F access

  sudo flatpak remote-add --if-not-exists NilsFlatpakRepo https://flatpak.nils.moe/repo/NilsFlatpakRepo.flatpakrepo
  sudo flatpak -y install NilsFlatpakRepo org.wangqr.Aegisub cc.spek.Spek com.github.mkv-extractor-qt5 gg.minion.Minion net.sourceforge.gMKVExtractGUI
  sudo flatpak -y install flathub org.freedesktop.Sdk.Extension.mono6//22.08 # required for net.sourceforge.gMKVExtractGUI

  install_optional_flatpaks com.rafaelmardojai.WebfontKitGenerator org.gnome.Evolution com.wps.Office com.calibre_ebook.calibre rocks.koreader.KOReader sh.ppy.osu net.cubers.assault.AssaultCube net.supertuxkart.SuperTuxKart com.raggesilver.BlackBox com.github.Anuken.Mindustry

  ask_yn "Add Elementary AppCenter flatpak remote and install Ensembles" "sudo flatpak remote-add --if-not-exists ElementaryAppCenter https://flatpak.elementary.io/repo.flatpakrepo && sudo flatpak -y install ElementaryAppCenter com.github.subhadeepjasu.ensembles"
  ask_yn "Install Mothership Defender 2 and Tactical Math Returns" "sudo flatpak -y install NilsFlatpakRepo com.DaRealRoyal.TacticalMathReturns de.Nalsai.MothershipDefender2"

  echo "Installing other packages..."
  if type dnf >/dev/null 2>&1; then
    sudo dnf -y install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
    sudo dnf -y groupupdate core

    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
    sudo sh -c "echo -e '[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc' > /etc/yum.repos.d/vscode.repo"
    sudo dnf -y install code

    sudo dnf -y install gnome-shell-extension-appindicator gnome-shell-extension-caffeine gnome-shell-extension-gsconnect gnome-shell-extension-sound-output-device-chooser --setopt=install_weak_deps=false
    sudo dnf -y install cargo dconf flatpak-builder gnome-tweaks hugo mangohud ocrmypdf openssl librsvg2-tools lutris pandoc perl-Image-ExifTool radeontop rust rustfmt steam syncthing tesseract-langpack-deu texlive wireguard-tools yt-dlp
    sudo dnf -y group install "Virtualization"

    sudo dnf -y copr enable nickavem/adw-gtk3
    sudo dnf -y install adw-gtk3
  fi
  install_pkgs curl fastfetch ffmpeg fish git htop neovim unzip
  if install_pkgs fish; then sudo usermod --shell /bin/fish $USER fi

  $DOT/linux/scripts/install_docker.sh
  ask_yn "Enable Docker service" "sudo systemctl enable docker --now"

  echo "Uninstalling replaced packages..."
  uninstall_pkgs firefox eog gnome-font-viewer libreoffice libreoffice-*

  if type dnf >/dev/null 2>&1; then
    sudo dnf -y group remove LibreOffice
  fi

  if systemctl --user list-unit-files "syncthing.service" --state=disabled >/dev/null 2>&1; then
    systemctl --user enable syncthing.service
  fi

  $DOT/linux/scripts/install_gotop.sh


  echo "Configuring Apps..."

  echo "Configuring Gnome..."
  if [ -d "/usr/share/themes/adw-gtk3-dark" ] || [ -d "$HOME/.local/share/themes/adw-gtk3-dark" ]; then
    dconf write /org/gnome/desktop/interface/gtk-theme "'adw-gtk3-dark'"
  else 
    dconf write /org/gnome/desktop/interface/gtk-theme "'Adwaita-dark'"
  fi
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
  dconf write /org/gnome/shell/keybindings/show-screenshot-ui  "['<Shift><Super>s']"
  dconf write /org/gnome/shell/keybindings/screenshot  "['Print']"
  dconf write /org/gnome/desktop/wm/preferences/button-layout "'appmenu:minimize,close'"
  dconf write /org/gnome/mutter/center-new-windows "true"
  dconf write /org/gnome/mutter/experimental-features "['scale-monitor-framebuffer']"
  dconf write /org/gnome/shell/favorite-apps "['org.mozilla.firefox.desktop', 'org.gnome.Nautilus.desktop', 'org.gnome.TextEditor.desktop', 'org.gnome.Terminal.desktop']"
  dconf write /org/gtk/settings/file-chooser/sort-directories-first "true"
  dconf write /org/gnome/desktop/input-sources/mru-sources "[('xkb', 'us'), ('ibus', 'anthy'), ('xkb', 'de'), ('xkb', 'jp')]"
  dconf write /org/gnome/desktop/session/idle-delay "uint32 900" # blank screen after 15 minutes inactivity
  dconf write /org/gnome/settings-daemon/plugins/power/sleep-inactive-ac-type "'suspend'" # suspend after 2 hours idle
  dconf write /org/gnome/settings-daemon/plugins/power/sleep-inactive-ac-timeout "7200"
  dconf write /org/gnome/settings-daemon/plugins/color/night-light-temperature "uint32 4700"
  dconf write /org/gnome/settings-daemon/plugins/color/night-light-schedule-automatic "true"

  # extensions
  dconf write /org/gnome/shell/disabled-extensions "['background-logo@fedorahosted.org']"
  dconf write /org/gnome/shell/enabled-extensions "['gsconnect@andyholmes.github.io', 'appindicatorsupport@rgcjonas.gmail.com', 'caffeine@patapon.info', 'sound-output-device-chooser@kgshank.net']"
  dconf write /org/gnome/shell/extensions/sound-output-device-chooser/hide-on-single-device "true"
  dconf write /org/gnome/shell/extensions/sound-output-device-chooser/show-profiles "false"
  dconf write /org/gnome/shell/extensions/sound-output-device-chooser/expand-volume-menu "false"
  dconf write /org/gnome/shell/extensions/sound-output-device-chooser/cannot-activate-hidden-device "false"
  dconf write /org/gnome/shell/extensions/caffeine/show-notifications "false"
  dconf write /org/gnome/shell/extensions/caffeine/enable-fullscreen "false"

  echo "Making discord rpc work..."
  mkdir -p ~/.config/user-tmpfiles.d
  echo "L %t/discord-ipc-0 - - - - app/com.discordapp.Discord/discord-ipc-0" > ~/.config/user-tmpfiles.d/discord-rpc.conf
  systemctl --user enable --now systemd-tmpfiles-setup.service

  echo "Installing Adwaita for Steam ..."

  git clone https://github.com/tkashkin/Adwaita-for-Steam $TMP/Adwaita-for-Steam
  cd $TMP/Adwaita-for-Steam
  ./install.py -c adwaita -w full -we login/hover_qr -we library/hide_whats_new
  rm -rf $TMP/Adwaita-for-Steam

  configure_gpgsign

  echo "Installing Fonts..."
  mkdir -p $TMP/fonts

  curl -SL "https://www.fontsquirrel.com/fonts/download/gandhi-sans" -o $TMP/fonts/gandhi-sans.zip
  unzip -u -d $TMP/fonts $TMP/fonts/gandhi-sans.zip
  sudo mkdir /usr/share/fonts/gandhi-sans
  sudo cp $TMP/fonts/GandhiSans-*.otf /usr/share/fonts/gandhi-sans

  # TODO
  
  sudo fc-cache -v

  end
}

MinimalInstall() {
  echo "This script is work in progress and supports Arch, Debian, Fedora and derivatives."
  ask_yn "Continue" "" "exit 130"
  prepare
  download
  update

  install_pkgs curl fastfetch ffmpeg fish git htop neovim unzip
  if install_pkgs fish; then sudo usermod --shell /bin/fish $USER fi
  # TODO

  end
}

ServerInstall() {
  echo "This script is work in progress and will support Raspbian, Armbian, Debian, Fedora and RockyLinux."
  ask_yn "Continue" "" "exit 130"
  prepare
  download
  update

  echo "Making Symlinks..."
  force_symlink $DOT/git/.gitconfig $HOME/.gitconfig
  force_symlink $DOT/linux/fish/ $HOME/.config/fish
  force_symlink $DOT/linux/bash/bash_aliases $HOME/.bash_aliases
  force_symlink $DOT/linux/nvim/ $HOME/.config/nvim

  # make sure bash loads bash_aliases
  grep -q ". ~/.bash_aliases" $HOME/.bashrc || echo -e "\nif [ -f ~/.bash_aliases ]; then\n    . ~/.bash_aliases\nfi\n" >> $HOME/.bashrc

  [[ -f /etc/os-release ]] && . /etc/os-release
  if [[ "$ID" == "rocky" ]]; then
    echo "Configuring ip_tables and iptable_mangle kernel modules to load at boot"
    echo ip_tables > /etc/modules-load.d/ip_tables.conf
    echo iptable_mangle > /etc/modules-load.d/iptable_mangle.conf
  fi

  echo "Installing packages..."

  install_pkgs ca-certificates cockpit cockpit-networkmanager cockpit-packagekit cockpit-pcp cockpit-storaged curl fastfetch fish git gnupg htop pcp unzip  # neovim needs epel

  if type apt-get >/dev/null 2>&1; then
    sudo apt-get install libblockdev-crypto2 lsb-release neovim packagekit xfsprogs -y
    if sudo apt-get install fish -y; then
      sudo usermod --shell /bin/fish $USER
    fi

  elif type dnf >/dev/null 2>&1; then
    ID=
    [[ -f /etc/os-release ]] && . /etc/os-release
    if [[ "$ID" == "rocky" ]]; then
      echo "Installing EPEL, ELRepo and RPM Fusion"
      sudo dnf -y install epel-release
      sudo dnf -y install elrepo-release
      sudo dnf -y install https://mirrors.rpmfusion.org/free/el/rpmfusion-free-release-$(rpm -E %rocky).noarch.rpmhttps://mirrors.rpmfusion.org/nonfree/el/rpmfusion-nonfree-release-$(rpm -E %rocky).noarch.rpm

    elif [[ "$ID" == "ol" ]]; then
      echo "Installing EPEL and RPM Fusion"
      sudo dnf -y install epel-release
      sudo rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org 
      #sudo dnf -y install https://www.elrepo.org/elrepo-release-$(rpm -E %rhel).el$(rpm -E %rhel).elrepo.noarch.rpm
      sudo dnf -y install --nogpgcheck https://dl.fedoraproject.org/pub/epel/epel-release-latest-$(rpm -E %rhel).noarch.rpm
      sudo dnf -y install --nogpgcheck https://mirrors.rpmfusion.org/free/el/rpmfusion-free-release-$(rpm -E %rhel).noarch.rpm https://mirrors.rpmfusion.org/nonfree/el/rpmfusion-nonfree-release-$(rpm -E %rhel).noarch.rpm

    elif [[ "$ID" == "fedora" ]]; then
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
  $DOT/linux/scripts/install_docker.sh
  sudo systemctl enable docker --now

  end
}

Tools() {
  while true; do
    echo
    echo "Please select what to do:"
    select s in "install shortcuts" "connect to ssh server" "update system" "clean package caches" "install docker" "install gotop" "exit"; do
      case $s in
      "install shortcuts")
        bash <(curl -Ss https://raw.githubusercontent.com/Nalsai/dotfiles/main/linux/shortcuts/install-shortcuts.sh)
        break
        ;;
      "connect to ssh server")
        bash <(curl -Ss https://raw.githubusercontent.com/Nalsai/dotfiles/main/linux/connect-ssh.sh)
        break
        ;;
      "update system")
        bash <(curl -Ss https://raw.githubusercontent.com/Nalsai/dotfiles/main/linux/update-system.sh)
        break
        ;;
      "clean package caches")
        bash <(curl -Ss https://raw.githubusercontent.com/Nalsai/dotfiles/main/linux/update-system.sh) -c
        break
        ;;
      "install docker")
        bash <(curl -Ss https://raw.githubusercontent.com/Nalsai/dotfiles/main/linux/scripts/install_docker.sh) -c
        $DOT/linux/scripts/install_docker.sh
        ask_yn "Enable Docker service" "sudo systemctl enable docker --now"
        break
        ;;
      "install gotop")
        bash <(curl -Ss https://raw.githubusercontent.com/Nalsai/dotfiles/main/linux/scripts/install_gotop.sh) -c
        break
        ;;
      "exit")
        exit
        break
        ;;
      esac
    done
  done
}

select s in "full installation" "minimal installation" "server installation" "tools"; do
  case $s in
  "full installation")
    FullInstall
    break
    ;;
  "minimal installation")
    MinimalInstall
    break
    ;;
  "server installation")
    ServerInstall
    break
    ;;
  "tools")
    Tools
    break
    ;;
  esac
done
