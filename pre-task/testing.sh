mainpath='/home/jp697/Major'
devpath='/home/jp697/Major/lattices'
store='/home/jp697/Major/exp/temp_file'
task1path="${mainpath}/exp/task1"
challengepath="/home/jp697/Major/challenge/streams/"
storedat="/home/jp697/Major/challenge/store_dat/"
# '''
# 1. Generate dev and eval lists
# Output: 
# 	./exp/temp_file/challenge_dev 
# 	./exp/temp_file/challenge_eval
# '''
# cd $devpath
# echo |find -name 'YTBG*' -maxdepth 1 >> "$store/challenge_dev"
# echo |find -name 'YTBE*' -maxdepth 1 >> "$store/challenge_eval"
# cd -
# echo \
# '''
# 2. Generate 1-best output from the dev set
# Output:
# 	./challenge/plp-bg/${dev_set}/1best
# '''
# echo 'obtain the 1-best output from the eval03'
# while read line
# do
# 	./scripts/1bestlats.sh $line lattices decode plp-bg
# done < "$store/temp2"
# #checking the completion of the 1-best output process
# echo "receiving the mfl"
# ./scripts/score.sh plp-bg eval03 1best/LM12.0_IN-10.0
# while(true)
# do
# 	test -e "./challenge/plp-bg/YTBGdev_YTB271-XXXXXXXX-XXXXXX/1best/LM12.0_IN-10.0/rescore.mlf" && break
# done
# read -p 'check 1best/rescore.mlf'

# echo \
# '''
# 3. Interpolate the LMs
# Process:
# 	a. Convert 1-best output to data file 
# 	b. Generate stream files from the data file in step a 
# 	c. Interpolate the Language Model
# Output:
# 	a. ./challenge/store_dat/eval03.dat
# 	b. ./challenge/streams
# 	c. ./exp/temp_file/weight_challenge_dev 
# 	   ./lm_int_challenge
# '''
# #step a
# python ${mainpath}/exp/shell/ConvertDat_Challenge.py

# #step b
# echo "Begin to generate the stream files" 

# for ((j=1;j<=5;j++))
# do
# 	base/bin/LPlex -C lib/cfgs/hlm.cfg -s stream${j} -u -t \
# 	lms/lm${j} ${storedat}/eval03.dat
# 	cp stream${j} ${challengepath}
# 	rm stream${j}
# done

# echo "begin to interpolate the weights"

# step c
# calculate the weights
# python "/home/jp697/Major/exp/shell/interpolation_challenge.py"
# #Read the weights and interpolation
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
# lms/lm5 lm_int_eval

# echo \
# '''
# 4. Use the intepolated LM to rescore the eval set
# Output:
# 	./challenge/lm_int_plp/${eval_set}/rescore/
# '''

# echo 'Evaluate the performance of YTBEeval'
# while read line		
# do
# 	${mainpath}/scripts/lmrescore.sh $line lattices decode lm_int \
# 	plp-bg TRUE
# done < "$store/temp2"

# tgdir="plp-bg" #"adapt-plp-bg" #"adapt-grph-plp" #"adapt-tandem" #"adapt-grph-tandem" #"lm_int_plp" #"grph-plp-bg" #"plp-tandem" #"grph-tandem"
# passdir="rescore" #"decode" #"decode_cn" #"adapt"
# outdir='rescore.mlf' #rescore.mlf #LOG.align
# while read line
# do
# 	while(true)
# 		do
# 			test -e "./${tgdir}/$line/${passdir}/${outdir}" && break
# 		done
# 	echo "$line finished!"		
# done < $store/temp2

# echo \
# '''
# 3. Merge and Rescore for later use
# Process:
# 	a. Merge the rescore directiory of eval set
# 	b. Rescore using graphemic system
# 	c. Rescore using tandem system
# 	d. Rescore using grph-tandem system
#   e: Rescore using hybrid system
# Output:
# 	a. ./challenge/lm_int_plp/${eval_set}/merge/
# 	b. ./challenge/grph-plp-bg/${eval_set}/decode/
# 	c. ./challenge/plp-tandem/${eval_set}/decode/
# 	d. ./challenge/grph-tandem/${eval_set}/decode/
# 	e. ./challenge/hybrid/${eval_set}/decode/
# '''

# # step a
# while read line
# do
# 	# rm -r challenge/plp-bg/${line}/merge
# 	# rm -r challenge/plp-bg/${line}/decode
# 	echo "$line rescore:" 
# 	./scripts/mergelats.sh $line plp-bg rescore plp-bg
# done < $store/temp2

