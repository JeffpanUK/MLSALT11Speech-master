mainpath='/home/jp697/Major'
devpath='/home/jp697/Major/lattices'
store='/home/jp697/Major/exp/temp_file'
taskpath="${mainpath}/exp/task6"

# #generate the CN
# while read line
# do
# 	#statements
# 	./scripts/cnrescore.sh ${line} plp-bg decode plp-bg
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

#score the results
# echo | ./scripts/score.sh plp-bg dev03sub decode_cn >> $taskpath/5.6.3.LOG


#use confident tree mapping
echo "Using confidence mapping trees" >> $taskpath/5.6.3.LOG
echo | ./scripts/score.sh -CONFTREE lib/trees/plp-bg_decode_cn.tree \
plp-bg dev03sub decode_cn >> $taskpath/5.6.3.LOG
