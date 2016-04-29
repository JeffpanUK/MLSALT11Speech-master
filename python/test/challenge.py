# -*- coding: UTF-8 -*-
import os,sys
import re

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
			print "文件 %s 不存在" % (filepath)
	 
	return _dict

delpenalty=3
altpenalty=5


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

def recovermlf(dict1,dict2,lfcom,nulls=0.2):
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


# def align_mlf(_dict1,_dict2,nulls=0.2):
# 	#alignment two dictionaries
# 	#align the files
# 	# for head in _dict1.keys():
# 	# 	if head not in _dict2.keys():
# 	# 		_dict2[head]={'start':[],'end':[],'word':[],'score':[]}
# 	# for head in _dict2.keys():
# 	# 	if head not in _dict1.keys():
# 	# 		_dict1[head]={'start':[],'end':[],'word':[],'score':[]}
# 	#algin the words
# 	for head in _dict1.keys():
# 		if _dict1[head]=={} and _dict2[head]!={}: 
# 			_dict1[head]={'word':['!NULL'],'start':[],'end':[],'score':[nulls]}
# 			_dict1[head]['start'].append(_dict2[head]['start'][0])
# 			_dict1[head]['end'].append(_dict2[head]['end'][-1])
# 			print '1'
# 			print head
# 		elif _dict2[head]=={} and _dict1[head]!={}: 
# 			_dict2[head]={'word':['!NULL'],'start':[],'end':[],'score':[nulls]}
# 			_dict2[head]['start'].append(_dict1[head]['start'][0])
# 			_dict2[head]['end'].append(_dict1[head]['end'][-1])
# 			print '2'
# 			print head
# 		elif _dict1[head] == {} and _dict2[head]=={}:
# 			_dict1[head]={'word':['!NULL'],'start':[0],'end':[1],'score':[nulls]}
# 			_dict2[head]={'word':['!NULL'],'start':[0],'end':[1],'score':[nulls]}
# 			print '3'
# 			print head

# 	for head in _dict1.keys():
# 		i=0
# 		maxv=max(len(_dict1[head]['word']),len(_dict2[head]['word']))
# 		while(i<maxv):
# 			maxv=max(len(_dict1[head]['word']),len(_dict2[head]['word']))
# 			if i+1>=len(_dict1[head]['word']) and i+1<len(_dict2[head]['word']):
# 				for j in range(i+1,maxv):
# 					_dict1[head]['start'].append(_dict2[head]['start'][j])
# 					_dict1[head]['end'].append(_dict2[head]['end'][j])
# 					_dict1[head]['score'].append(nulls)
# 					_dict1[head]['word'].append("!NULL")
# 			elif i+1>=len(_dict2[head]['word']) and i+1<len(_dict1[head]['word']):
# 				for j in range(i+1,maxv):
# 					_dict2[head]['start'].append(_dict1[head]['start'][j])
# 					_dict2[head]['end'].append(_dict1[head]['end'][j])
# 					_dict2[head]['score'].append(nulls)
# 					_dict2[head]['word'].append("!NULL")
# 			dife=int(_dict1[head]['end'][i])-int(_dict2[head]['end'][i])
# 			if abs(dife)<200000:
# 				_dict1[head]['end'][i]=max(int(_dict1[head]['end'][i]),int(_dict2[head]['end'][i]))
# 				_dict2[head]['end'][i]=max(int(_dict1[head]['end'][i]),int(_dict2[head]['end'][i]))
# 				if (i+1)<len(_dict1[head]['start']) and (i+1)<len(_dict2[head]['start']):
# 					_dict1[head]['start'][i+1]=_dict1[head]['end'][i]
# 					_dict2[head]['start'][i+1]=_dict2[head]['end'][i]
# 			elif dife>0: # dict1 |-------|  dict2 |-|, so dict1 is NULL
# 				if len(_dict1[head]['word'])==len(_dict2[head]['word']) and (i+1)==maxv:
# 					_dict2[head]['end'][i]=_dict1[head]['end'][i]		
# 				else:
# 					ins_time=_dict2[head]['end'][i]
# 					_dict1[head]['start'].insert(i+1,ins_time)
# 					_dict1[head]['end'].insert(i,ins_time)
# 					_dict1[head]['end'][i+1]=_dict2[head]['end'][i+1]
# 					_dict1[head]['word'].insert(i+1,'!NULL')
# 					_dict1[head]['score'].insert(i+1,nulls)
# 			elif dife<0: # dict1 |-------|  dict2 |-|, so dict1 is NULL
# 				if len(_dict1[head]['word'])==len(_dict2[head]['word']) and (i+1)==maxv:
# 					_dict1[head]['end'][i]=_dict2[head]['end'][i]	
# 				else:
# 					ins_time=_dict1[head]['end'][i]
# 					_dict2[head]['start'].insert(i+1,ins_time)
# 					_dict2[head]['end'].insert(i,ins_time)
# 					_dict2[head]['end'][i+1]=_dict1[head]['end'][i+1]
# 					_dict2[head]['word'].insert(i+1,'!NULL')
# 					_dict2[head]['score'].insert(i+1,nulls)
# 			i+=1