# tgdir="plp-bg" #"adapt-plp-bg" #"adapt-grph-plp" #"adapt-tandem" #"adapt-grph-tandem" #"lm_int_plp" #"grph-plp-bg" #"plp-tandem" #"grph-tandem"
# passdir="merge" #"decode" #"decode_cn" #"adapt"
# outdir='LOG' #rescore.mlf #LOG.align
# while read line
# do
# 	while(true)
# 		do
# 			test -e "./${tgdir}/$line/${passdir}/${outdir}" && break
# 		done
# 	echo "$line finished!"		
# done < $store/temp2
# # #step b
# # while read line
# # do
# # 	#generate decode directiory
# # 	./scripts/hmmrescore.sh $line plp-bg merge plp-bg \
# # 	plp
# # 	echo "Done"	
# # done < $store/temp2
# # echo "Step3 finished!"


# #step b
# while read line
# do
# 	#generate decode directiory
# 	./scripts/hmmrescore.sh $line plp-bg merge grph-plp-bg \
# 	grph-plp
# 	echo "Done"	
# done < $store/temp2
# echo "Step3 finished!"

# # # step c
# # while read line
# # do
# # 	#generate decode directiory
# # 	./scripts/hmmrescore.sh $line plp-bg merge plp-tandem\
# # 	tandem
# # 	echo "Done"	
# # done < $store/temp2
# # echo "Step3 finished!"

# # #step d
# # while read line
# # do
# # 	#generate decode directiory
# # 	./scripts/hmmrescore.sh $line plp-bg merge grph-tandem \
# # 	grph-tandem
# # 	echo "Done"	
# # done < $store/temp2
# # echo "Step3 finished!"

# step e
while read line
do
	#generate decode directiory
	./scripts/hmmrescore.sh $line plp-bg merge hybrid \
	hybrid
	echo "Done"	
done < $store/temp2
echo "Step3 finished!"

tgdir="hybrid" #"adapt-plp-bg" #"adapt-grph-plp" #"adapt-tandem" #"adapt-grph-tandem" #"lm_int_plp" #"grph-plp-bg" #"plp-tandem" #"grph-tandem"
passdir="decode" #"decode" #"decode_cn" #"adapt"
outdir='rescore.mlf' #rescore.mlf #LOG.align
while read line
do
	while(true)
		do
			test -e "./${tgdir}/$line/${passdir}/${outdir}" && break
		done
	echo "$line finished!"		
done < $store/temp2

# echo \
# '''
# 4. speaker adaptation use adapted plp system for plp and grph-plp
# Process:
# 	a. adapt plp
# 	b. adapt grph-plp
# 	c. adapt tandem
# 	d. adapt grph-tandem	
# Output:
# 	a. ./adapt-plp-bg/${eval_set}/adapt
# 	   ./adapt-plp-bg/${eval_set}/decode
# 	b. ./adapt-grph-plp/${eval_set}/adapt
# 	   ./adapt-grph-plp/${eval_set}/decode
# 	c. ./adapt-tandem/${eval_set}/adapt
# 	   ./adapt-tandem/${eval_set}/decode
# 	d. ./adapt-grph-tandem/${eval_set}/adapt
# 	   ./adapt-grph-tandem/${eval_set}/decode
# '''
# # # step a
# # while read line
# # do
# #    echo "$line rescore using plp"
# # 	./scripts/hmmadapt.sh $line plp-bg decode adapt-plp-bg \
# # 	plp
# # done < $store/temp2

# # while read line
# # do
# # 	./scripts/hmmrescore.sh -ADAPT adapt-plp-bg adapt \
# # 	${line} plp-bg merge \
# # 	adapt-plp-bg \
# # 	plp
# # done < $store/temp2

# #step b
# while read line
# do
#    echo "$line rescore using plp"
# 	./scripts/hmmadapt.sh $line grph-plp-bg decode adapt-grph-plp \
# 	plp
# done < $store/temp2

# tgdir="adapt-grph-plp" #"adapt-plp-bg" #"adapt-grph-plp" #"adapt-tandem" #"adapt-grph-tandem" #"lm_int_plp" #"grph-plp-bg" #"plp-tandem" #"grph-tandem"
# passdir="adapt" #"decode" #"decode_cn" #"adapt"
# outdir='LOG.align' #rescore.mlf #LOG.align
# while read line
# do
# 	while(true)
# 		do
# 			test -e "./${tgdir}/$line/${passdir}/${outdir}" && break
# 		done
# 	echo "$line finished!"		
# done < $store/temp2

