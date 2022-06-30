#!/bin/bash

echo 'Please select the server:'

select s in "hachiman.nils.moe" "shiina.nils.moe" "shion.nils.moe"; do
  case $s in
  "hachiman.nils.moe")
    ssh root@hachiman.nils.moe -p 2022
    break
    ;;
  "shiina.nils.moe")
    ssh root@shiina.nils.moe -p 2022
    break
    ;;
  "shion.nils.moe")
    ssh opc@shion.nils.moe
    break
    ;;
  *)
    break
    ;;
  esac
done
