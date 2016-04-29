# -*- coding: UTF-8 -*-
import os,sys
import xml.dom.minidom
#try:
#    fsock = open(r"/usr/MLSALT5/practical1/exp/final.xml", "r")
#except IOError:
#    print "The file don't exist, Please double check!"
#    exit()
#fsock.close()


def load_dict_from_file(filepath):
	try:
		_dict = {}
		with open(filepath, 'r') as dict_file:	  
			sent=0
			for line in dict_file:
				wordline = line.strip().split(' ')
				if wordline[0] == '.':
					sent+=1
				elif len(wordline)==1:
					continue
				else:
					if sent not in _dict.keys():
						_dict[sent]=[]
					_dict[sent].append(wordline[2])
							
	except IOError as ioerr:
			print "文件 %s 不存在" % (filepath)
	 
	return _dict
 
def save_dict_to_file(_dict, filepath):
	try:
		with open(filepath, 'a') as dict_file:
			for key in _dict.keys():
				dict_file.write('''<s> ''')
				for word in _dict[key]:
					dict_file.write(word+' ')
				dict_file.write('''</s>\n''')
	except IOError as ioerr:
		print "文件 %s 无法创建" % (filepath)

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
	files=readlist(r'/home/jp697/Major/exp/temp_file/challenge_dev')
	for f in files:
		_dict = load_dict_from_file(r'/home/jp697/Major/challenge/plp-bg_dev/%s/1best/LM12.0_IN-10.0/rescore.mlf'%f)
		save_dict_to_file(_dict, r'/home/jp697/Major/challenge/store_dat/YTBEdev.dat')  	