# while read line
# do
# 	./scripts/hmmrescore.sh -ADAPT adapt-grph-plp adapt \
# 	${line} plp-bg merge \
# 	adapt-grph-plp \
# 	plp
# done < $store/temp2

# tgdir="adapt-grph-plp" #"adapt-plp-bg" #"adapt-grph-plp" #"adapt-tandem" #"adapt-grph-tandem" #"lm_int_plp" #"grph-plp-bg" #"plp-tandem" #"grph-tandem"
# passdir="decode" #"decode" #"decode_cn" #"adapt"
# outdir='rescore.mlf' #rescore.mlf #LOG.align
# while read line
# do
# 	while(true)
# 		do
# 			test -e "./${tgdir}/$line/${passdir}/${outdir}" && break
# 		done
# 	echo "$line finished!"		
# done < $store/temp2
# # #step c
# # while read line
# # do
# # 	echo "$line rescore using tandem"
# # 	./scripts/hmmadapt.sh $line plp-tandem decode adapt-tandem \
# # 	tandem
# # done < $store/temp2

# # while read line
# # do
# # 	./scripts/hmmrescore.sh -ADAPT adapt-tandem adapt \
# # 	${line} plp-bg merge \
# # 	adapt-tandem \
# # 	tandem
# # done < $store/temp2


# # #step d
# # while read line
# # do
# # 	echo "$line rescore using grph-tandem"
# # 	./scripts/hmmadapt.sh $line grph-tandem decode adapt-grph-tandem \
# # 	tandem
# # done < $store/temp2

# # while read line
# # do
# # 	./scripts/hmmrescore.sh -ADAPT adapt-grph-tandem adapt \
# # 	${line} plp-bg merge \
# # 	adapt-grph-tandem \
# # 	tandem
# # done < $store/temp2

# '''
# 5. Confusion Network
# Process:
# 	a1. CN from plp
# 	a2. CN from adapt-plp-bg
# 	b1. CN from grph-plp
# 	b2. CN from adapt-grph-plp
# 	e1. CN from hybrid
# Output:
# 	a1. ./challenge/lm_int_plp/${eval_set}/decode_cn
# 	a2. ./challenge/adapt-plp-bg/${eval_set}/decode_cn
# 	b1. ./challenge/grph-plp-bg/${eval_set}/decode_cn
# 	b2. ./challenge/adapt-grph-plp/${eval_set}/decode_cn
# '''

# while read line
# do
# 	#a1
# 	# ./scripts/cnrescore.sh ${line} plp-bg decode plp-bg
# 	#a2
# 	# ./scripts/cnrescore.sh ${line} adapt-plp-bg decode adapt-plp-bg
# 	#b1
# 	# ./scripts/cnrescore.sh ${line} grph-plp-bg decode grph-plp-bg
# 	#b2
# 	./scripts/cnrescore.sh ${line} adapt-grph-plp decode adapt-grph-plp
# 	#c1
# 	# ./scripts/cnrescore.sh ${line} plp-tandem decode plp-tandem
# 	#c2
# 	# ./scripts/cnrescore.sh ${line} adapt-tandem decode adapt-tandem
# 	#d1
# 	# ./scripts/cnrescore.sh ${line} grph-tandem decode grph-tandem
# 	#d2
# 	# ./scripts/cnrescore.sh ${line} adapt-grph-tandem decode adapt-grph-tandem
# 	# e1
# 	./scripts/cnrescore.sh ${line} hybrid decode hybrid
# done < $store/temp2

# tgdir="hybrid" #"adapt-plp-bg" #"adapt-grph-plp" #"adapt-tandem" #"adapt-grph-tandem" #"lm_int_plp" #"grph-plp-bg" #"plp-tandem" #"grph-tandem"
# passdir="decode_cn" #"decode" #"decode_cn" #"adapt"
# outdir='rescore.mlf' #rescore.mlf #LOG.align
# while read line
# do
# 	while(true)
# 		do
# 			test -e "./${tgdir}/$line/${passdir}/${outdir}" && break
# 		done
# 	echo "$line finished!"		
# done < $store/temp2

