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
   echo " -r      update remote servers"
   echo " -h      print this help"
   echo
}
############################################################
# Clean                                                    #
############################################################
Clean()
{
    echo Cleaning...

    if type apt-get >/dev/null 2>&1; then
        sudo apt-get autoremove
        sudo apt-get clean
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
# Update SSH                                               #
############################################################
UpdateSSH()
{
    echo Updating Servers over SSH...
    echo -n "Do you really want to do this? [y/n]: "
    # https://stackoverflow.com/questions/226703/how-do-i-prompt-for-yes-no-cancel-input-in-a-linux-shell-script#27875395
    old_stty_cfg=$(stty -g)
    stty raw -echo
    answer=$( while ! head -c 1 | grep -i '[ny]' ;do true ;done )
    stty $old_stty_cfg
    if echo "$answer" | grep -iq "^y" ;then
        echo y
    else
        echo n
        exit 130
    fi

    ssh root@nanopineo3 'sudo apt-get update && sudo apt-get full-upgrade -y'
    ssh root@nanopi-r4s 'sudo apt-get update && sudo apt-get full-upgrade -y'
    ssh root@odroidxu4 'sudo apt-get update && sudo apt-get full-upgrade -y'
    ssh root@144.91.122.166 'sudo dnf -y update'
    ssh root@164.68.116.69 -p 35474 'sudo apt-get update && sudo apt-get full-upgrade -y'
}

############################################################
############################################################
# Main program                                             #
############################################################
############################################################

while getopts ":chr" option; do
   case $option in
      c) # clean
        Clean
        exit;;
      r) # update ssh servers
        UpdateSSH
        exit;;
      h) # display Help
        Help
        exit;;
     \?) # Invalid option
        echo "Error: Invalid option"
        exit;;
   esac
done


echo Updating...
if type apt-get >/dev/null 2>&1; then
    sudo apt-get update
    sudo apt-get full-upgrade -y
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
