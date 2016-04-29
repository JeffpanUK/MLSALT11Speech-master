#!/bin/bash

#\$ -S /bin/bash

devpath='/home/jp697/Major/lattices'
store='/home/jp697/Major/exp/temp_file'
taskpath="${mainpath}/exp/task6"

# if ( $#argv != 7 ) then
#    echo "usage: `basename $0` MDIR1 CONVERT_MLF SDIR1 MDIR2 COMPARE_MLF SDIR2 RESULT_SAVE"
#    exit 0
# fi

# mdir1=$1
# omlf=$2
# sdir1=$3
# mdir2=$4
# pmlf=$5
# sdir2=$6
# result=$7
# echo $mdir1
# #convert the mlf file to scoreable format using HLEd command
# echo "Start to convert the mlf file to proper format for scoring"



# ./base/bin/HLEd -i ${mdir1}/${omlf}/${sdir1}/score.mlf -l "*" /dev/null ${mdir1}/${omlf}/${sdir1}/rescore.mlf

# #compare Using HResult command
# echo "Start to compare two mlf using HResults command"
# ./base/bin/HResults -t -f -I ${mdir1}/${omlf}/${sdir1}/score.mlf lib/wlists/train.lst ${mdir2}/${pmlf}/${sdir2}/rescore.mlf >> ./exp/task3/${result}
while read line
do
	echo "Start to convert the mlf file to proper format for scoring"

	./base/bin/HLEd -i grph-plp-bg/${line}/decode_cn/score.mlf -l "*" /dev/null \
	grph-plp-bg/${line}/decode_cn/rescore.mlf

	#compare Using HResult command
	echo "Start to compare two mlf using HResults command"
	./base/bin/HResults -t -f -I grph-plp-bg/${line}/decode_cn/score.mlf lib/wlists/train.lst \
	plp-bg/${line}/decode_cn/rescore.mlf >> ./exp/task6/5.6.5.LOG
done < $store/temp1