# '''
# 6. Combination
# Process:
# 	a. Use mapping-tree to reduce the over-high score
# 	b. Use challenge.py to combine two mlf
# '''
# # tg1="adapt-plp-bg"
# # tg2="adapt-grph-plp"
# # tgs="${tg1}+${tg2}"
# # trdir1="plp-bg_decode_cn.tree"
# # trdir2="grph-plp-bg_decode_cn.tree"
# while read line
# do
# 	# mkdir -p ./challenge/mlf_cnc/adapt-plp-bg+grph-tandem/combine/${line}/decode_cn/
# # 	# echo $line
# # 	mkdir -p ./challenge/mlf_cnc/${tgs}/combine/${line}/decode_cn/
# # # 	## rm  plp-adapt-bg/${line}/decode_cn/rescore_mappingtrees.mlf
# 	# trdir1="plp-bg_decode_cn.tree"
# 	# tg1="plp-bg"
# 	# echo | base/conftools/smoothtree-mlf.pl lib/trees/${trdir1}\
# 	# ./${tg1}/${line}/decode_cn/rescore.mlf > ./${tg1}/${line}/decode_cn/rescore_mappingtrees.mlf
# 	# tg1="adapt-plp-bg"
# 	# echo | base/conftools/smoothtree-mlf.pl lib/trees/${trdir1}\
# 	# ./${tg1}/${line}/decode_cn/rescore.mlf > ./${tg1}/${line}/decode_cn/rescore_mappingtrees.mlf

# 	trdir1="grph-plp-bg_decode_cn.tree"
# 	# tg1="grph-plp-bg"
# 	# echo | base/conftools/smoothtree-mlf.pl lib/trees/${trdir1}\
# 	# ./${tg1}/${line}/decode_cn/rescore.mlf > ./${tg1}/${line}/decode_cn/rescore_mappingtrees.mlf
# 	tg1="adapt-grph-plp"
# 	echo | base/conftools/smoothtree-mlf.pl lib/trees/${trdir1}\
# 	./${tg1}/${line}/decode_cn/rescore.mlf > ./${tg1}/${line}/decode_cn/rescore_mappingtrees.mlf

# 	# trdir1="tandem-bg_decode_cn.tree"
# 	# tg1="plp-tandem"
# 	# echo | base/conftools/smoothtree-mlf.pl lib/trees/${trdir1}\
# 	# ./${tg1}/${line}/decode_cn/rescore.mlf > ./${tg1}/${line}/decode_cn/rescore_mappingtrees.mlf
# 	# tg1="adapt-tandem"
# 	# echo | base/conftools/smoothtree-mlf.pl lib/trees/${trdir1}\
# 	# ./${tg1}/${line}/decode_cn/rescore.mlf > ./${tg1}/${line}/decode_cn/rescore_mappingtrees.mlf

# 	# trdir1="grph-tandem-bg_decode_cn.tree"
# 	# tg1="grph-tandem"
# 	# echo | base/conftools/smoothtree-mlf.pl lib/trees/${trdir1}\
# 	# ./${tg1}/${line}/decode_cn/rescore.mlf > ./${tg1}/${line}/decode_cn/rescore_mappingtrees.mlf
# 	# tg1="adapt-grph-tandem"
# 	# echo | base/conftools/smoothtree-mlf.pl lib/trees/${trdir1}\
# 	# ./${tg1}/${line}/decode_cn/rescore.mlf > ./${tg1}/${line}/decode_cn/rescore_mappingtrees.mlf

# 	trdir1="hybrid-bg_decode_cn.tree"
# 	tg1="hybrid"
# 	echo | base/conftools/smoothtree-mlf.pl lib/trees/${trdir1}\
# 	./${tg1}/${line}/decode_cn/rescore.mlf > ./${tg1}/${line}/decode_cn/rescore_mappingtrees.mlf
	
# done < $store/temp2

# sys=('adapt-grph-plp' 'hybrid')
# types=('decode_cn')
# # sys=('plp-bg' 'adapt-plp-bg' 'grph-plp-bg' 'adapt-grph-plp' \
# # 	'plp-tandem' 'adapt-tandem' 'grph-tandem' 'adapt-grph-tandem' 'hybrid')
# # types=('decode' 'decode_cn')

# # echo \
# # '''
# # mlf
# # '''
# # for t in ${types[@]};
# # do
# # 	for i in ${sys[@]};
# # 	do
# # 		tg1=$i
# # 		decode_type='decode_cn'
# # 		for j in ${sys[@]};
# # 		do
# # 			if [ $i == $j ]
# # 			then
# # 				continue
# # 			else
# # 				tg2=$j

# # 				tgs="${tg1}+${tg2}_${decode_type}"

