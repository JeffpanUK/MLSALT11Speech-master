mainpath='/home/jp697/Major'
devpath='/home/jp697/Major/lattices'
store='/home/jp697/Major/exp/temp_file'
task2path="${mainpath}/exp/task2"

#generate cross adapted system which is specific to the model that was used to generate


while read line
do
    ./scripts/hmmrescore.sh $line plp-bg merge grph-plp-bg grph-plp
done < $store/temp1

#check the file to complte and then continue
while(true)
do
	test -e "./grph-plp-bg/dev03_DEV001-20010117-XX2000/decode/LOG" && break
done
while(true)
do	
	egrep -c File grph-plp-bg/dev03_DEV001-20010117-XX2000/decode/LOG > ./store.t
	check=`cat ./store.t`
	if [[ $check == 132 ]]; then
		rm ./store.t
		break
	fi
done
read -p "check grph-plp-bg decode dir"

echo "the score of the grph PLP system:" > $task2path/5.5.3.LOG
echo | ./scripts/score.sh grph-plp-bg dev03sub decode >> $task2path/5.5.3.LOG

# Use the grph-plp-bg tfor adaptation
while read line
do
	#statements
	./scripts/hmmadapt.sh -OUTPASS adapt-grph-plp ${line} grph-plp-bg decode plp-adapt-bg plp
done < $store/temp1

#check the file to complte and then continue
while(true)
do
	test -e "./plp-adapt-bg/dev03_DEV001-20010117-XX2000/adapt-grph-plp/LOG.align" && break
done
while(true)
do	
	egrep -c File plp-adapt-bg/dev03_DEV001-20010117-XX2000/adapt-grph-plp/LOG.align > ./store.t
	check=`cat ./store.t`
	if [[ $check == 132 ]]; then
		rm ./store.t
		break
	fi
done
read -p "check adapt-grph-plp merge dir"

while read line
do
	./scripts/hmmrescore.sh -ADAPT plp-adapt-bg adapt-grph-plp -OUTPASS decode-grph-plp ${line} plp-bg merge plp-adapt-bg plp
done < ${store}/temp1

# check the file to complte and then continue
while(true)
do
	test -e "./plp-adapt-bg/dev03_DEV001-20010117-XX2000/decode-grph-plp/LOG" && break
done
while(true)
do	
	egrep -c File plp-adapt-bg/dev03_DEV001-20010117-XX2000/decode-grph-plp/LOG > ./store.t
	check=`cat ./store.t`
	if [[ $check == 132 ]]; then
		rm ./store.t
		break
	fi
done
read -p "check plp-adapt-bg decode dir"
echo "the score of the cross adapted system:" >> $task2path/5.5.3.LOG
echo | ./scripts/score.sh plp-adapt-bg dev03sub decode-grph-plp >> $task2path/5.5.3.LOG
