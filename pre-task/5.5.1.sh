mainpath='/home/jp697/Major'
devpath='/home/jp697/Major/lattices'
store='/home/jp697/Major/exp/temp_file'
task2path="${mainpath}/exp/task2"


# while read line
# do
# 	echo "original lattices"
# 	./scripts/hmmrescore.sh $line lattices decode plp-bg/original plp
# done < $store/temp1


# while read line
# do
# 	echo "$line rescore:" >> $task2path/5.5.1.LOG
# 	./scripts/mergelats.sh $line lattices decode plp-bg
# 	while(true)
# 		do
# 			test -e "./plp-bg/$line/merge/LOG" && break
# 		done	
# 	while(true)
# 	do	
# 		egrep -c "HTK Configuration Parameters" plp-bg/$line/merge/LOG > ./store.t
# 		check=`cat ./store.t`
# 		if [[ $check == 2 ]]; then
# 			rm ./store.t
# 			break
# 		fi
# 	done
# 	echo | ./scripts/hmmrescore.sh $line plp-bg merge plp-bg plp >> $task2path/5.5.1.LOG
# 	echo "Done"
# done < $store/temp1


echo "original lattices" >> ./exp/5.5.1.LOG
echo | ./scripts/score.sh plp-bg/original dev03 decode >> ./exp/5.5.1.LOG
echo "minimised lattices" >> ./exp/5.5.1.LOG
echo | ./scripts/score.sh plp-bg/mini dev03 decode >> ./exp/5.5.1.LOG