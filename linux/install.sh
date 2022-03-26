#!/bin/bash

clear
echo -e " _   _ _ _     ____        _    __ _ _\n| \ | (_| |___|  _ \  ___ | |_ / _(_| | ___ ___\n|  \| | | / __| | | |/ _ \| __| |_| | |/ _ / __|\n| |\  | | \__ | |_| | (_) | |_|  _| | |  __\__ \\n|_| \_|_|_|___|____/ \___/ \__|_| |_|_|\___|___/"
echo

prepare() {
  DOT="$HOME/.dotfiles"
  TMP="/tmp/ZG90ZmlsZXM"
  mkdir -p $TMP
}

end() {
  rm -rf $TMP > /dev/null 2>&1
  echo Done!
}

FullInstall()
{
  echo "This script is work in progress and supports Fedora."
  echo "It partially supports Arch, Debian and Derivatives."
  echo -n "Continue? [y/n]: "
  old_stty_cfg=$(stty -g)
  stty raw -echo
  answer=$( while ! head -c 1 | grep -i '[ny]' ;do true ;done )
  stty $old_stty_cfg
  if echo "$answer" | grep -iq "^y" ;then
    echo y
  else
    echo n
    exit 130
  fi

  prepare

  echo Making sure everything needed for setup is installed...
  if type apt-get >/dev/null 2>&1; then
    sudo apt-get install curl git unzip xdg-user-dirs -y
  elif type dnf >/dev/null 2>&1; then
    sudo dnf -y install curl git unzip xdg-user-dirs
  elif type pacman >/dev/null 2>&1; then
    sudo pacman -S curl git unzip xdg-user-dirs
  fi

  echo -n "Install to Documents with git? [y/n]: "
  old_stty_cfg=$(stty -g)
  stty raw -echo
  answer=$( while ! head -c 1 | grep -i '[ny]' ;do true ;done )
  stty $old_stty_cfg
  if echo "$answer" | grep -iq "^y" ;then
    echo y
    cd "$(xdg-user-dir DOCUMENTS)"
    rm -rf "$(xdg-user-dir DOCUMENTS)/dotfiles" > /dev/null 2>&1
    echo -n "Clone using ssh or https? [s/h]: "
    old_stty_cfg=$(stty -g)
    stty raw -echo
    answer=$( while ! head -c 1 | grep -i '[sh]' ;do true ;done )
    stty $old_stty_cfg
    if echo "$answer" | grep -iq "^s" ;then
      echo s
      if ! git clone git@github.com:Nalsai/dotfiles.git; then
        echo An error occured!
        echo You may need to setup your git ssh key first to clone over ssh.
        exit 1
      fi
    else
      echo h
      if ! git clone https://github.com/Nalsai/dotfiles.git; then
        echo An error occured!
        exit 1
      fi
    fi
    rm -rf $DOT > /dev/null 2>&1
    ln -sf "$(xdg-user-dir DOCUMENTS)/dotfiles" $DOT
  else
    echo n
    echo Downloading Dotfiles...
    curl -SL "https://github.com/Nalsai/dotfiles/archive/refs/heads/main.zip" -o $TMP/dotfiles.zip
    unzip -u -d $TMP $TMP/dotfiles.zip
    rm -rf $DOT > /dev/null 2>&1
    mv $TMP/dotfiles-main $DOT
  fi

  chmod +x $DOT/linux/connect-ssh.sh
  chmod +x $DOT/linux/install.sh
  chmod +x $DOT/linux/update-system.sh
  chmod +x $DOT/linux/scripts/install_docker.sh
  chmod +x $DOT/linux/scripts/install_gotop.sh
  chmod +x $DOT/linux/shortcuts/install-shortcuts.sh


  echo Updating System...
  $DOT/linux/update-system.sh

  echo Making Symlinks...
  # mpv
  mkdir -p $HOME/.var/app/io.mpv.Mpv/config                     # make parent folder if not exists
  rm -rf $HOME/.var/app/io.mpv.Mpv/config/mpv > /dev/null 2>&1  # remove folder to be symlinked if exists
  ln -sf $DOT/mpv/mpv $HOME/.var/app/io.mpv.Mpv/config/mpv      # make symlink
  #$HOME/.config/plex-mpv-shim
  #$HOME/.var/app/com.github.iwalton3.jellyfin-mpv-shim/config/jellyfin-mpv-shim
  #$HOME/.var/app/io.github.celluloid_player.Celluloid/config/celluloid
  #$HOME/.config/mpv

  # Visual Studio Code settings.json and keybindings.json
  mkdir -p $HOME/.config/Code/User
  ln -sf $DOT/vscode/settings.json $HOME/.config/Code/User/settings.json
  ln -sf $DOT/vscode/keybindings.json $HOME/.config/Code/User/keybindings.json
  #mkdir -p $HOME/.config/code-oss/User
  #ln -sf $DOT/vscode/settings.json $HOME/.config/code-oss/User/settings.json
  #ln -sf $DOT/vscode/keybindings.json $HOME/.config/code-oss/User/keybindings.json
  #mkdir -p "$HOME/.config/Code - OSS/User"
  #ln -sf $DOT/vscode/settings.json "$HOME/.config/Code - OSS/User/settings.json"
  #ln -sf $DOT/vscode/keybindings.json "$HOME/.config/Code - OSS/User/keybindings.json"

  # Chrom(e|ium) dark mode and Wayland
  mkdir -p $HOME/.var/app/com.google.Chrome/config/chrome-flags.conf
  ln -sf $DOT/linux/chromium-flags.conf $HOME/.var/app/com.google.Chrome/config/chrome-flags.conf
  mkdir -p $HOME/.var/app/org.chromium.Chromium/config/chromium-flags.conf
  ln -sf $DOT/linux/chromium-flags.conf $HOME/.var/app/org.chromium.Chromium/config/chromium-flags.conf
  mkdir -p $HOME/.var/app/com.github.Eloston.UngoogledChromium/config/chromium-flags.conf
  ln -sf $DOT/linux/chromium-flags.conf $HOME/.var/app/com.github.Eloston.UngoogledChromium/config/chromium-flags.conf

  # .gitconfig
  ln -sf $DOT/git/.gitconfig $HOME/.gitconfig

  # fish
  rm -rf $HOME/.config/fish > /dev/null 2>&1
  ln -sf $DOT/linux/fish/ $HOME/.config/fish
  
  # neovim
  rm -rf $HOME/.config/nvim > /dev/null 2>&1
  ln -sf $DOT/linux/nvim/ $HOME/.config/nvim

  # Templates
  \cp -r $DOT/linux/templates/** $(xdg-user-dir TEMPLATES)

  echo Installing Flatpaks...
  if type apt-get >/dev/null 2>&1; then
    echo Flatpak needs to be installed first...
    sudo apt-get install flatpak gnome-software-plugin-flatpak -y
  fi
  flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
  flatpak remote-add --if-not-exists NilsFlatpakRepo https://flatpak.nils.moe/NilsFlatpakRepo.flatpakrepo
  flatpak install flathub com.belmoussaoui.Decoder com.discordapp.Discord com.github.gi_lom.dialect com.github.huluti.Curtail com.github.iwalton3.jellyfin-media-player com.github.johnfactotum.Foliate com.github.kmwallio.thiefmd com.github.liferooter.textpieces com.github.tchx84.Flatseal com.leinardi.gst com.mattjakeman.ExtensionManager com.skype.Client com.usebottles.bottles dev.alextren.Spot io.github.seadve.Kooha io.mpv.Mpv net.ankiweb.Anki net.mediaarea.MediaInfo net.sourceforge.Hugin nl.hjdskes.gcolor3 org.bunkus.mkvtoolnix-gui org.gnome.Builder org.gnome.TextEditor org.gnome.eog org.gnome.font-viewer org.gnome.gitlab.YaLTeR.Identity org.gnome.gitlab.somas.Apostrophe org.inkscape.Inkscape org.libreoffice.LibreOffice org.gnome.Extensions org.deluge_torrent.deluge org.blender.Blender io.github.celluloid_player.Celluloid org.gnome.meld org.gimp.GIMP org.nomacs.ImageLounge org.gnome.seahorse.Application org.mozilla.firefox org.gnome.Evolution
  flatpak install NilsFlatpakRepo org.wangqr.Aegisub cc.spek.Spek com.github.mkv-extractor-qt5 net.sourceforge.gMKVExtractGUI
  #com.calibre_ebook.calibre com.github.qarmin.czkawka com.github.qarmin.szyszka com.katawa_shoujo.KatawaShoujo com.rafaelmardojai.WebfontKitGenerator fr.romainvigier.MetadataCleaner info.febvre.Komikku io.github.ciromattia.kcc io.github.hakuneko.HakuNeko org.gnome.Connections org.gnome.Epiphany org.kde.krita org.pitivi.Pitivi

  # allow Bottles to access $HOME/Apps/Bottles
  sudo flatpak override com.usebottles.bottles --filesystem="$HOME/Apps/Bottles"

  # Firefox Wayland
  sudo flatpak override --socket=wayland --env=MOZ_ENABLE_WAYLAND=1 org.mozilla.firefox

  flatpak info org.libreoffice.LibreOffice
  echo ""
  echo ""
  echo "If LibreOffice uses a different Runtime, the script needs to be updated"
  echo "Reinstalling the Locale installs all Locales, instead of just the main one."
  echo "This is needed for Spell Checking in other languages than the main one."
  echo "Reinstall org.freedesktop.Platform.Locale//21.08? [y/n]: "
  old_stty_cfg=$(stty -g)
  stty raw -echo
  answer=$( while ! head -c 1 | grep -i '[ny]' ;do true ;done )
  stty $old_stty_cfg
  if echo "$answer" | grep -iq "^y" ;then
    echo y
    flatpak install --reinstall flathub org.freedesktop.Platform.Locale//21.08
  else
    echo n
  fi

  echo -n "Add AppCenter (Elementary) flatpak remote and install Ensembles? [y/n]: "
  old_stty_cfg=$(stty -g)
  stty raw -echo
  answer=$( while ! head -c 1 | grep -i '[ny]' ;do true ;done )
  stty $old_stty_cfg
  if echo "$answer" | grep -iq "^y" ;then
    echo y
    flatpak remote-add --if-not-exists ElementaryAppCenter https://flatpak.elementary.io/repo.flatpakrepo
    flatpak install ElementaryAppCenter com.github.subhadeepjasu.ensembles
  else
    echo n
  fi

  echo -n "Install osu? [y/n]: "
  old_stty_cfg=$(stty -g)
  stty raw -echo
  answer=$( while ! head -c 1 | grep -i '[ny]' ;do true ;done )
  stty $old_stty_cfg
  if echo "$answer" | grep -iq "^y" ;then
    echo y
    flatpak install flathub sh.ppy.osu
  else
    echo n
  fi

  echo -n "Install Mothership Defender 2? [y/n]: "
  old_stty_cfg=$(stty -g)
  stty raw -echo
  answer=$( while ! head -c 1 | grep -i '[ny]' ;do true ;done )
  stty $old_stty_cfg
  if echo "$answer" | grep -iq "^y" ;then
    echo y
    flatpak install NilsFlatpakRepo de.Nalsai.MothershipDefender2
  else
    echo n
  fi

  echo -n "Install Tactical Math Returns? [y/n]: "
  old_stty_cfg=$(stty -g)
  stty raw -echo
  answer=$( while ! head -c 1 | grep -i '[ny]' ;do true ;done )
  stty $old_stty_cfg
  if echo "$answer" | grep -iq "^y" ;then
    echo y
    flatpak install NilsFlatpakRepo com.DaRealRoyal.TacticalMathReturns
  else
    echo n
  fi

  if type apt-get >/dev/null 2>&1; then
    echo Uninstalling packages not needed anymore...
    sudo apt-get remove firefox -y

    echo Installing other packages...
    sudo apt-get install ffmpeg git htop neofetch neovim -y

    if sudo apt-get install fish -y; then
      sudo usermod --shell /bin/fish $USER
    fi

    # Docker
    $DOT/linux/scripts/install_docker.sh
    echo -n "Enable Docker service? [y/n]: "
    old_stty_cfg=$(stty -g)
    stty raw -echo
    answer=$( while ! head -c 1 | grep -i '[ny]' ;do true ;done )
    stty $old_stty_cfg
    if echo "$answer" | grep -iq "^y" ;then
      echo y
      sudo systemctl enable docker --now
    else
      echo n
    fi


  elif type dnf >/dev/null 2>&1; then
    echo Uninstalling packages not needed anymore...
    sudo dnf -y remove eog gnome-font-viewer libreoffice-* firefox
    sudo dnf -y group remove LibreOffice

    echo Installing RPM Fusion
    sudo dnf -y install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
    sudo dnf -y groupupdate core

    echo Installing other packages...
    sudo dnf -y install ffmpeg flatpak-builder git gnome-tweaks htop hugo mangohud neofetch neovim ocrmypdf openssl pandoc radeontop steam syncthing texlive youtube-dl yt-dlp tesseract-langpack-deu librsvg2-tools lutris dconf wireguard-tools
    sudo dnf -y group install "Virtualization"

    if sudo dnf -y install fish; then
      sudo usermod --shell /bin/fish $USER
    fi

    # VSCode
    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
    sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
    sudo dnf -y install code

    # Docker
    $DOT/linux/scripts/install_docker.sh
    echo -n "Enable Docker service? [y/n]: "
    old_stty_cfg=$(stty -g)
    stty raw -echo
    answer=$( while ! head -c 1 | grep -i '[ny]' ;do true ;done )
    stty $old_stty_cfg
    if echo "$answer" | grep -iq "^y" ;then
      echo y
      sudo systemctl enable docker --now
    else
      echo n
    fi


  elif type pacman >/dev/null 2>&1; then
    echo Uninstalling packages not needed anymore...
    sudo pacman -R firefox

    echo Installing other packages...
    sudo pacman -S ffmpeg fish git htop neofetch neovim

    if sudo pacman -S fish; then
      sudo usermod --shell /bin/fish $USER
    fi
  fi

  if systemctl --user list-unit-files "syncthing.service" --state=disabled >/dev/null 2>&1; then
    systemctl --user enable syncthing.service
  fi

  $DOT/linux/scripts/install_gotop.sh

  echo Configuring Apps...
  if [ -f "/usr/share/applications/google-chrome.desktop" ]; then
    $DOT/linux/scripts/chrome_dark_mode.sh
  fi

  echo Configuring Gnome \(dconf\)...
  dconf write /org/gnome/desktop/interface/gtk-theme "'Adwaita-dark'"
  dconf write /org/gnome/desktop/interface/enable-hot-corners "false"
  dconf write /org/gnome/desktop/privacy/recent-files-max-age "1"
  dconf write /org/gnome/desktop/privacy/remove-old-trash-files "true"
  dconf write /org/gnome/desktop/privacy/remove-old-temp-files "true"
  dconf write /org/gnome/desktop/privacy/old-files-age "uint32 7"
  dconf write /org/gnome/desktop/input-sources/xkb-options "['lv3:ralt_switch', 'compose:caps']"
  dconf write /org/gnome/desktop/peripherals/mouse/accel-profile "'flat'"
  dconf write /org/gnome/desktop/wm/keybindings/show-desktop "['<Super>d']"
  dconf write /org/gnome/desktop/wm/preferences/button-layout "'appmenu:minimize,close'"
  dconf write /org/gnome/mutter/center-new-windows "true"
  dconf write /org/gnome/shell/favorite-apps "['org.mozilla.firefox.desktop', 'org.gnome.Nautilus.desktop', 'org.gnome.TextEditor.desktop', 'org.gnome.Terminal.desktop', 'org.gnome.Screenshot.desktop']"
  dconf write /org/gtk/settings/file-chooser/sort-directories-first "true"

  echo Making discord rpc work...
  mkdir -p ~/.config/user-tmpfiles.d
  echo 'L %t/discord-ipc-0 - - - - app/com.discordapp.Discord/discord-ipc-0' > ~/.config/user-tmpfiles.d/discord-rpc.conf
  systemctl --user enable --now systemd-tmpfiles-setup.service

  echo -n "Install shortcut for /home/nalsai/Apps/Minion3.0.5-java? [y/n]: "
  old_stty_cfg=$(stty -g)
  stty raw -echo
  answer=$( while ! head -c 1 | grep -i '[ny]' ;do true ;done )
  stty $old_stty_cfg
  if echo "$answer" | grep -iq "^y" ;then
    echo y
    sudo ln -s $DOT/linux/shortcuts/esoui-minion.desktop $HOME/.local/share/applications/esoui-minion.desktop
  else
    echo n
  fi

  # TODO
  #git gpg key
  #ask for sponsorblock.txt
  #gnome terminal, builder...
  #install extensions

  echo Installing Fonts...
  # TODO

  end
}

MinimalInstall() {
  echo "This script is work in progress and supports Arch, Debian, Fedora and Derivatives."
  echo "(including Chrome OS, WSL etc.)"
  echo -n "Continue? [y/n]: "
  old_stty_cfg=$(stty -g)
  stty raw -echo
  answer=$( while ! head -c 1 | grep -i '[ny]' ;do true ;done )
  stty $old_stty_cfg
  if echo "$answer" | grep -iq "^y" ;then
    echo y
  else
    echo n
    exit 130
  fi

  prepare

  # TODO

  end
}

ServerInstall() {
  echo "This script is work in progress and will support Raspbian, Armbian, Debian, Fedora and RockyLinux."
  echo -n "Continue? [y/n]: "
  old_stty_cfg=$(stty -g)
  stty raw -echo
  answer=$( while ! head -c 1 | grep -i '[ny]' ;do true ;done )
  stty $old_stty_cfg
  if echo "$answer" | grep -iq "^y" ;then
    echo y
  else
    echo n
    exit 130
  fi

  prepare

  echo Making sure curl and unzip are installed

  if type apt-get >/dev/null 2>&1; then
    sudo apt-get install curl unzip -y
  elif type dnf >/dev/null 2>&1; then
    sudo dnf -y install curl unzip
  fi

  echo Downloading Dotfiles...
  curl -SL "https://github.com/Nalsai/dotfiles/archive/refs/heads/main.zip" -o $TMP/dotfiles.zip
  unzip -u -d $TMP $TMP/dotfiles.zip
  rm -rf $DOT > /dev/null 2>&1
  mv $TMP/dotfiles-main $DOT

  chmod +x $DOT/linux/connect-ssh.sh
  chmod +x $DOT/linux/install.sh
  chmod +x $DOT/linux/update-system.sh
  chmod +x $DOT/linux/scripts/chrome_dark_mode.sh
  chmod +x $DOT/linux/scripts/install_docker.sh
  chmod +x $DOT/linux/scripts/install_gotop.sh
  chmod +x $DOT/linux/shortcuts/install-shortcuts.sh


  echo Updating System...
  $DOT/linux/update-system.sh


  echo Making Symlinks...
  # .gitconfig
  ln -sf $DOT/git/.gitconfig $HOME/.gitconfig

  # fish
  rm -rf $HOME/.config/fish > /dev/null 2>&1
  ln -sf $DOT/linux/fish/ $HOME/.config/fish

  # neovim
  rm -rf $HOME/.config/nvim > /dev/null 2>&1
  ln -sf $DOT/linux/nvim/ $HOME/.config/nvim


  echo Installing packages...

  if type apt-get >/dev/null 2>&1; then
    sudo apt-get install ca-certificates curl gnupg lsb-release git neovim fish htop neofetch -y
    # cockpit cockpit-pcp pcp packagekit

    if sudo apt-get install fish -y; then
      sudo usermod --shell /bin/fish $USER
    fi

  elif type dnf >/dev/null 2>&1; then
    ID=
    [[ -f /etc/os-release ]] && . /etc/os-release
    if [[ "$ID" == "rocky" ]]; then
      echo Installing EPEL and RPM Fusion
      sudo dnf -y install epel-release
      sudo dnf -y install https://mirrors.rpmfusion.org/free/el/rpmfusion-free-release-$(rpm -E %rocky).noarch.rpmhttps://mirrors.rpmfusion.org/nonfree/el/rpmfusion-nonfree-release-$(rpm -E %rocky).noarch.rpm

    elif [[ "$ID" == "fedora" ]]; then
      echo Installing RPM Fusion
      sudo dnf -y install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
      sudo dnf -y groupupdate core
    fi

    sudo dnf -y install git htop neofetch neovim dnf-utils dnf-plugins-core dnf-automatic cockpit cockpit-pcp pcp PackageKit

    if sudo dnf -y install fish; then
      sudo usermod --shell /bin/fish $USER
    fi
  fi

  $DOT/linux/scripts/install_docker.sh
  sudo systemctl enable docker --now

  end
}

Tools() {
  while true; do
    echo
    echo 'Please select what to do:'
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
        echo -n "Enable Docker service? [y/n]: "
        old_stty_cfg=$(stty -g)
        stty raw -echo
        answer=$( while ! head -c 1 | grep -i '[ny]' ;do true ;done )
        stty $old_stty_cfg
        if echo "$answer" | grep -iq "^y" ;then
          echo y
          sudo systemctl enable docker --now
        else
          echo n
        fi
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
