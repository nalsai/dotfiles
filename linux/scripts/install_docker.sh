#!/bin/bash

github_latest_release() {
  curl --silent "https://api.github.com/repos/$1/releases/latest" |
  grep -Po '"tag_name": "\K.*?(?=")'
}


echo "This script is WIP, using the official install script."
curl -sSL https://get.docker.com/ | sh


# Debian
# sudo apt-get install ca-certificates curl gnupg lsb-release -y
# curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
# echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
# sudo apt-get update
# sudo apt-get install docker-ce docker-ce-cli containerd.io -y
# sudo usermod -aG docker $USER


# Fedora
# sudo dnf -y install dnf-plugins-core
# sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
# sudo dnf -y install docker-ce docker-ce-cli containerd.io
# sudo usermod -aG docker $USER


# Docker CentOS/RockyLinux
# sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
# sudo dnf -y install docker-ce docker-ce-cli containerd.io
# sudo usermod -aG docker $USER


# Docker Raspberry Pi
# curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
# echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
# sudo apt-get update
# sudo apt-get install docker-ce docker-ce-cli containerd.io -y
# sudo usermod -aG docker $USER
#(docker doesn't need to be started manually on debian)
# sudo systemctl enable docker


# Docker Compose V2
# Raspberry Pi TODO: trim l (there is only a build without l //github.com/docker/compose/releases/download/v2.2.2/docker-compose-Linux-armv7l)
# sudo mkdir -p /usr/local/lib/docker/cli-plugins/
# sudo curl -SL https://github.com/docker/compose/releases/download/$(github_latest_release "docker/compose")/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/lib/docker/cli-plugins/docker-compose
# sudo chmod +x /usr/local/lib/docker/cli-plugins/docker-compose


# sudo systemctl start docker

# docker --version
# docker compose version