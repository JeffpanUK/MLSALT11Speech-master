import os
import collections as c
import numpy as np
import sys
limit = 1;

#################################################################################################
# This is the final Merge file so never delete this file 
################################ Initial Function Settings #######################################
# os.chdir('/home/msa53/MLSALT11/')
if len(sys.argv) < 3:
    print 'python 5.6.1.py ref_mlf another_mlf'
    print '-----------------------------------'
    print 'Example:'
    print 'python job/merge.py [output file path] [ref1 file path] [ref-n file paths]'
    print 'python jobs/merge.py plp-bg/dev03_DEV001-20010117-XX2000/decode/rescore.mlf grph-plp-bg/dev03_DEV001-20010117-XX2000/decode/rescore.mlf'
    exit(1)

outputFile = sys.argv[1]
refString  = sys.argv[2]
othString  = [sys.argv[i] for i in range(3,len(sys.argv))]

########################################### Class ###############################################
class mlfEntry:
    t1,t2=None,None; woSc=c.OrderedDict();
    def __init__(s,line):
        entries=line.split(' ');
        s.t1=int(entries[0]); s.t2=int(entries[1]);words=entries[2]; scores=entries[3];
        Wo=[x for x in words.replace('<ALTSTART>','').replace('<ALT>','').replace('<ALTEND>','').split('_') if x]
        Sc=[float(x) for x in scores.split('_')]
        s.woSc=c.OrderedDict( zip(Wo,Sc))

    def toSTR(s):
        words=s.woSc.keys();
        scores=s.woSc.values();

        # If there are more than a certain number of words
        if len(s.woSc)>=limit:
            word_x = [x for (y,x) in sorted(zip(scores,words))]
            score_x = [y for (y,x) in sorted(zip(scores,words))]
            word_x.reverse();score_x.reverse()
            words = word_x[:limit]
            scores = score_x[:limit]

        # Merge all together
        if len(words)>=2:
            # If there is more than one word, merge them with the given way
            wordOut=words[0]+'_<ALTSTART>_'+'_<ALT>_'.join(words[1:])+'_<ALTEND>'
            scoreOut=str(scores[0])+'_'+'_'.join(str(x) for x in scores[1:])
        else:
            # If there is only one word, then just take that
            wordOut=words[0]
            scoreOut=str(scores[0])

        return ' '.join([str(s.t1),str(s.t2),wordOut,scoreOut])

    def DPmetric(s,o):
        # ovrlap betwen the start and end times
        [a,b,c,d]=sorted([(s.t1,0),(s.t2,0),(o.t1,1),(o.t2,1)])
        return abs(a[1]-b[1])*(c[0]-b[0])

    def makeAlt(s,o):
        for word in o.woSc.keys():
            if s.woSc.has_key(word):
                s.woSc[word]+=o.woSc[word]
            else:
                s.woSc[word]=o.woSc[word]
#################################################################################################

######################################## Functions###############################################
# creates MLF mapping
def readmlf(inputFile):
    mlf = {}
    f= open(inputFile, 'r')
    for line_ in f:
        line=line_.strip('\"/\n*')
        if line[0].isalpha():
            lattice = line.split('/')[-1]
            mlf[lattice] = [None]
        elif line[0].isdigit():
            Entry=mlfEntry(line)
            mlf[lattice].append(Entry)
    f.close()
    return mlf
#################################################################################################

############################################ MERGING ############################################
# Opening the reference files and initialising the newMLF file
ref_mlf=readmlf(refString);newMLF={}

# Looping over the new files
for oth in othString:
    # Opening the file paths
    oth_mlf=readmlf(oth)    

    #  Taking each lattice from the reference mlf file 
    for lattice in ref_mlf.keys():
        A=None;B=None;
        #  Taking the same lattice from the other file
        if oth_mlf.has_key(lattice):
            A=ref_mlf[lattice]; B=oth_mlf[lattice];
            lenA = len(A); lenB = len(B);
            rwdMatrix = np.zeros(shape=[lenA,lenB])
            align = [[None for q in range(lenB)]for m in range(lenA) ]

            # Find Edit Distances
            for a in range(1,lenA):
                for b in range(1,lenB):
                    Rwd=A[a].DPmetric(B[b])
                    possible =[rwdMatrix[a,b-1],rwdMatrix[a-1,b],rwdMatrix[a-1,b-1]+Rwd]
                    rwdMatrix[a,b]=max(possible);
                    instruct={0:['donothing',a,b-1],1:[mlfEntry('1 1 <DEL> 0.2'),a-1,b],2:[B[b],a-1,b-1]}
                    align[a][b]=instruct[np.argmax(possible)]

            # Initialising the new lattice
            newMLF[lattice]=[]

            # Recombine to Ref
            a=lenA-1; b=lenB-1;
            while align[a][b]!=None:
                [z,a1,b1]=align[a][b]
                if z!='donothing':
                    A[a].makeAlt(z)
                a=a1; b=b1 ;
            newMLF[lattice]=A
    ref_mlf = newMLF
#################################################################################################

########################################### output ##############################################
output = '#!MLF!#\n'
for lattice in newMLF.keys():
    output+='.\n'+'"'+lattice+'"\n'
    for ent in newMLF[lattice]:
        if ent!=None:
            output+=ent.toSTR()+'\n'
#print(output[1:])
########################################### Printing ################################
f = open(outputFile, "w")
f.write(output)
f.close()
######################################################################################

