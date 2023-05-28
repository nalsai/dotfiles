#!/bin/bash

if [ -f /setup_done ]; then
  exit 0
fi

echo "Installing host-spawn..."
curl -L "https://github.com/1player/host-spawn/releases/download/${host_spawn_version}/host-spawn-$(uname -m)" -o /usr/bin/host-spawn
sudo chmod +x /usr/bin/host-spawn

echo "Installing packages..."
pacman -S --noconfirm bat exa fish git which
pacman -S --noconfirm base-devel fakeroot ffmpeg ffms2 meson pipewire-jack pkgconf tesseract-data-eng python-pip gcc libxkbcommon vapoursynth

echo "Installing Paru..."
git clone https://aur.archlinux.org/paru-bin.git /tmp/paru-bin
chown -R nalsai:nalsai /tmp/paru-bin
su - nalsai -c 'cd /tmp/paru-bin && makepkg --noconfirm --syncdeps --rmdeps --install --clean'
rm -rf /tmp/paru-bin

echo "Installing VapourSynth plugins..."
su - nalsai -c 'paru -S vapoursynth-plugin-vsakarin-git'

mkdir -p /tmp/LibP2P-Vapoursynth
git clone https://github.com/DJATOM/LibP2P-Vapoursynth.git /tmp/LibP2P-Vapoursynth
cd /tmp/LibP2P-Vapoursynth
meson setup /tmp/LibP2P-Vapoursynth/build
meson compile -C /tmp/LibP2P-Vapoursynth/build
meson install -C /tmp/LibP2P-Vapoursynth/build
cd ~
rm -rf /tmp/LibP2P-Vapoursynth

pip install vspreview

touch /setup_done
