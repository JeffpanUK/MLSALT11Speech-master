mainpath='/home/jp697/Major'
devpath='/home/jp697/Major/lattices'
store='/home/jp697/Major/exp/temp_file'
taskpath="${mainpath}/exp/task6"


rm -r ./exp/task6/5.6.5
mkdir ./exp/task6/5.6.5
while read line
do
	# cp ./plp-bg/${line}/decode_cn ./plp-bg/${line}/decode_cn_new
	# rm ./plp-bg/${line}/decode_cn_new/rescore.mlf
	mkdir ./exp/task6/5.6.5/${line}/
	mkdir ./exp/task6/5.6.5/${line}/decode
	echo | python ./exp/shell/cncs.py --outfile ./exp/task6/5.6.5/${line}/decode/rescore.mlf \
	./plp-bg/${line}/decode_cn/lattices/ ./grph-plp-bg/${line}/decode_cn/lattices/ \
	>> ./exp/task6/5.6.5/${line}/decode/rescore.mlf
	# python ./exp/shell/rover.py --outfile ./exp/task6/combine/${line}/decode_cn/rescore.mlf ./exp/task6/${line}.mlf
	# cp ./exp/task6/${line}.mlf ./exp/task6/combine/${line}/decode_cn/rescore.mlf
done < $store/temp1
# score the results
echo | ./scripts/score.sh  exp/task6/5.6.5 dev03sub decode >> $taskpath/5.6.5.LOG
# echo | ./scripts/score.sh  plp-bg dev03sub decode_cn_new >> $taskpath/5.6.4.LOG

