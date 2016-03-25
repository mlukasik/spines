'''
Plots histograms of feature differences, overlapped.
'''

import sys
sys.path.append('../')
from parsing.utils import nencki_feature_names_noid, TIME_STAMPS, HEADER_DATA_3STAMPS, ID_COUNT, read_feature_lists
from utils import maximum_contigous_region_of_dominance
from utils import normalize, plot_hists, plot_hists_lines, plot_hists_lines_3buckets, display_value_lists
from utils import calc_relative_changes

from matplotlib import pyplot
import numpy

if __name__ == "__main__":
    from params import *
    featname = sys.argv[1]
    
    ########################################################################
    #Read the data, compute vectors of relative changes between time-stamps
    header1, feature_lists1 = read_feature_lists(csv1)
    header2, feature_lists2 = read_feature_lists(csv2)
    
    #what index do features have, which we are to analyze
    ind_before  =   header1.index(begin_stamp+'_'+featname)
    ind_end     =   header2.index(end_stamp+'_'+featname)
    
    feats1 = calc_relative_changes(ind_before,
                                           ind_end,
                                           feature_lists1)
    feats2 = calc_relative_changes(ind_before,
                                           ind_end,
                                           feature_lists2)
    
    ########################################################################
    #Find seperating points which divide spines into growing-not changing-shortening
    
    best_outcome_start, best_end_point_start,\
    best_outcome_end, best_end_point_end = \
    maximum_contigous_region_of_dominance(feats2, feats1)
    
    print "[main]: Separating points found for the feature "+featname+": "+\
    str(best_end_point_start)+", "+str(best_end_point_end)
    
    bins_number=10
    
    fname = cat_name+"feature_"+featname+"_relative_change.png"
    plot_hists_lines_3buckets([feats1, feats2], 
                       ["FORSKOLIN", "DMSO"],
                       fname, ['r', 'b'], bins_number, plotting_function, 
                       'Relative change of '+featname, best_end_point_start, best_end_point_end,
                       "Relative change in time", "Number of spines")
    #print "feats1:", feats1
    #print "feats2:", feats2