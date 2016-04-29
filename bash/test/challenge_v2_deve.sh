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
# 	./exp/temp_file/challenge_dev
# '''
# cd $devpath
# echo |find -name 'YTBG*' -maxdepth 1 >> "$store/challenge_dev"
# echo |find -name 'YTBE*' -maxdepth 1 >> "$store/challenge_dev"
# cd -

# '''
# 2. Generate 1-best output from the dev set
# Output:
# 	./challenge/plp-bg/${dev_set}/1best
# '''
# echo 'obtain the 1-best output from the YTBEdev'
# while read line
# do
# 	echo $line
# 	./scripts/1bestlats.sh $line lattices decode challenge/lm_int_plp
# done < "$store/challenge_dev"
#checking the completion of the 1-best output process


# tgdir="lm_int_plp" #"adapt-lm-plp" #"adapt-lm-grph" #"adapt-lm-tandem" #"adapt-lm-grph-tandem" #"lm_int_plp" #"lm_int_grph" #"lm_int_tandem" #"lm_int_grph-tandem"
# passdir="1best/LM12.0_IN-10.0" #"decode" #"decode_cn" #"adapt"
# outdir='rescore.mlf' #rescore.mlf #LOG.align
# while read line
# do
# 	while(true)
# 		do
# 			test -e "./challenge/${tgdir}/$line/${passdir}/${outdir}" && break
# 		done
# 	echo "$line finished!"		
# done < $store/challenge_dev

# echo \
# '''
# 3. Interpolate the LMs
# Process:
# 	a. Convert 1-best output to data file 
# 	b. Generate stream files from the data file in step a 
# 	c. Interpolate the Language Model
# Output:
# 	a. ./challenge/store_dat/YTBEdev.dat
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
# 	lms/lm${j} ${storedat}/YTBEdev.dat
# 	cp stream${j} ${challengepath}
# 	rm stream${j}
# done

# echo "begin to interpolate the weights"

# #step c
# #calculate the weights
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
# lms/lm5 lm_int_challenge

# echo \
# '''
# 4. Use the intepolated LM to rescore the eval set
# Output:
# 	./challenge/lm_int_plp/${eval_set}/rescore/
# '''

# echo 'Evaluate the performance of YTBEeval'
# while read line		
# do
# 	${mainpath}/scripts/lmrescore.sh $line lattices decode lm_int_challenge \
# 	challenge/lm_int_plp TRUE
# done < "$store/challenge_dev"

# tgdir="lm_int_plp" #"adapt-lm-plp" #"adapt-lm-grph" #"adapt-lm-tandem" #"adapt-lm-grph-tandem" #"lm_int_plp" #"lm_int_grph" #"lm_int_tandem" #"lm_int_grph-tandem"
# passdir="rescore" #"decode" #"decode_cn" #"adapt"
# outdir='rescore.mlf' #rescore.mlf #LOG.align
# while read line
# do
# 	while(true)
# 		do
# 			test -e "./challenge/${tgdir}/$line/${passdir}/${outdir}" && break
# 		done
# 	echo "$line finished!"		
# done < $store/challenge_dev

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
# 	b. ./challenge/lm_int_grph/${eval_set}/decode/
# 	c. ./challenge/lm_int_tandem/${eval_set}/decode/
# 	d. ./challenge/lm_int_grph-tandem/${eval_set}/decode/
# 	e. ./challenge/lm_int_hybrid/${eval_set}/decode/
# '''

# # step a
# while read line
# do
# 	# rm -r challenge/plp-bg/${line}/merge
# 	# rm -r challenge/plp-bg/${line}/decode
# 	echo "$line rescore:" 
# 	./scripts/mergelats.sh $line challenge/lm_int_plp rescore challenge/lm_int_plp
# done < $store/challenge_dev

# tgdir="lm_int_plp" #"adapt-lm-plp" #"adapt-lm-grph" #"adapt-lm-tandem" #"adapt-lm-grph-tandem" #"lm_int_plp" #"lm_int_grph" #"lm_int_tandem" #"lm_int_grph-tandem"
# passdir="merge" #"decode" #"decode_cn" #"adapt"
# outdir='LOG' #rescore.mlf #LOG.align
# while read line
# do
# 	while(true)
# 		do
# 			test -e "./challenge/${tgdir}/$line/${passdir}/${outdir}" && break
# 		done
# 	echo "$line finished!"		
# done < $store/challenge_dev

