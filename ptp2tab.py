#!/usr/bin/python3.5
"""
Convert output file of PTP in a table readable in R
Saclier Nathanaelle
2017/06/09
"""
import sys
import re

"""Read arguments"""
def read_args(args):
    if len(args)<3 or len(args)>3:
        print ("\nUsage : <PTP file output> <output file name>")
        print ("Convert output file of PTP in a table readable in R")
        sys.exit(0)
    else :
        try :
            filename=str(args[1])
        except:
            print ("\nUsage : <PTP file output> <output file name>")
            print ("Convert output file of PTP in a table readable in R")
            sys.exit(0)
        else:
            return filename


"""Open the file"""
def open_file(filename):
    try:
        f=open(filename,'r')
    except:
        print("\nerreur lors de l'ouverture du fichier\n")
        sys.exit(0)
    else:
        return f

"""Main"""
filename=read_args(sys.argv)
outputfile=str(sys.argv[2])

f = open(filename,'r')
o = open (outputfile, 'w')

n=0

while n<9:
    l=f.readline()
    n+=1

while l!="" :
    if l.find('Species')==0 :
        pat=re.compile('Species \d+')
        result=pat.search(l)
        sp=result.group(0)
        nsp=sp.split()[0]+'_'+sp.split()[1]+'\n'
        l=f.readline()
    elif l=="\n":
        l=f.readline()
    else :
        o.write(l.rstrip()+'\t'+nsp)
        l=f.readline()
    
f.close()
o.close()




