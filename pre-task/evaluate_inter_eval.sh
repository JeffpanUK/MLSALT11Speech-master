mainpath='/home/jp697/Major'
devpath='/home/jp697/Major/lattices'
store='/home/jp697/Major/exp/temp_file'
task1path="${mainpath}/exp/task1"
#evaluate the performance of the merged lm_eval
echo 'Evaluate the performance of WER of 5 LM using eval03 shows'
while read line		
do
	${mainpath}/scripts/lmrescore.sh $line lattices decode lm_int_eval plp-tglm_int_eval FALSE
done < "$store/temp2"


#score eval03 of all LMs

echo "receiving the mfl"
while(true)
do
	test -e "./plp-tglm_int_eval/eval03_DEV013-20010220-XX2000/rescore/rescore.mlf" && break
done

echo 'scoring all the files'
./scripts/score.sh plp-tglm_int_eval eval03 rescore