# #step b
# while read line
# do
# 	#generate decode directiory
# 	./scripts/hmmrescore.sh $line challenge/lm_int_plp merge challenge/lm_int_plp \
# 	plp
# 	echo "Done"	
# done < $store/challenge_dev
# echo "Step3 finished!"


# #step b
# while read line
# do
# 	#generate decode directiory
# 	./scripts/hmmrescore.sh $line challenge/lm_int_plp merge challenge/lm_int_grph \
# 	grph-plp
# 	echo "Done"	
# done < $store/challenge_dev
# echo "Step3 finished!"

# #step c
# while read line
# do
# 	#generate decode directiory
# 	./scripts/hmmrescore.sh $line challenge/lm_int_plp merge challenge/lm_int_tandem \
# 	tandem
# 	echo "Done"	
# done < $store/challenge_dev
# echo "Step3 finished!"

# #step d
# while read line
# do
# 	#generate decode directiory
# 	./scripts/hmmrescore.sh $line challenge/lm_int_plp merge challenge/lm_int_grph-tandem \
# 	grph-tandem
# 	echo "Done"	
# done < $store/challenge_dev
# echo "Step3 finished!"

# # step e
# while read line
# do
# 	#generate decode directiory
# 	./scripts/hmmrescore.sh $line challenge/lm_int_plp merge challenge/lm_int_hybrid \
# 	hybrid
# 	echo "Done"	
# done < $store/challenge_dev
# echo "Step3 finished!"

# tgdir="lm_int_hybrid" #"adapt-lm-plp" #"adapt-lm-grph" #"adapt-lm-tandem" #"adapt-lm-grph-tandem" #"lm_int_plp" #"lm_int_grph" #"lm_int_tandem" #"lm_int_grph-tandem"
# passdir="decode" #"decode" #"decode_cn" #"adapt"
# outdir='rescore.mlf' #rescore.mlf #LOG.align
# while read line
# do
# 	while(true)
# 		do
# 			test -e "./challenge/${tgdir}/$line/${passdir}/${outdir}" && break
# 		done
# 	echo "$line finished!"		
# done < $store/challenge_dev

# '''
# 4. speaker adaptation use adapted plp system for plp and grph-plp
# Process:
# 	a. adapt plp
# 	b. adapt grph-plp
# 	c. adapt tandem
# 	d. adapt grph-tandem	
# Output:
# 	a. ./adapt-lm-plp/${eval_set}/adapt
# 	   ./adapt-lm-plp/${eval_set}/decode
# 	b. ./adapt-lm-grph/${eval_set}/adapt
# 	   ./adapt-lm-grph/${eval_set}/decode
# 	c. ./adapt-lm-tandem/${eval_set}/adapt
# 	   ./adapt-lm-tandem/${eval_set}/decode
# 	d. ./adapt-lm-grph-tandem/${eval_set}/adapt
# 	   ./adapt-lm-grph-tandem/${eval_set}/decode
# '''
# #step a
# while read line
# do
#    echo "$line rescore using plp"
# 	./scripts/hmmadapt.sh $line challenge/lm_int_plp decode challenge/adapt-lm-plp \
# 	plp
# done < $store/challenge_dev

# #step b
# while read line
# do
#    echo "$line rescore using plp"
# 	./scripts/hmmadapt.sh $line challenge/lm_int_grph decode challenge/adapt-lm-grph \
# 	plp
# done < $store/challenge_dev

# #step c
# while read line
# do
# 	echo "$line rescore using tandem"
# 	./scripts/hmmadapt.sh $line challenge/lm_int_tandem decode challenge/adapt-lm-tandem \
# 	tandem
# done < $store/challenge_dev

# #step d
# while read line
# do
# 	echo "$line rescore using grph-tandem"
# 	./scripts/hmmadapt.sh $line challenge/lm_int_grph-tandem decode challenge/adapt-lm-grph-tandem \
# 	tandem
# done < $store/challenge_dev

# tgdir="adapt-lm-grph-tandem" #"adapt-lm-plp" #"adapt-lm-grph" #"adapt-lm-tandem" #"adapt-lm-grph-tandem" #"lm_int_plp" #"lm_int_grph" #"lm_int_tandem" #"lm_int_grph-tandem"
# passdir="adapt" #"decode" #"decode_cn" #"adapt"
# outdir='LOG.align' #rescore.mlf #LOG.align
# while read line
# do
# 	while(true)
# 		do
# 			test -e "./challenge/${tgdir}/$line/${passdir}/${outdir}" && break
# 		done
# 	echo "$line finished!"		
# done < $store/challenge_dev


