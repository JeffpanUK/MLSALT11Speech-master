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
	for i in range(5):
		ls.append([])
		ls[i]=read_file("/home/jp697/Major/exp/task1/stream%d" % (i+1))
		#print len(ls[i])
		#print ls[i]
		#input('stop')
	ls=np.array(ls)
	weight=inter(ls)
	for i in range(5):
		#print "LM%d w=%f\n" % (i,weight[i])
		print weight[i]
	

