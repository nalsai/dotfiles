#!/bin/bash

echo 'Please select the server:'

select s in "hachiman.nils.moe" "alya.nils.moe" "odroidxu4.nils.moe"; do
  case $s in
  "hachiman.nils.moe")
    ssh root@hachiman -p 2022 || ssh root@hachiman.nils.moe -p 2022
    break
    ;;
  "alya.nils.moe")
    ssh root@alya || ssh root@alya.nils.moe
    break
    ;;
  "odroidxu4.nils.moe")
    ssh root@odroidxu4 -p 2223
    break
    ;;
  *)
    break
    ;;
  esac
done
