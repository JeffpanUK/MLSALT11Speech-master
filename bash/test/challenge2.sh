mainpath='/home/jp697/Major'
devpath='/home/jp697/Major/lattices'
store='/home/jp697/Major/exp/temp_file'
task1path="${mainpath}/exp/task1"
challengepath="/home/jp697/Major/challenge/streams/"
storedat="/home/jp697/Major/challenge/store_dat/"
##1. Generate dev and eval lists
# cd $devpath

# rm $store/challenge_eval
# # echo |find -name 'YTBG*' -maxdepth 1 >> "$store/challenge_dev"
# echo |find -name 'YTBE*' -maxdepth 1 >> "$store/challenge_eval"

# # #obtain the 1 best output from the lattices
# cd -

##2. Generate 1-best output from the dev set
# echo 'obtain the 1-best output from the YTBEdev'
# while read line
# do
# 	./scripts/1bestlats.sh $line lattices decode challenge/plp-bg
# done < "$store/challenge_dev"

# echo "receiving the mfl"
# while(true)
# do
# 	test -e "./challenge/plp-bg/YTBGdev_YTB271-XXXXXXXX-XXXXXX/1best/LM12.0_IN-10.0/rescore.mlf" && break
# done
# read -p 'check 1best/rescore.mlf'
# 


# 3. CInterpolate the LMs
# echo "Begin to generate the stream files" 

# for ((j=1;j<=5;j++))
# do
# 	base/bin/LPlex -C lib/cfgs/hlm.cfg -s stream${j} -u -t \
# 	lms/lm${j} ${storedat}/YTBEdev.dat
# 	cp stream${j} ${challengepath}
# 	rm stream${j}
# done


# echo "begin to interpolate the weights"

# python "/home/jp697/Major/exp/shell/interpolation_challenge.py"

# echo "begin to merge the LMs"

# j=0
# weight=[]
# while read line
# do
# 	weight[j]=$line
# 	let j=$j+1
# 	echo $j
# done < ${store}/weight_challenge_dev

# echo "Start the weight_challenge_dev LM merge"
# echo ${weight[0]}
# base/bin/LMerge -C lib/cfgs/hlm.cfg \
# -i ${weight[0]} lms/lm1 \
# -i ${weight[1]} lms/lm2 \
# -i ${weight[2]} lms/lm3 \
# -i ${weight[3]} lms/lm4 \
# lib/wlists/train.lst \
# lms/lm5 lm_int_challenge

# # 4. lmrescore the eval set
# echo 'Evaluate the performance of YTBEeval'
# while read line		
# do
# 	${mainpath}/scripts/lmrescore.sh $line lattices decode lm_int_challenge challenge/lm_int_plp FALSE
# done < "$store/challenge_eval"

##test the training set WER
# echo 'Evaluate the performance of YTBEeval'
# while read line		
# do
# 	${mainpath}/scripts/lmrescore.sh $line lattices decode lm_int_challenge_dev challenge/lm_int_plp_dev FALSE
# done < "$store/challenge_dev"
# ./scripts/score.sh challenge/lm_int_plp YTBEeval rescore


# #merge
# while read line
# do
# 	# rm -r challenge/plp-bg/${line}/merge
# 	# rm -r challenge/plp-bg/${line}/decode

# 	echo "$line rescore:" 
# 	./scripts/mergelats.sh $line lattices decode challenge/plp-bg
# done < $store/challenge_eval

# while read line
# do
# 	while(true)
# 			do
# 				test -e "./challenge/plp-bg/$line/merge/LOG" && break
# 			done	
# 		while(true)
# 		do	
# 			egrep -c "HTK Configuration Parameters" challenge/plp-bg/$line/merge/LOG > ./store.t
# 			check=`cat ./store.t`
# 			if [[ $check == 2 ]]; then
# 				rm ./store.t
# 				break
# 			fi
# 		done
# done < $store/challenge_dev

while read line
do
	#generate decode directiory
	./scripts/hmmrescore.sh $line challenge/plp-bg merge challenge/plp-bg plp
	echo "Done"	
done < $store/challenge_dev
echo "Step3 finished!"

# #score eval03 of all LMs

# echo "receiving the mfl"
# while(true)
# do
# 	test -e "./plp-tglm_int_eval/eval03_DEV013-20010220-XX2000/rescore/rescore.mlf" && break
# done

