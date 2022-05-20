#!/bin/bash

echo 'Please select the server:'

select s in "hachiman.nils.moe" "shiina.nils.moe" "minecraft.nils.moe" "nalsai@nanopineo3"; do
  case $s in
  "hachiman.nils.moe")
    ssh root@hachiman.nils.moe -p 2022
    break
    ;;
  "shiina.nils.moe")
    ssh root@shiina.nils.moe -p 2022
    break
    ;;
  "minecraft.nils.moe")
    ssh opc@minecraft.nils.moe
    break
    ;;
  "nalsai@nanopineo3")
    ssh nalsai@nanopineo3
    break
    ;;
  *)
    break
    ;;
  esac
done