# 		for head in _dict1.keys():
# 			if head=="*/DEV001-20010117-XX2000-en_FFWXXXX_0071230_0071778.rec":
# 				print _dict1[head]

# 			if len(_dict1[head]['start'])==0 or len(_dict2[head]['end'])==0:
# 				print head
# 			if _dict1[head]['start'][-1]==_dict1[head]['end'][-1]:
# 				_dict1[head]['start'].pop(-1)
# 				_dict1[head]['end'].pop(-1)
# 				_dict1[head]['word'].pop(-1)
# 				_dict1[head]['score'].pop(-1)
# 			if _dict2[head]['start'][-1]==_dict2[head]['end'][-1]:
# 				_dict2[head]['start'].pop(-1)
# 				_dict2[head]['end'].pop(-1)
# 				_dict2[head]['word'].pop(-1)
# 				_dict2[head]['score'].pop(-1)
# 		# print _dict1[head]['end']
# 	return _dict1,_dict2

# def combine_mlf(dicts):
# 	dictcom={}
# 	scale=float(len(dicts.keys()))
# 	if len(dicts.keys())==2:
# 		for head in dicts[0].keys():
# 			dictcom[head]={'word':[],'start':[],'end':[],'score':[]}
# 			for i in range(len(dicts[0][head]['word'])):
# 				dictcom[head]['start'].append(dicts[0][head]['start'][i])
# 				dictcom[head]['end'].append(dicts[0][head]['end'][i])
# 				if dicts[0][head]['word'][i] == dicts[1][head]['word'][i]:
# 					if dicts[0][head]['word'][i]!='!NULL':
# 						w=dicts[0][head]['word'][i]
# 					else:
# 						w=''
# 					s=(float(dicts[0][head]['score'][i])+float(dicts[1][head]['score'][i]))/scale
# 				else:
# 					if dicts[0][head]['word'][i]!='!NULL' and dicts[1][head]['word'][i]!='!NULL':
# 						w=dicts[0][head]['word'][i]+'_<ALTSTART>_'+dicts[1][head]['word'][i]+'_<ALTEND>'
# 						s=str(dicts[0][head]['score'][i])+'_'+str(dicts[1][head]['score'][i])
# 					elif dicts[0][head]['word'][i]=='!NULL':
# 						w=dicts[1][head]['word'][i]+'_<ALTSTART>_'+'<ALTEND>'
# 						s=str(dicts[1][head]['score'][i])+'_'+str(dicts[0][head]['score'][i])
# 					elif dicts[1][head]['word'][i]=='!NULL':
# 						w=dicts[0][head]['word'][i]+'_<ALTSTART>_'+'<ALTEND>'
# 						s=str(dicts[0][head]['score'][i])+'_'+str(dicts[1][head]['score'][i])
# 				dictcom[head]['word'].append(w)
# 				dictcom[head]['score'].append(s)
# 	else:
# 		for head in dicts[0].keys():
# 			dictcom[head]={'word':[],'start':[],'end':[],'score':[]}
# 			for i in range(len(dicts[0][head]['word'])):
# 				wordstore=[]
# 				scorestore=[]
# 				dictcom[head]['start'].append(dicts[0][head]['start'][i])
# 				dictcom[head]['end'].append(dicts[0][head]['end'][i])
# 				for j in dicts.keys():
# 					if dicts[j][head]['word'][i] not in wordstore:
# 						wordstore.append(dicts[j][head]['word'][i])
# 						scorestore.append(dicts[j][head]['score'][i])
# 					else:
# 						for k in range(len(wordstore)):
# 							if wordstore[k] == dicts[j][head]['word'][i]:
# 								scorestore[k] = (float(scorestore[k])+float(dicts[j][head]['score'][i]))/scale
# 				for i in range(len(wordstore)):
# 					if wordstore[i] == '!NULL':
# 						wordstore.pop(i)
# 						wordstore.append('!NULL')
# 						scorestore.pop(i)
# 						scorestore.append(nulls)
# 				if len(wordstore)==1:
# 					if wordstore[0]=='!NULL':
# 						w=''
# 					else:	
# 						w=wordstore[0]
# 						s=str(scorestore[0])
# 				else:
# 					w=wordstore[0]+'_<ALTSTART>_'
# 					s=str(scorestore[0])+'_'
# 					for j in range(1,len(wordstore)):
# 						if j==len(wordstore)-1:
# 							if wordstore[j]!='!NULL':
# 								w+=wordstore[j]+'_<ALTEND>'
# 							else:
# 								w+='<ALTEND>'
# 							s+=str(scorestore[j])
# 						else:
# 							if wordstore[j]!='!NULL':
# 								w+=wordstore[j]+'_<ALT>_'
# 							else:
# 								w+='<DEL>'
# 							s+=str(scorestore[j])+'_'
# 				dictcom[head]['word'].append(w)
# 				dictcom[head]['score'].append(s)
# 	return dictcom
def save_dict_to_file(_dict, filepath):
	try:
		with open(filepath, 'w') as sf:
			sf.write('''#!MLF!#\n''')
			for head in _dict.keys():
				sf.write('''%s\n'''% head)
				for i in range(len(_dict[head]['word'])):
					if _dict[head]['start'][0]==0 and _dict[head]['end'][0]==1:
						print 'yesseesesese'
						break
					else:
						sf.write("%s %s %s %s\n"%(_dict[head]['start'][i],_dict[head]['end'][i],\
							_dict[head]['word'][i],_dict[head]['score'][i]))
				sf.write('.\n')
	except IOError as ioerr:
		print "文件 %s 无法创建" % (filepath)
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
			_dict[head]['score'][i]=s[ind]

	save_dict_to_file(_dict,outputdir)

