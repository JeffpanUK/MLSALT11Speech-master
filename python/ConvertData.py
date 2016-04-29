# -*- coding: UTF-8 -*-
'''
ConvertData.py file
Function: Convert 1-best hypothesis into suitable data file, so that it can be used 
to generate the interpolation weights

Description:
Usage: ConvertData.py dataset 1best_path savepath
-dataset: the data list. eg: challenge_dev, challenge_eval, dev03, eval03
-1best_path: the directory of the 1best hypothesis (after./Major)
-savepath: the directory to store the converted data file.

Author: Junjie Pan
Latest Modified: 2016/04/25
'''
#read the MLF file and save it into dictionary
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
			print "File %s does not exist" % (filepath)
	 
	return _dict
 
# save the dictionary into reuqire data format
def save_dict_to_file(_dict, filepath):
	try:
		with open(filepath, 'a') as dict_file:
			for key in _dict.keys():
				dict_file.write('''<s> ''')
				for word in _dict[key]:
					dict_file.write(word+' ')
				dict_file.write('''</s>\n''')
	except IOError as ioerr:
		print "File %s unable to create" % (filepath)

#read dataset list
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

def main(lists,path,output):
	files=readlist(r'/home/jp697/Major/exp/temp_file/%s'%lists)
	for f in files:
		_dict = load_dict_from_file(r'/home/jp697/Major/%s/%s/1best/LM12.0_IN-10.0/rescore.mlf'%(path,f))
		save_dict_to_file(_dict, output)

if __name__ == '__main__' :
	import argparse  	
	parser=argparse.ArgumentParser(decription='Convert 1best Hyp into suitable format')
	parser.add_argumrnt('dataset_list',type=str)
	parser.add_argumrnt('1best_path',type=str)
	parser.add_argumrnt('output',type=str)
	args=parser.parse_args()
	main(args.dataset_list, args.1best_path, args.output)