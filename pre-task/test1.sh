devpath='/home/jp697/Major/lattices'
store='/home/jp697/Major/exp/temp'
cd $devpath
test -e $store && rm $store
echo |find -name 'dev*' -maxdepth 1 >> ${store}
while read line
do
	a=$line
	
done < ${store}
