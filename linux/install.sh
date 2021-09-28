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


# download dotfiles


# make symlinks
#ln -sf 

#git/.gitconfig -->  ~/.gitconfig
#vscode --> ~/.config/Code/User
#vscode --> ~/.config/code-oss/User
#vscode --> ~/.config/Code - OSS/User
#/home/nalsai/.config/plex-mpv-shim
#/home/nalsai/.var/app/com.github.iwalton3.jellyfin-mpv-shim/config/jellyfin-mpv-shim
#/home/nalsai/.var/app/io.mpv.Mpv/config/mpv
#/home/nalsai/.config/mpv
#celluloid


# change os settings


# install apps


# change app settings?
#if chrome is installed:
#linux/chrome/dark_mode.sh
#git gpg key
#flatpak: allow access to screenshot path
#~/Pictures/mpv-screenshots:create
#mpv ask for sponsorblock.txt
#gnome terminal


# install fonts


# other TODO:
#nvim
#fish
#Apps:
#dnf:
#pacman/yay:
#flatpaks:
