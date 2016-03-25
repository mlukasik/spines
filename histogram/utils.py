def get_perc_diff(feats1, feats2, bins):
    '''
    How many percent of elements from feats1 and feats2 is different. 
    Bins - list of consecutive borders. In a single region, denoted 
    by 2 consecutive borders, values are not distinguished from one another.
    '''
    #gathers elements into bins; feats1 occurences are added, 
    #feats2 occurences are substracted
    elements = {}
    for ind in xrange(len(bins)):
        elements[ind] = 0
    for i in feats1:
        is_ok = False
        for ind in xrange(len(bins)):
            if i < bins[ind]:
                elements[ind-1] += 1
                is_ok = True
                break
        if not is_ok:
            elements[len(bins)-1] += 1
    
    for i in feats2:
        is_ok = False
        for ind in xrange(len(bins)):
            if i < bins[ind]:
                elements[ind-1] -= 1
                is_ok = True
                break
        if not is_ok:
            elements[len(bins)-1] -= 1
    
    #gather final info:
    res = 0
    for v in elements.itervalues():
        res += abs(v)
    return res*1.0/(len(feats1) + len(feats2))
    
def get_furthest_point_maximum_contigous_region_of_dominance(feats):
    '''
    Find the biggest sum of starting elements in a list feats with possible 
    repetitions (which must be accumulated) and with multiplication factors
    for each element (only 1 or -1 can appear in feats).
    
    >>> get_furthest_point_maximum_contigous_region_of_dominance([(1, 1), (2, -1), (3, 1), (4, 1)])
    (0.75, 4)
    >>> get_furthest_point_maximum_contigous_region_of_dominance([(1, -1), (2, -1), (3, 1), (4, 1)])
    (0, 0)
    >>> get_furthest_point_maximum_contigous_region_of_dominance([(1, 1), (2, 1), (3, -1), (4, 1)])
    (1, 2)
    
    '''
    best_end_point = 0
    best_outcome = 0
    best_how_many_1 = 0
    best_how_many_min_1 = 0
    
    how_many_1 = 0
    how_many_min_1 = 0
    curr_sum = 0
    ind = 0
    vi = feats[0]
    while ind < len(feats):
        curr_val = vi[0]
        #use all elements which have the same value, regardless of which 
        #list they come from (-1 or 1):
        while ind < len(feats) and vi[0] == curr_val:
            curr_sum += vi[1]
            how_many_1 += int(vi[1]==1)
            how_many_min_1 += int(vi[1]==-1)
            ind += 1
            if ind < len(feats):
                vi = feats[ind]
        #only now we can update:
        if curr_sum > best_outcome:
            best_outcome = curr_sum
            best_end_point = curr_val
            best_how_many_1 = how_many_1
            best_how_many_min_1 = how_many_min_1
            
    #now calculate the returnable value: percentage of dominance:
    ret_utility = 0
    if (best_how_many_1 != 0 or best_how_many_min_1 != 0):
        ret_utility = best_how_many_1*1.0 /(best_how_many_1+best_how_many_min_1)
    #print "best_how_many_1, best_how_many_min_1:", best_how_many_1, best_how_many_min_1
    return ret_utility, best_end_point

def maximum_contigous_region_of_dominance(feats1, feats2):
    '''
    Find 2 contigous regions (one starting at minimum, second starting at maximum), 
    where feats2 dominates feats1 the most. 
    Criterion: biggest difference.
    '''
    #make it possible to easily distinguish feats from one another in a single list
    feats1 = map(lambda x: (x, -1), feats1)
    feats2 = map(lambda x: (x, 1), feats2)
    feats = feats1+feats2
    feats = sorted(feats, key=lambda x: x[0])
    #print "[maximum_contigous_region_of_dominance] feats:", feats
    
    #first: from the start
    best_outcome_start, best_end_point_start = \
        get_furthest_point_maximum_contigous_region_of_dominance(feats)
    #second: from the end:
    feats.reverse()
    best_outcome_end, best_end_point_end = \
        get_furthest_point_maximum_contigous_region_of_dominance(feats)
    
    return best_outcome_start, best_end_point_start, \
        best_outcome_end, best_end_point_end
    
