mainpath='/home/jp697/Major'
devpath='/home/jp697/Major/lattices'
testlist='/home/jp697/Major/lib/testlists/'
streampath="/home/jp697/Major/challenge/dev_streams/"
storedat="/home/jp697/Major/challenge/store_dat/"

echo \
'''
1. Generate 1-best output from the dev set
Output:
	./plp/${dev_set}/1best/LM12.0_IN-10.0
'''
echo 'obtain the 1-best output from the dev03'
while read line
do
	./scripts/1bestlats.sh $line lattices decode plp
done < "$testlist/dev03.lst"

echo "checking the completion of the 1-best output process"
tgdir="plp" 
passdir="1best/LM12.0_IN-10.0" 
outdir='rescore.mlf'
while read line
do
	while(true)
		do
			test -e "./${tgdir}/$line/${passdir}/${outdir}" && break
		done
	echo "$line finished!"		
done < ${testlist}/dev03.lst

echo \
'''
3. Interpolate the LMs
Process:
	a. Convert 1-best output to data file 
	b. Generate stream files from the data file in step a 
	c. Interpolate the Language Model
Output:
	a. ./challenge/store_dat/dev03.dat
	b. ./challenge/streams
	c. ./exp/temp_file/weight_challenge_dev 
	   ./lm_int_challenge
'''
#step a
echo 'convert 1best hypothesis to dev03.dat'
python ${mainpath}/exp/shell/ConvertData.py ${testlist}/dev03.lst plp ${storedat}/dev03.dat

#step b
echo "Begin to generate the stream files"
mkdir -p  ${streampath}
for ((j=1;j<=5;j++))
do
	base/bin/LPlex -C lib/cfgs/hlm.cfg -s stream${j} -u -t \
	lms/lm${j} ${storedat}/dev03.dat
	cp stream${j} ${streampath}
	rm stream${j}
done

#step c
echo "begin to interpolate the weights"
python "/home/jp697/Major/exp/shell/Interpolate.py"  ${streampath} ${store}/weight_dev03


#Read the weights and interpolation
echo "begin to merge the LMs"
j=0
weight=[]
while read line
do
	weight[j]=$line
	let j=$j+1
	echo $j
done < ${store}/weight_dev03

echo "Start the weight_challenge_dev LM merge"
echo ${weight[0]}
base/bin/LMerge -C lib/cfgs/hlm.cfg \
-i ${weight[0]} lms/lm1 \
-i ${weight[1]} lms/lm2 \
-i ${weight[2]} lms/lm3 \
-i ${weight[3]} lms/lm4 \
lib/wlists/train.lst \
lms/lm5 lm_int

echo \
'''
4. Use the intepolated LM to rescore the eval set
Output:
	./plp/${eval_set}/rescore/
'''
echo 'Evaluate the performance of eval03'
while read line		
do
	${mainpath}/scripts/lmrescore.sh $line lattices decode lm_int \
	plp TRUE
done < ${testlist}/dev03.lst

'''
5. Merge and Rescore and built basic systems
Process:
	a. Merge the rescore directiory of eval set
	b. Rescore using graphemic system
	c. Rescore using tandem system
	d. Rescore using grph-tandem system
  e: Rescore using hybrid system
Output:
	a. ./challenge/lm_int_plp/${eval_set}/merge/
	b. ./challenge/grph-plp-bg/${eval_set}/decode/
	c. ./challenge/plp-tandem/${eval_set}/decode/
	d. ./challenge/grph-tandem/${eval_set}/decode/
	e. ./challenge/hybrid/${eval_set}/decode/
'''
# step a
echo "start to merge lattices"
while read line
do
	echo "$line rescore:" 
	./scripts/mergelats.sh $line plp rescore plp
done < ${testlist}/dev03.lst

echo "checking the completion of merge process"
tgdir="plp" 
passdir="merge" 
outdir='LOG'
while read line
do
	while(true)
		do
			test -e "./${tgdir}/$line/${passdir}/${outdir}" && break
		done
	echo "$line finished!"		
done < ${testlist}/dev03.lst

for model in plp grph-plp tandem grph-tandem hybrid
do
	echo "building ${model} system"
	while read line
	do
		./scripts/hmmrescore.sh $line plp merge ${model} ${model}	
	done < ${testlist}/dev03.lst
done

echo "checking the completion of building process"
tgdir="hybrid" 
passdir="decode" 
outdir='rescore.mlf'
while read line
do
	while(true)
		do
			test -e "./${tgdir}/$line/${passdir}/${outdir}" && break
		done
	echo "$line finished!"		
