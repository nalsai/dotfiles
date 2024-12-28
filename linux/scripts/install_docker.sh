#!/bin/bash

if type docker >/dev/null 2>&1; then
  echo "Docker is already installed, skipping"
else
  ID=
  [[ -f /etc/os-release ]] && . /etc/os-release
  if [[ $ID == "rocky" || $ID == "ol" ]]; then
    echo Installing Docker manually on Rocky Linux/Oracle Linux
    sudo dnf -y install dnf-plugins-core
    sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo  # CentOS
    sudo dnf -y install docker-ce docker-ce-cli containerd.io docker-compose-plugin
  else 
    curl -sSL https://get.docker.com/ | sh
  fi
  
  # Debian (and Raspberry Pi - Raspbian)
  # sudo apt-get install ca-certificates curl gnupg lsb-release -y
  # curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
  # echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  # sudo apt-get update
  # sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y

  # Fedora/CentOS
  # sudo dnf -y install dnf-plugins-core
  # sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo  # Fedora
  # sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo  # CentOS
  # sudo dnf -y install docker-ce docker-ce-cli containerd.io docker-compose-plugin

  sudo usermod -aG docker $USER

  sudo systemctl start docker

  docker --version
  docker compose version
fi
