echo 'Please select the server' 

select s in "nalsai@nanopineo3" "nalsai@nanopi-r4s" "nalsai@odroidxu4" "nalsai@144.91.122.166 (NilsFedoraVPS)" "nalsai@164.68.116.69 (NilsVPS)"
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
"nalsai@144.91.122.166 (NilsFedoraVPS)")
ssh nalsai@144.91.122.166
break
;;
"nalsai@164.68.116.69 (NilsVPS)")
ssh nalsai@164.68.116.69 -p 35474
break
;;
*)
echo "Invalid entry."
break
;;
esac
done
#ssh nalsai@nanopineo3
#ssh nalsai@nanopi-r4s
#ssh nalsai@144.91.122.166
#ssh nalsai@164.68.116.69 -p 35474
#ssh nalsai@odroidxu4