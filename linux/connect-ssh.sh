echo 'Please select the server' 

select s in "hachiman.nils.moe" "shiina.nils.moe" "vps.nils.moe" "minecraft.nils.moe" "pi@raspberrypi" "nalsai@odroidxu4" "nalsai@nanopineo3" "nalsai@nanopi-r4s" "138.3.248.255 (OpenMPTCProuter)"; do
  case $s in
  "hachiman.nils.moe")
    ssh root@hachiman.nils.moe -p 2022
    break
    ;;
  "shiina.nils.moe")
    ssh root@shiina.nils.moe -p 2022
    break
    ;;
  "vps.nils.moe")
    ssh nalsai@vps.nils.moe -p 35474
    break
    ;;
  "minecraft.nils.moe")
    ssh opc@minecraft.nils.moe
    break
    ;;
  "pi@raspberrypi")
    ssh pi@raspberrypi
    break
    ;;
  "nalsai@odroidxu4")
    ssh nalsai@odroidxu4
    break
    ;;
  "nalsai@nanopineo3")
    ssh nalsai@nanopineo3
    break
    ;;
  "nalsai@nanopi-r4s")
    ssh nalsai@nanopi-r4s
    break
    ;;
  "138.3.248.255 (OpenMPTCProuter)")
    ssh ubuntu@138.3.248.255 -p 65222
    break
    ;;
  *)
    echo "Invalid entry."
    break
    ;;
  esac
done