# echo 'scoring all the files'
# ./scripts/score.sh plp-tglm_int_eval eval03 rescore


# read -p "Press any key to continue"

# for ((i=1;i<=6;i++))
# do
# 	#evaluate the performance of the merged lm_eval
# 	echo 'Evaluate the performance of WER of 5 LM using eval03 shows'>> $task1path/5.4.6LOG
# 	while read line		
# 	do
# 		echo | ${mainpath}/scripts/lmrescore.sh $line lattices decode lm_int_eval_${i} plp-tglm_int_eval_${i} FALSE >> $task1path/5.4.6LOG
# 	done < "$store/temp2"

# 	#score eval03 of all LMs
# 	echo "receiving the mfl"
# 	while(true)
# 	do
# 		test -e "./plp-tglm_int_eval_${i}/eval03_DEV013-20010220-XX2000/rescore/rescore.mlf" && break
# 	done

# 	echo 'scoring all the files' >> $task1path/5.4.6LOG
# 	echo | ./scripts/score.sh plp-tglm_int_eval_${i} eval03 rescore >> $task1path/5.4.6LOG
# done


# while read line
# do
# 	rm -r challenge/plp-bg/${line}/merge
# 	rm -r challenge/plp-bg/${line}/decode

# 	echo "$line rescore:" 
# 	./scripts/mergelats.sh $line lattices decode challenge/plp-bg
# done < $store/challenge_dev

# while read line
# do
# 	while(true)
# 			do
# 				test -e "./challenge/plp-bg/$line/merge/LOG" && break
# 			done	
# 		while(true)
# 		do	
# 			egrep -c "HTK Configuration Parameters" challenge/plp-bg/$line/merge/LOG > ./store.t
# 			check=`cat ./store.t`
# 			if [[ $check == 2 ]]; then
# 				rm ./store.t
# 				break
# 			fi
# 		done
# done < $store/challenge_dev

# while read line
# do
# 	#generate decode directiory
# 	./scripts/hmmrescore.sh $line challenge/plp-bg merge challenge/plp-bg plp
# 	echo "Done"	
# done < $store/challenge_dev
# echo "Step3 finished!"

# 4. speaker adaptation for plp-bg, generate the challenge/plp-adapt-bg/ directory
# 4.1 hmmadapt.sh generate plp-adapt-bg/adapt
# while read line
# do
#    echo "$line rescore using plp"
# 	./scripts/hmmadapt.sh $line challenge/plp-bg decode challenge/plp-adapt-bg plp
# done < $store/challenge_dev

# while read line
# do
# 	while(true)
# 			do
# 				test -e "./challenge/plp-adapt-bg/$line/adapt/LOG.align" && break
# 			done	
# 		while(true)
# 		do	
# 			egrep -c "HTK Configuration Parameters" challenge/plp-adapt-bg/$line/adapt/LOG.align > ./store.t
# 			check=`cat ./store.t`
# 			if [[ $check == 2 ]]; then
# 				rm ./store.t
# 				break
# 			fi
# 		done
# done < $store/challenge_dev
# #4.2 hmmrescore.sh generate plp-adapt-bg/decode from plp-bg/merge 
# while read line
# do
# 	rm -r challenge/plp-adapt-bg/${line}/decode/
#     ./scripts/hmmrescore.sh -ADAPT challenge/plp-adapt-bg adapt $line challenge/plp-bg merge challenge/plp-adapt-bg plp
# done < $store/challenge_dev

# while(true)
# do
# 	test -e "./challenge/plp-adapt-bg/YTBGdev_YTB271-XXXXXXXX-XXXXXX/decode/rescore.mlf" && break
# done
# echo "Step4 finished!"

# #5 Generate grph-plp-bg dir, and adapt it !!!
# #5.1 hmmrescore.sh Generate grph-plp-bg/decode directory
# while read line
# do
#     ./scripts/hmmrescore.sh $line challenge/plp-bg merge challenge/grph-plp-bg grph-plp
# done < $store/challenge_dev

# ##check the file to complte and then continue
# while(true)
# do
# 	test -e "./challenge/grph-plp-bg/YTBGdev_YTB271-XXXXXXXX-XXXXXX/decode/LOG" && break
# done

