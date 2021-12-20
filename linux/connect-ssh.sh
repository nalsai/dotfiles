echo 'Please select the server' 

select s in "nalsai@nanopineo3" "nalsai@nanopi-r4s" "nalsai@odroidxu4" "nalsai@164.68.116.69 (NilsVPS)" "root@144.91.122.166 (NilsVPS2, OpenMPTCProuter)" "opc@130.61.35.124 (ARM Server Minecraft)" "ubuntu@138.3.248.255 (OpenMPTCProuter)"
do
case $s in
"nalsai@nanopineo3")
ssh nalsai@nanopineo3
break
;;
"nalsai@nanopi-r4s")
ssh nalsai@nanopi-r4s
break
;;
"nalsai@odroidxu4")
ssh nalsai@odroidxu4
break
;;
"nalsai@164.68.116.69 (NilsVPS)")
ssh nalsai@164.68.116.69 -p 35474
break
;;
"root@144.91.122.166 (NilsVPS2, OpenMPTCProuter)")
ssh root@144.91.122.166 -p 65222
break
;;
"opc@130.61.35.124 (ARM Server Minecraft)")
ssh opc@130.61.35.124
break
;;
"ubuntu@138.3.248.255 (OpenMPTCProuter)")
ssh ubuntu@138.3.248.255 -p 65222
break
;;
*)
echo "Invalid entry."
break
;;
esac
done
