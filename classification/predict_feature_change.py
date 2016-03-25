'''
Created on Jan 13, 2013

@author: mlukasik

Can we predict change in features based on feature values at time 0?
'''
import sys
sys.path.append('../')
from parsing.utils import nencki_feature_names, pvalues_diff_DMSO_FORSKOLIN
from data_convertion import get_data_matrix, matrix_to_orange_data
import Orange

if __name__ == "__main__":
    import sys
    if len(sys.argv) < 2:
        print "First argument: excel file"
        exit(1)
    excel = sys.argv[1]
    if len(sys.argv) < 3:
        print "Second argument: catalogue with csv files"
        exit(1)
    inp_catalogue = sys.argv[2]
    if len(sys.argv) < 4:
        print "3d argument: group_id"
        exit(1)
    group_id = sys.argv[3]
    if len(sys.argv) < 5:
        print "4th argument: sub_group_id from"
        exit(1)
    sub_from_id = sys.argv[4]
    if len(sys.argv) < 6:
        print "5th argument: sub_group_id to"
        exit(1)
    sub_to_id = sys.argv[5]
    if len(sys.argv) < 7:
        print "5th argument: predicted feature index"
        exit(1)
    predicted_ind = int(sys.argv[6])
    if len(sys.argv) < 8:
        print "5th argument: left boundary of left side of prediction region"+\
         "in histogram of feature changes"
        exit(1)
    left_reg_end = float(sys.argv[7])
    if len(sys.argv) < 9:
        print "5th argument: right boundary of right side of prediction region"+\
         "in histogram of feature changes"
        exit(1)
    right_reg_start = float(sys.argv[8])

    #Calculate data matrix:
    from class_value import class_value_straight
    data_matrix = get_data_matrix(excel, inp_catalogue, group_id, sub_from_id,
                    sub_to_id, 
                    lambda x, y: class_value_straight(x, y, predicted_ind))
    
    #postprocess data matrix to contain true positives/negatives
    from postprocess_matrix import choose_most_changing_least_changing
    data_matrix = choose_most_changing_least_changing(data_matrix, 50, 50)
    
    #convert to table in Orange format:
    data = matrix_to_orange_data(data_matrix)
    
    #simple statistics of features:
    """bas = Orange.statistics.basic.Domain(data) 
    print "%20s %5s %5s %5s" % ("feature", "min", "max", "avg")
    for a in bas:
        if a:
            print "%20s %5.3f %5.3f %5.3f" % (a.variable.name, a.min, a.max, a.avg)
    """
    #accuracy of classifiers trained on the features:
    learners = [Orange.classification.majority.MajorityLearner(),
                Orange.classification.bayes.NaiveLearner(),
                Orange.classification.knn.kNNLearner(k=3),
                Orange.classification.knn.kNNLearner(k=5),
                Orange.classification.knn.kNNLearner(k=7),
                Orange.classification.svm.SVMLearnerEasy(),
                Orange.classification.svm.SVMLearner(kernel_type=
                                                     Orange.classification.\
                                                     svm.SVMLearner.RBF)
                ]
    
    cv = Orange.evaluation.testing.cross_validation(learners, data, folds=5)
    print "PREDICTING FEATURE:", nencki_feature_names[predicted_ind+1]
    
    #calculated using R, temporarily put here:
    
    results = ["%.4f" % score for score in Orange.evaluation.scoring.CA(cv)]
    print results
    #if results[0] < max(results):
    #    print "GOOD:)"
    #else:
    #    print "BAD:("
    print "its p-value:", pvalues_diff_DMSO_FORSKOLIN[predicted_ind]