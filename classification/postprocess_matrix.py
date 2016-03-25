'''
Created on Jan 16, 2013

@author: mlukasik
'''
def choose_most_changing_least_changing(data_matrix, most_chg, least_chg):
    '''
    Converts class value from real to boolean.
    We choose most_chg most changing values as positives and 
    least_chg least changing values as negatives.
    '''
    inddiff = []
    for ind, row in enumerate(data_matrix):
        inddiff.append((ind, row[-1]))
    inddiff.sort(key=lambda x:abs(x[1]))
    #print "inddiff:", inddiff
    #print "len(inddiff):", len(inddiff)
    indices_true = set(map(lambda x: x[0], inddiff[:least_chg]))
    indices_false = set(map(lambda x: x[0], inddiff[-most_chg:]))
    
    new_data_matrix = []
    for ind, row in enumerate(data_matrix):
        if ind in indices_true:
            row[-1] = 1
            new_data_matrix.append(row)
        if ind in indices_false:
            row[-1] = 0
            new_data_matrix.append(row)
        
    return new_data_matrix