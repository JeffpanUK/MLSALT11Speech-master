# -*- coding: UTF-8 -*-
import os,sys
import xml.dom.minidom

import gzip
 

def read_gz_file(path):
	if os.path.exists(path):
		with gzip.open(path, 'rt') as pf:
			count=0
			_dict={}
			for line in pf:
				currentline = line.strip().split()
				if currentline[0][0]=='N':
					N=currentline[0][-1]
				elif currentline[0][0]=='k':
					_dict[count]={'word':[],'start':[],'end':[],'score':[]}
					count+=1
				else:
					_dict[count-1]['word'].append(currentline[0][2:])
					_dict[count-1]['start'].append(currentline[1][2:])
					_dict[count-1]['end'].append(currentline[2][2:])
					_dict[count-1]['score'].append(currentline[3][2:])
			print _dict

	else:
		print('the path [{}] is not exist!'.format(path))
 
 
def align_mlf(_dict1,_dict2,nulls=0.2):
	#alignment two dictionaries
	for head in _dict1.keys():
		if _dict1[head]=={} and _dict2[head]!={}: 
			_dict1[head]={'word':['!NULL'],'start':[],'end':[],'score':[nulls]}
			_dict1[head]['start'].append(_dict2[head]['start'][0])
			_dict1[head]['end'].append(_dict2[head]['end'][-1])
		elif _dict2[head]=={} and _dict1[head]!={}: 
			_dict2[head]={'word':['!NULL'],'start':[],'end':[],'score':[nulls]}
			_dict2[head]['start'].append(_dict1[head]['start'][0])
			_dict2[head]['end'].append(_dict1[head]['end'][-1])
		elif _dict1[head] == {} and _dict2[head]=={}:
			_dict1[head]={'word':['!NULL'],'start':[0],'end':[1],'score':[nulls]}
			_dict2[head]={'word':['!NULL'],'start':[0],'end':[1],'score':[nulls]}
			print head

	for head in _dict1.keys():
		i=0
		maxv=max(len(_dict1[head]['word']),len(_dict2[head]['word']))
		while(i<maxv):
			maxv=max(len(_dict1[head]['word']),len(_dict2[head]['word']))
			if i+1>=len(_dict1[head]['word']) and i+1<len(_dict2[head]['word']):
				for j in range(i+1,maxv):
					_dict1[head]['start'].append(_dict2[head]['start'][j])
					_dict1[head]['end'].append(_dict2[head]['end'][j])
					_dict1[head]['score'].append(nulls)
					_dict1[head]['word'].append("!NULL")
			elif i+1>=len(_dict2[head]['word']) and i+1<len(_dict1[head]['word']):
				for j in range(i+1,maxv):
					_dict2[head]['start'].append(_dict1[head]['start'][j])
					_dict2[head]['end'].append(_dict1[head]['end'][j])
					_dict2[head]['score'].append(nulls)
					_dict2[head]['word'].append("!NULL")
			dife=int(_dict1[head]['end'][i])-int(_dict2[head]['end'][i])
			if abs(dife)<300000:
				_dict1[head]['end'][i]=max(int(_dict1[head]['end'][i]),int(_dict2[head]['end'][i]))
				_dict2[head]['end'][i]=max(int(_dict1[head]['end'][i]),int(_dict2[head]['end'][i]))
				if (i+1)<len(_dict1[head]['start']) and (i+1)<len(_dict2[head]['start']):
					_dict1[head]['start'][i+1]=_dict1[head]['end'][i]
					_dict2[head]['start'][i+1]=_dict2[head]['end'][i]
			elif dife>0: # dict1 |-------|  dict2 |-|, so dict1 is NULL
				if len(_dict1[head]['word'])==len(_dict2[head]['word']) and (i+1)==maxv:
					_dict2[head]['end'][i]=_dict1[head]['end'][i]		
				else:
					ins_time=_dict2[head]['end'][i]
					_dict1[head]['start'].insert(i+1,ins_time)
					_dict1[head]['end'].insert(i,ins_time)
					_dict1[head]['end'][i+1]=_dict2[head]['end'][i+1]
					_dict1[head]['word'].insert(i+1,'!NULL')
					_dict1[head]['score'].insert(i+1,nulls)
			elif dife<0: # dict1 |-------|  dict2 |-|, so dict1 is NULL
				if len(_dict1[head]['word'])==len(_dict2[head]['word']) and (i+1)==maxv:
					_dict1[head]['end'][i]=_dict2[head]['end'][i]	
				else:
					ins_time=_dict1[head]['end'][i]
					_dict2[head]['start'].insert(i+1,ins_time)
					_dict2[head]['end'].insert(i,ins_time)
					_dict2[head]['end'][i+1]=_dict1[head]['end'][i+1]
					_dict2[head]['word'].insert(i+1,'!NULL')
					_dict2[head]['score'].insert(i+1,nulls)
			i+=1

		for head in _dict1.keys():
			if len(_dict1[head]['start'])==0 or len(_dict2[head]['end'])==0:
				print head
			if _dict1[head]['start'][-1]==_dict1[head]['end'][-1]:
				_dict1[head]['start'].pop(-1)
				_dict1[head]['end'].pop(-1)
				_dict1[head]['word'].pop(-1)
				_dict1[head]['score'].pop(-1)
			if _dict2[head]['start'][-1]==_dict2[head]['end'][-1]:
				_dict2[head]['start'].pop(-1)
				_dict2[head]['end'].pop(-1)
				_dict2[head]['word'].pop(-1)
				_dict2[head]['score'].pop(-1)
		# print _dict1[head]['end']
	return _dict1,_dict2