# while read line
# do
# 	./scripts/hmmrescore.sh -ADAPT challenge/adapt-lm-plp adapt \
# 	${line} challenge/lm_int_plp merge \
# 	challenge/adapt-lm-plp\
# 	plp
# done < ${store}/challenge_dev
# while read line
# do
# 	./scripts/hmmrescore.sh -ADAPT challenge/adapt-lm-grph adapt \
# 	${line} challenge/lm_int_plp merge \
# 	challenge/adapt-lm-grph\
# 	plp
# done < ${store}/challenge_dev
# while read line
# do
# 	./scripts/hmmrescore.sh -ADAPT challenge/adapt-lm-tandem adapt \
# 	${line} challenge/lm_int_plp merge \
# 	challenge/adapt-lm-tandem\
# 	tandem
# done < ${store}/challenge_dev

# while read line
# do
# 	./scripts/hmmrescore.sh -ADAPT challenge/adapt-lm-grph-tandem adapt \
# 	${line} challenge/lm_int_plp merge \
# 	challenge/adapt-lm-grph-tandem\
# 	tandem
# done < ${store}/challenge_dev

# tgdir="adapt-lm-grph-tandem" #"adapt-lm-plp" #"adapt-lm-grph" #"adapt-lm-tandem" #"adapt-lm-grph-tandem" #"lm_int_plp" #"lm_int_grph" #"lm_int_tandem" #"lm_int_grph-tandem"
# passdir="decode" #"decode" #"decode_cn" #"adapt"
# outdir='rescore.mlf' #rescore.mlf #LOG.align
# while read line
# do
# 	while(true)
# 		do
# 			test -e "./challenge/${tgdir}/$line/${passdir}/${outdir}" && break
# 		done
# 	echo "$line finished!"		
# done < $store/challenge_dev

# '''
# 5. Confusion Network
# Process:
# 	a1. CN from plp
# 	a2. CN from adapt-lm-plp
# 	b1. CN from grph-plp
# 	b2. CN from adapt-lm-grph
# 	e1. CN from hybrid
# Output:
# 	a1. ./challenge/lm_int_plp/${eval_set}/decode_cn
# 	a2. ./challenge/adapt-lm-plp/${eval_set}/decode_cn
# 	b1. ./challenge/lm_int_grph/${eval_set}/decode_cn
# 	b2. ./challenge/adapt-lm-grph/${eval_set}/decode_cn
# '''

# while read line
# do
# 	#a1
# 	./scripts/cnrescore.sh ${line} challenge/lm_int_plp decode challenge/lm_int_plp
# 	#a2
# 	./scripts/cnrescore.sh ${line} challenge/adapt-lm-plp decode challenge/adapt-lm-plp
# 	#b1
# 	./scripts/cnrescore.sh ${line} challenge/lm_int_grph decode challenge/lm_int_grph
# 	#b2
# 	./scripts/cnrescore.sh ${line} challenge/adapt-lm-grph decode challenge/adapt-lm-grph
# 	#c1
# 	./scripts/cnrescore.sh ${line} challenge/lm_int_tandem decode challenge/lm_int_tandem
# 	#c2
# 	./scripts/cnrescore.sh ${line} challenge/adapt-lm-tandem decode challenge/adapt-lm-tandem
# 	#d1
# 	./scripts/cnrescore.sh ${line} challenge/lm_int_grph-tandem decode challenge/lm_int_grph-tandem
# 	#d2
# 	./scripts/cnrescore.sh ${line} challenge/adapt-lm-grph-tandem decode challenge/adapt-lm-grph-tandem
# 	# e1
# 	./scripts/cnrescore.sh ${line} challenge/lm_int_hybrid decode challenge/lm_int_hybrid
# done < $store/challenge_dev

# tgdir="lm_int_hybrid" #"adapt-lm-plp" #"adapt-lm-grph" #"adapt-lm-tandem" #"adapt-lm-grph-tandem" #"lm_int_plp" #"lm_int_grph" #"lm_int_tandem" #"lm_int_grph-tandem"
# passdir="decode_cn" #"decode" #"decode_cn" #"adapt"
# outdir='rescore.mlf' #rescore.mlf #LOG.align
# while read line
# do
# 	while(true)
# 		do
# 			test -e "./challenge/${tgdir}/$line/${passdir}/${outdir}" && break
# 		done
# 	echo "$line finished!"		
# done < $store/challenge_dev

