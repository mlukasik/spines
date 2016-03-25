import sys

def load_assignments(f):
    lines = f.readlines()
    obj2cluster = dict(line.strip().replace("\"","").split() for line in lines[1:])
    return   obj2cluster
    
def calc_cluster2objs(obj2cluster):
    cluster2objs = {}
    for obj, cluster in obj2cluster.iteritems():
        cluster2objs[cluster] = cluster2objs.get(cluster,[]) + [obj]
    return cluster2objs

def calc_cluster2size(obj2cluster):
    cluster2size = {}
    for obj, cluster in obj2cluster.iteritems():
        cluster2size[cluster] = cluster2size.get(cluster,0) + 1
    return cluster2size

if __name__=="__main__":
    print "######################################################################"
    print "The program compares two results of clusterings."
    print "Two files with assignments expected. Sample file may look like (each row=object-id+cluster-id):"
    print "<sample>"
    print "[header-line]"
    print "f317 1"
    print "d9 2"
    print "..."
    print "f224 2"
    print "d69 2"
    print "</sample>"
    print "######################################################################"
    
    try: assignment1path = sys.argv[1]    
    except: print "Arg expected: first assignments file."; sys.exit(-1)

    try: assignment2path = sys.argv[2]    
    except: print "Arg expected: second assignments file."; sys.exit(-1)
    
    objtocluster1 = load_assignments(open(assignment1path))
    print len(objtocluster1)," objects, ", len(set(objtocluster1.values())) ," clusters loaded from ", assignment1path

    objtocluster2 = load_assignments(open(assignment2path))
    print len(objtocluster2)," objects, ", len(set(objtocluster2.values()))," clusters loaded from ", assignment2path

    objs = set(objtocluster1).intersection(set(objtocluster2))
    print "Number of shared objects:",len(objs)
    print "Filtering out non-shared objects"
    objtocluster1 = dict( (o,c) for o,c in objtocluster1.iteritems() if o in objs)
    objtocluster2 = dict( (o,c) for o,c in objtocluster2.iteritems() if o in objs)

    print "================",assignment1path,"stats================"
    print len(objtocluster1)," objects left in ", len(set(objtocluster1.values())),"clusters"
    clustertoobjs1 = calc_cluster2objs(objtocluster1)
    clustertosize1 = calc_cluster2size(objtocluster1)
    sizetocluster1 = sorted(list((s,c)  for c,s in clustertosize1.iteritems()), reverse=True)
    print "cluster2size:", sizetocluster1
    #print "cluster2objs:", clustertoobjs1

    print "================",assignment2path,"stats================"
    print len(objtocluster2)," objects left in ", len(set(objtocluster2.values())),"clusters"
    clustertoobjs2 = calc_cluster2objs(objtocluster2)
    clustertosize2 = calc_cluster2size(objtocluster2)
    sizetocluster2 = sorted(list((s,c)  for c,s in clustertosize2.iteritems()), reverse=True)
    print "cluster2size:", sizetocluster2
    #print "cluster2objs:", clustertoobjs2


    #print contingency table
    out = sys.stdout
    print "------------------------------"
    print "Contingency table:"
    print "Rows:", assignment1path
    print "Columns:", assignment2path
    print "------------------------------"
    print "Counts:"
    out.write("  \t"+reduce(lambda c1,c2: c1+"\t"+c2, ("c"+str(cluster2) for size2,cluster2 in sizetocluster2) ) + "\n")
    for size1,cluster1 in sizetocluster1:
        out.write("c"+str(cluster1))
        for size2,cluster2 in sizetocluster2:
            commonobjs = set(clustertoobjs1[cluster1]).intersection(clustertoobjs2[cluster2])
            out.write("\t"+str(len(commonobjs)))
        out.write("\n")
    print "------------------------------"
    print "Percents:"
    out.write("  \t"+reduce(lambda c1,c2: c1+"\t"+c2, ("c"+str(cluster2) for size2,cluster2 in sizetocluster2) ) + "\n")
    for size1,cluster1 in sizetocluster1:
        out.write("c"+str(cluster1))
        for size2,cluster2 in sizetocluster2:
            commonobjs = set(clustertoobjs1[cluster1]).intersection(clustertoobjs2[cluster2])
            out.write("\t"+str(int(round(100.0*float(len(commonobjs))/size1))))
        out.write("\n")

