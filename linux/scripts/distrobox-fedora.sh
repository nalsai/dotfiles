#!/bin/bash

if [ -f /setup_done ]; then
  exit 0
fi

echo "Exporting apps..."
su - nalsai -c 'CONTAINER_ID=my-distrobox distrobox-export --app code'
su - nalsai -c 'CONTAINER_ID=my-distrobox distrobox-export --app gnome-tweaks'

touch /setup_done