# # 				while read line
# # 				do
# # 					mkdir -p ./mlf_combine/${tgs}/combine/${line}/${decode_type}/
# # 				# python exp/shell/CNC.py
# # 				done < $store/temp2
# # 				python exp/shell/challenge_dev.py ${tg1} ${tg2} ${decode_type}
# # 				# 
# # 				echo 'MLF_combination' >> ./challenge/LOG_eval.LOG
# # 				echo $tgs
# # 				tg=$tgs #"adapt-grph-plp" #"adapt-tandem" #"adapt-grph-tandem" "lm_int_plp" #"grph-plp-bg" #"plp-tandem" #"grph-tandem"
# # 				echo $tg >> ./challenge/LOG_eval.LOG 
# # 				echo | ./scripts/score.sh ./mlf_combine/${tg}/combine eval03 ${decode_type} >> ./challenge/LOG_eval.LOG
# # 			fi
# # 			rm -r ./mlf_combine/${tgs}/
# # 			# '''
# # 		done
# # 	done
# # done

# for t in ${types[@]};
# do
# 	for i in ${sys[@]};
# 	do
# 		tg1=$i
# 		decode_type='decode_cn'
# 		for j in ${sys[@]};
# 		do
# 			if [ $i == $j ]
# 			then
# 				continue
# 			else
# 				tg2=$j

# 				tgs="CNC_${tg1}+${tg2}"

# 				while read line
# 				do
# 					mkdir -p ./mlf_cnc/${tgs}/combine/${line}/${decode_type}/
# 				# python exp/shell/CNC.py
# 				done < $store/temp2
# 				python exp/shell/CNC_dev03.py ${tg1} ${tg2} temp2 
# 				# 
# 				echo $tgs
# 				tg=$tgs #"adapt-grph-plp" #"adapt-tandem" #"adapt-grph-tandem" "lm_int_plp" #"grph-plp-bg" #"plp-tandem" #"grph-tandem"
# 				echo $tg >> ./challenge/LOG_eval.LOG 
# 				echo | ./scripts/score.sh ./mlf_cnc/${tg}/combine eval03 ${decode_type} >> ./challenge/LOG_eval.LOG
# 			fi
# 			rm -r ./mlf_cnc/${tgs}/
# 			# '''
# 		done
# 	done
# done
# tg1='plp-bg'
# tg2='adapt-plp-bg'
# decode_type='decode_cn'
# tgs="${tg1}+${tg2}_${decode_type}"
# while read line
# do
# 	mkdir -p ./mlf_cnc/${tgs}/combine/${line}/${decode_type}/
# # python exp/shell/CNC.py
# done < $store/temp2
# python exp/shell/challenge_dev.py ${tg1} ${tg2} ${decode_type}
# # 
# echo $tgs
# tg=$tgs #"adapt-grph-plp" #"adapt-tandem" #"adapt-grph-tandem" "lm_int_plp" #"grph-plp-bg" #"plp-tandem" #"grph-tandem"
# echo $tg >> ./challenge/LOG_eval.LOG 
# echo | ./scripts/score.sh ./mlf_cnc/${tg}/combine eval03 ${decode_type} >> ./challenge/LOG_eval.LOG


# 7. Scoring
# Output:
# 	./scoring/
# '''
# tg="plp-bg" #"adapt-grph-plp" #"adapt-tandem" #"adapt-grph-tandem" "lm_int_plp" #"grph-plp-bg" #"plp-tandem" #"grph-tandem"
# echo $tg  > ./challenge/LOG_eval.LOG
# echo | ./scripts/score.sh ${tg} eval03 decode >> ./challenge/LOG_eval.LOG

# echo $tg
# echo | ./scripts/score.sh ${tg} eval03 decode_cn >> ./challenge/LOG_eval.LOG


# tg="adapt-plp-bg" #"adapt-grph-plp" #"adapt-tandem" #"adapt-grph-tandem" "lm_int_plp" #"grph-plp-bg" #"plp-tandem" #"grph-tandem"
# echo $tg >> ./challenge/LOG_eval.LOG 
# echo | ./scripts/score.sh ${tg} eval03 decode >> ./challenge/LOG_eval.LOG

# echo $tg 
# echo | ./scripts/score.sh ${tg} eval03 decode_cn >> ./challenge/LOG_eval.LOG

# tg="grph-plp-bg" #"adapt-grph-plp" #"adapt-tandem" #"adapt-grph-tandem" "lm_int_plp" #"grph-plp-bg" #"plp-tandem" #"grph-tandem"
# echo $tg >> ./challenge/LOG_eval.LOG 
# echo | ./scripts/score.sh ${tg} eval03 decode >> ./challenge/LOG_eval.LOG

# echo $tg
# echo | ./scripts/score.sh ${tg} eval03 decode_cn >> ./challenge/LOG_eval.LOG

# tg="adapt-grph-plp" #"adapt-grph-plp" #"adapt-tandem" #"adapt-grph-tandem" "lm_int_plp" #"grph-plp-bg" #"plp-tandem" #"grph-tandem"
# echo $tg >> ./challenge/LOG_eval.LOG
# echo | ./scripts/score.sh ${tg} eval03 decode >> ./challenge/LOG_eval.LOG