# '''
# 6. Combination
# Process:
# 	a. Use mapping-tree to reduce the over-high score
# 	b. Use challenge.py to combine two mlf
# '''
# # tg1="adapt-lm-plp"
# # tg2="adapt-lm-grph"
# # tgs="${tg1}+${tg2}"
# # trdir1="plp-bg_decode_cn.tree"
# # trdir2="grph-plp-bg_decode_cn.tree"
# while read line
# do
# 	# mkdir -p ./challenge/mlf_cnc/adapt-lm-plp+lm_int_grph-tandem/combine/${line}/decode_cn/
# # 	# echo $line

# # 	mkdir -p ./challenge/mlf_combine/${tgs}/combine/${line}/decode_cn/
# # # 	## rm  plp-adapt-bg/${line}/decode_cn/rescore_mappingtrees.mlf
# 	trdir1="plp-bg_decode_cn.tree"
# 	tg1="lm_int_plp"
# 	echo | base/conftools/smoothtree-mlf.pl lib/trees/${trdir1}\
# 	./challenge/${tg1}/${line}/decode_cn/rescore.mlf > ./challenge/${tg1}/${line}/decode_cn/rescore_mappingtrees.mlf
# 	tg1="adapt-lm-plp"
# 	echo | base/conftools/smoothtree-mlf.pl lib/trees/${trdir1}\
# 	./challenge/${tg1}/${line}/decode_cn/rescore.mlf > ./challenge/${tg1}/${line}/decode_cn/rescore_mappingtrees.mlf

# 	trdir1="grph-plp-bg_decode_cn.tree"
# 	tg1="lm_int_grph"
# 	echo | base/conftools/smoothtree-mlf.pl lib/trees/${trdir1}\
# 	./challenge/${tg1}/${line}/decode_cn/rescore.mlf > ./challenge/${tg1}/${line}/decode_cn/rescore_mappingtrees.mlf
# 	tg1="adapt-lm-grph"
# 	echo | base/conftools/smoothtree-mlf.pl lib/trees/${trdir1}\
# 	./challenge/${tg1}/${line}/decode_cn/rescore.mlf > ./challenge/${tg1}/${line}/decode_cn/rescore_mappingtrees.mlf

# 	trdir1="tandem-bg_decode_cn.tree"
# 	tg1="lm_int_tandem"
# 	echo | base/conftools/smoothtree-mlf.pl lib/trees/${trdir1}\
# 	./challenge/${tg1}/${line}/decode_cn/rescore.mlf > ./challenge/${tg1}/${line}/decode_cn/rescore_mappingtrees.mlf
# 	tg1="adapt-lm-tandem"
# 	echo | base/conftools/smoothtree-mlf.pl lib/trees/${trdir1}\
# 	./challenge/${tg1}/${line}/decode_cn/rescore.mlf > ./challenge/${tg1}/${line}/decode_cn/rescore_mappingtrees.mlf

# 	trdir1="grph-tandem-bg_decode_cn.tree"
# 	tg1="lm_int_grph-tandem"
# 	echo | base/conftools/smoothtree-mlf.pl lib/trees/${trdir1}\
# 	./challenge/${tg1}/${line}/decode_cn/rescore.mlf > ./challenge/${tg1}/${line}/decode_cn/rescore_mappingtrees.mlf
# 	tg1="adapt-lm-grph-tandem"
# 	echo | base/conftools/smoothtree-mlf.pl lib/trees/${trdir1}\
# 	./challenge/${tg1}/${line}/decode_cn/rescore.mlf > ./challenge/${tg1}/${line}/decode_cn/rescore_mappingtrees.mlf

# 	trdir1="hybrid-bg_decode_cn.tree"
# 	tg1="lm_int_hybrid"
# 	echo | base/conftools/smoothtree-mlf.pl lib/trees/${trdir1}\
# 	./challenge/${tg1}/${line}/decode_cn/rescore.mlf > ./challenge/${tg1}/${line}/decode_cn/rescore_mappingtrees.mlf
	
