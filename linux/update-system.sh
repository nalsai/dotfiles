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
    sudo dnf -y autoremove
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
    rpm-ostree cleanup --base --repomd
  fi

  if pgrep -f docker >/dev/null && type docker >/dev/null 2>&1; then
    sudo docker system prune -a
  fi

  if type podman >/dev/null 2>&1; then
    if type distrobox >/dev/null 2>&1; then
      # Start all distroboxes so they don't get pruned
      distrobox list | tail -n +2 | cut -d'|' -f2 | while read -r container; do
          #echo "Starting $container"
          distrobox enter "$container" -- echo "Container $container started" &
      done
      sleep 1
    fi

    podman system prune -a

    if type distrobox >/dev/null 2>&1; then
      # Stop all distroboxes after pruning
      distrobox list | tail -n +2 | cut -d'|' -f2 | while read -r container; do
          #echo "Stopping $container"
          distrobox stop "$container" -Y
      done
    fi
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

echo Updating dotfiles...
DOT="$HOME/.dotfiles"
if [ -d "$DOT/.git" ]; then
  git -C $DOT pull origin main
elif [ -d "$DOT" ]; then
  TMP="/tmp/ZG90ZmlsZXM"
  mkdir -p $TMP
  curl -SL "https://github.com/Nalsai/dotfiles/archive/refs/heads/main.zip" -o $TMP/dotfiles.zip &&
    unzip -q -u -d $TMP $TMP/dotfiles.zip &&
    rm -rf $DOT >/dev/null 2>&1 &&
    mv $TMP/dotfiles-main $DOT
fi

if type distrobox >/dev/null 2>&1; then
  echo Updating distroboxes...
  distrobox upgrade --all
fi

echo Updating packages...
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

if type flatpak >/dev/null 2>&1 && [[ $(systemd-detect-virt) != "podman" ]]; then
  flatpak -y update
fi

if type podman >/dev/null 2>&1; then
  podman auto-update
fi
