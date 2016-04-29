mainpath='/home/jp697/Major'
devpath='/home/jp697/Major/lattices'
store='/home/jp697/Major/exp/temp_file'
taskpath="${mainpath}/exp/task6"


# while read line
# do
#     ./scripts/hmmrescore.sh  $line plp-bg merge plp-bg plp
# done < $store/temp1

# check the file to complte and then continue
# while(true)
# do
# 	test -e "./plp-bg/dev03_DEV001-20010117-XX2000/decode/LOG" && break
# done
# while(true)
# do	
# 	egrep -c File plp-bg/dev03_DEV001-20010117-XX2000/decode/LOG > ./store.t
# 	check=`cat ./store.t`
# 	if [[ $check == 132 ]]; then
# 		rm ./store.t
# 		break
# 	fi
# done


# while read line
# do
#     ./scripts/hmmrescore.sh  $line plp-bg merge grph-plp-bg grph-plp
# done < $store/temp1

# #check the file to complte and then continue
# while(true)
# do
# 	test -e "./grph-plp-bg/dev03_DEV001-20010117-XX2000/decode/LOG" && break
# done
# while(true)
# do	
# 	egrep -c File grph-plp-bg/dev03_DEV001-20010117-XX2000/decode/LOG > ./store.t
# 	check=`cat ./store.t`
# 	if [[ $check == 132 ]]; then
# 		rm ./store.t
# 		break
# 	fi
# done




# while read line
# do
# 	#statements
# 	rm -r plp-bg/${line}/decode_cn/
# done < $store/temp1

# # generate the CN
# while read line
# do
# 	#statements
# 	./scripts/cnrescore.sh  ${line} plp-bg decode plp-bg
# done < $store/temp1

# while(true)
# do
# 	test -e "./plp-bg/dev03_DEV001-20010117-XX2000/decode_cn/LOG" && break
# done
# while(true)
# do	
# 	egrep -c File plp-bg/dev03_DEV001-20010117-XX2000/decode_cn/LOG > ./store.t
# 	check=`cat ./store.t`
# 	if [[ $check == 132 ]]; then
# 		rm ./store.t
# 		break
# 	fi
# done


# while read line
# do
# 	#statements
# 	rm -r grph-plp-bg/${line}/decode_cn/
# done < $store/temp1

# # generate the CN
# while read line
# do
# 	#statements
# 	./scripts/cnrescore.sh  ${line} grph-plp-bg decode grph-plp-bg
# done < $store/temp1

# while(true)
# do
# 	test -e "./grph-plp-bg/dev03_DEV001-20010117-XX2000/decode_cn/LOG" && break
# done
# while(true)
# do	
# 	egrep -c File grph-plp-bg/dev03_DEV001-20010117-XX2000/decode_cn/LOG > ./store.t
# 	check=`cat ./store.t`
# 	if [[ $check == 132 ]]; then
# 		rm ./store.t
# 		break
# 	fi
# done
# # mapping trees
# while read line
# do
# 	rm plp-bg/${line}/decode_cn/rescore_mappingtrees.mlf
# 	rm grph-plp-bg/${line}/decode_cn/rescore_mappingtrees.mlf
# 	echo | base/conftools/smoothtree-mlf.pl lib/trees/plp-bg_decode_cn.tree\
# 	plp-bg/${line}/decode_cn/rescore.mlf >> plp-bg/${line}/decode_cn/rescore_mappingtrees.mlf
# 	echo | base/conftools/smoothtree-mlf.pl lib/trees/plp-bg_decode_cn.tree\
# 	grph-plp-bg/${line}/decode_cn/rescore.mlf >> grph-plp-bg/${line}/decode_cn/rescore_mappingtrees.mlf
# done < $store/temp1

# # #combine the two mlf ffrom plp and grph-plp


rm -r ./exp/task6/combine
mkdir ./exp/task6/combine
while read line
do
	# cp ./plp-bg/${line}/decode_cn ./plp-bg/${line}/decode_cn_new
	# rm ./plp-bg/${line}/decode_cn_new/rescore.mlf
	mkdir ./exp/task6/combine/${line}/
	mkdir ./exp/task6/combine/${line}/decode_cn
	# python ./exp/shell/rover.py --outfile ./exp/task6/combine/${line}/decode_cn/rescore.mlf ./exp/task6/${line}.mlf
	# cp ./exp/task6/${line}.mlf ./exp/task6/combine/${line}/decode_cn/rescore.mlf
done < $store/temp1
python /home/jp697/Major/exp/shell/5.6.4.py
# score the results
echo | ./scripts/score.sh  exp/task6/combine dev03sub decode_cn >> $taskpath/5.6.4.LOG
# echo | ./scripts/score.sh  plp-bg dev03sub decode_cn_new >> $taskpath/5.6.4.LOG

