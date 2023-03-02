#!/bin/bash

echo "Installing RPM Fusion"
sudo dnf -y install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
sudo dnf -y groupupdate core

echo "Installing packages..."
sudo dnf -y install bat cargo curl exa fastfetch ffmpeg flatpak-builder git gnome-tweaks htop hugo neovim ocrmypdf librsvg2-tools pandoc perl-Image-ExifTool ripgrep rust tesseract-langpack-deu tesseract-langpack-eng unzip yt-dlp
#openssl radeontop rustfmt texlive wireguard-tools

echo "Installing VSCode..."
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo sh -c "echo -e '[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc' > /etc/yum.repos.d/vscode.repo"
sudo dnf -y install code

echo "Adding xdg-open wrapper ..."
echo -e "if [[ -f \"/run/.containerenv\" ]]; then\n\tflatpak-spawn --host /usr/bin/xdg-open \"\$@\"\nelse\n\t/usr/bin/xdg-open \"\$@\"\nfi" | sudo tee /usr/local/bin/xdg-open
sudo chmod +x /usr/local/bin/xdg-open

echo "Installing PowerShell..."
curl https://packages.microsoft.com/config/rhel/8/prod.repo | sudo tee /etc/yum.repos.d/microsoft.repo
sudo dnf -y install powershell

echo "Exporting apps..."
distrobox-export --app code
distrobox-export --app gnome-tweaks
