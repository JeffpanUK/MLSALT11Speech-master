#combine the weight of train file to merge the language modle
mainpath='/home/jp697/Major'
devpath='/home/jp697/Major/lattices'
store='/home/jp697/Major/exp/temp_file'
task1path="${mainpath}/exp/task1"

for((i=1;i<=5;i++))
do
	echo "LM${i}" >> ./5.4.5.LOG
	echo| base/bin/LPlex -C lib/cfgs/hlm.cfg -u -t lms/lm${i} lib/texts/dev03.dat >> ./5.4.3.LOG
done
#python ${mainpath}/exp/shell/interpolation2.py >> ${store}/weight.int
#i=0
#while read line
#do
#	weight[i]=$line
#	let i=$i+1
#	echo $i
#done < ${store}/weight.int
#
#echo 'begining'
#echo ${weight[0]}
#base/bin/LMerge -C lib/cfgs/hlm.cfg -i ${weight[0]} lms/lm1 -i ${weight[1]} lms/lm2 -i ${weight[2]} lms/lm3 -i ${weight[3]} lms/lm4 lib/wlists/train.lst lms/lm5 lm_int