from math import ceil
def normalize(f, ratio):
    '''
    Multiplies occurences of elements in f by a given ratio. The ratio can 
    be non-inger, so each element is counted and then approprately multiplied.
    '''
    dfeats2 = {}
    for j in f:
        dfeats2[j] = dfeats2.get(j, 0)+1
    for k in dfeats2.iterkeys():    
        dfeats2[k] = ceil(dfeats2[k]*ratio)
    l = []
    for k, v in dfeats2.iteritems():
        l += [k]*int(v)
    return l

def mxc_region_of_dominance(feats1, feats2):
    """Executes maximum_contigous_region_of_dominance for normalized vectors of features feats1,feats2."""
    len1 = len(feats1)
    len2 = len(feats2)
    feats1 = normalize(feats1, len2)
    feats2 = normalize(feats2, len1)
    best_outcome_start, best_end_point_start, best_outcome_end, best_end_point_end = maximum_contigous_region_of_dominance(feats1, feats2)
    if best_end_point_end > best_end_point_start: return best_end_point_start, best_end_point_end
    else:                                         return best_end_point_end, best_end_point_start
    
from matplotlib import pyplot
import numpy
def plot_hists(feature_list, title_list, fname, colours, buckets, plot_hist,
               main_title_prefix=None, normalize=False):
    '''
    Plot a number of histograms on the same figure. 
    plot_hist - function responsible for drawing a single histogram, which is passed
        list of values, colour, bins list
    '''
    vfrom = min([min(x) for x in feature_list])
    vto = max([max(x) for x in feature_list])
    print "[plot_hists]", vfrom, vto
    if type(vfrom) != float:
        vfrom = -10 
    bins = numpy.linspace(vfrom, vto, buckets)
    
    initial_lengths = map(lambda x: len(x), feature_list)
    
    if normalize:
        for i in xrange(len(feature_list)):
            for j in xrange(len(initial_lengths)):
                if i != j:
                    feature_list[i] = normalize(feature_list[i], initial_lengths[j]) 
        
    from itertools import izip
    for feats, col in izip(feature_list, colours):
        plot_hist(feats, col, bins)
    
    full_title = []
    if main_title_prefix:
        full_title.append(main_title_prefix)
    for title, col in izip(title_list, colours):
        full_title.append(title+" has colour: "+col+";")
    
    pyplot.title(" ".join(full_title))
    pyplot.savefig(fname)
    pyplot.close()
    
def plot_hists_lines(feature_list, title_list, fname, colours, buckets, plot_hist,
               main_title_prefix, x1, x2, xlabel, ylabel, obwiednia=False):
    '''
    Plot a number of histograms on the same figure. 
    plot_hist - function responsible for drawing a single histogram, which is passed
        list of values, colour, bins list
        
    '''
    print "[plot_hists_lines]"
    bins = numpy.linspace(min([min(x) for x in feature_list]), 
                          max([max(x) for x in feature_list]), buckets)

    from itertools import izip
    for feats, col in izip(feature_list, colours):
        if obwiednia:
            h1,edges1 = numpy.histogram(feats, bins, normed=False)
            pyplot.step(edges1[1:], h1, color=col)
        else:
            plot_hist(feats, col, bins)
    full_title = []
    if main_title_prefix:
        full_title.append(main_title_prefix)
    #for title, col in izip(title_list, colours):
    #    full_title.append(title+" has colour: "+col+"  ")
    
    pyplot.title(" ".join(full_title))
    #pyplot.axvline(x1, 0, 7000, color="black")
    #pyplot.axvline(x2, 0, 7000, color="black")
    frame1 = pyplot.gca()
    #frame1.get_yaxis().set_visible(False)
    pyplot.xlabel(xlabel)
    pyplot.ylabel(ylabel)
    
    pyplot.savefig(fname)
    pyplot.close()
    