def readlist(filepath):
	try:
		with open (filepath,'r') as fs:
			store=[]
			for line in fs:
				filename=line.strip().split()
				if len(filename) == 1:
					store.append(filename[0][2:])
		return store
	except IOError as ioerr:
		print "error happens when writing %s" %filepath

if __name__ == '__main__' :
	c1="adapt-lm-plp"
	c2="adapt-lm-grph"
	comb=c1+"+"+c2
	files=readlist(r'/home/jp697/Major/exp/temp_file/challenge_eval')
	for f in files:
		_dict1 = load_dict_from_file(r'/home/jp697/Major/challenge/%s/%s/decode_cn/rescore_mappingtrees.mlf'%(c1,f))
		_dict2 = load_dict_from_file(r'/home/jp697/Major/challenge/%s/%s/decode_cn/rescore_mappingtrees.mlf'%(c2,f))
		mlfcom=merge_mlf(_dict1,_dict2)
		dictcom = recovermlf(_dict1,_dict2,mlfcom)	
		save_dict_to_file(dictcom,r'/home/jp697/Major/challenge/mlf_combine/%s/%s.mlf'%(comb,f))
		rover(r'/home/jp697/Major/challenge/mlf_combine/%s/%s.mlf'%(comb,f),\
			r'/home/jp697/Major/challenge/mlf_combine/%s/combine/%s/decode_cn/rescore.mlf'%(comb,f))
		# _dict1 = load_dict_from_file(r'/home/jp697/Major/challenge/mlf_combine/%s/combine/%s/decode_cn/rescore.mlf'%(c1,f))
		# _dict2 = load_dict_from_file(r'/home/jp697/Major/challenge/mlf_combine/%s/combine/%s/decode_cn/rescore.mlf'%(c2,f))
		# mlfcom=merge_mlf(_dict1,_dict2)
		# dictcom = recovermlf(_dict1,_dict2,mlfcom)	
		# save_dict_to_file(dictcom,r'/home/jp697/Major/challenge/mlf_combine/%s/%s.mlf'%(comb,f))
		# rover(r'/home/jp697/Major/challenge/mlf_combine/%s/%s.mlf'%(comb,f),\
		# 	r'/home/jp697/Major/challenge/mlf_combine/%s/combine/%s/decode_cn/rescore.mlf'%(comb,f))
