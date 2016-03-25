'''
Adds a column to a csv file.
'''
import itertools

if __name__ == "__main__":
    import sys
    if len(sys.argv) < 2:
        print "First argument: csv file"
        exit(1)
    infname = sys.argv[1]
    if len(sys.argv) < 3:
        print "Second argument: column to be added"
        exit(1)
    colfile = sys.argv[2]
    if len(sys.argv) < 4:
        print "3d argument: column name"
        exit(1)
    colname = sys.argv[3]
    if len(sys.argv) < 5:
        print "4th argument: outfile"
        exit(1)
    outfname = sys.argv[4]
    
    with open(outfname, 'w') as fout:
        with open(infname, 'r') as fin:
            with open(colfile, 'r') as colin:
                line = fin.readline().strip()
                fout.write(line+" "+colname+"\n")
                for line, new_col in itertools.izip(fin.xreadlines(), colin.xreadlines()):
                    line = line.strip()
                    fout.write(line+" "+new_col)