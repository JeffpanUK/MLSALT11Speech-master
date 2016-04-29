#!usr/env/bin python
#-*-UTF-8-*-
'''
Confusion Network Combination

author: Junjie Pan
data:03/April/2016
'''

import os,sys
import gzip
import re
import numpy as np
delpenalty=3
altpenalty=5
def rover(inputdir,outputdir):
	_dict=load_dict_from_file(inputdir)
	for head in _dict.keys():
		for i in range(len(_dict[head]['word'])):
			w=filter(lambda x: len(x) > 0,re.split(r"_<ALTSTART>_|_<ALT>_|_<ALTEND>",_dict[head]['word'][i]))

			s=list(float(s) for s in str(_dict[head]['score'][i]).split('_'))
			for j in range(len(s)):
				if s[j]==max(s):
					ind=j
			_dict[head]['word'][i]=w[ind]
			_dict[head]['score'][i]=round(np.exp(float(s[ind])),6)

	save_dict_to_file(_dict,outputdir)

def read_lattice(filepath):
	lattice = {}
	for head in os.listdir(filepath):
		path = filepath + head
		head='\"/'+head[:-6]+'rec\"'
		lattice[head]={'word':[],'start':[],'end':[],'score':[]}
		words=[]
		starts=[]
		ends=[]
		scores=[]
		with gzip.open(path, 'rb') as fs:
			flag=0
			jump=0
			for line in fs:
				info=line.strip().split()
				if len(info)==1 and info[0][0]!='N':
					flag=1
					jump=0
					word=''
					count=int(info[0][2:])
					continue
				elif flag==1 and jump==0:
					if info[0][2:]=='<s>':
						count-=1
						jump=1
						continue
					elif info[0][2:]=='</s>':
						count-=1
						flag=0
						continue
					else:
						if word=='' and count>1: #start word of alternative path
							word=info[0][2:]+'_<ALTSTART>_'
							score=info[3][2:]+'_'
							start=float(info[1][2:])
							end=float(info[2][2:])
							count-=1
						elif word=='' and count==1: #unique path
							word=info[0][2:]
							score=info[3][2:]
							start=float(info[1][2:])
							end=float(info[2][2:])
							flag=0
						elif count>1: #middle of alternative path
							word+=info[0][2:]+'_<ALT>_'
							score+=info[3][2:]+'_'
							start=max(float(info[1][2:]),start)
							end=max(float(info[2][2:]),end)
							count-=1
						elif count==1: #end of alternative path
							word+=info[0][2:]+'_<ALTEND>'
							score+=info[3][2:]
							start=max(float(info[1][2:]),start)
							end=max(float(info[2][2:]),end)
							flag=0
				else:
					continue
				if flag==0:
					words.append(word)
					scores.append(score)
					starts.append(int(start*(1e7)))
					ends.append(int(end*(1e7)))
			lattice[head]['word']=list(reversed(words))
			lattice[head]['start']=list(reversed(starts))
			lattice[head]['end']=list(reversed(ends))
			lattice[head]['score']=list(reversed(scores))
	return lattice

def load_dict_from_file(filepath):
	try:
		_dict = {}
		with open(filepath, 'r') as dict_file:	   
				for line in dict_file:
					currentline = line.strip().split(' ')
					if currentline[0] == "#!MLF!#" or len(currentline)==0 or currentline[0] == '.' :
						continue
					elif len(currentline)==1:
						head='\"*'+currentline[0][-55:]
						_dict[head]={'word':[],'score':[],'start':[],'end':[]}
						# print head
					else:
						_dict[head]['start'].append(currentline[0])
						_dict[head]['end'].append(currentline[1])
						_dict[head]['word'].append(currentline[2])
						_dict[head]['score'].append(currentline[3])
				
	except IOError as ioerr:
			print "File %s does not exist" % (filepath)
	 
	return _dict

def save_dict_to_file(_dict, filepath):
	try:
		with open(filepath, 'w') as sf:
			sf.write('''#!MLF!#\n''')
			for head in _dict.keys():
				sf.write('''%s\n'''% head)
				for i in range(len(_dict[head]['word'])):
					if _dict[head]['start'][0]==0 and _dict[head]['end'][0]==1:
						# print 'yesseesesese'
						break
					else:
						sf.write("%s %s %s %s\n"%(_dict[head]['start'][i],_dict[head]['end'][i],\
							_dict[head]['word'][i],_dict[head]['score'][i]))
				sf.write('.\n')
	except IOError as ioerr:
		print "unable %s" % (filepath)