def combine_mlf(dicts):
	dictcom={}
	scale=float(len(dicts.keys()))
	if len(dicts.keys())==2:
		for head in dicts[0].keys():
			dictcom[head]={'word':[],'start':[],'end':[],'score':[]}
			for i in range(len(dicts[0][head]['word'])):
				dictcom[head]['start'].append(dicts[0][head]['start'][i])
				dictcom[head]['end'].append(dicts[0][head]['end'][i])
				if dicts[0][head]['word'][i] == dicts[1][head]['word'][i]:
					if dicts[0][head]['word'][i]!='!NULL':
						w=dicts[0][head]['word'][i]
					else:
						w=''
					s=(float(dicts[0][head]['score'][i])+float(dicts[1][head]['score'][i]))/scale
				else:
					if dicts[0][head]['word'][i]!='!NULL' and dicts[1][head]['word'][i]!='!NULL':
						w=dicts[0][head]['word'][i]+'_<ALTSTART>_'+dicts[1][head]['word'][i]+'_<ALTEND>'
						s=str(dicts[0][head]['score'][i])+'_'+str(dicts[1][head]['score'][i])
					elif dicts[0][head]['word'][i]=='!NULL':
						w=dicts[1][head]['word'][i]+'_<ALTSTART>_'+'<ALTEND>'
						s=str(dicts[1][head]['score'][i])+'_'+str(dicts[0][head]['score'][i])
					elif dicts[1][head]['word'][i]=='!NULL':
						w=dicts[0][head]['word'][i]+'_<ALTSTART>_'+'<ALTEND>'
						s=str(dicts[0][head]['score'][i])+'_'+str(dicts[1][head]['score'][i])
				dictcom[head]['word'].append(w)
				dictcom[head]['score'].append(s)
	else:
		for head in dicts[0].keys():
			dictcom[head]={'word':[],'start':[],'end':[],'score':[]}
			for i in range(len(dicts[0][head]['word'])):
				wordstore=[]
				scorestore=[]
				dictcom[head]['start'].append(dicts[0][head]['start'][i])
				dictcom[head]['end'].append(dicts[0][head]['end'][i])
				for j in dicts.keys():
					if dicts[j][head]['word'][i] not in wordstore:
						wordstore.append(dicts[j][head]['word'][i])
						scorestore.append(dicts[j][head]['score'][i])
					else:
						for k in range(len(wordstore)):
							if wordstore[k] == dicts[j][head]['word'][i]:
								scorestore[k] = (float(scorestore[k])+float(dicts[j][head]['score'][i]))/scale
				for i in range(len(wordstore)):
					if wordstore[i] == '!NULL':
						wordstore.pop(i)
						wordstore.append('!NULL')
						scorestore.pop(i)
						scorestore.append(nulls)
				if len(wordstore)==1:
					if wordstore[0]=='!NULL':
						w=''
					else:	
						w=wordstore[0]
						s=str(scorestore[0])
				else:
					w=wordstore[0]+'_<ALTSTART>_'
					s=str(scorestore[0])+'_'
					for j in range(1,len(wordstore)):
						if j==len(wordstore)-1:
							if wordstore[j]!='!NULL':
								w+=wordstore[j]+'_<ALTEND>'
							else:
								w+='<ALTEND>'
							s+=str(scorestore[j])
						else:
							if wordstore[j]!='!NULL':
								w+=wordstore[j]+'_<ALT>_'
							else:
								w+='<DEL>'
							s+=str(scorestore[j])+'_'
				dictcom[head]['word'].append(w)
				dictcom[head]['score'].append(s)
	return dictcom
def save_dict_to_file(_dict, filepath):
    try:
        with open(filepath, 'w') as sf:
	    	sf.write('''#!MLF!#\n''')
	    	for head in _dict.keys():
	    		sf.write('''%s\n'''% head)
	    		for i in range(len(_dict[head]['word'])):
	    			sf.write("%s %s %s %s\n"%(_dict[head]['start'][i],_dict[head]['end'][i],\
	    				_dict[head]['word'][i],_dict[head]['score'][i]))
	    		sf.write('.\n')
    except IOError as ioerr:
        print "文件 %s 无法创建" % (filepath)
		
if __name__ == '__main__' :
	# files=['dev03_DEV002-20010120-XX1830',\
	# 		'dev03_DEV010-20010131-XX2000',\
	# 		'dev03_DEV007-20010128-XX1400',\
	# 		'dev03_DEV004-20010125-XX1830',\
	# 		'dev03_DEV003-20010122-XX2100',\
	# 		'dev03_DEV001-20010117-XX2000']
	# for f in files:
	# 	_dict1 = load_dict_from_file(r'/home/jp697/Major/plp-bg/%s/decode_cn/rescore_mappingtrees.mlf'%f)
	# 	_dict2 = load_dict_from_file(r'/home/jp697/Major/grph-plp-bg/%s/decode_cn/rescore_mappingtrees.mlf'%f)
	
	# 	(_dict1,_dict2)=align_mlf(_dict1,_dict2)
	# 	dicts={0:_dict1,1:_dict2}
	# 	dictcom = combine_mlf(dicts)	
	# # print dictcom
	# 	save_dict_to_file(dictcom,r'/home/jp697/Major/exp/task6/%s.mlf'%f)
	read_gz_file(r'/home/jp697/Major/grph-plp-bg/dev03_DEV002-20010120-XX1830/decode_cn/lattices/DEV002-20010120-XX1830-en_FFWXXXX_0011893_0012137.scf.gz')