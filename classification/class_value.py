'''
Created on Jan 16, 2013

@author: mlukasik

What value to assign to a class, based on feature vectors from before and after
the growth process of a spine.
'''
from parsing.utils import get_differences

def class_value_both_regions(features_prev, features_after,
                             predicted_ind, left_reg_end, right_reg_start):
    '''
    Growth is represented by being in the region on histogram represented by
    [0 - left_reg_end], [right_reg_start - infinity]
    '''
    class_value = 0
    differences = get_differences(features_prev, features_after,
                                  relative=True)
    if differences[predicted_ind] <= left_reg_end or \
    differences[predicted_ind] >= right_reg_start:
        class_value = 1
    return class_value
    
def class_value_straight(features_prev, features_after,
                         predicted_ind):
    '''
    Just assign the feature value itself as a class value.
    '''
    differences = get_differences(features_prev, features_after,
                                  relative=True)
    return differences[predicted_ind]
    