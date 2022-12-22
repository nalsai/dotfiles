#!/bin/bash

DOT="$HOME/.dotfiles"

while true; do
  echo
  echo 'Please select what to do:'
  select s in "install Fate shortcut" "install TTC shortcut" "install Tsukihime shortcut" "install ESO symlink" "install Fate symlink" "install MBTL symlink" "install osu symlinks" "exit"; do
    case $s in
    "install Fate shortcut")
      rm -f $HOME/.local/share/applications/fate-stay-night.desktop > /dev/null 2>&1
      ln -s $DOT/linux/shortcuts/fate-stay-night.desktop $HOME/.local/share/applications/fate-stay-night.desktop
      break
      ;;
    "install TTC shortcut")
      rm -f $HOME/.local/share/applications/tamrieltradecentre.desktop > /dev/null 2>&1
      ln -s $DOT/linux/shortcuts/tamrieltradecentre.desktop $HOME/.local/share/applications/tamrieltradecentre.desktop
      break
      ;;
    "install Tsukihime shortcut")
      rm -f $HOME/.local/share/applications/tsukihime.desktop > /dev/null 2>&1
      ln -s $DOT/linux/shortcuts/tsukihime.desktop $HOME/.local/share/applications/tsukihime.desktop
      break
      ;;
    "install ESO symlink")
      rm -rf "$HOME/Documents/Elder Scrolls Online" > /dev/null 2>&1
      mkdir -p $HOME/.local/share/Steam/steamapps/compatdata/306130/pfx/drive_c/users/steamuser/Documents/
      ln -s "$HOME/.local/share/Steam/steamapps/compatdata/306130/pfx/drive_c/users/steamuser/Documents/Elder Scrolls Online" "$HOME/Documents/Elder Scrolls Online"
      break
      ;;
    "install Fate symlink")
      sudo flatpak override com.usebottles.bottles --filesystem="$HOME/Sync/Files/Documents/faterealtanua_savedata"
      mkdir -p $HOME/.var/app/com.usebottles.bottles/data/bottles/bottles/Fate/drive_c/users/carrie/documents/
      rm -rf $HOME/.var/app/com.usebottles.bottles/data/bottles/bottles/Fate/drive_c/users/carrie/documents/faterealtanua_savedata > /dev/null 2>&1
      ln -s $HOME/Sync/Files/Documents/faterealtanua_savedata $HOME/.var/app/com.usebottles.bottles/data/bottles/bottles/Fate/drive_c/users/carrie/documents/faterealtanua_savedata
      break
      ;;
    "install MBTL symlink")
      rm -rf "$HOME/.local/share/Steam/steamapps/common/MELTY BLOOD TYPE LUMINA/winsave/228783925" > /dev/null 2>&1
      ln -s "$HOME/Sync/Files/Documents/Melty Blood Type Lumina Save" "$HOME/.local/share/Steam/steamapps/common/MELTY BLOOD TYPE LUMINA/winsave/228783925"
      break
      ;;
    "install osu symlinks")
      sudo flatpak override sh.ppy.osu --filesystem="$HOME/Sync/Files/osu"
      mkdir -p $HOME/.var/app/sh.ppy.osu/data/osu
      rm -rf $HOME/.var/app/sh.ppy.osu/data/osu/files > /dev/null 2>&1
      ln -sf $HOME/Sync/Files/osu/files $HOME/.var/app/sh.ppy.osu/data/osu/files
      rm -f $HOME/.var/app/sh.ppy.osu/data/osu/client.realm > /dev/null 2>&1
      ln -sf $HOME/Sync/Files/osu/client.realm $HOME/.var/app/sh.ppy.osu/data/osu/client.realm
      break
      ;;
    "exit")
      exit
      break
      ;;
    *)
      break
      ;;
    esac
  done
done
