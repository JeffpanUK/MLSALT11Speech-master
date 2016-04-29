#!usr/env/bin python
#-*-coding:UTF-8-*-
import numpy as np
'''
Interpolation.py

This script is to interpolate LM weights, with uniform intial weights setting

Usage: Interpolation.py stream_path weight_path
-stream_path: the directory of stream files
-weight_path: the directory to save the generated weights into file

Author: Junjie Pan
Latest Modified: 2016/04/26
'''

# read stream files into dictiory
def read_file(filepath):
	try:
		ls=[]
		with open(filepath,'r') as ls_file:
			for line in ls_file:
				p=float(line)
				ls.append(p)
		return ls
	except IOError as ioerr:
		print "File %s cannot be open"%filepath

#Interpolation LM weights
def inter(ls):
	#set the initial weights uniform
	w=np.array([0.2,0.2,0.2,0.2,0.2])
	PP=w[0]*ls[0]+w[1]*ls[1]+w[2]*ls[2]+w[3]*ls[3]+w[4]*ls[4]
	temp=0 #store the current perplexity
	while(abs(sum(PP)-temp)>1e-12):
		temp=sum(PP)
		# update rules
		for i in range(5):
			p=(w[i]*ls[i])/PP
			w[i]=np.mean(p)
		PP=w[0]*ls[0]+w[1]*ls[1]+w[2]*ls[2]+w[3]*ls[3]+w[4]*ls[4]	
	return w

#main function to perform interpolation
def main(streamdir,weightsdir):
	ls=[]
	for j in range(5):
		ls.append([])
		ls[j]=read_file("%s/stream%d" % (streamdir,j+1))
	ls=np.array(ls)
	weight=inter(ls)
	
	weightfile=open(weightsdir,'w')
	for w in weight:
		weightfile.write(str(w)+'\n')
	weightfile.close()

if __name__=='__main__':
	import argparser
	parser=arg.ArgumentParser(description='Interpolation LM Weights')
	parser.add_argument('StreamPath',type=str)
	parser.add_argument('WeightPath',type=str)
	args=parser.parse_args()
	main(args.StreamPath, args.WeightPath)