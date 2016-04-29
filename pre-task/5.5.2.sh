mainpath='/home/jp697/Major'
devpath='/home/jp697/Major/lattices'
store='/home/jp697/Major/exp/temp_file'
task2path="${mainpath}/exp/task2"

#while read line
#do
#    echo "$line rescore using plp"
#	./scripts/hmmadapt.sh $line plp-bg decode plp-adapt-bg plp
#done < $store/temp1

while read line
do
    ./scripts/hmmrescore.sh -ADAPT plp-adapt-bg adapt $line plp-bg merge plp-adapt-bg plp
done < $store/temp1

while(true)
do
	test -e "./plp-adapt-bg/dev03_DEV001-20010117-XX2000/decode/rescore.mlf" && break
done
echo | ./scripts/score.sh plp-adapt-bg dev03sub decode > $task2path/5.5.2.LOG
