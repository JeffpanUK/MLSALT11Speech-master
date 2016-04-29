mainpath='/home/jp697/Major'
devpath='/home/jp697/Major/lattices'
store='/home/jp697/Major/exp/temp_file'
task1path="${mainpath}/exp/task1"
#cd $devpath
#test -e "${store}/temp2" && rm "${store}/temp2"
#echo |find -name 'eval*' -maxdepth 1 >> "$store/temp2"
#obtain the 1 best output from the lattices
#cd -

#read
#cd ${mainpath}
#echo `pwd`

#echo 'Evaluate the performance of WER of 5 LM using dev03 shows'
#
#
# while read line		
# do	
# 	${mainpath}/scripts/lmrescore.sh $line lattices decode lm_int plp-tglm_int/dev03 FALSE
# done < "$store/temp1"
#
# ./scripts/score.sh plp-tglm_int/dev03 dev03 rescore

# base/bin/LPlex -C lib/cfgs/hlm.cfg -u -t lm_int lib/texts/dev03.dat

#eval dataset
echo "eval 03"
./scripts/score.sh plp-tglm_int/eval03 eval03 specific
# base/bin/LPlex -C lib/cfgs/hlm.cfg -u -t lm_int lib/texts/eval03.dat



#for((j=1;j<=5;j++))
#do
#	while read line		
#	do	
#		${mainpath}/scripts/lmrescore.sh $line lattices decode lms/lm${j} plp-tglm-eval${j} FALSE
#	done < "$store/temp2"
#done
#
##score eval03 of all LMs
#
#echo "receiving the mfl"
#while(true)
#do
#	test -e "./plp-tglm-eval5/eval03_DEV013-20010220-XX2000/rescore/rescore.mlf" && break
#done
#
#echo 'scoring all the files'
#for ((i=1;i<=5;i++))
#do
#	./scripts/score.sh plp-tglm-eval${i} eval03 rescore
#done
#
##evaluate the eval03 by the interpolate LM
#echo 'Evaluate the performance of WER of 5 LM using eval03 shows'
#while read line		
#do
#	${mainpath}/scripts/lmrescore.sh $line lattices decode lm_int plp-tglm_int_eval FALSE
#done < "$store/temp2"
#
#
##score eval03 of all LMs
#
#echo "receiving the mfl"
#while(true)
#do
#	test -e "./plp-tglm_int_eval/eval03_DEV013-20010220-XX2000/rescore/rescore.mlf" && break
#done
#
#echo 'scoring all the files'
#./scripts/score.sh plp-tglm_int_eval eval03 rescore
