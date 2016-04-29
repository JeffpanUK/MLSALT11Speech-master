# -*- coding: UTF-8 -*-
import os,sys
import xml.dom.minidom


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
						_dict[head]={}
						# print head
					else:
						if _dict[head]=={}:
							_dict[head]['start']=[currentline[0]]
							_dict[head]['end']=[currentline[1]]
							_dict[head]['word']=[currentline[2]]
							_dict[head]['score']=[currentline[3]]
						else:
							_dict[head]['start'].append(currentline[0])
							_dict[head]['end'].append(currentline[1])
							_dict[head]['word'].append(currentline[2])
							_dict[head]['score'].append(currentline[3])
				
	except IOError as ioerr:
        	print "文件 %s 不存在" % (filepath)
     
	return _dict
 
 
def align_mlf(_dict1,_dict2):
	#alignment two dictionaries
	#align the files
	# for head in _dict1.keys():
	# 	if head not in _dict2.keys():
	# 		_dict2[head]={'start':[],'end':[],'word':[],'score':[]}
	# for head in _dict2.keys():
	# 	if head not in _dict1.keys():
	# 		_dict1[head]={'start':[],'end':[],'word':[],'score':[]}
	#algin the words
	for head in _dict1.keys():
		if _dict1[head]=={} and _dict2[head]!={}: 
			_dict1[head]={'word':['!NULL'],'start':[],'end':[],'score':[0]}
			_dict1[head]['start'].append(_dict2[head]['start'][0])
			_dict1[head]['end'].append(_dict2[head]['end'][-1])
		elif _dict2[head]=={} and _dict1[head]!={}: 
			_dict2[head]={'word':['!NULL'],'start':[],'end':[],'score':[0]}
			_dict2[head]['start'].append(_dict1[head]['start'][0])
			_dict2[head]['end'].append(_dict1[head]['end'][-1])
	for head in _dict1.keys():
		i=0
		# print _dict1[head]['end']
		# input('')
		# head='\"*/DEV001-20010117-XX2000-en_FFWXXXX_0068025_0069727.rec\"'
		# print head
		# print _dict1[head]['word']
		maxv=max(len(_dict1[head]['word']),len(_dict2[head]['word']))
		# print maxv
		while(i<maxv):
			maxv=max(len(_dict1[head]['word']),len(_dict2[head]['word']))
			if i+1>=len(_dict1[head]['word']) and i+1<len(_dict2[head]['word']):
				# _dict1[head]['end'][i]=_dict2[head]['end'][-1]
				ls=_dict1[head]['score'][-1]
				for j in range(i+1,maxv):
					_dict1[head]['start'].append(_dict2[head]['start'][j])
					_dict1[head]['end'].append(_dict2[head]['end'][j])
					_dict1[head]['score'].append(ls)
					_dict1[head]['word'].append("!NULL")
			elif i+1>=len(_dict2[head]['word']) and i+1<len(_dict1[head]['word']):
			 	ls=_dict1[head]['score'][-1]
			 	# _dict2[head]['end'][i]=_dict1[head]['end'][-1]
				for j in range(i+1,maxv):
					_dict2[head]['start'].append(_dict1[head]['start'][j])
					_dict2[head]['end'].append(_dict1[head]['end'][j])
					_dict2[head]['score'].append(ls)
					_dict2[head]['word'].append("!NULL")
			# else:
			dife=int(_dict1[head]['end'][i])-int(_dict2[head]['end'][i])
			# print '-1'
			# print int(_dict1[head]['end'][i])
			# print int(_dict1[head]['end'][i])
			if abs(dife)<300000:
				_dict1[head]['end'][i]=max(int(_dict1[head]['end'][i]),int(_dict2[head]['end'][i]))
				_dict2[head]['end'][i]=max(int(_dict1[head]['end'][i]),int(_dict2[head]['end'][i]))
				# print '0'
				# print int(_dict1[head]['end'][i])
				# print int(_dict1[head]['end'][i])
				if (i+1)<len(_dict1[head]['start']) and (i+1)<len(_dict2[head]['start']):
					_dict1[head]['start'][i+1]=_dict1[head]['end'][i]
					_dict2[head]['start'][i+1]=_dict2[head]['end'][i]
				# print '1'
				# print _dict1[head]['end'][i]
			elif dife>0: # dict1 |-------|  dict2 |-|, so dict1 is NULL
				if len(_dict1[head]['word'])==len(_dict2[head]['word']) and (i+1)==maxv:
					_dict2[head]['end'][i]=_dict1[head]['end'][i]
				# elif (i+1)==len(_dict1[head]['word']):
				# 	ins_time=_dict2[head]['end'][i]
				# 	_dict1[head]['start'].append(ins_time)
				# 	_dict1[head]['end'].insert(i,ins_time)
				# 	_dict1[head]['end'][i+1]=(_dict2[head]['end'][-1])
				# 	_dict1[head]['word'].append('!NULL')
				# 	_dict1[head]['score'].append(0)	

				# #if the short one is end, extend it to the end of the longer one
				# elif (i+1)==len(_dict2[head]['word']):
				# 	_dict2[head]['end'][i]=_dict1[head]['end'][-1]
				# 	input(' ')
				# 	continue			
				else:
					ins_time=_dict2[head]['end'][i]
					_dict1[head]['start'].insert(i+1,ins_time)
					_dict1[head]['end'].insert(i,ins_time)
					_dict1[head]['end'][i+1]=_dict2[head]['end'][i+1]
					_dict1[head]['word'].insert(i+1,'!NULL')
					_dict1[head]['score'].insert(i+1,_dict1[head]['score'][i])
				# print '2'
				# print _dict1[head]['end'][i] 
			elif dife<0: # dict1 |-------|  dict2 |-|, so dict1 is NULL
				if len(_dict1[head]['word'])==len(_dict2[head]['word']) and (i+1)==maxv:
					_dict1[head]['end'][i]=_dict2[head]['end'][i]
				# elif (i+1)==len(_dict2[head]['word']):
				# 	ins_time=_dict1[head]['end'][i]
				# 	_dict2[head]['start'].append(ins_time)
				# 	_dict2[head]['end'].insert(i,ins_time)
				# 	_dict2[head]['end'][i+1]=(_dict1[head]['end'][-1])
				# 	_dict2[head]['word'].append('!NULL')
				# 	_dict2[head]['score'].append(0)	
				# #if the short one is end, extend it to the end of the longer one
				# elif (i+1)==len(_dict1[head]['word']):
				# 	_dict1[head]['end'][i]=_dict2[head]['end'][-1]
				# 	print '1'
				# 	continue	
				else:
					ins_time=_dict1[head]['end'][i]
					_dict2[head]['start'].insert(i+1,ins_time)
					_dict2[head]['end'].insert(i,ins_time)
					_dict2[head]['end'][i+1]=_dict1[head]['end'][i+1]
					_dict2[head]['word'].insert(i+1,'!NULL')
					_dict2[head]['score'].insert(i+1,_dict2[head]['score'][i])
					# print '3'
					# print _dict1[head]['end'][i] 
			i+=1
		for head in _dict1.keys():
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
					w=dicts[0][head]['word'][i]
					s=(float(dicts[0][head]['score'][i])+float(dicts[1][head]['score'][i]))/scale
				else:
					w=dicts[0][head]['word'][i]+'_<ALTSTART>_'+dicts[1][head]['word'][i]+'_<ALTEND>'
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
						ls=scorestore[i]
						wordstore.pop(i)
						wordstore.append('!NULL')
						scorestore.pop(i)
						scorestore.append(ls)
				if len(wordstore)==1:
					w=wordstore[0]
					s=scorestore[0]
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
	_dict1 = load_dict_from_file(r'/home/jp697/Major/plp-bg/dev03_DEV001-20010117-XX2000/decode/rescore.mlf')
	_dict2 = load_dict_from_file(r'/home/jp697/Major/grph-plp-bg/dev03_DEV001-20010117-XX2000/decode/rescore.mlf')
	_dict3 = load_dict_from_file(r'/home/jp697/Major/plp-adapt-bg/dev03_DEV001-20010117-XX2000/decode/rescore.mlf')
	(_dict1,_dict2)=align_mlf(_dict1,_dict2)
	(_dict1,_dict3)=align_mlf(_dict1,_dict3)
	(_dict2,_dict3)=align_mlf(_dict2,_dict3)
	dicts={0:_dict1,1:_dict2,2:_dict3}
	dictcom = combine_mlf(dicts)
	# print dictcom

	save_dict_to_file(dictcom,r'/home/jp697/Major/testing/a.txt')
