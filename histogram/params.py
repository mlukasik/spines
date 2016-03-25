'''
Created on Apr 22, 2013

@author: mlukasik

Parameters for relative_feature_changes.py.
'''
from matplotlib import pyplot

def plot_hist_line_overlapped(feats, col, bins):
    pyplot.hist(feats, bins, alpha=0.5, color=col)

#=====================================================

#csv1 = "../DATA/PARSED/130709_triple_updated_control/FORSKOLIN_triple.txt"
#csv2 = "../DATA/PARSED/130709_triple_updated_control/CONTROLTEST_DMSO_triple.txt"

#csv1 = "../DATA/PARSED/130710_triple_updated_control_filtered_max2/FORSKOLIN_triple.txt"
#csv2 = "../DATA/PARSED/130710_triple_updated_control_filtered_max2/CONTROLTEST_DMSO_triple.txt"
#csv1 = "../DATA/PARSED/130710_filtered300/FORSKOLIN_triple.txt"
#csv2 = "../DATA/PARSED/130710_filtered300/CONTROLTEST_DMSO_triple.txt"
#csv1 = "../DATA/PARSED/131215_filtered_300/FORSKOLIN_triple.txt"
#csv2 = "../DATA/PARSED/131215_filtered_300/CONTROLTEST_DMSO_triple.txt"
csv1 = "../DATA/PARSED/140303_olddata/filtered_300/FORSKOLIN_triple.txt"
csv2 = "../DATA/PARSED/140303_olddata/filtered_300/CONTROLTEST_DMSO_triple.txt"


#csv1 = "../DATA/PARSED/130303_triple/FORSKOLIN_triple.txt"
#csv2 = "../DATA/PARSED/130303_triple/CONTROLTEST_DMSO_triple.txt"


#=====================================================

cat_name = "histograms140924/"
#
import sys
sys.path.append('../')
from parsing.utils import ensure_dir
ensure_dir(cat_name)

#=====================================================

#featname = "length"
begin_stamp = "0MIN"
end_stamp = "10_MIN"
bins_number = 50
#bins_number = 100
plotting_function = plot_hist_line_overlapped
#plotting_function = plot_line

#=====================================================
SEPARATOR_PRNT = ", "#" & "
ENDING_PRNT = ";"#"\\\\"
