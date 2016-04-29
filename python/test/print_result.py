# filepath='./challenge/dev03.ROVER'
# savepath='./challenge/sorted_dev03.ROVER'
def main(filepath,savepath):
	fs=open(filepath,'r')
	WER={}
	for line in fs:
		wer=line.strip().split()
		if len(wer)==1:
			sysn=wer[0]
			continue
		else:
			WER[sysn]=wer[10]
	fs.close()
	WER=sorted(WER.items(),key=lambda d:d[1])

	fsv=open(savepath,'w')
	fsv.write('System\tWER\n')
	for i in WER:
		fsv.write('%s\t%s\n'%(i[0],i[1]))
	fsv.close()

if __name__ == '__main__':
	import argparse
	parser=argparse.ArgumentParser(description='sorting the results')
	parser.add_argument('filepath',type=str)
	parser.add_argument('savepath',type=str)
	args=parser.parse_args()
	main(args.filepath, args.savepath)