#-*-coding:UTF-8-*-
import numpy as np
import sys,os
def read_file(filepath):
	try:
		ls=[]
		with open(filepath,'r') as ls_file:
			for line in ls_file:
				p=float(line)
				ls.append(p)
		return ls
	except IOError as ioerr:
		print "File filepath cannot be open"

def inter(ls):
	w=np.array([0.2,0.2,0.2,0.2,0.2])
	PP=w[0]*ls[0]+w[1]*ls[1]+w[2]*ls[2]+w[3]*ls[3]+w[4]*ls[4]
	temp=0
	while(abs(sum(PP)-temp)>1e-12):
		temp=sum(PP)
		for i in range(5):
			p=(w[i]*ls[i])/PP
			w[i]=np.mean(p)
		PP=w[0]*ls[0]+w[1]*ls[1]+w[2]*ls[2]+w[3]*ls[3]+w[4]*ls[4]	
	return w

if __name__=='__main__':
	ls=[]
	for j in range(5):
		ls.append([])
		ls[j]=read_file("/home/jp697/Major/challenge/streams/stream%d" % (j+1))
	ls=np.array(ls)
	weight=inter(ls)
	
	weightfile=open("/home/jp697/Major/exp/temp_file/weight_challenge_dev",'w')
	for w in weight:
		weightfile.write(str(w)+'\n')
	weightfile.close()