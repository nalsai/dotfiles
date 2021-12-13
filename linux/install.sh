#!/bin/bash
clear
echo -e " _   _ _ _     ____        _    __ _ _\n| \ | (_| |___|  _ \  ___ | |_ / _(_| | ___ ___\n|  \| | | / __| | | |/ _ \| __| |_| | |/ _ / __|\n| |\  | | \__ | |_| | (_) | |_|  _| | |  __\__ \\n|_| \_|_|_|___|____/ \___/ \__|_| |_|_|\___|___/"
echo
echo "This script is still work in progress and currently only made for Fedora."

echo -n "Continue? [y/n]: "
# https://stackoverflow.com/questions/226703/how-do-i-prompt-for-yes-no-cancel-input-in-a-linux-shell-script#27875395
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

# TODO:
# [1] rootless installation
# [2] full installation
# [3] server installation

TMP="/tmp/ZG90ZmlsZXM"
DOT="$HOME/.dotfiles"
mkdir -p $TMP

echo Downloading Dotfiles...
wget -O $TMP/dotfiles.zip "https://github.com/Nalsai/dotfiles/archive/refs/heads/rework.zip"
unzip -u -d $TMP $TMP/dotfiles.zip
rm -r $DOT > /dev/null 2>&1
mv $TMP/dotfiles-rework $DOT

chmod +x $DOT/linux/connect-ssh.sh
chmod +x $DOT/linux/install.sh
chmod +x $DOT/linux/update-system.sh
chmod +x $DOT/linux/chrome/dark_mode.sh

echo Updating System...
$DOT/linux/update-system.sh

echo Making Symlinks...
# mpv
mkdir -p $HOME/.var/app/io.mpv.Mpv/config                       # make parent folder if not exists
rm -r $HOME/.var/app/io.mpv.Mpv/config/mpv > /dev/null 2>&1     # remove folder to be symlinked if exists
ln -sf $DOT/mpv/mpv $HOME/.var/app/io.mpv.Mpv/config/mpv        # make symlink
#/home/nalsai/.config/plex-mpv-shim
#/home/nalsai/.var/app/com.github.iwalton3.jellyfin-mpv-shim/config/jellyfin-mpv-shim
#/home/nalsai/.var/app/io.mpv.Mpv/config/mpv
#/home/nalsai/.config/mpv
#celluloid

# Visual Studio Code settings.json and keybindings.json
mkdir -p $HOME/.config/Code/User
mkdir -p $HOME/.config/code-oss/User
mkdir -p "$HOME/.config/Code - OSS/User"
ln -sf $DOT/vscode/settings.json $HOME/.config/Code/User/settings.json
ln -sf $DOT/vscode/keybindings.json $HOME/.config/Code/User/keybindings.json
ln -sf $DOT/vscode/settings.json $HOME/.config/code-oss/User/settings.json
ln -sf $DOT/vscode/keybindings.json $HOME/.config/code-oss/User/keybindings.json
ln -sf $DOT/vscode/settings.json "$HOME/.config/Code - OSS/User/settings.json"
ln -sf $DOT/vscode/keybindings.json "$HOME/.config/Code - OSS/User/keybindings.json"

# .gitconfig
ln -sf $DOT/git/.gitconfig $HOME/.gitconfig

# fish
rm -r $HOME/.config/fish > /dev/null 2>&1    # remove folder to be symlinked if exists
ln -sf $DOT/linux/fish/ $HOME/.config/fish


echo Installing Flatpaks...
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak remote-add --if-not-exists NilsFlatpakRepo https://flatpak.nils.moe/NilsFlatpakRepo.flatpakrepo
flatpak install flathub com.belmoussaoui.Decoder com.discordapp.Discord com.github.huluti.Curtail com.github.iwalton3.jellyfin-media-player com.github.johnfactotum.Foliate com.github.kmwallio.thiefmd com.github.liferooter.textpieces com.github.tchx84.Flatseal com.skype.Client com.spotify.Client com.usebottles.bottles io.github.seadve.Kooha io.mpv.Mpv net.mediaarea.MediaInfo net.sourceforge.Hugin nl.hjdskes.gcolor3 org.bunkus.mkvtoolnix-gui org.gnome.Builder org.gnome.TextEditor org.gnome.eog org.gnome.font-viewer org.gnome.gitlab.YaLTeR.Identity org.gnome.gitlab.somas.Apostrophe org.inkscape.Inkscape org.libreoffice.LibreOffice org.gnome.Extensions org.deluge_torrent.deluge org.blender.Blender io.github.celluloid_player.Celluloid org.gnome.meld org.gimp.GIMP org.nomacs.ImageLounge org.gnome.seahorse.Application
flatpak install NilsFlatpakRepo org.wangqr.Aegisub cc.spek.Spek
#com.calibre_ebook.calibre com.github.qarmin.czkawka com.github.qarmin.szyszka com.katawa_shoujo.KatawaShoujo com.rafaelmardojai.WebfontKitGenerator fr.romainvigier.MetadataCleaner info.febvre.Komikku io.github.ciromattia.kcc io.github.hakuneko.HakuNeko org.gnome.Connections org.gnome.Epiphany org.gnome.Evolution org.kde.krita org.pitivi.Pitivi

