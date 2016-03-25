
import sys
from itertools import izip

from overlapped_hist_utils import *

sys.path.append("../")
from parsing.utils import *



#####################################################################################
#SCRIPT CONFIGURATION:
#what features to use as values in earlier time
T0FEATURES = T0MINFEATURES
#what features to use as values in later time
T1FEATURES = T10MINFEATURES 
#####################################################################################

def find_group_borders(features, d_feature2changes, f_feature2changes):
    """Returns dictionary {feature: pair-of-feature-borders} calculated on comparision of values in two data sets.

    features  list of column names
    d_feature2changes  dataset1 (dictionary {feature: list-of-values})
    f_feature2changes  dataset2 (dictionary {feature: list-of-values})
    """
    feature2borders = {}
    for feature in features:
        feature_start, feature_end = mxc_region_of_dominance(d_feature2changes[feature], f_feature2changes[feature])        
        feature2borders[feature] = feature_start, feature_end
    return feature2borders

def split_into_groups(feature2borders, feature2changes, uqids):
    """
    Returns 3 dictionaries {feature: list-of-ids-in-this-group}
        
    feature2borders  dictionary{feature: pair-of-feature-borders}
    feature2changes  dictionary{feature: list-of-values}
    uqids  list of ids of values in feature2changes dictionary
    """
    group1 = {}; group2 = {}; group3 = {}
    for feature in feature2borders:
        changes             = feature2changes[feature]
        border1, border2    = feature2borders[feature]
        for uid,val in izip(uqids, changes):
            if   val < border1: group1[feature] = group1.get(feature,[]) + [uid]
            elif val > border2: group3[feature] = group3.get(feature,[]) + [uid]
            else:               group2[feature] = group2.get(feature,[]) + [uid]
    return group1,group2,group3

def print_table(out, features, group1, group2, group3):
    """

    out - output file
    features - list of feature names
    group1/2/3 - dictionaries {feature-name: list-of-ids-in-this-group}
    """
    #HEADER
    out.write(" \t")
    for f in features: 
        out.write(feature_shortname(f)+"_g1\t")
        out.write(feature_shortname(f)+"_g2\t")   
        out.write(feature_shortname(f)+"_g3\t")      
    out.write("\n")
    #TABLE
    for f1 in features: #rows
        out.write(feature_shortname(f1)+"_g1\t")
        for f2 in features: #columns
            sharedids = set(group1[f1]).intersection(group1[f2])
            out.write(str(len(sharedids))+"\t")
            
            sharedids = set(group1[f1]).intersection(group2[f2])
            out.write(str(len(sharedids))+"\t")

            sharedids = set(group1[f1]).intersection(group3[f2])
            out.write(str(len(sharedids))+"\t")
        out.write("\n")

        out.write(feature_shortname(f1)+"_g2\t")
        for f2 in features: #columns
            sharedids = set(group2[f1]).intersection(group1[f2])
            out.write(str(len(sharedids))+"\t")
            
            sharedids = set(group2[f1]).intersection(group2[f2])
            out.write(str(len(sharedids))+"\t")

            sharedids = set(group2[f1]).intersection(group3[f2])
            out.write(str(len(sharedids))+"\t")
        out.write("\n")

        out.write(feature_shortname(f1)+"_g3\t")
        for f2 in features: #columns
            sharedids = set(group3[f1]).intersection(group1[f2])
            out.write(str(len(sharedids))+"\t")
            
            sharedids = set(group3[f1]).intersection(group2[f2])
            out.write(str(len(sharedids))+"\t")

            sharedids = set(group3[f1]).intersection(group3[f2])
            out.write(str(len(sharedids))+"\t")                
        out.write("\n")



