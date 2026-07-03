#!/bin/bash

echo 'Please select the server:'

select s in "hachiman.nils.moe" "alya.nils.moe"; do
  case $s in
  "hachiman.nils.moe")
    ssh root@hachiman -p 2022   # ssh root@hachiman.nils.moe -p 2022
    break
    ;;
  "alya.nils.moe")
    ssh root@alya   # ssh root@alya.nils.moe
    break
    ;;
  *)
    break
    ;;
  esac
done
