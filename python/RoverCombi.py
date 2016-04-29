#!usr/env/bin python
# -*- coding: UTF-8 -*-
'''
ROVER combination script

This script uses DP to perform alignment to the two input MLF files.
The final version of MLF will be stored in ./Major/challenge/mlf_combination

Usage: RoverCombi.py mlf_A mlf_B decodetype testlist --pass1 --pass2
-mlf_A: reference mlf file
-mlf_B: the other mlf file
-decodetype: decode or decode_cn
-testlist: the list of dataset
-pass1 2: the pass directory of the mlf1,2 files

Author: Junjie Pan
Latest Modified: 2016/04/26
'''
import re
from numpy import *
#global setting
delpenalty=5 #deletion and insertion penalty

#load the MLF file and convert it into python dictionary
def load_dict_from_file(filepath):
	try:
		_dict = {}
		with open(filepath, 'r') as dict_file:	   
				for line in dict_file:
					currentline = line.strip().split(' ')
					#jump the head the end and space line
					if currentline[0] == "#!MLF!#" or len(currentline)==0 or currentline[0] == '.' :
						continue
					# read the head, and inital the sub-dictionary
					elif len(currentline)==1:
						head='\"*'+currentline[0][-55:]
						_dict[head]={'word':[],'score':[],'start':[],'end':[]}
					# read the entries information
					else:
						_dict[head]['start'].append(currentline[0])
						_dict[head]['end'].append(currentline[1])
						_dict[head]['word'].append(currentline[2])
						_dict[head]['score'].append(currentline[3])				
	except IOError as ioerr:
			print "File %s does not exist" % (filepath) 
	return _dict

#cost evaluation
def costfunction(entry1,entry2,ind1,ind2):
		first=entry1['word'][ind1]
		second=entry2['word'][ind2]
		if len(first) > len(second):
			first,second = second,first

		first_length = len(first) + 1
		second_length = len(second) + 1
		distance_matrix = [range(second_length) for x in range(first_length)] 
		#print distance_matrix
		for i in range(1,first_length):
			for j in range(1,second_length):
				deletion = distance_matrix[i-1][j] + 1
				insertion = distance_matrix[i][j-1] + 1
				substitution = distance_matrix[i-1][j-1]
				if first[i-1] != second[j-1]:
					substitution += 1
				distance_matrix[i][j] = min(insertion,deletion,substitution)
		pw=distance_matrix[first_length-1][second_length-1]
		ptb=float(entry1['start'][ind1])-float(entry2['start'][ind2])
		pte=float(entry1['end'][ind1])-float(entry2['end'][ind2])
		pt=abs(ptb+pte)/1e7
		penalty=pt+pw
		return penalty
	

"""
ROVER combination usi7g Dynamic programming

Data structure:
ref={'filename1':{'word':[],'start':[],'end':[],'score':[]},'filename2':{....}}
record=[('f1 or f2 or X',index)]
penalty=[[s11,s12,...],[s21,s22,...],...]
"""
def merge_mlf(dict1, dict2):
	mlfcom={}
	for head in dict1.keys():
		f1=dict1[head]
		if head not in dict2.keys():
			f2={'word':[],'start':[],'end':[],'score':[]}
		else:
			f2=dict2[head]

		#1. DP intialisation
		penalty=[] # store penalty information in each step chosen
		record=[] # store moving step information in each step chosen
		# assign inital value to the first column and row in penalty and record matrix
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

		#2. Matrix Fill (scoring)
		for i in range(1,len(f1['word'])+1):
			for j in range(1,len(f2['word'])+1):
				# mlf_A match mlf_B
				if f1['word'][i-1] == f2['word'][j-1]:
					f1p=(('f1m', i-1, j-1), penalty[i-1][j])
				# mlf_A match !NULL in mlf_B
				else:
					f1p=(('f1', i-1), penalty[i-1][j]+\
						delpenalty)
				# !NULL in mlf_A match mlf_B
				f2p=(('f2', j-1), penalty[i][j-1]+\
					delpenalty)
				# mlf_A subsitute mlf_B
				f12p=(('X', i-1, j-1), penalty[i-1][j-1]+\
					costfunction(f1,f2,i-1,j-1))
				# choose moving step by selecting the minimum penalty
				moving=min(f1p,f2p,f12p,key=lambda x: x[1])
				#store the penalty and record information to corresponding matrix
				penalty[i][j]=moving[1]
				record[i][j]=moving[0]
		#3. Trackback (alignment)
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
				print "An unknown error occurs in trackback"
		mlfcom[head]=list(reversed(path))
		# print "DP process completed."
	return mlfcom

