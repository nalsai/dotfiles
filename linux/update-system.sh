#!/bin/bash

Help() {
  echo "Updates or cleans system and its packages."
  echo
  echo "Syntax: update-system.sh [OPTION]"
  echo
  echo "Options:"
  echo " -c      clean system"
  echo " -h      print this help"
  echo
}

Clean() {
  echo Cleaning...

  if type apt-get >/dev/null 2>&1; then
    sudo apt-get autoremove
    sudo apt-get clean
  fi

  if type dnf >/dev/null 2>&1; then
    sudo dnf clean all
  fi

  if type yay >/dev/null 2>&1; then
    yay -c
    yay -Sc
  elif type pacman >/dev/null 2>&1; then
    sudo pacman -Sc
  fi

  if type flatpak >/dev/null 2>&1; then
    flatpak uninstall --unused
  fi

  if type rpm-ostree >/dev/null 2>&1; then
    rpm-ostree cleanup
  fi

  if pgrep -f docker >/dev/null; then
    sudo docker system prune -a
  fi
}

while getopts ":chr" option; do
  case $option in
  c)
    Clean
    exit
    ;;
  h)
    Help
    exit
    ;;
  \?)
    echo "Error: Invalid option"
    exit
    ;;
  esac
done

echo Updating...
if type apt-get >/dev/null 2>&1; then
  sudo apt-get update
  sudo apt-get full-upgrade -y
fi

if type dnf >/dev/null 2>&1; then
  sudo dnf -y upgrade
fi

if type yay >/dev/null 2>&1; then
  yay -Syu
elif type pacman >/dev/null 2>&1; then
  sudo pacman -Syu
fi

if type rpm-ostree >/dev/null 2>&1; then
  rpm-ostree upgrade
fi

if type flatpak >/dev/null 2>&1; then
  flatpak -y update
fi
