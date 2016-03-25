import os,sys
from os import path

if __name__=="__main__":
    print "The program walks over all CSV files in given directory and searches for specific row."

    try: dirpath = sys.argv[1]
    except: print "Directory path expected as an argument."; sys.exit(-1)

    try: row = sys.argv[2]
    except: print "Row content expected as an argument."; sys.exit(-1)


    dirList = os.listdir(dirpath)
    for fname in dirList:
        if fname.lower().endswith(".csv"):
            lines = open(dirpath+path.sep+fname).readlines()
            for line in lines:
                if row.lower() in line.lower():            
                    print "\n",fname,"-->",line.strip()
                    print lines[:15]

