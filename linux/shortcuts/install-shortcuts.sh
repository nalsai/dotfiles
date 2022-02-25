#!/bin/bash

DOT="$HOME/.dotfiles"

while true; do
  echo
  echo 'Please select what to do:'
  select s in "install Minion shortcut" "install Fate shortcut" "install TTC shortcut" "install Tsukihime shortcut" "install ESO symlink" "install Fate symlink" "install MBTL symlink" "exit"; do
    case $s in
    "install Minion shortcut")
      ln -s $DOT/linux/shortcuts/esoui-minion.desktop $HOME/.local/share/applications/
      break
      ;;
    "install Fate shortcut")
      ln -s $DOT/linux/shortcuts/fate-stay-night.desktop $HOME/.local/share/applications/
      break
      ;;
    "install TTC shortcut")
      ln -s $DOT/linux/shortcuts/tamrieltradecentre.desktop $HOME/.local/share/applications/
      break
      ;;
    "install Tsukihime shortcut")
      ln -s $DOT/linux/shortcuts/tsukihime.desktop $HOME/.local/share/applications/
      break
      ;;
    "install ESO symlink")
      ln -s "/home/nalsai/.local/share/Steam/steamapps/compatdata/306130/pfx/drive_c/users/steamuser/Documents/Elder Scrolls Online" "/home/nalsai/Documents/Elder Scrolls Online"
      break
      ;;
    "install Fate symlink")
      ln -s "/home/nalsai/.var/app/com.usebottles.bottles/data/bottles/bottles/Fate/drive_c/users/carrie/documents/faterealtanua_savedata" "/home/nalsai/Apps/Bottles/Fate Stay Night/faterealtanua_savedata"
      break
      ;;
    "install MBTL symlink")
      ln -s "/home/nalsai/Sync/Files/Documents/Melty Blood: Type Lumina Save" "/home/nalsai/.local/share/Steam/steamapps/common/MELTY BLOOD TYPE LUMINA/winsave/228783925"
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