done < ${testlist}/dev03.lst

echo \
'''
6. speaker adaptation
'''
for model in plp grph-plp tandem grph-tandem hybrid; do
	for ad in plp tandem grph-tandem; do #grph-plp adaptation is removed for error output
		echo "${ad} adaptation on ${model}"	
		while read line
		do
			./scripts/hmmadapt.sh $line ${model} decode ./cross-adapt/${ad}-adapt-${model} ${ad}
		done < ${testlist}/dev03.lst
	done
done

tgdir="cross-adapt/grph-tandem-adapt-hybrid" 
passdir="adapt" 
outdir='LOG.align' 
while read line
do
	while(true)
		do
			test -e "./${tgdir}/$line/${passdir}/${outdir}" && break
		done
	echo "$line finished!"		
done < ${testlist}/dev03.lst


for model in plp grph-plp tandem grph-tandem hybrid; do
	for ad in plp tandem grph-tandem; do
		echo "hmmrescore ${ad}-adapt-${model}"		
		while read line
		do
			./scripts/hmmrescore.sh -ADAPT ./cross-adapt/${ad}-adapt-${model} \
			adapt ${line} plp merge ./cross-adapt/${ad}-adapt-${model} ${ad}
		done < ${testlist}/dev03.lst
	done
done

tgdir="cross-adapt/grph-tandem-adapt-hybrid"
passdir="decode" 
outdir='rescore.mlf' 
while read line
do
	while(true)
		do
			test -e "./${tgdir}/$line/${passdir}/${outdir}" && break
		done
	echo "$line finished!"		
done < ${testlist}/dev03.lst

echo \
'''
7. confusion network generation
'''

for model in plp grph-plp tandem grph-tandem hybrid; do
	for ad in plp tandem grph-tandem; do	
		echo "generating CN for ${ad}-adapt-${model}"
		while read line
		do
			./scripts/cnrescore.sh ${line} ./cross-adapt/${ad}-adapt-${model} decode ./cross-adapt/${ad}-adapt-${model}
		done < ${testlist}/dev03.lst
	done
done

tgdir="cross-adapt/grph-tandem-adapt-hybrid" 
passdir="decode_cn" 
outdir='rescore.mlf'
while read line
do
	while(true)
		do
			test -e "./${tgdir}/$line/${passdir}/${outdir}" && break
		done
	echo "$line finished!"		
done < ${testlist}/dev03.lst

echo 'mapping confidence scores'
for model in plp grph-plp tandem grph-tandem hybrid; do
	for ad in plp tandem grph-tandem; do
		while read line
		do	
			trdir="${model}-bg_decode_cn.tree"
			echo $trdir
			echo | base/conftools/smoothtree-mlf.pl lib/trees/${trdir} \
			./cross-adapt/${ad}-adapt-${model}/${line}/decode_cn/rescore.mlf > ./cross-adapt/${ad}-adapt-${model}/${line}/decode_cn/rescore_mappingtrees.mlf
		done < ${testlist}/dev03.lst
	done
done

Logdir="./challenge/dev03.adapt"
echo 'scoring the adapted systems'
for model in plp grph-plp tandem grph-tandem hybrid; do
	for ad in plp tandem grph-tandem; do
		for de in decode decode_cn;do
			tgs="${ad}-adapt-${model}"
			echo $tgs >> ${Logdir}
			echo | ./scripts/score.sh ./cross-adapt/${tgs} dev03 ${de} >> ${Logdir}
		done
	done
done

echo 'scoring individual systems'

Logdir="./challenge/dev03.individual"
for model in plp grph-plp tandem grph-tandem hybrid; do
	for de in decode decode_cn;do
		tgs=${model}
		echo $tgs >> ${Logdir}
		echo | ./scripts/score.sh ${tgs} dev03 ${de} >> ${Logdir}
	done
done

echo \
'''
8. ROVER combination
'''

while read line
do
	mkdir -p ./testing/${line}/decode
	python ./exp/shell/rtest.py ./testing/${line}/decode/rescore.mlf ./hybrid/${line}/decode/rescore.mlf ./cross-adapt/plp-adapt-hybrid/${line}/decode/rescore.mlf
