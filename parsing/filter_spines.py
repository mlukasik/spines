'''
Created on Apr 9, 2013

@author: mlukasik
'''
from utils import read_feature_lists, save_spines_by_indices, time0_features_inds_distance
import math, numpy

def euclidean_distance(spine1, spine2):
    '''
    Return euclidean distance between 2 spines, represented by vectors of features.
    '''
    d = 0
    for relevant_feature_ind in time0_features_inds_distance():
        d += (spine1[relevant_feature_ind] - spine2[relevant_feature_ind])**2
    return math.sqrt(d)

def normalize_features(feature_lists1, feature_lists2, feature_inds):
    '''
    For each feature_ind in feature_inds, normalize feature_lists1[feature_ind]
    and feature_lists2[feature_ind], by substructing common mean and dividing by 
    common std deviation.
    '''
    for feature_ind in feature_inds:#no need to normalize other features
        #print feature_ind, feature_lists1[feature_ind] 
        feature_lists1[feature_ind] = map(float, feature_lists1[feature_ind])
        feature_lists2[feature_ind] = map(float, feature_lists2[feature_ind])
        
        values = feature_lists1[feature_ind]+feature_lists2[feature_ind]
        
        m = numpy.mean(values)
        std = numpy.std(values)
        
        feature_lists1[feature_ind] = map(lambda x: (x-m)/std, feature_lists1[feature_ind])
        feature_lists2[feature_ind] = map(lambda x: (x-m)/std, feature_lists2[feature_ind])

if __name__ == "__main__":
    from filter_spines_params import * 
    
    _, feature_lists1_original = read_feature_lists(csv1)
    _, feature_lists2_original = read_feature_lists(csv2)
    
    header1, feature_lists1 = read_feature_lists(csv1)
    header2, feature_lists2 = read_feature_lists(csv2)


    f = open(csv2)
    for l in f:
        if len(l.split())!=82:
            print l
    #normalize the spines lists
    normalize_features(feature_lists1, feature_lists2, time0_features_inds_distance())

    #generate spines ids denoted by indices:    
    spines1 = range(len(feature_lists1[0]))
    spines2 = range(len(feature_lists2[0]))
    print "loaded numbers of spines:", len(spines1), len(spines2)
    ########################################################################################

    #for x in range(len(feature_lists1)):
    #    print len(feature_lists1[x])
    print "len(feature_lists2):", len(feature_lists2)
    #for x in range(len(feature_lists2)):
    #    print len(feature_lists2[x])
    #find matrix of distances
    distances = []
    for spine1 in spines1:
        row = []
        for spine2 in spines2:
            #print feature_lists1
            #print feature_lists2
            d = euclidean_distance([feature_lists1[x][spine1] for x in xrange(len(feature_lists1))], [feature_lists2[x][spine2] for x in xrange(len(feature_lists2))])
            row.append(d)
        distances.append(row)
        
    ########################################################################################

    #find closest pairs of spines, delete them from lists of indices, and repeat
    ind = 1
    chosen_spines1 = []
    chosen_spines2 = []
    while len(spines1) > 0 and len(spines1) > 0 and ind <= spine_cnt:
        min_pair = (-1, -1, 100000000)
        #find pair with minimum distance:
        for spine1 in spines1:
            for spine2 in spines2:
                if distances[spine1][spine2] < min_pair[2]:
                    min_pair = (spine1, spine2, distances[spine1][spine2])
        print "Drawn pair:", ind, min_pair
        if stop_criterion(distances, min_pair[0], min_pair[1]):
            break
        ind += 1
        chosen_spines1.append(min_pair[0])
        chosen_spines2.append(min_pair[1])
        spines1.remove(min_pair[0])
        spines2.remove(min_pair[1])

    ########################################################################################
    #save the selected spines:
    save_spines_by_indices(outfile_spines1, header1, 
                           chosen_spines1[:spine_cnt],  feature_lists1_original)
    save_spines_by_indices(outfile_spines2, header2, 
                           chosen_spines2[:spine_cnt],  feature_lists2_original)
    