def display_value_lists(feature_list, title_list, fname, colours, buckets, plot_hist,
               main_title_prefix, x1, x2, xlabel, ylabel, obwiednia=False):
    '''
    Plot a number of histograms on the same figure. 
    plot_hist - function responsible for drawing a single histogram, which is passed
        list of values, colour, bins list
        
    '''
    bins = numpy.linspace(min([min(x) for x in feature_list]), 
                          max([max(x) for x in feature_list]), buckets)
    
    #print "breaks = c(", ", ".join(map(str, bins)), ")"
    from itertools import izip
    for feats, col in izip(feature_list, colours):
        counts = [0]*(len(bins)-1)
        for v in feats:
            for vbreak_ind, vbreak in enumerate(bins):
                if vbreak >= v:
                    counts[vbreak_ind-1]+=1
                    break
        print col, "= c(", ", ".join(map(str, counts)), ")"
    
    print "labels=c(\"", "\", \"".join(["("+str("{0:.2f}".format(bins[i]))+", "+str("{0:.2f}".format(bins[i+1]))+")" for i in xrange(len(bins)-1)]), "\")"

    print "png(filename=\""+main_title_prefix+".png\")"
    print "pyramid.plot(r, b, labels=labels, gap=40, top.labels=c(\"FORSKOLIN\",\"Range\",\"DMSO\"), unit=\"\", laxlab=c(0,50,100,150, 200), raxlab=c(0,50,100,150, 200))"
    print "title(\""+main_title_prefix+"\")"
    print "dev.off()"
    
import numpy as np
def plot_hists_lines_3buckets(feature_list, title_list, fname, colours, buckets, plot_hist,
               main_title_prefix, x1, x2, xlabel, ylabel, smooth=False):
    '''
    Plot a group bar plot, consisting of 3 subgroups indicated by the x1 and x2 values.
        
    '''
    FONTSIZE = 20
    N = 3
    ind = np.arange(N)  # the x locations for the groups
    width = 0.27       # the width of the bars
    
    fig = pyplot.figure()
    ax = fig.add_subplot(111)
    
    yvals = [0, 0, 0]
    for v in feature_list[0]:
        if v < x1:
            yvals[0]+=1
        elif v < x2:
            yvals[1]+=1
        else:
            yvals[2]+=1
    rects1 = ax.bar(ind, yvals, width, color=colours[0])

    zvals = [0, 0, 0]
    for v in feature_list[1]:
        if v < x1:
            zvals[0]+=1
        elif v < x2:
            zvals[1]+=1
        else:
            zvals[2]+=1
    rects2 = ax.bar(ind+width, zvals, width, color=colours[1])
    #kvals = [11,12,13]
    #rects3 = ax.bar(ind+width*2, kvals, width, color='b')
    
    ax.set_ylabel('Counts', fontsize = FONTSIZE)
    ax.set_xticks(ind+width)
    ax.set_xticklabels( ('shrinking', 'not changing', 'growing') , fontsize = FONTSIZE)
    ax.legend( (rects1[0], rects2[0]), ('FORSKOLIN', 'DMSO') , fontsize = FONTSIZE)#, 'k') )
    
    ax.set_ylim(bottom=0, top=1.7*max(max(yvals), max(zvals)))
    ax.set_xlim(left=-0.1)#, right=None)
    
    def autolabel(rects):
        for rect in rects:
            h = rect.get_height()
            ax.text(rect.get_x()+rect.get_width()/2., 1.05*h, '%d'%int(h),
                    ha='center', va='bottom' , fontsize = FONTSIZE)
    
    autolabel(rects1)
    autolabel(rects2)
    #autolabel(rects3)
    
    ax.tick_params(axis='y', labelsize=FONTSIZE)
    ax.yaxis.label.set_size(FONTSIZE)
    pyplot.savefig(fname)
    

def calc_relative_changes(ind1, ind2, feature_lists):
    '''
    Calculate a list of relative changes between columns ind1 and ind2 from feature_lists.
    For l0 and l1 the relative change has the following form: (l1-l0)/l0.
    '''
    res = []
    for i in xrange(len(feature_lists[ind1])):
        if float(feature_lists[ind1][i]) != 0:
            a = float(feature_lists[ind2][i])
            b = float(feature_lists[ind1][i])
            res.append((a-b)/b)
        else:
            res.append(np.sign(a)*9999999)
    return res
    
from math import log
def calc_log_relative_changes(ind1, ind2, feature_lists):
    '''
    Calculate a list of logarithmic relative changes between columns ind1 and ind2 from feature_lists.
    For l0 and l1 the logarithmic relative change has the following form: log(l1/l0)
    '''
    res = []
    for i in xrange(len(feature_lists[ind1])):
        if feature_lists[ind1][i] != 0:
            res.append(1.0*log(feature_lists[ind2][i]/feature_lists[ind1][i]))
    return res

    
if __name__ == "__main__":
    import doctest
    doctest.testmod()
