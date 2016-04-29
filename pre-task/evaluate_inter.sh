mainpath='/home/jp697/Major'
devpath='/home/jp697/Major/lattices'
store='/home/jp697/Major/exp/temp_file'
task1path="${mainpath}/exp/task1"

echo 'Evaluate the performance of WER of 5 LM using dev03 shows'
while read line		
do
	${mainpath}/scripts/lmrescore.sh $line lattices decode lm_int plp-tglm_int FALSE
done < "$store/temp1"


#score dev03 of all LMs

echo "receiving the mfl"
while(true)
do
	test -e "./plp-tglm_int/dev03_DEV010-20010131-XX2000/rescore/rescore.mlf" && break
done

echo 'scoring all the files'
./scripts/score.sh plp-tglm_int dev03 rescore

