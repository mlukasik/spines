
import sys

if __name__=="__main__":
    "Reads CSV from source and removes last column"

    fin = open(sys.argv[1])
    print "in=",fin
    fout = open(sys.argv[2], "w")
    print "out=",fout

    for i,line in enumerate(fin.xreadlines()):
        line = line.strip()
        fout.write(line)
        fout.write("\n")
        if line.startswith("--"): break    

    print "Content start detected: <",line,">"
    for line in fin.xreadlines():
        line = line.strip()
        if len(line) <= 0 or line.startswith("Mean"): break

        parts = line.split(",")
        line = reduce(lambda p1,p2: p1+","+p2, (p for p in parts[:-1]) )
        fout.write(line)
        fout.write("\n")

    if len(line) != 0 and not line.startswith("Mean"): 
        print "WARNING: Footer not found!"
        sys.exit(0)

    print "Footer start detected: <",line,">"
    fout.write(line)
    fout.write("\n")
        
    for line in fin.xreadlines():
        line = line.strip()
        fout.write(line)
        fout.write("\n")




