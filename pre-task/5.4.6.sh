mainpath='/home/jp697/Major'
devpath='/home/jp697/Major/lattices'
store='/home/jp697/Major/exp/temp_file'
task1path="${mainpath}/exp/task1"

# echo "start to create the 1best hypothesis"


# echo \
# '''\
# step 1: use the dev03 generated LM to rescore each show in the eval sets\
# '''
# while read line		
# do
# 	${mainpath}/scripts/lmrescore.sh $line lattices decode lm_int plp-tglm_int TRUE
# done < "$store/temp2"



# tgdir="plp-tglm_int" #"adapt-lm-plp" #"adapt-lm-grph" #"adapt-lm-tandem" #"adapt-lm-grph-tandem" #"lm_int_plp" #"lm_int_grph" #"lm_int_tandem" #"lm_int_grph-tandem"
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
# '''\
# step 2: generate the 1best hypothesis from the eval lattices\
# '''

# while read line
# do
# 	./scripts/1bestlats.sh $line ./plp-tglm_int rescore plp-tglm_int
# 	echo "complete one task"
# done < "$store/temp2"


# tgdir="plp-tglm_int" #"adapt-lm-plp" #"adapt-lm-grph" #"adapt-lm-tandem" #"adapt-lm-grph-tandem" #"lm_int_plp" #"lm_int_grph" #"lm_int_tandem" #"lm_int_grph-tandem"
# passdir="1best/LM12.0_IN-10.0" #"decode" #"decode_cn" #"adapt"
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
# '''\
# step 3: convert the 1best hypothesis into suitable format\
# '''
# python ./exp/shell/ConvertDat.py


# echo \
# '''
# step 4: generate streams from the converted data file 
# '''
# for ((i=1;i<=5;i++))
# do
# 	echo | base/bin/LPlex -C lib/cfgs/hlm.cfg -s stream_eval${i} -u -t lms/lm${i} ./exp/temp_file/eval03.dat \
# 	>> exp/5.4.6.LOG
# 	cp stream_eval${i} ${task1path}
# 	rm stream_eval${i}
# done


# echo \
# '''
# step 5: compute the weights from the streams generated from last step
# '''
# python "/home/jp697/Major/exp/shell/interpolation3_eval.py"


# echo \
# '''
# step 6: generate the interpolation LM according to the weights
# '''
# weight=[]
# while read line
# do
# 	weight[j]=$line
# 	let j=$j+1
# 	echo $j
# done < ${store}/weight_eval

# echo "Start the evalLM merge"
# echo ${weight[0]}
# base/bin/LMerge -C lib/cfgs/hlm.cfg -i ${weight[0]} lms/lm1 -i ${weight[1]} lms/lm2 -i ${weight[2]} lms/lm3 -i ${weight[3]} lms/lm4 lib/wlists/train.lst lms/lm5 lm_int_specific


# echo \
# '''
# step 7: use the new_interpolated LM to rescore the eval data_set
# '''
# while read line		
# do
# 	${mainpath}/scripts/lmrescore.sh -OUTPASS specific $line lattices decode lm_int_specific plp-tglm_int TRUE
# done < "$store/temp2"

# tgdir="plp-tglm_int" #"adapt-lm-plp" #"adapt-lm-grph" #"adapt-lm-tandem" #"adapt-lm-grph-tandem" #"lm_int_plp" #"lm_int_grph" #"lm_int_tandem" #"lm_int_grph-tandem"
# passdir="specific" #"decode" #"decode_cn" #"adapt"
# outdir='rescore.mlf' #rescore.mlf #LOG.align
# while read line
# do
# 	while(true)
# 		do
# 			test -e "./${tgdir}/$line/${passdir}/${outdir}" && break
# 		done
# 	echo "$line finished!"		
# done < $store/temp2

echo \
'''
WER and perplexity for eval03 dataset from LM1-5, lm_int, and lm_int_specific
'''


echo 'scoring all the files'
for ((i=1;i<=5;i++))
do
	echo "LM${i}" >> ./exp/5.4.6_LM1-5_eval
	echo | ./scripts/score.sh plp-tglm-eval${i} eval03 rescore >> ./exp/5.4.6_LM1-5_eval
	echo | base/bin/LPlex -C lib/cfgs/hlm.cfg -u -t lms/lm${i} lib/texts/eval03.dat >> ./exp/5.4.6_LM1-5_eval
done
echo "int_LM" >> ./exp/5.4.6_LM1-5_eval
echo | ./scripts/score.sh plp-tglm_int/eval03 eval03 rescore >> ./exp/5.4.6_LM1-5_eval
echo | base/bin/LPlex -C lib/cfgs/hlm.cfg -u -t lm_int lib/texts/eval03.dat >> ./exp/5.4.6_LM1-5_eval

echo "int_specified_lm" >> ./exp/5.4.6_LM1-5_eval
echo | ./scripts/score.sh plp-tglm_int/eval03 eval03 specific >> ./exp/5.4.6_LM1-5_eval
echo | base/bin/LPlex -C lib/cfgs/hlm.cfg -u -t lm_int_specific lib/texts/eval03.dat >> ./exp/5.4.6_LM1-5_eval