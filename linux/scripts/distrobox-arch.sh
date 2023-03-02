#!/bin/bash

echo "Installing packages..."
sudo pacman -S fakeroot ffmpeg ffms2 pipewire-jack tesseract-data-eng python-pip gcc libxkbcommon vapoursynth

echo "Installing Paru..."
git clone git clone https://aur.archlinux.org/paru-bin.git
cd paru-bin
makepkg --noconfirm --syncdeps --rmdeps --install --clean

echo "Installing VapourSynth plugins..."
paru -S pkgconf vapoursynth-plugin-vsakarin-git

git clone https://github.com/DJATOM/LibP2P-Vapoursynth.git
cd LibP2P-Vapoursynth
meson configure build
cd build
meson compile
sudo meson install
cd ../../
rm -r LibP2P-Vapoursynth

pip install vspreview