# # 	echo | base/conftools/smoothtree-mlf.pl lib/trees/${trdir1}\
# # 	./challenge/${tg1}/${line}/decode_cn/rescore.mlf > ./challenge/${tg1}/${line}/decode_cn/rescore_mappingtrees.mlf
# # 	echo | base/conftools/smoothtree-mlf.pl lib/trees/${trdir1}\
# # 	./challenge/${tg2}/${line}/decode_cn/rescore.mlf > ./challenge/${tg2}/${line}/decode_cn/rescore_mappingtrees.mlf
# done < $store/challenge_dev
# # python exp/shell/CNC.py
# # python exp/shell/challenge.py
# # 
# sys=('lm_int_plp' 'adapt-lm-plp' 'lm_int_grph' 'adapt-lm-grph' \
# 	'lm_int_tandem' 'adapt-lm-tandem' 'lm_int_grph-tandem' 'adapt-lm-grph-tandem' 'lm_int_hybrid')
# types=('decode_cn')
# sys=('lm_int_hybrid' 'adapt-lm-plp')
sys=('lm_int_hybrid+adapt-lm-plp_decode_cn' 'lm_int_hybrid+adapt-lm-grph_decode_cn')
types=('other')
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
# 					mkdir -p ./challenge/mlf_cnc/${tgs}/combine/${line}/${decode_type}/
# 				# python exp/shell/CNC.py
# 				done < $store/challenge_dev
# 				python exp/shell/CNC_dev03.py ${tg1} ${tg2} challenge_dev 
# 				# 
# 				echo $tgs
# 				tg=$tgs #"adapt-grph-plp" #"adapt-tandem" #"adapt-grph-tandem" "lm_int_plp" #"grph-plp-bg" #"plp-tandem" #"grph-tandem"
# 				echo $tg >> ./challenge/LOG_YTBdev_CNC.LOG 
# 				echo | ./scripts/score.sh ./challenge/mlf_cnc/${tg}/combine YTBEdev ${decode_type} >> ./challenge/LOG_YTBdev_CNC.LOG
# 			fi
# 			rm -r ./challenge/mlf_cnc/${tgs}/
# 			# '''
# 		done
# 	done
# done

for t in ${types[@]};
do
	for i in ${sys[@]};
	do
		tg1=$i
		decode_type=$t
		for j in ${sys[@]};
		do
			if [ $i == $j ]
			then
				continue
			else
				tg2=$j

				tgs="${tg1}+${tg2}_${decode_type}"

				while read line
				do
					mkdir -p ./challenge/mlf_combine/${tgs}/combine/${line}/${decode_type}/
				# python exp/shell/CNC.py
				done < $store/challenge_dev
				python exp/shell/challenge_YTBdev.py ${tg1} ${tg2} ${decode_type}


				# 
				echo $tgs
				tg=$tgs #"adapt-grph-plp" #"adapt-tandem" #"adapt-grph-tandem" "lm_int_plp" #"grph-plp-bg" #"plp-tandem" #"grph-tandem"
				echo $tg >> ./challenge/LOG_YTBdev.LOG 
				echo | ./scripts/score.sh ./challenge/mlf_combine/${tg}/combine YTBEdev ${decode_type} >> ./challenge/LOG_YTBdev.LOG
			fi
			# rm -r ./challenge/mlf_combine/${tgs}/
			# '''
		done
	done
done

# '''
# 7. Scoring
# Output:
# 	./scoring/`
# '''

# tg="lm_int_plp" #"adapt-lm-grph" #"adapt-lm-tandem" #"adapt-lm-grph-tandem" "lm_int_plp" #"lm_int_grph" #"lm_int_tandem" #"lm_int_grph-tandem"
# echo $tg 
# echo | ./scripts/score.sh challenge/${tg} YTBEdev decode 

# echo $tg > ./challenge/LOG_v2.LOG
# echo | ./scripts/score.sh challenge/${tg} YTBEdev decode_cn >> ./challenge/LOG_v2.LOG


# tg="adapt-lm-plp" #"adapt-lm-grph" #"adapt-lm-tandem" #"adapt-lm-grph-tandem" "lm_int_plp" #"lm_int_grph" #"lm_int_tandem" #"lm_int_grph-tandem"
# echo $tg 
# echo | ./scripts/score.sh challenge/${tg} YTBEdev decode 

# echo $tg >> ./challenge/LOG_v2.LOG
# echo | ./scripts/score.sh challenge/${tg} YTBEdev decode_cn >> ./challenge/LOG_v2.LOG

# tg="lm_int_grph" #"adapt-lm-grph" #"adapt-lm-tandem" #"adapt-lm-grph-tandem" "lm_int_plp" #"lm_int_grph" #"lm_int_tandem" #"lm_int_grph-tandem"
# echo $tg 
# echo | ./scripts/score.sh challenge/${tg} YTBEdev decode

