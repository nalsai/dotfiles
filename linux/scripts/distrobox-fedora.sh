#!/bin/bash

if which code >/dev/null 2>&1; then
  echo "VSCode is already installed."
  echo "init-hooks don't need to be run again!"
  exit 0
fi

echo "Installing host-spawn..."
host_spawn_version="1.4.1"
curl -L "https://github.com/1player/host-spawn/releases/download/${host_spawn_version}/host-spawn-$(uname -m)" -o /usr/bin/host-spawn
sudo chmod +x /usr/bin/host-spawn

echo "Installing RPM Fusion"
dnf -y install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
dnf -y groupupdate core

echo "Installing packages..."
dnf -y install bat exa fish git which
dnf -y install cargo curl fastfetch ffmpeg flatpak-builder gnome-tweaks htop hugo neovim ocrmypdf librsvg2-tools pandoc perl-Image-ExifTool poppler-utils ripgrep rust tesseract-langpack-deu tesseract-langpack-eng tesseract-osd unzip yt-dlp
#openssl radeontop rustfmt texlive

echo "Installing jbig2enc..."
dnf -y install automake libtool leptonica-devel zlib-devel gcc-c++
git clone https://github.com/agl/jbig2enc /tmp/jbig2enc
cd /tmp/jbig2enc
./autogen.sh
./configure && make
make install
cd ~
rm -rf /tmp/jbig2enc

echo "Installing VSCode..."
rpm --import https://packages.microsoft.com/keys/microsoft.asc
sh -c "echo -e '[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc' > /etc/yum.repos.d/vscode.repo"
dnf -y install code

echo "Adding xdg-open wrapper ..."
echo -e "if [[ -f \"/run/.containerenv\" ]]; then\n\tflatpak-spawn --host /usr/bin/xdg-open \"\$@\"\nelse\n\t/usr/bin/xdg-open \"\$@\"\nfi" | tee /usr/local/bin/xdg-open
chmod +x /usr/local/bin/xdg-open

echo "Installing PowerShell..."
curl https://packages.microsoft.com/config/rhel/8/prod.repo | tee /etc/yum.repos.d/microsoft.repo
dnf -y install powershell

echo "Installing imgname..."
mkdir -p /tmp/imgname
CARGO_TARGET_DIR=/tmp/imgname cargo install --git https://github.com/Nalsai/imgname
mkdir -p /usr/share/bash-completion/completions
mkdir -p /usr/share/fish/completions
mkdir -p /usr/share/zsh/site-functions
sudo install -m644 /tmp/imgname/release/build/imgname-*/out/imgname.bash /usr/share/bash-completion/completions/imgname
sudo install -m644 /tmp/imgname/release/build/imgname-*/out/imgname.fish /usr/share/fish/completions/imgname.fish
sudo install -m644 /tmp/imgname/release/build/imgname-*/out/_imgname /usr/share/zsh/site-functions/_imgname
rm -rf /tmp/imgname

echo "Exporting apps..."
su - nalsai -c 'CONTAINER_ID=my-distrobox distrobox-export --app code'
su - nalsai -c 'CONTAINER_ID=my-distrobox distrobox-export --app gnome-tweaks'
