mainpath='/home/jp697/Major'
devpath='/home/jp697/Major/lattices'
store='/home/jp697/Major/exp/temp_file'
task1path="${mainpath}/exp/task1"
# cd $devpath
# test -e "${store}/temp1" && rm "${store}/temp1"
# echo |find -name 'dev*' -maxdepth 1 >> "$store/temp1"
# #obtain the 1 best output from the lattices
# cd -
# echo 'obtain the 1-best output from the dev03_sub'

# while read line
# do
# 	./scripts/1bestlats.sh $line lattices decode plp-bg
# done < "$store/temp1"

# echo "receiving the mfl"
# while(true)
# do
# 	test -e "./plp-bg/dev03_DEV001-20010117-XX2000/1best/LM12.0_IN-10.0/rescore.mlf" && break
# done
# echo 'score the MLF file(showing the recognition output)'
# ./scripts/score.sh plp-bg dev03sub 1best/LM12.0_IN-10.0


#read
#cd ${mainpath}
echo `pwd`
echo 'Evaluate the performance of WER of 5 LM using dev03 shows'

for((j=1;j<=5;j++))
do
	while read line		
	do	
		${mainpath}/scripts/lmrescore.sh $line lattices decode lms/lm${j} plp-tglm${j} FALSE
	done < "$store/temp1"
done

# #score dev03 of all LMs

# echo "receiving the mfl"
# while(true)
# do
# 	test -e "./plp-tglm5/dev03_DEV010-20010131-XX2000/rescore/rescore.mlf" && break
# done

# echo 'scoring all the files'
# for ((i=1;i<=5;i++))
# do
# 	./scripts/score.sh plp-tglm${i} dev03 rescore
# done