if __name__=="__main__":
    print "#########################################################################################"
    print "#########################################################################################"
    print "#########################################################################################"
    print "#########################################################################################"
    print "The script calculates contingency table of dominant groups for changes."

    try: dmsocsv = sys.argv[1]
    except: print "Argument expected: CSV file with description of DMSO group spines."; sys.exit(-1)

    try: forskolinacsv = sys.argv[2]
    except: print "Argument expected: CSV file with description of FORSKOLINA group spines."; sys.exit(-1)

    print "-------------------------------"
    print "Loading DMSO from file",dmsocsv
    d_feature2vals = load_csv(open(dmsocsv), csvseparator=' ', cast_method=float)
    print "Filtering out bad rows in DMSO..."
    d_feature2vals = filterout_columns_col2vals(d_feature2vals, ALLFEATURES)
    print "DMSO header:", sorted(d_feature2vals.keys())
    print "DMSO num objects:", len(d_feature2vals.iteritems().next()[1])
    print_dict_of_lists(d_feature2vals)

    print "-------------------------------"
    print "Loading FORSKOLINA from file",forskolinacsv
    f_feature2vals = load_csv(open(forskolinacsv), csvseparator=' ', cast_method=float)
    print "Filtering out bad rows in FORSKOLINA..."
    f_feature2vals = filterout_columns_col2vals(f_feature2vals, ALLFEATURES)
    print "FORSKOLINA header:", sorted(f_feature2vals.keys())
    print "FORSKOLINA num objects:", len(f_feature2vals.iteritems().next()[1])
    print_dict_of_lists(f_feature2vals)

    print "-------------------------------"
    print "T0FEATURES:", T0FEATURES
    print "T1FEATURES:", T1FEATURES

    print "-------------------------------"
    print "DMSO RELATIVE CHANGES:"
    d_feature2changes = calc_col2changes(d_feature2vals, T0FEATURES, T1FEATURES, relative=True)
    print_dict_of_lists(d_feature2changes)

    print "-------------------------------"
    print "FORSKOLINA RELATIVE CHANGES:"
    f_feature2changes = calc_col2changes(f_feature2vals, T0FEATURES, T1FEATURES, relative=True)
    print_dict_of_lists(f_feature2changes)
        
    print "-------------------------------"
    print "FINDING BORDERS OF THREE GROUPS (shortening, no-change, longening) ON FEATURES:"
    feature2borders = find_group_borders(f_feature2changes.keys(), d_feature2changes, f_feature2changes)
    print_dict_of_lists(feature2borders)

    print "-------------------------------"
    print "SPLITING FORSKOLINA INTO GROUPS:"
    f_group1, f_group2, f_group3 = split_into_groups(feature2borders, f_feature2changes, f_feature2vals[UQID])
   
    print "FORSKOLINA GROUPS1:------"
    print_dict_of_lists(f_group1)
    print "FORSKOLINA GROUPS2:------"
    print_dict_of_lists(f_group2)
    print "FORSKOLINA GROUPS3:------"
    print_dict_of_lists(f_group3)

    print "-------------------------------"
    print "FORSKOLINA GROUPS-CONTIGNENCY-TABLE:"

    #features = ['40_MIN_length', '40_MIN_max_width', '40_MIN_length_width_ratio', '40_MIN_width_length_ratio', '40_MIN_foot', '40_MIN_neck_width', 
    # '40_MIN_length_area_ratio', '40_MIN_head_width', '40_MIN_max_width_location', '40_MIN_circumference', '40_MIN_area']
    #features = ['10_MIN_length', '10_MIN_max_width', '10_MIN_length_width_ratio', '10_MIN_width_length_ratio', '10_MIN_foot', '10_MIN_neck_width', 
    # '10_MIN_length_area_ratio', '10_MIN_head_width',  '10_MIN_max_width_location', '10_MIN_circumference', '10_MIN_area']
    features    = feature2borders

    out         = sys.stdout
    print_table(sys.stdout, features, f_group1, f_group2, f_group3)

    #LEGEND:
    print "Legend:"
    print "_g1 - group1 (shortening), _g2 - group2 (no change), _g3 - group3 (longening)"
    for f in features: 
        print feature_shortname(f),"-",f        