flatpak info org.libreoffice.LibreOffice
echo ""
echo ""
echo "If LibreOffice uses a different Runtime, the script needs to be updated"
echo "Reinstalling the Locale installs all Locales, instead of just the main one."
echo "This is needed for Spell Checking in other languages than the main one."
echo "Reinstall org.freedesktop.Platform.Locale//21.08? [y/n]: "
# https://stackoverflow.com/questions/226703/how-do-i-prompt-for-yes-no-cancel-input-in-a-linux-shell-script#27875395
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
# https://stackoverflow.com/questions/226703/how-do-i-prompt-for-yes-no-cancel-input-in-a-linux-shell-script#27875395
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
# https://stackoverflow.com/questions/226703/how-do-i-prompt-for-yes-no-cancel-input-in-a-linux-shell-script#27875395
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
# https://stackoverflow.com/questions/226703/how-do-i-prompt-for-yes-no-cancel-input-in-a-linux-shell-script#27875395
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
# https://stackoverflow.com/questions/226703/how-do-i-prompt-for-yes-no-cancel-input-in-a-linux-shell-script#27875395
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
    # TODO

    echo Installing other packages...
    sudo apt-get install neofetch -y # TODO

    # Docker
    sudo apt-get install ca-certificates curl gnupg lsb-release -y
    curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
    sudo apt-get install docker-ce docker-ce-cli containerd.io -y
    docker --version

    echo -n "Enable Docker service? [y/n]: "
    # https://stackoverflow.com/questions/226703/how-do-i-prompt-for-yes-no-cancel-input-in-a-linux-shell-script#27875395
    old_stty_cfg=$(stty -g)
    stty raw -echo
    answer=$( while ! head -c 1 | grep -i '[ny]' ;do true ;done )
    stty $old_stty_cfg
    if echo "$answer" | grep -iq "^y" ;then
        echo y
        sudo systemctl enable docker
    else
        echo n
    fi

    echo -n "Install Docker Compose V2? [y/n]: "
    # https://stackoverflow.com/questions/226703/how-do-i-prompt-for-yes-no-cancel-input-in-a-linux-shell-script#27875395
    old_stty_cfg=$(stty -g)
    stty raw -echo
    answer=$( while ! head -c 1 | grep -i '[ny]' ;do true ;done )
    stty $old_stty_cfg
    if echo "$answer" | grep -iq "^y" ;then
        echo y
        sudo mkdir -p /usr/local/lib/docker/cli-plugins/
        sudo curl -SL https://github.com/docker/compose/releases/download/v2.1.1/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/lib/docker/cli-plugins/docker-compose
        sudo chmod +x /usr/local/lib/docker/cli-plugins/docker-compose
        docker compose version
    else
        echo n
    fi

elif type dnf >/dev/null 2>&1; then
    echo Uninstalling packages not needed anymore...
    sudo dnf -y remove eog gnome-font-viewer libreoffice-*
    sudo dnf -y group remove LibreOffice

    echo Installing RPM Fusion
    sudo dnf -y install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
    sudo dnf -y groupupdate core

    echo Installing other packages...
    sudo dnf -y install ffmpeg fish flatpak-builder git gnome-tweaks htop hugo mangohud neofetch neovim ocrmypdf openssl pandoc radeontop steam syncthing texlive vscode youtube-dl yt-dlp tesseract-langpack-deu librsvg2-tools lutris dconf wireguard-tools
    sudo dnf -y group install "Virtualization"

    if sudo dnf -y install fish; then
        sudo usermod --shell /bin/fish $USER
    fi

    # Docker
    sudo dnf -y install dnf-plugins-core
    sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
    sudo dnf -y install docker-ce docker-ce-cli containerd.io
    sudo systemctl start docker
    docker --version

    echo -n "Enable Docker service? [y/n]: "
    # https://stackoverflow.com/questions/226703/how-do-i-prompt-for-yes-no-cancel-input-in-a-linux-shell-script#27875395
    old_stty_cfg=$(stty -g)
    stty raw -echo
    answer=$( while ! head -c 1 | grep -i '[ny]' ;do true ;done )
    stty $old_stty_cfg
    if echo "$answer" | grep -iq "^y" ;then
        echo y
        sudo systemctl enable docker
    else
        echo n
    fi

    echo -n "Install Docker Compose V2? [y/n]: "
    # https://stackoverflow.com/questions/226703/how-do-i-prompt-for-yes-no-cancel-input-in-a-linux-shell-script#27875395
    old_stty_cfg=$(stty -g)
    stty raw -echo
    answer=$( while ! head -c 1 | grep -i '[ny]' ;do true ;done )
    stty $old_stty_cfg
    if echo "$answer" | grep -iq "^y" ;then
        echo y
        sudo mkdir -p /usr/local/lib/docker/cli-plugins/
        sudo curl -SL https://github.com/docker/compose/releases/download/v2.1.1/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/lib/docker/cli-plugins/docker-compose
        sudo chmod +x /usr/local/lib/docker/cli-plugins/docker-compose
        docker compose version
    else
        echo n
    fi

elif type pacman >/dev/null 2>&1; then
    echo Uninstalling packages not needed anymore...
    # TODO

    echo Installing other packages...
    sudo pacman -S neofetch
fi

if systemctl --user list-unit-files "syncthing.service" --state=disabled >/dev/null 2>&1; then
    systemctl --user enable syncthing.service
fi


echo Configuring Apps...
if [ -f "/usr/share/applications/google-chrome.desktop" ]; then
    $DOT/linux/chrome/dark_mode.sh
fi

echo Configuring Gnome \(dconf\)...
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
# https://stackoverflow.com/questions/226703/how-do-i-prompt-for-yes-no-cancel-input-in-a-linux-shell-script#27875395
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
#celluloid,gnome terminal, builder...
#file Templates
#install extensions
#firefox flatpak or system?

echo Installing Fonts...
# TODO


rm -r $TMP
echo Done!
