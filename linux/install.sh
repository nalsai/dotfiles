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
fi

# TODO:
# [1] minimal installation
# [2] full installation
# [3] server installation

TMP="/tmp/ZG90ZmlsZXM"
DOT="$HOME/.dotfiles"
mkdir -p $TMP

# download dotfiles
echo Downloading Dotfiles
wget -O $TMP/dotfiles.zip "https://github.com/Nalsai/dotfiles/archive/refs/heads/rework.zip"
unzip -u -d $TMP $TMP/dotfiles.zip
rm -r $DOT > /dev/null 2>&1
mv $TMP/dotfiles-rework $DOT


# change os settings
if type dnf >/dev/null 2>&1; then
    echo Installing RPM Fusion
    sudo dnf -y install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
    sudo dnf -y groupupdate core
fi

# make symlinks 
echo Making Symlinks

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


# install apps
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak remote-add --if-not-exists NilsFlatpakRepo https://flatpak.nils.moe/NilsFlatpakRepo.flatpakrepo
flatpak install flathub com.belmoussaoui.Decoder com.discordapp.Discord com.github.huluti.Curtail com.github.iwalton3.jellyfin-media-player com.github.iwalton3.jellyfin-mpv-shim com.github.johnfactotum.Foliate com.github.kmwallio.thiefmd com.github.liferooter.textpieces com.github.tchx84.Flatseal com.skype.Client com.spotify.Client com.usebottles.bottles io.github.seadve.Kooha io.mpv.Mpv net.sourceforge.Hugin nl.hjdskes.gcolor3 org.bunkus.mkvtoolnix-gui org.gnome.TextEditor org.gnome.eog org.gnome.font-viewer org.gnome.gitlab.YaLTeR.Identity org.gnome.gitlab.somas.Apostrophe org.inkscape.Inkscape org.libreoffice.LibreOffice org.mozilla.firefox
# net.mediaarea.MediaInfo
flatpak install NilsFlatpakRepo org.wangqr.Aegisub

#com.calibre_ebook.calibre com.github.polymeilex.neothesia com.github.qarmin.czkawka com.github.qarmin.szyszka com.katawa_shoujo.KatawaShoujo com.rafaelmardojai.WebfontKitGenerator dev.alextren.Spot fr.romainvigier.MetadataCleaner info.febvre.Komikku io.github.celluloid_player.Celluloid io.github.ciromattia.kcc io.github.hakuneko.HakuNeko io.github.lainsce.Notejot org.fedoraproject.MediaWriter org.free_astro.siril org.gnome.Builder org.gnome.Connections org.gnome.Epiphany org.gnome.Evolution org.kde.krita org.pitivi.Pitivi

#TODO: dnf, pacman/yay, apt

echo Uninstalling old packages
if type dnf >/dev/null 2>&1; then
    sudo dnf -y remove eog firefox gnome-font-viewer libreoffice-*
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


# change app settings
echo Configuring Apps
$DOT/linux/chrome/dark_mode.sh  #if chrome is installed:
#git gpg key
#flatpak: allow access to screenshot path   ~/Pictures/mpv-screenshots:create
#mpv ask for sponsorblock.txt
#gnome terminal


# install fonts


# other TODO:
#nvim


sudo chmod +x $DOT/linux/connect-ssh.sh
sudo chmod +x $DOT/linux/update-system.sh

rm -r $TMP