# echo $tg
# echo | ./scripts/score.sh ${tg} eval03 decode_cn >> ./challenge/LOG_eval.LOG

# tg="plp-tandem" #"adapt-grph-plp" #"adapt-tandem" #"adapt-grph-tandem" "lm_int_plp" #"grph-plp-bg" #"plp-tandem" #"grph-tandem"
# echo $tg >> ./challenge/LOG_eval.LOG 
# echo | ./scripts/score.sh ${tg} eval03 decode  >> ./challenge/LOG_eval.LOG

# echo $tg
# echo | ./scripts/score.sh ${tg} eval03 decode_cn >> ./challenge/LOG_eval.LOG

# tg="adapt-tandem" #"adapt-grph-plp" #"adapt-tandem" #"adapt-grph-tandem" "lm_int_plp" #"grph-plp-bg" #"plp-tandem" #"grph-tandem"
# echo $tg >> ./challenge/LOG_eval.LOG
# echo | ./scripts/score.sh ${tg} eval03 decode  >> ./challenge/LOG_eval.LOG

# echo $tg
# echo | ./scripts/score.sh ${tg} eval03 decode_cn >> ./challenge/LOG_eval.LOG

# tg="grph-tandem" #"adapt-grph-plp" #"adapt-tandem" #"adapt-grph-tandem" "lm_int_plp" #"grph-plp-bg" #"plp-tandem" #"grph-tandem"
# echo $tg >> ./challenge/LOG_eval.LOG 
# echo | ./scripts/score.sh ${tg} eval03 decode  >> ./challenge/LOG_eval.LOG

# echo $tg
# echo | ./scripts/score.sh ${tg} eval03 decode_cn >> ./challenge/LOG_eval.LOG

# tg="adapt-grph-tandem" #"adapt-grph-plp" #"adapt-tandem" #"adapt-grph-tandem" "lm_int_plp" #"grph-plp-bg" #"plp-tandem" #"grph-tandem"
# echo $tg >> ./challenge/LOG_eval.LOG
# echo | ./scripts/score.sh ${tg} eval03 decode >> ./challenge/LOG_eval.LOG

# echo $tg
# echo | ./scripts/score.sh ${tg} eval03 decode_cn >> ./challenge/LOG_eval.LOG

# tg="hybrid" #"adapt-grph-plp" #"adapt-tandem" #"adapt-grph-tandem" "lm_int_plp" #"grph-plp-bg" #"plp-tandem" #"grph-tandem"
# echo $tg >> ./challenge/LOG_eval.LOG
# echo | ./scripts/score.sh ${tg} eval03 decode >> ./challenge/LOG_eval.LOG

# echo $tg 
# echo | ./scripts/score.sh ${tg} eval03 decode_cn >> ./challenge/LOG_eval.LOG
# tg="grph-plp-bg" #"adapt-grph-plp" #"adapt-tandem" #"adapt-grph-tandem" "lm_int_plp" #"grph-plp-bg" #"plp-tandem" #"grph-tandem"
# ./scripts/score.sh ${tg} eval03 decode
# # tg="adapt-plp-bg" #"adapt-grph-plp" #"adapt-tandem" #"adapt-grph-tandem" "lm_int_plp" #"grph-plp-bg" #"plp-tandem" #"grph-tandem"
# # ./scripts/score.sh ${tg} eval03 decode

# tg="grph-plp-bg" #"adapt-grph-plp" #"adapt-tandem" #"adapt-grph-tandem" "lm_int_plp" #"grph-plp-bg" #"plp-tandem" #"grph-tandem"
# ./scripts/score.sh ${tg} eval03 decode
# # tg="adapt-grph-plp" #"adapt-grph-plp" #"adapt-tandem" #"adapt-grph-tandem" "lm_int_plp" #"grph-plp-bg" #"plp-tandem" #"grph-tandem"
# # ./scripts/score.sh ${tg} eval03 decode

# tg="plp-tandem" #"adapt-grph-plp" #"adapt-tandem" #"adapt-grph-tandem" "lm_int_plp" #"grph-plp-bg" #"plp-tandem" #"grph-tandem"
# ./scripts/score.sh ${tg} eval03 decode
# # tg="adapt-tandem" #"adapt-grph-plp" #"adapt-tandem" #"adapt-grph-tandem" "lm_int_plp" #"grph-plp-bg" #"plp-tandem" #"grph-tandem"
# # ./scripts/score.sh ${tg} eval03 decode