# echo $tg >> ./challenge/LOG_v2.LOG
# echo | ./scripts/score.sh challenge/${tg} YTBEdev decode_cn >> ./challenge/LOG_v2.LOG

# tg="adapt-lm-grph" #"adapt-lm-grph" #"adapt-lm-tandem" #"adapt-lm-grph-tandem" "lm_int_plp" #"lm_int_grph" #"lm_int_tandem" #"lm_int_grph-tandem"
# echo $tg
# echo | ./scripts/score.sh challenge/${tg} YTBEdev decode

# echo $tg >> ./challenge/LOG_v2.LOG
# echo | ./scripts/score.sh challenge/${tg} YTBEdev decode_cn >> ./challenge/LOG_v2.LOG

# tg="lm_int_tandem" #"adapt-lm-grph" #"adapt-lm-tandem" #"adapt-lm-grph-tandem" "lm_int_plp" #"lm_int_grph" #"lm_int_tandem" #"lm_int_grph-tandem"
# echo $tg 
# echo | ./scripts/score.sh challenge/${tg} YTBEdev decode 

# echo $tg >> ./challenge/LOG_v2.LOG
# echo | ./scripts/score.sh challenge/${tg} YTBEdev decode_cn >> ./challenge/LOG_v2.LOG

# tg="adapt-lm-tandem" #"adapt-lm-grph" #"adapt-lm-tandem" #"adapt-lm-grph-tandem" "lm_int_plp" #"lm_int_grph" #"lm_int_tandem" #"lm_int_grph-tandem"
# echo $tg
# echo | ./scripts/score.sh challenge/${tg} YTBEdev decode 

# echo $tg >> ./challenge/LOG_v2.LOG
# echo | ./scripts/score.sh challenge/${tg} YTBEdev decode_cn >> ./challenge/LOG_v2.LOG

# tg="lm_int_grph-tandem" #"adapt-lm-grph" #"adapt-lm-tandem" #"adapt-lm-grph-tandem" "lm_int_plp" #"lm_int_grph" #"lm_int_tandem" #"lm_int_grph-tandem"
# echo $tg 
# echo | ./scripts/score.sh challenge/${tg} YTBEdev decode 

# echo $tg >> ./challenge/LOG_v2.LOG
# echo | ./scripts/score.sh challenge/${tg} YTBEdev decode_cn >> ./challenge/LOG_v2.LOG

# tg="adapt-lm-grph-tandem" #"adapt-lm-grph" #"adapt-lm-tandem" #"adapt-lm-grph-tandem" "lm_int_plp" #"lm_int_grph" #"lm_int_tandem" #"lm_int_grph-tandem"
# echo $tg
# echo | ./scripts/score.sh challenge/${tg} YTBEdev decode

# echo $tg >> ./challenge/LOG_v2.LOG
# echo | ./scripts/score.sh challenge/${tg} YTBEdev decode_cn >> ./challenge/LOG_v2.LOG

# tg="lm_int_hybrid" #"adapt-lm-grph" #"adapt-lm-tandem" #"adapt-lm-grph-tandem" "lm_int_plp" #"lm_int_grph" #"lm_int_tandem" #"lm_int_grph-tandem"
# echo $tg
# echo | ./scripts/score.sh challenge/${tg} YTBEdev decode

# echo $tg >> ./challenge/LOG_v2.LOG
# echo | ./scripts/score.sh challenge/${tg} YTBEdev decode_cn >> ./challenge/LOG_v2.LOG








# tg="plp-tglm_int_eval" #"adapt-lm-grph" #"adapt-lm-tandem" #"adapt-lm-grph-tandem" "lm_int_plp" #"lm_int_grph" #"lm_int_tandem" #"lm_int_grph-tandem"
# ./scripts/score.sh ${tg} eval03 rescore