# rewrite DP results into required format MLF file, !NULL score is set as 0.2
def recovermlf(dict1,dict2,mlfcom,NULL_Score=0.2):
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
				s=dict2[head]['score'][step[1]]+'_'+str(NULL_Score)
				start=dict2[head]['start'][step[1]]
				end=dict2[head]['end'][step[1]]
			elif step[1]=='!NULL':
				w=dict1[head]['word'][step[0]]+'_<ALTSTART>_<ALTEND>'
				s=dict1[head]['score'][step[0]]+'_'+str(NULL_Score)
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

# save final results into MLF file
def save_dict_to_file(_dict, filepath):
	try:
		with open(filepath, 'w') as sf:
			sf.write('''#!MLF!#\n''')
			for head in _dict.keys():
				sf.write('''%s\n'''% head)
				for i in range(len(_dict[head]['word'])):
					if _dict[head]['start'][0]==0 and _dict[head]['end'][0]==1:
						break
					else:
						sf.write("%s %s %s %s\n"%(_dict[head]['start'][i],_dict[head]['end'][i],\
							_dict[head]['word'][i],_dict[head]['score'][i]))
				sf.write('.\n')
	except IOError as ioerr:
		print "File %s unable to generate, \nPlease checking the path and the storage" % (filepath)

# selecting the word with highest score in each case, and save it to mlf file
def bestpath(inputdir,outputdir):
	_dict=load_dict_from_file(inputdir)
	for head in _dict.keys():
		for i in range(len(_dict[head]['word'])):
			w=filter(lambda x: len(x) > 0,re.split(r"_<ALTSTART>_|_<ALT>_|_<ALTEND>",_dict[head]['word'][i]))

			s=list(float(s) for s in str(_dict[head]['score'][i]).split('_'))
			for j in range(len(s)):
				if s[j]==max(s):
					ind=j
			_dict[head]['word'][i]=w[ind]
			_dict[head]['score'][i]=s[ind]
	save_dict_to_file(_dict,outputdir)

# load the dataset list
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

def main(c1,c2,decodetype, testlist, pass1, pass2):
	comb=c1+"+"+c2+'_'+decodetype
	# print 'ok'
	# print testlist
	files=readlist(testlist)
	for f in files:
		# for CN mlf files
		if decodetype=="decode_cn":
			_dict1 = load_dict_from_file(r'/home/jp697/Major/%s/%s/%s/%s/rescore_mappingtrees.mlf'%(pass1, c1,f,decodetype))
			_dict2 = load_dict_from_file(r'/home/jp697/Major/%s/%s/%s/%s/rescore_mappingtrees.mlf'%(pass2, c2,f,decodetype))
		# for original mlf files
		elif decodetype=='decode':
			_dict1 = load_dict_from_file(r'/home/jp697/Major/%s/%s/%s/%s/rescore.mlf'%(pass1,c1,f,decodetype))
			_dict2 = load_dict_from_file(r'/home/jp697/Major/%s/%s/%s/%s/rescore.mlf'%(pass2,c2,f,decodetype))
		# for 2nd combination
		else:
			_dict1 = load_dict_from_file(r'/home/jp697/Major/mlf_combine/%s/combine/%s/decode_cn/rescore.mlf'%(c1,f))
			_dict2 = load_dict_from_file(r'/home/jp697/Major/mlf_combine/%s/combine/%s/decode_cn/rescore.mlf'%(c2,f))
		mlfcom=merge_mlf(_dict1,_dict2)
		dictcom = recovermlf(_dict1,_dict2, mlfcom)	
		save_dict_to_file(dictcom,r'/home/jp697/Major/mlf_combine/%s/%s.mlf'%(comb,f))
		bestpath(r'/home/jp697/Major/mlf_combine/%s/%s.mlf'%(comb,f),\
			r'/home/jp697/Major/mlf_combine/%s/combine/%s/%s/rescore.mlf'%(comb,f,decodetype))

if __name__ == '__main__' :
	import argparse
	parser=argparse.ArgumentParser(description='Combine two mlf files')
	parser.add_argument('sys1',type=str)
	parser.add_argument('sys2',type=str)
	parser.add_argument('decode_type',type=str)
	parser.add_argument('testlist',type=str)
	parser.add_argument('--pass1',type=str)
	parser.add_argument('--pass2',type=str)
	args=parser.parse_args()
	main(args.sys1,args.sys2,args.decode_type, args.testlist,args.pass1, args.pass2)