# def remove_null(_dict):
# 	new_dict={}
# 	for head in _dict:
# 		new_dict[head]={'word':[],'start':[],'end':[],'score':[]}
# 		for i in len(_dict[head]):
# 			if _dict[head]['word'][i]='!NULL':
# 				_dict[head]['word'].pop(i)
# 				_dict[head]['end'][i-1]=_dict[head]['end'][i]
# 				i-=1


def merge_mlf(dict1, dict2):
	mlfcom={}
	for head in dict1.keys():
		f1=dict1[head]
		if head not in dict2.keys():
			f2={'word':[],'start':[],'end':[],'score':[]}
		else:
			f2=dict2[head]
		"""
		ref={'filename1':{'word':[],'start':[],'end':[],'score':[]},'filename2':{....}}
		record=[('f1 or f2 or X',index)]
		penalty=[[s11,s12,...],[s21,s22,...],...]
		"""
		penalty=[]
		record=[]

		for i in range(len(f1['word'])+1):
			penalty.append([])
			record.append([])
			for j in range(len(f2['word'])+1):
				penalty[i].append(0)
				record[i].append('')
		#initialisation
		record[0][0] = ('Begin', '')
		for i in range(1,len(f1['word'])+1):
			penalty[i][0] = i*delpenalty
			record[i][0] = ('f1', i-1)
		for j in range(1,len(f2['word'])+1):
			penalty[0][j] = j*delpenalty
			record[0][j] = ('f2', j-1)
		for i in range(1,len(f1['word'])+1):
			for j in range(1,len(f2['word'])+1):
				#match or word in reference mapps NULL in other
				if f1['word'][i-1] == f2['word'][j-1]:
					f1p=(('f1m', i-1, j-1), penalty[i-1][j])
				else:
					f1p=(('f1', i-1), penalty[i-1][j]+delpenalty)
				#if word in other mapps NULL in reference
				f2p=(('f2', j-1), penalty[i][j-1]+delpenalty)
				#if word in ref alter word in other
				f12p=(('X', i-1, j-1), penalty[i-1][j-1]+altpenalty)
				moving=min(f1p,f2p,f12p,key=lambda x: x[1])
				penalty[i][j]=moving[1]
				record[i][j]=moving[0]
		"""
		recordacktracks DP actions to return alignment and result statistics.
		"""
		path = []
		i = len(record)-1
		j = len(record[0])-1
		while record[i][j][0] != 'Begin':
			if record[i][j][0] == 'f1':
				path.append((record[i][j][1],'!NULL'))
				i-=1
			elif record[i][j][0] == 'f2':
				path.append(('!NULL',record[i][j][1]))
				j -= 1
			elif record[i][j][0] == 'X':
				path.append((record[i][j][1],record[i][j][2]))
				i -= 1
				j -= 1
			elif record[i][j][0] == 'f1m':
				path.append((record[i][j][1],record[i][j][2],'match'))
				i -= 1
				j -= 1
			else:
				raise Exception("Undefined action '{0}' in backtrack()".format(record[i][j]))
		mlfcom[head]=list(reversed(path))
	return mlfcom

def recovermlf(dict1,dict2,mlfcom,nulls=0.2):
	comdict={}
	for head in mlfcom.keys():
		comdict[head]={'word':[],'start':[],'end':[],'score':[]}
		for step in mlfcom[head]:
			if 'match' in step:
				w=dict1[head]['word'][step[0]]
				s=str((float(dict1[head]['score'][step[0]])+float(dict2[head]['score'][step[1]]))/2.0)
				start=dict1[head]['start'][step[0]]
				end=dict1[head]['end'][step[0]]
			elif step[0]=='!NULL':
				w=dict2[head]['word'][step[1]]+'_<ALTSTART>_<ALTEND>'
				s=dict2[head]['score'][step[1]]+'_'+str(nulls)
				start=dict2[head]['start'][step[1]]
				end=dict2[head]['end'][step[1]]
			elif step[1]=='!NULL':
				w=dict1[head]['word'][step[0]]+'_<ALTSTART>_<ALTEND>'
				s=dict1[head]['score'][step[0]]+'_'+str(nulls)
				start=dict1[head]['start'][step[0]]
				end=dict1[head]['end'][step[0]]
			else:
				w=dict1[head]['word'][step[0]]+'_<ALTSTART>_'+dict2[head]['word'][step[1]]+'_<ALTEND>'
				s=dict1[head]['score'][step[0]]+'_'+dict2[head]['score'][step[1]]
				start=dict1[head]['start'][step[0]]
				end=dict1[head]['end'][step[0]]
			comdict[head]['word'].append(w)
			comdict[head]['score'].append(s)
			comdict[head]['start'].append(start)
			comdict[head]['end'].append(end)
	return comdict