# while(true)
# do	
# 	egrep -c File challenge/grph-plp-bg/YTBGdev_YTB271-XXXXXXXX-XXXXXX/decode/LOG > ./store.t
# 	cat ./store.t
# 	rm ./store.t
# 	read -p "check grph-plp-bg decode dir"
# done

# #5.2 adapt.sh Generate challenge/adapt-grph-plp/adapt directory !!!
# while read line
# do
# 	#statements
# 	./scripts/hmmadapt.sh \
# 	-OUTPASS challenge/adapt-grph-plp \
# 	${line} grph-plp-bg decode \
# 	challenge/adapt-grph-plp \
# 	grph-plp
# done < $store/challenge_dev

# #5.3 hmmrescore.sh Generate the adapt-grph-bg/decode directory
# while read line
# do
# 	./scripts/hmmrescore.sh -ADAPT challenge/adapt-grph-plp adapt \
# 	-OUTPASS challenge/adapt-grph-plp \
# 	${line} challenge/plp-bg merge \
# 	challenge/adapt-grph-plp \
# 	grph-plp
# done < ${store}/challenge_dev

# ##check the file to complte and then continue
# while(true)
# do
# 	test -e "./challenge/adapt-grph-plp/YTBGdev_YTB271-XXXXXXXX-XXXXXX/decode/LOG" && break
# done

# while(true)
# do	
# 	egrep -c File challenge/adapt-grph-plp/YTBGdev_YTB271-XXXXXXXX-XXXXXX/decode/LOG > ./store.t
# 	cat ./store.t
# 	rm ./store.t
# 	read -p "check adapt-grph-plp decode dir"
# done

# #6. Merge the MLF in plp-adapt-bg and adapt-graph-plp
# #6.1 Generate CN 
# while read line
# do
# 	./scripts/cnrescore.sh ${line} challenge/plp-adapt-bg decode challenge/plp-adapt-bg
# 	./scripts/cnrescore.sh ${line} challenge/adapt-grph-plp decode challenge/adapt-grph-plp

# done < $store/challenge_dev

# while(true)
# do
# 	test -e "./challenge/adapt-grph-plp/YTBGdev_YTB271-XXXXXXXX-XXXXXX/decode_cn/LOG" && break
# done
# while(true)
# do	
# 	egrep -c File ./challenge/adapt-grph-plp/YTBGdev_YTB271-XXXXXXXX-XXXXXX/decode_cn/LOG > ./store.t
# 	cat ./store.t
# 	rm ./store.t
# 	read -p "check adapt-grph-plp/decode_cn"
#  done

# #6.2 combine the two mlf by challenge.py
# echo "make directory for challenge.py"
# mkdir ./challenge/com_mlf_1/
# while read line
# do
# 	mkdir ./challenge/com_mlf_1/${line}/
# 	mkdir ./challenge/com_mlf_1/${line}/decode_cn/
# done < $store/challenge_dev
# # mapping trees
# while read line
# do
# 	rm  plp-adapt-bg/${line}/decode_cn/rescore_mappingtrees.mlf
# 	echo | base/conftools/smoothtree-mlf.pl lib/trees/plp-bg_decode_cn.tree\
# 	plp-adapt-bg/${line}/decode_cn/rescore.mlf >> plp-adapt-bg/${line}/decode_cn/rescore_mappingtrees.mlf
# done < $store/temp1

# python exp/shell/challenge.py
# echo 'Step 6 finished!'



# echo "begin to interpolate the weights"
# python "/home/jp697/Major/exp/shell/interpolation_challenge.py"


# echo "begin to merge the LMs"

# j=0
# weight=[]
# while read line
# do
# 	weight[j]=$line
# 	let j=$j+1
# 	echo $j
# done < ${challenge}/weight

# echo "Start the eval_${i} LM merge"
# echo ${weight[0]}
# base/bin/LMerge -C lib/cfgs/hlm.cfg \
# -i ${weight[0]} lms/lm1 \
# -i ${weight[1]} lms/lm2 \
# -i ${weight[2]} lms/lm3 \
# -i ${weight[3]} lms/lm4 \
# lib/wlists/train.lst lms/lm5 lm_int_challenge

# while read line
# do
# 	./scripts/lmrescore.sh $line lattices decode \
# lm_int_challenge challenge_try1 FALSE
# done < $store/challenge_sub

# ./scripts/score.sh challenge_try1 YTBEdevsub rescore
