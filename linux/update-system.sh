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
        sudo apt-get autoremove
    fi

    if type yay >/dev/null 2>&1; then
        # Remove unneeded dependencies.
        yay -c

        # Remove all the cached packages that are not currently installed, and the unused sync database
        yay -Sc

        # Remove unused packages (orphans)
        yay -Qtdq | yay -Rs -
    fi

    if type flatpak >/dev/null 2>&1; then
        flatpak uninstall --unused
    fi

    #TODO: check if docker daemon running
    if type docker >/dev/null 2>&1; then
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
    sudo apt update && sudo apt full-upgrade -y
fi

if type dnf >/dev/null 2>&1; then
    sudo dnf -y upgrade
fi

if type yay >/dev/null 2>&1; then
    yay -Syu
fi

if type flatpak >/dev/null 2>&1; then
    flatpak upgrade
fi

# docker-compose
#docker-compose pull
#docker-compose up --force-recreate --build -d

#TODO: update servers
