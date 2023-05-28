#!/bin/bash

if [ -f /setup_done ]; then
  exit 0
fi

echo "Installing dependencies..."
sudo dnf install alsa-lib apr apr-util fontconfig freetype libglvnd-egl librsvg2 libXcursor libXi libXinerama libxkbcommon-x11 libXrandr libXrender libXtst mtdev pulseaudio-libs
sudo dnf install mesa-libGLU xcb-util-image xcb-util-keysyms xcb-util-renderutil xcb-util-wm

echo "Installing runtime dependencies..."
sudo dnf install alsa-plugins-pulseaudio libxcrypt-compat
sudo dnf install rocm-opencl  # AMD GPU

touch /setup_done
