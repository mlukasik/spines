
import sys

if __name__=="__main__":
    print "The scripts reads cluster-assignment file and prints out subset of rows with chosen prefix."

    try: inpath = sys.argv[1]
    except: print "First argument expected: clustering-assignment file path"; sys.exit(-1)

    try: prefix = sys.argv[2]
    except: print "Second argument expected: prefix of ids to be selected"; sys.exit(-1)

    try: outpath = sys.argv[3]
    except: print "Third argument expected: output file path"; sys.exit(-1)

    lines = open(inpath).readlines()
    print len(lines)-1,"data rows loaded from file",inpath #does not count header
    sellines = list(line for line in lines[1:] if line.replace("\"","").replace("\'","").startswith(prefix))        
    print len(sellines),"data rows (having prefix \""+str(prefix)+"\") selected"
    sellines = [lines[0]] + sellines #add header
    open(outpath,"w").writelines(sellines)
    print "stored to",outpath
    
