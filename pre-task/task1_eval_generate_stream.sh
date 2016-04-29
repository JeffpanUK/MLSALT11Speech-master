mainpath='/home/jp697/Major'
devpath='/home/jp697/Major/lattices'
store='/home/jp697/Major/exp/temp_file'
task1path="${mainpath}/exp/task1"


#for ((i=1;i<=5;i++))
#do
#	echo "===================================================================" >> ${store}/perlexity_LM
#	echo "Language Model ${i}" >> ${store}/perlexity_LM
#	echo "-------------------" >> ${store}/perlexity_LM
#	base/bin/LPlex -C lib/cfgs/hlm.cfg -u -t lms/lm${i} lib/texts/dev03.dat >> ${store}/perlexity_LM
#done


for ((i=1;i<=5;i++))
do
	base/bin/LPlex -C lib/cfgs/hlm.cfg -s stream_eval${i} -u -t lms/lm${i} lib/texts/eval03.dat
	cp stream_eval${i} ${task1path}
	rm stream_eval${i}
done