def readlist(filepath):
	try:
		with open (filepath,'r') as fs:
			store=[]
			for line in fs:
				filename=line.strip().split()
				if len(filename) == 1:
					store.append(filename[0])
		return store
	except IOError as ioerr:
		print "error happens when writing %s" %filepath	

def main(c1,c2,dataset,challenge='challenge'):
	files=readlist(r'/home/jp697/Major/exp/temp_file/%s'%dataset)
	comb='CNC_%s+%s'%(c1,c2)
	for f in files:
		_dict1 = read_lattice(r'/home/jp697/Major/%s/%s/%s/decode_cn/lattices/'\
			%(challenge,c1,f))
		_dict2 = read_lattice(r'/home/jp697/Major/%s/%s/%s/decode_cn/lattices/'\
			%(challenge,c2,f))
		# print _dict1
		# input('')
		save_dict_to_file(_dict1,r'/home/jp697/Major/%s/%s/%s/decode_cn/rescore_lattices.mlf'\
			%(challenge,c1,f))
		save_dict_to_file(_dict2,r'/home/jp697/Major/%s/%s/%s/decode_cn/rescore_lattices.mlf'\
			%(challenge,c2,f))
		rover(r'/home/jp697/Major/%s/%s/%s/decode_cn/rescore_lattices.mlf'%(challenge,c1,f),\
			r'/home/jp697/Major/%s/%s/%s/decode_cn/rescore_lattices_rover.mlf'%(challenge,c1,f))
		rover(r'/home/jp697/Major/%s/%s/%s/decode_cn/rescore_lattices.mlf'%(challenge,c2,f),\
			r'/home/jp697/Major/%s/%s/%s/decode_cn/rescore_lattices_rover.mlf'%(challenge,c2,f))
		os.popen('echo | base/conftools/smoothtree-mlf.pl lib/trees/plp-bg_decode_cn.tree\
	./%s/%s/%s/decode_cn/rescore_lattices_rover.mlf \
	> ./%s/%s/%s/decode_cn/rescore_lattices_rover_mappingtrees.mlf'%(challenge,c1,f,challenge,c1,f))
		os.popen('echo | base/conftools/smoothtree-mlf.pl lib/trees/plp-bg_decode_cn.tree\
	./%s/%s/%s/decode_cn/rescore_lattices_rover.mlf \
	> ./%s/%s/%s/decode_cn/rescore_lattices_rover_mappingtrees.mlf'%(challenge,c2,f,challenge,c2,f))

		_dict1 = load_dict_from_file(r'/home/jp697/Major/%s/%s/%s/decode_cn/rescore_lattices_rover_mappingtrees.mlf'%(challenge,c1,f))
		_dict2 = load_dict_from_file(r'/home/jp697/Major/%s/%s/%s/decode_cn/rescore_lattices_rover_mappingtrees.mlf'%(challenge,c2,f))
		mlfcom=merge_mlf(_dict1,_dict2)
		dictcom = recovermlf(_dict1,_dict2,mlfcom)	
		save_dict_to_file(dictcom,r'/home/jp697/Major/%s/mlf_cnc/%s/%s.mlf'%(challenge,comb,f))
		rover(r'/home/jp697/Major/%s/mlf_cnc/%s/%s.mlf'%(challenge,comb,f),\
			r'/home/jp697/Major/%s/mlf_cnc/%s/combine/%s/decode_cn/rescore.mlf'%(challenge,comb,f))
if __name__ == '__main__':
	import argparse
	parser=argparse.ArgumentParser(description='CNC')
	parser.add_argument('sys1',type=str)
	parser.add_argument('sys2',type=str)
	parser.add_argument('dataset',type=str)
	args = parser.parse_args()
	challenge='challenge'
	main(args.sys1, args.sys2, args.dataset, challenge)
