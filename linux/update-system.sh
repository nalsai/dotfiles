#!/bin/bash
############################################################
# Help                                                     #
############################################################
Help()
{
   # Display Help
   echo "Updates or cleans system and its packages."
   echo
   echo "Syntax: update-system.sh [OPTION]"
   echo
   echo "Options:"
   echo " -c      clean system"
   echo " -h      Print this Help."
   echo
}
############################################################
# Clean                                                    #
############################################################
Clean()
{
    echo Cleaning...

    if type apt >/dev/null 2>&1; then
        sudo apt autoremove
        sudo apt clean
    fi

    if type dnf >/dev/null 2>&1; then
        sudo dnf clean all
    fi

    if type yay >/dev/null 2>&1; then
        yay -c  # Remove unneeded dependencies
        yay -Sc # Remove untracked files in cache
    fi

    if type flatpak >/dev/null 2>&1; then
        flatpak uninstall --unused
    fi

    if pgrep -f docker > /dev/null; then
        sudo docker system prune -f
    fi
}

############################################################
############################################################
# Main program                                             #
############################################################
############################################################

while getopts ":hc" option; do
   case $option in
      h) # display Help
        Help
        exit;;
      c) # clean
        Clean
        exit;;
     \?) # Invalid option
        echo "Error: Invalid option"
        exit;;
   esac
done


echo Updating...
if type apt >/dev/null 2>&1; then
    sudo apt update
    sudo apt full-upgrade -y
fi

if type dnf >/dev/null 2>&1; then
    sudo dnf -y upgrade
fi

if type yay >/dev/null 2>&1; then
    yay -Syu
fi

if type flatpak >/dev/null 2>&1; then
    flatpak -y update
fi

# docker-compose
#docker-compose pull
#docker-compose up --force-recreate --build -d

#TODO: update servers
