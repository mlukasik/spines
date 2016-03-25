from params import *

import sys
sys.path.append('../')
from parsing.utils import nencki_feature_names_for_ttest_comparison, TIME_STAMPS, HEADER_DATA_3STAMPS, ID_COUNT, read_feature_lists, T0MINFEATURES

import scipy.stats

header1, feature_lists1 = read_feature_lists(csv1)
header2, feature_lists2 = read_feature_lists(csv2)

for feature_name in nencki_feature_names_for_ttest_comparison:
    try:
        feature_id1 = header1.index(feature_name)
        feature_id2 = header2.index(feature_name)
        
        print "ttest for feature:", feature_name, "is:", scipy.stats.ttest_ind(map(float, feature_lists1[feature_id1]), map(float, feature_lists2[feature_id2]))
    except:
        print "no feature:", feature_name, "found"