done < ${testlist}/dev03.lst
Logdir="./challenge/dev03.ROVER"
for t in decode_cn
do
	for model1 in plp grph-plp tandem grph-tandem hybrid
	# for model1 in hybrid
	do
		tg1=${model1}
		for model2 in plp grph-plp tandem grph-tandem hybrid
		# for model2 in hybrid
		do
			for ad2 in plp tandem grph-tandem
			# for ad2 in plp
			do
				tg2="${ad2}-adapt-${model2}"
				if [ $tg1 == $tg2 ]
				then
					continue
				else
					tgs="${tg1}+${tg2}_${t}"
					echo $tgs
					while read line
					do
						mkdir -p ./mlf_combine/${tgs}/combine/${line}/${t}/
					done < ${testlist}/dev03.lst
					python exp/shell/RoverCombi.py ${tg1} ${tg2} ${t} ${testlist}/dev03.lst --pass1 . --pass2 cross-adapt
					echo $tgs >> ${Logdir}
					echo | ./scripts/score.sh ./mlf_combine/${tgs}/combine dev03 ${t} >> ${Logdir}
				fi
				rm -r ./mlf_combine/${tgs}/
			done
		done
	done
done

for t in decode_cn
do
	for model1 in plp grph-plp tandem grph-tandem hybrid
	do
		for ad1 in plp tandem grph-tandem
		do
			tg1="${ad1}-adapt-${model1}"
			for model2 in plp grph-plp tandem grph-tandem hybrid
			do
				for ad2 in plp tandem grph-tandem
				do
					tg2="${ad2}-adapt-${model2}"
					if [ $tg1 == $tg2 ]
					then
						continue
					else
						tgs="${tg1}+${tg2}_${t}"
						echo $tgs
						while read line
						do
							mkdir -p ./mlf_combine/${tgs}/combine/${line}/${t}/
						done < ${testlist}/dev03.lst
						python exp/shell/RoverCombi.py ${tg1} ${tg2} ${t} ${testlist}/dev03.lst \
						--pass1 cross-adapt --pass2 cross-adapt
						echo $tgs >> ${Logdir}
						echo | ./scripts/score.sh ./mlf_combine/${tgs}/combine dev03 ${t} >> ${Logdir}
					fi
					rm -r ./mlf_combine/${tgs}/
				done
			done
		done
	done
done

echo \
'''
9. CNC 
'''
Logdir="./challenge/dev03.CNC"
for t in decode_cn
do
	for model1 in plp grph-plp tandem grph-tandem hybrid
	do
		tg1=${model1}
		for model2 in plp grph-plp tandem grph-tandem hybrid
		do
			for ad2 in plp tandem grph-tandem
			do
				tg2="${ad2}-adapt-${model2}"
				if [ $tg1 == $tg2 ]
				then
					continue
				else
					tgs="${tg1}+${tg2}_${t}"
					echo $tgs
					while read line
					do
						mkdir -p ./mlf_cnc/${tgs}/combine/${line}/${t}/
					done < ${testlist}/dev03.lst
					python exp/shell/CNC.py ${tg1} ${tg2} ${t} ${testlist}/dev03.lst --pass1 . --pass2 cross-adapt
					echo $tgs >> ${Logdir}
					echo | ./scripts/score.sh ./mlf_cnc/${tgs}/combine dev03 ${t} >> ${Logdir}
				fi
				rm -r ./mlf_cnc/${tgs}/
			done
		done
	done
done

for t in decode_cn
do
	for model1 in plp grph-plp tandem grph-tandem hybrid
	do
		for ad1 in plp tandem grph-tandem
		do
			tg1="${ad1}-adapt-${model1}"
			for model2 in plp tandem grph-tandem hybrid
			do
				for ad2 in plp tandem grph-tandem
				do
					tg2="${ad2}-adapt-${model2}"
					if [ $tg1 == $tg2 ]
					then
						continue
					else
						tgs="${tg1}+${tg2}_${t}"
						echo $tgs
						while read line
						do
							mkdir -p ./mlf_cnc/${tgs}/combine/${line}/${t}/
						done < ${testlist}/dev03.lst
						python exp/shell/CNC.py ${tg1} ${tg2} ${t} ${testlist}/dev03.lst --pass1 cross-adapt --pass2 cross-adapt
						echo $tgs >> ${Logdir}
						echo | ./scripts/score.sh ./mlf_cnc/${tgs}/combine dev03 ${t} >> ${Logdir}
					fi
					rm -r ./mlf_cnc/${tgs}/
				done
			done
		done
	done
done

echo 'sorting the results'
for type in individual adapt ROVER CNC
do
	Logdir="./challenge/dev03.${type}"
	savepath="./challenge/sorted_dev03.${type}"
	python /home/jp697/Major/exp/shell/print_result.py ${Logdir} ${savepath}
done