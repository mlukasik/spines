'''
    Prepare R script for chisq tests comparing counts of:
    growing-not changing-shrinking groups between Forskolin and DMSO.
'''

import sys
sys.path.append('../')
from parsing.utils import nencki_feature_names_for_ttest_comparison, TIME_STAMPS, HEADER_DATA_3STAMPS, ID_COUNT, read_feature_lists
from utils import maximum_contigous_region_of_dominance
from utils import normalize, plot_hists, plot_hists_lines
from utils import calc_relative_changes
import numpy as np

def subgroups_counts(features, best_end_point_start, best_end_point_end):
    #let's define 3 regions: (-inf, best_end_point_start)
    points1 = 0
    #[best_end_point_start, best_end_point_end]
    points2 = 0
    #(best_end_point_end, +inf)
    points3 = 0
    
    for i in features:
        if i == None:
            pass
        elif i < best_end_point_start:
            points1+=1
        elif i <= best_end_point_end:
            points2+=1
        else:
            points3+=1
    
    return [points1, points2, points3]

HEADER_DATA_3STAMPS = HEADER_DATA_3STAMPS
print "HEADER_DATA_3STAMPS:", HEADER_DATA_3STAMPS
if __name__ == "__main__":
    from params import *
    
    ########################################################################
    #Read the data, compute vectors of relative changes between time-stamps
    header1, feature_lists1 = read_feature_lists(csv1)
    header2, feature_lists2 = read_feature_lists(csv2)
    
    ########################################################################
    print "pvals = c()"
    print "sizes_fs = c()"
    print "sizes_fn = c()"
    print "sizes_fg = c()"
    print "sizes_ds = c()"
    print "sizes_dn = c()"
    print "sizes_dg = c()"
    features2vectors = {}
    for featname in nencki_feature_names_for_ttest_comparison:
        feature_ind = 0
        
        ########################################################################
        #what indices do features have, which we are to analyze
        ind_before  =   header1.index(begin_stamp+'_'+featname)
        ind_end     =   header1.index(end_stamp+'_'+featname)
        
        #print "ind_before:", ind_before, "ind_end:", ind_end
        
        relative_feat1 = calc_relative_changes(ind_before,
                                               ind_end,
                                               feature_lists1)
        relative_feat2 = calc_relative_changes(ind_before,
                                               ind_end,
                                               feature_lists2)
        
        features2vectors[featname] = (np.array(relative_feat1), np.array(relative_feat2))
    
    
    #featname = "Rel.Comp.1"
    #feats1 = -0.289 * features2vectors['length'][0] - 0.931 * features2vectors['circumference'][0] - 0.186 * features2vectors['area'][0]
    #feats2 = -0.289 * features2vectors['length'][1] - 0.931 * features2vectors['circumference'][1] - 0.186 * features2vectors['area'][1]
        
    featname = "Rel.Comp.2"
    feats1 = -0.141 * features2vectors['width_length_ratio'][0] + 0.938 * features2vectors['length_width_ratio'][0] + 0.284 * features2vectors['length_area_ratio'][0]
    feats2 = -0.141 * features2vectors['width_length_ratio'][1] + 0.938 * features2vectors['length_width_ratio'][1] + 0.284 * features2vectors['length_area_ratio'][1]
    
    ########################################################################
    #Find seperating points at time 0, which divide spines into growing-not changing-shrinking
        
    best_outcome_start, best_end_point_start,\
        best_outcome_end, best_end_point_end = \
        maximum_contigous_region_of_dominance(feats2, feats1)
    print "#best end-points: "+str(best_end_point_start)+", "+str(best_end_point_end)
        
    #plot_hists([feats1, feats2], ["f", "d"], "histogram_"+featname, ['r', 'g'], 100, plotting_function)
        
    ########################################################################
        
    forskolin_lengths = map(str, subgroups_counts(feats1, best_end_point_start, best_end_point_end))
    dmso_lengths = map(str, subgroups_counts(feats2, best_end_point_start, best_end_point_end))
        
    print "#"+featname
    #forskolin_lengths = map(lambda x: str(len(x)), forskolin_points)
    #dmso_lengths = map(lambda x: str(len(x)), dmso_points)
        
    print "m_"+featname+" = matrix(c("+", ".join(forskolin_lengths+dmso_lengths)+"), nrow=3, ncol=2)"
    print "p = chisq.test(m_"+featname+")$p.value"
    print "pvals = c(pvals, "+featname+"=p)"
        
    for name, new_val in [("sizes_fs", forskolin_lengths[0]), ("sizes_fn", forskolin_lengths[1]), ("sizes_fg", forskolin_lengths[2]),
                            ("sizes_ds", dmso_lengths[0]), ("sizes_dn", dmso_lengths[1]), ("sizes_dg", dmso_lengths[2])]:
            
        print name+" = c("+name+", "+featname+"="+str(new_val)+")"
    
    ########################################################################
    #join results into storable format
    print "cbind(feature=c(\""+"\", \"".join(nencki_feature_names_for_ttest_comparison)+"\"), p_value=pvals, forskolin_shrinking=sizes_fs,"+\
    "forskolin_not_changing=sizes_fn, forskolin_growing=sizes_fg, dmso_shrinking=sizes_ds, "+\
    "dmso_not_changing=sizes_dn, dmso_growing=sizes_dg)"
    
    #Store results
    print "library(xlsx)"
    print "write.xlsx(pvals, file = \"pvals_chisq.xlsx\", sheetName = \"Sheet1\", row.names = TRUE)"
    