# tg="lm_int_grph" #"adapt-lm-grph" #"adapt-lm-tandem" #"adapt-lm-grph-tandem" "lm_int_plp" #"lm_int_grph" #"lm_int_tandem" #"lm_int_grph-tandem"
# echo | ./scripts/score.sh challenge/${tg} YTBEdev decode >> ./challenge/${tg}.LOG
# tg="lm_int_grph" #"adapt-lm-grph" #"adapt-lm-tandem" #"adapt-lm-grph-tandem" "lm_int_plp" #"lm_int_grph" #"lm_int_tandem" #"lm_int_grph-tandem"
# echo | ./scripts/score.sh challenge/${tg} YTBEdev decode_cn >> ./challenge/${tg}.LOG
# cat ./challenge/${tg}.LOG
# tg="adapt-lm-grph" #"adapt-lm-grph" #"adapt-lm-tandem" #"adapt-lm-grph-tandem" "lm_int_plp" #"lm_int_grph" #"lm_int_tandem" #"lm_int_grph-tandem"
# echo | ./scripts/score.sh challenge/${tg} YTBEdev decode >> ./challenge/${tg}.LOG
# tg="adapt-lm-grph" #"adapt-lm-grph" #"adapt-lm-tandem" #"adapt-lm-grph-tandem" "lm_int_plp" #"lm_int_grph" #"lm_int_tandem" #"lm_int_grph-tandem"
# echo | ./scripts/score.sh challenge/${tg} YTBEdev decode_cn >> ./challenge/${tg}.LOG
# cat ./challenge/${tg}.LOG
# tg="adapt-lm-tandem" #"adapt-lm-grph" #"adapt-lm-tandem" #"adapt-lm-grph-tandem" "lm_int_plp" #"lm_int_grph" #"lm_int_tandem" #"lm_int_grph-tandem"
# echo | ./scripts/score.sh challenge/${tg} YTBEdev decode_cn >> ./challenge/${tg}.LOG
# cat ./challenge/${tg}.LOG
# tg="adapt-lm-grph-tandem" #"adapt-lm-grph" #"adapt-lm-tandem" #"adapt-lm-grph-tandem" "lm_int_plp" #"lm_int_grph" #"lm_int_tandem" #"lm_int_grph-tandem"
# echo | ./scripts/score.sh challenge/${tg} YTBEdev decode_cn >> ./challenge/${tg}.LOG
# cat ./challenge/${tg}.LOG
# tg="lm_int_tandem" #"adapt-lm-grph" #"adapt-lm-tandem" #"adapt-lm-grph-tandem" "lm_int_plp" #"lm_int_grph" #"lm_int_tandem" #"lm_int_grph-tandem"
# echo | ./scripts/score.sh challenge/${tg} YTBEdev decode_cn >> ./challenge/${tg}.LOG
# cat ./challenge/${tg}.LOG
# tg="lm_int_grph-tandem" #"adapt-lm-grph" #"adapt-lm-tandem" #"adapt-lm-grph-tandem" "lm_int_plp" #"lm_int_grph" #"lm_int_tandem" #"lm_int_grph-tandem"
# echo | ./scripts/score.sh challenge/${tg} YTBEdev decode_cn >> ./challenge/${tg}.LOG
# cat ./challenge/${tg}.LOG
# tg="mlf_combine/adapt-lm-plp+lm_int_grph-tandem/combine" #"adapt-lm-grph" #"adapt-lm-tandem" #"adapt-lm-grph-tandem" "lm_int_plp" #"lm_int_grph" #"lm_int_tandem" #"lm_int_grph-tandem"
# echo | ./scripts/score.sh challenge/${tg} YTBEdev decode_cn >> ./challenge/${tg}.LOG
# cat ./challenge/${tg}.LOG
# tg="mlf_combine/lm_int_tandem+adapt-lm-grph/combine" #"adapt-lm-grph" #"adapt-lm-tandem" #"adapt-lm-grph-tandem" "lm_int_plp" #"lm_int_grph" #"lm_int_tandem" #"lm_int_grph-tandem"
# echo | ./scripts/score.sh challenge/${tg} YTBEdev decode_cn >> ./challenge/${tg}.LOG
# cat ./challenge/${tg}.LOG
# tg="mlf_combine/adapt-lm-plp+lm_int_grph-tandem+lm_int_tandem+adapt-lm-grph/combine" #"adapt-lm-grph" #"adapt-lm-tandem" #"adapt-lm-grph-tandem" "lm_int_plp" #"lm_int_grph" #"lm_int_tandem" #"lm_int_grph-tandem"
# echo | ./scripts/score.sh challenge/${tg} YTBEdev decode_cn >> ./challenge/${tg}.LOG
# cat ./challenge/${tg}.LOG
# tg="lm_int_hybrid" #"adapt-lm-grph" #"adapt-lm-tandem" #"adapt-lm-grph-tandem" "lm_int_plp" #"lm_int_grph" #"lm_int_tandem" #"lm_int_grph-tandem"
# echo | ./scripts/score.sh challenge/${tg} YTBEdev decode >> ./challenge/${tg}.LOG
# cat ./challenge/${tg}.LOG
# tg="lm_int_hybrid" #"adapt-lm-grph" #"adapt-lm-tandem" #"adapt-lm-grph-tandem" "lm_int_plp" #"lm_int_grph" #"lm_int_tandem" #"lm_int_grph-tandem"
# echo | ./scripts/score.sh challenge/${tg} YTBEdev decode_cn >> ./challenge/${tg}.LOG
# cat ./challenge/${tg}.LOG
# tg="mlf_combine/lm_int_hybrid+lm_int_grph-tandem/combine" #"adapt-lm-grph" #"adapt-lm-tandem" #"adapt-lm-grph-tandem" "lm_int_plp" #"lm_int_grph" #"lm_int_tandem" #"lm_int_grph-tandem"
# echo | ./scripts/score.sh challenge/${tg} YTBEdev decode_cn >> ./challenge/${tg}.LOG
# cat ./challenge/${tg}.LOG
# tg="mlf_combine/lm_int_hybrid+lm_int_grph-tandem+adapt-lm-plp+lm_int_grph-tandem/combine" #"adapt-lm-grph" #"adapt-lm-tandem" #"adapt-lm-grph-tandem" "lm_int_plp" #"lm_int_grph" #"lm_int_tandem" #"lm_int_grph-tandem"
# echo | ./scripts/score.sh challenge/${tg} YTBEdev decode_cn >> ./challenge/${tg}.LOG
# cat ./challenge/${tg}.LOG
# ./scripts/score.sh challenge/${tg} YTBEeval decode_cn
# tg="mlf_combine/adapt-lm-plp+adapt-lm-grph/combine" #"adapt-lm-grph" #"adapt-lm-tandem" #"adapt-lm-grph-tandem" "lm_int_plp" #"lm_int_grph" #"lm_int_tandem" #"lm_int_grph-tandem"
# echo | ./scripts/score.sh challenge/${tg} YTBEdev decode_cn >> ./challenge/${tg}.LOG
# cat ./challenge/${tg}.LOG
# tg="mlf_cnc/adapt-lm-plp+adapt-lm-grph/combine" #"adapt-lm-grph" #"adapt-lm-tandem" #"adapt-lm-grph-tandem" "lm_int_plp" #"lm_int_grph" #"lm_int_tandem" #"lm_int_grph-tandem"
# echo | ./scripts/score.sh challenge/${tg} YTBEdev decode_cn >> ./challenge/${tg}.LOG
# cat ./challenge/${tg}.LOG
# tg="mlf_cnc/adapt-lm-plp+lm_int_grph-tandem/combine" #"adapt-lm-grph" #"adapt-lm-tandem" #"adapt-lm-grph-tandem" "lm_int_plp" #"lm_int_grph" #"lm_int_tandem" #"lm_int_grph-tandem"
# echo | ./scripts/score.sh challenge/${tg} YTBEdev decode_cn >> ./challenge/${tg}.LOG
# cat ./challenge/${tg}.LOG
# '''
# 8. checking
# '''

# tgdir="lm_int_hybrid" #"adapt-lm-plp" #"adapt-lm-grph" #"adapt-lm-tandem" #"adapt-lm-grph-tandem" #"lm_int_plp" #"lm_int_grph" #"lm_int_tandem" #"lm_int_grph-tandem"
# passdir="decode_cn" #"decode" #"decode_cn" #"adapt"
# outdir='rescore.mlf' #rescore.mlf #LOG.align
# while read line
# do
# 	while(true)
# 		do
# 			test -e "./challenge/${tgdir}/$line/${passdir}/${outdir}" && break
# 		done
# 	echo "$line finished!"		
# done < $store/challenge_dev

# '''
# 9. Remove files
# '''

# tgdir="lm_int_plp" #"adapt-lm-plp" #"adapt-lm-grph" #"adapt-lm-tandem" #"adapt-lm-grph-tandem" #"lm_int_plp" #"lm_int_grph" #"lm_int_tandem" #"lm_int_grph-tandem"
# passdir="decode" #"decode" #"decode_cn" #"adapt"
# outdir='rescore.mlf' #rescore.mlf #LOG.align

# while read line
# do
# 	rm -r ./challenge/${tgdir}/$line/${passdir}	
# done < $store/challenge_dev