# tg="grph-tandem" #"adapt-grph-plp" #"adapt-tandem" #"adapt-grph-tandem" "lm_int_plp" #"grph-plp-bg" #"plp-tandem" #"grph-tandem"
# ./scripts/score.sh ${tg} eval03 decode
# # tg="adapt-grph-tandem" #"adapt-grph-plp" #"adapt-tandem" #"adapt-grph-tandem" "lm_int_plp" #"grph-plp-bg" #"plp-tandem" #"grph-tandem"
# # ./scripts/score.sh ${tg} eval03 decode


# tg="hybrid" #"adapt-grph-plp" #"adapt-tandem" #"adapt-grph-tandem" "lm_int_plp" #"grph-plp-bg" #"plp-tandem" #"grph-tandem"
# ./scripts/score.sh ${tg} eval03 decode
# tg="grph-plp-bg" #"adapt-grph-plp" #"adapt-tandem" #"adapt-grph-tandem" "lm_int_plp" #"grph-plp-bg" #"plp-tandem" #"grph-tandem"
# echo | ./scripts/score.sh ${tg} eval03 decode >> ./challenge/${tg}.LOG
# tg="grph-plp-bg" #"adapt-grph-plp" #"adapt-tandem" #"adapt-grph-tandem" "lm_int_plp" #"grph-plp-bg" #"plp-tandem" #"grph-tandem"
# echo | ./scripts/score.sh ${tg} eval03 decode_cn >> ./challenge/${tg}.LOG
# cat ./challenge/${tg}.LOG
# tg="adapt-grph-plp" #"adapt-grph-plp" #"adapt-tandem" #"adapt-grph-tandem" "lm_int_plp" #"grph-plp-bg" #"plp-tandem" #"grph-tandem"
# echo | ./scripts/score.sh ${tg} eval03 decode >> ./challenge/${tg}.LOG
# tg="adapt-grph-plp" #"adapt-grph-plp" #"adapt-tandem" #"adapt-grph-tandem" "lm_int_plp" #"grph-plp-bg" #"plp-tandem" #"grph-tandem"
# echo | ./scripts/score.sh ${tg} eval03 decode_cn >> ./challenge/${tg}.LOG
# cat ./challenge/${tg}.LOG
# tg="adapt-tandem" #"adapt-grph-plp" #"adapt-tandem" #"adapt-grph-tandem" "lm_int_plp" #"grph-plp-bg" #"plp-tandem" #"grph-tandem"
# echo | ./scripts/score.sh ${tg} eval03 decode_cn >> ./challenge/${tg}.LOG
# cat ./challenge/${tg}.LOG
# tg="adapt-grph-tandem" #"adapt-grph-plp" #"adapt-tandem" #"adapt-grph-tandem" "lm_int_plp" #"grph-plp-bg" #"plp-tandem" #"grph-tandem"
# echo | ./scripts/score.sh ${tg} eval03 decode_cn >> ./challenge/${tg}.LOG
# cat ./challenge/${tg}.LOG
# tg="plp-tandem" #"adapt-grph-plp" #"adapt-tandem" #"adapt-grph-tandem" "lm_int_plp" #"grph-plp-bg" #"plp-tandem" #"grph-tandem"
# echo | ./scripts/score.sh ${tg} eval03 decode_cn >> ./challenge/${tg}.LOG
# cat ./challenge/${tg}.LOG
# tg="grph-tandem" #"adapt-grph-plp" #"adapt-tandem" #"adapt-grph-tandem" "lm_int_plp" #"grph-plp-bg" #"plp-tandem" #"grph-tandem"
# echo | ./scripts/score.sh ${tg} eval03 decode_cn >> ./challenge/${tg}.LOG
# cat ./challenge/${tg}.LOG
# tg="mlf_cnc/adapt-plp-bg+grph-tandem/combine" #"adapt-grph-plp" #"adapt-tandem" #"adapt-grph-tandem" "lm_int_plp" #"grph-plp-bg" #"plp-tandem" #"grph-tandem"
# echo | ./scripts/score.sh ${tg} eval03 decode_cn >> ./challenge/${tg}.LOG
# cat ./challenge/${tg}.LOG
# tg="mlf_cnc/plp-tandem+adapt-grph-plp/combine" #"adapt-grph-plp" #"adapt-tandem" #"adapt-grph-tandem" "lm_int_plp" #"grph-plp-bg" #"plp-tandem" #"grph-tandem"
# echo | ./scripts/score.sh ${tg} eval03 decode_cn >> ./challenge/${tg}.LOG
# cat ./challenge/${tg}.LOG
# tg="mlf_cnc/adapt-plp-bg+grph-tandem+plp-tandem+adapt-grph-plp/combine" #"adapt-grph-plp" #"adapt-tandem" #"adapt-grph-tandem" "lm_int_plp" #"grph-plp-bg" #"plp-tandem" #"grph-tandem"
# echo | ./scripts/score.sh ${tg} eval03 decode_cn >> ./challenge/${tg}.LOG
# cat ./challenge/${tg}.LOG
# tg="hybrid" #"adapt-grph-plp" #"adapt-tandem" #"adapt-grph-tandem" "lm_int_plp" #"grph-plp-bg" #"plp-tandem" #"grph-tandem"
# echo | ./scripts/score.sh ${tg} eval03 decode >> ./challenge/${tg}.LOG
# cat ./challenge/${tg}.LOG
# tg="hybrid" #"adapt-grph-plp" #"adapt-tandem" #"adapt-grph-tandem" "lm_int_plp" #"grph-plp-bg" #"plp-tandem" #"grph-tandem"
# echo | ./scripts/score.sh ${tg} eval03 decode_cn >> ./challenge/${tg}.LOG
# cat ./challenge/${tg}.LOG
# tg="mlf_cnc/hybrid+grph-tandem/combine" #"adapt-grph-plp" #"adapt-tandem" #"adapt-grph-tandem" "lm_int_plp" #"grph-plp-bg" #"plp-tandem" #"grph-tandem"
# echo | ./scripts/score.sh ${tg} eval03 decode_cn >> ./challenge/${tg}.LOG
# cat ./challenge/${tg}.LOG
# tg="mlf_cnc/hybrid+grph-tandem+adapt-plp-bg+grph-tandem/combine" #"adapt-grph-plp" #"adapt-tandem" #"adapt-grph-tandem" "lm_int_plp" #"grph-plp-bg" #"plp-tandem" #"grph-tandem"
# echo | ./scripts/score.sh ${tg} eval03 decode_cn >> ./challenge/${tg}.LOG
# cat ./challenge/${tg}.LOG
# ./scripts/score.sh ${tg}YTBEeval decode_cn
# tg="mlf_cnc/adapt-plp-bg+adapt-grph-plp/combine" #"adapt-grph-plp" #"adapt-tandem" #"adapt-grph-tandem" "lm_int_plp" #"grph-plp-bg" #"plp-tandem" #"grph-tandem"
# echo | ./scripts/score.sh ${tg} eval03 decode_cn >> ./challenge/${tg}.LOG
# cat ./challenge/${tg}.LOG
# tg="mlf_cnc/adapt-plp-bg+adapt-grph-plp/combine" #"adapt-grph-plp" #"adapt-tandem" #"adapt-grph-tandem" "lm_int_plp" #"grph-plp-bg" #"plp-tandem" #"grph-tandem"
# echo | ./scripts/score.sh ${tg} eval03 decode_cn >> ./challenge/${tg}.LOG
# cat ./challenge/${tg}.LOG
# tg="mlf_cnc/adapt-plp-bg+grph-tandem/combine" #"adapt-grph-plp" #"adapt-tandem" #"adapt-grph-tandem" "lm_int_plp" #"grph-plp-bg" #"plp-tandem" #"grph-tandem"
# echo | ./scripts/score.sh ${tg} eval03 decode_cn >> ./challenge/${tg}.LOG
# cat ./challenge/${tg}.LOG
# '''
# 8. checking
# '''

# tgdir="plp-bg" #"adapt-plp-bg" #"adapt-grph-plp" #"adapt-tandem" #"adapt-grph-tandem" #"lm_int_plp" #"grph-plp-bg" #"plp-tandem" #"grph-tandem"
# passdir="decode_cn" #"decode" #"decode_cn" #"adapt"
# outdir='rescore.mlf' #rescore.mlf #LOG.align
# while read line
# do
# 	while(true)
# 		do
# 			test -e "./${tgdir}/$line/${passdir}/${outdir}" && break
# 		done
# 	echo "$line finished!"		
# done < $store/temp2

# '''
# 9. Remove files
# '''

# tgdir="adapt-grph-tandem" #"adapt-plp-bg" #"adapt-grph-plp" #"adapt-tandem" #"adapt-grph-tandem" #"lm_int_plp" #"grph-plp-bg" #"plp-tandem" #"grph-tandem"
# passdir="decode" #"decode" #"decode_cn" #"adapt"
# outdir='rescore.mlf' #rescore.mlf #LOG.align

# while read line
# do
# 	rm -r ./${tgdir}/$line/${passdir}	
# done < $store/temp2

