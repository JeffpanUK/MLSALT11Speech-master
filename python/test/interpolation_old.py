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
	w=np.array([0,0,0,0,1])
	w[0]=0
	temp=0
	while(sum(w)==1):
		w[1]=0
		while(sum(w)==1):
			w[2]=0
			while(sum(w)==1):
				w[3]=0
				while(sum(w)==1):					
					PP=w[0]*ls[0]+w[1]*ls[1]+w[2]*ls[2]+w[3]*ls[3]+w[4]*ls[4]
					print w[0]
					print w[1]
					print w[2]
					print w[3]
					print w[4]
					if sum(PP)>temp:
						temp=sum(PP)
						rw=w
						print temp
						print w[0]
					#print "4st: %f"%w[3]
					w[3]+=0.1
					w[4]=1.0-w[0]-w[1]-w[2]-w[3]
					print sum(PP)
				#print "3st: %f"%w[2]
				w[2]+=0.1
			#print "2st: %f"%w[1]
			w[1]+=0.1
		#print "1st: %f"%w[0]
		w[0]+=0.1
					
	return rw

if __name__=='__main__':
	ls=[]
	for i in range(5):
		ls.append([])
		ls[i]=read_file("/home/jp697/Major/exp/task1/stream%d" % (i+1))
		#print ls[i]
		#input('stop')
	ls=np.array(ls)
	weight=inter(ls)
	for i in range(5):
		print "LM%d w=%f\n" % (i,weight[i])
	

