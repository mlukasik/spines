
import sys

def load_table(f):
    """Loads file: first line is a header and next are pairs key value."""
    k2v = {}
    for line in f.readlines()[1:]:
        parts = line.replace("\"","").split()
        k2v[parts[0]] = int(parts[1])
    return k2v

def print_analysis(type2ids, id2assignment):
    assignments = list(set(changes.values()))
    print "possible assignments:", assignments
    print "type\tsize\tassignments"        
    for t,ids in type2ids.iteritems():
        sys.stdout.write(str(t)+"\t")

        assignment2count = {}
        for idd in ids:      
            if idd not in id2assignment:
                #print "SKIPPING",idd
                continue
            assignment = id2assignment[idd]
            assignment2count[assignment] = assignment2count.get(assignment,0) + 1

    
        Z = sum(assignment2count.values()) 
        sys.stdout.write(str(Z)+"\t")

        if Z==0: Z=1
        for a in assignments:
            #sys.stdout.write("%i\t"%(assignment2count.get(a,0)) )  
            sys.stdout.write("%.0f\t"%(float(assignment2count.get(a,0)*100)/Z))    

        print ""
        
    

if __name__=="__main__":
    try:
        id2type       = load_table(open(sys.argv[1]))
        print "id2type:", id2type
    except: 
        print "First argument: file with shapes assignment."; 
        sys.exit(-1)


    #TRANSFORM SHAPE TYPES:
    for i,t in id2type.iteritems():
        if t==3 or t==7: id2type[i] = 37
        if t==6 or t==9: id2type[i] = 69
        if t>=10: id2type[i] = 10

    #SPLIT TYPES INTO GROUPS
    fcount = 0
    dcount = 0
    ftype2ids = {}
    dtype2ids = {}
    for i,t in id2type.iteritems():
        parts = i.split('t')
        idd = parts[0]
        group = idd[0]
        time = parts[1]
        #print idd,group,time
        if time=='0':
            if group=='f':
                ftype2ids[t] = ftype2ids.get(t,[]) + [idd]
                fcount+=1
            elif group=='d':
                dtype2ids[t] = dtype2ids.get(t,[]) + [idd]
                dcount+=1
            else: print "ERROR"; sys.exit(-1)
    print "fcount:",fcount
    print "dcount:",dcount
    print "ftype2ids:",ftype2ids
    print "dtype2ids:",dtype2ids
    
    #ANALYSIS:
    try:
        changes  = load_table(open(sys.argv[2]))
        print "changes:", len(changes), changes
        print "changes.values():", set(changes.values())
    except:
        print "Second argument: file with spines assignment."; 
        sys.exit(-1)

    print "FORSKOLIN analysis ====================="        
    print_analysis(ftype2ids, changes)

    print "DMSO analysis ====================="        
    print_analysis(dtype2ids, changes)
