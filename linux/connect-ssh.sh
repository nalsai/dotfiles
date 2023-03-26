#!/bin/bash

echo 'Please select the server:'

select s in "hachiman.nils.moe" "shiina.nils.moe" "shion.nils.moe" "odroidxu4.nils.moe"; do
  case $s in
  "hachiman.nils.moe")
    ssh root@ssh.hachiman.nils.moe -p 2022
    break
    ;;
  "shiina.nils.moe")
    ssh root@ssh.shiina.nils.moe -p 2022
    break
    ;;
  "shion.nils.moe")
    ssh opc@ssh.shion.nils.moe
    break
    ;;
  "odroidxu4.nils.moe")
    ssh root@ssh.odroidxu4.nils.moe -p 2223
    break
    ;;
  *)
    break
    ;;
  esac
done
