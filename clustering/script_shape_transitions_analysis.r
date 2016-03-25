# Script for analysis of spines' shapes and behaviour using PCA, clustering 
# and linear Shape Transtion Model.
#
# author: tomasz.kusmierczyk(at)gmail.com

#######################################################################################
#######################################################################################

source(file="clustering.r")
source(file="drawing.r")
source(file="transitions.r")
source(file="transitions_comparison.r")
source(file="predictions.r")


#######################################################################################
#######################################################################################
#######################################################################################
#######################################################################################
# Script configuration.

# Input data:
#train.data.file = "~/spines_bitbucket/data/140303_olddata/filtered_300/ALL.txt" 
#test.data.file = "~/spines_bitbucket/data/140303_olddata/filtered_300/ALL.txt" 

#train.data.file = "~/spines_bitbucket/data/140303_olddata/ALL_triple.txt"
#test.data.file = "~/spines_bitbucket/data/140303_olddata/ALL_triple.txt" 

train.data.file = "~/spines_bitbucket/data/140303_140803_merged/ALL_triple.txt"
test.data.file = "~/spines_bitbucket/data/140303_140803_merged/ALL_triple.txt"

#train.data.file = "~/spines_bitbucket/data/140403_dane_treningowe_testowe_300_2/train.txt"
#test.data.file = "~/spines_bitbucket/data/140403_dane_treningowe_testowe_300_2/valid_test.txt" 

#train.data.file = "~/spines_bitbucket/data/140403_dane_treningowe_testowe_300_2/train_valid.txt"
#test.data.file = "~/spines_bitbucket/data/140403_dane_treningowe_testowe_300_2/test.txt" 

#train.data.file = "~/spines_bitbucket/data/140403_dane_treningowe_testowe/validation_and_train.txt"
#test.data.file = "~/spines_bitbucket/data/140403_dane_treningowe_testowe/test.txt"

#train.data.file = "~/spines_bitbucket/data/140403_dane_treningowe_testowe3/validation_and_train.txt"
#test.data.file = "~/spines_bitbucket/data/140403_dane_treningowe_testowe3/test.txt"

# file with ids (must have column spine.id) of selected subset of data
# set to NaN if you want to construct transition matrices basing on whole data
#balanced.ids.file = NaN
balanced.ids.file = "~/spines_bitbucket/data/140303_140803_merged/filtered_300.txt" 


# names of features describing inital time moment
features.names.t0 =  c("0MIN_length", "0MIN_head_width", "0MIN_max_width_location", 
                       "0MIN_max_width", "0MIN_width_length_ratio", "0MIN_length_width_ratio", 
                       "0MIN_neck_width", "0MIN_foot", "0MIN_circumference", "0MIN_area", 
                       "0MIN_length_area_ratio") 

# names of features describing final time moment
features.names.t1 = c("10_MIN_length", "10_MIN_head_width", "10_MIN_max_width_location", 
                      "10_MIN_max_width", "10_MIN_width_length_ratio", "10_MIN_length_width_ratio", 
                      "10_MIN_neck_width", "10_MIN_foot", "10_MIN_circumference", "10_MIN_area", 
                      "10_MIN_length_area_ratio") 

# names of features will be changed to this below
features.names.nice = c("length", "hw", "mwl", "mw", "wlr", "lwr", 
                        "nw", "foot", "circumference", "area", "lar")

# description of identificator field
spine.id = 'unique_id'
group.id = 'group_id'
spine.id.field.separator = '-'
#spine.id.fields = c('data_id', 'animal_id', 'nencki_id', 'group_id')

# ids of groups to be considered
groups.ids = c('f', 'd') 

# spine images:
source0 = "source0"
source1 = "source10"
xpos0 = "0MIN_x_m"
ypos0 = "0MIN_y_m"
xpos1 = "10_MIN_x_m"
ypos1 = "10_MIN_y_m"
image.features.t0 = c(source0, xpos0, ypos0)
image.features.t1 = c(source1, xpos1, ypos1)

# TO TURN OFF IMAGES SUPPORT COMMENT LINE BELOW
images.base.dir = "~/140719_dane_ze_wspolrzednymi/spiny/"
spine.image.size = 70
visualise.num.representants = 3


# features that should be kept while splitting data according to time moments
additional.features.names = c(spine.id, 'animal_id', 'nencki_id', group.id)
additional.features.names.t0 = image.features.t0
additional.features.names.t1 = image.features.t1


# PCA:
# each group of features will be considered separately while calculating pca
pca.feature.groups = list( 
  c("length",  "circumference", "area"),
  c("hw", "foot", "mwl", "mw", "wlr", "lwr", "lar", "nw") )
#pca.feature.groups = list( c("length",  "circumference", "area","hw", "foot", "mwl", "mw", "wlr", "lwr", "lar", "nw") ) #one group

# what size of (PCA) representation should be used
pca.num.features = 2

# should features be scaled or not
normalization = F 


# Clustering parameters:

#clustering.method = "hierarchical"
clustering.method = "cmeans"
#clustering.method = "kmeans"

k = 8
m = 4

# Transition matrices:

# how to calculate transitions of elements:
#TransitionMatrixCalculator = BuildTransitionMatrix # crisp: transition as change of between major clustering in t0 and t1   
TransitionMatrixCalculator = BuildNonnegativeTransitionMatrixLeastSquares # fuzzy: general method 

# how to calculate errors of predictions
#PredictionErrorEstimator = TotalError # sum of squares of residual matrix elements
PredictionErrorEstimator = AvgElementError # sum of squares of residual matrix elements / number of rows

# bootstrap for  SE estimation and comparing matrices:
num.repetitions = 1000 # bootstrap (for SE estimation) parameter 
bootstrap.fraction = 1.0 # bootstrap (for SE estimation) parameter
num.repetitions.comp.distribution.changes = 1000 # comparing relative changes in clusters distribution for groups
num.repetitions.comp.trans.matrices = 1000 # comparing transition matrices

# testing prediction error on training set using k-fold crossvalidation
k.fold = 10

# threshold of edge values in transition graphs plots
threshold.counts = 6
threshold.percents = 20 

# Output:
# where output results should be stored
output.dir = paste("/tmp/", format(Sys.time(), "%Y%m%d-%H%M%S"), "shapes", sep="_")
dir.create(output.dir, showWarnings = FALSE)
# redirects printing output into file (to turn on/off uncomment/comment below line)
sink(paste(output.dir,"/script_shape_transitions_analysis.log",sep=""), split=T)

# Line wrapping:
options(max.print=1000000)
options(width=1000) 

# Pdf output:
#options(device="pdf")
#pdf(paste(output.dir, "script_global_typology.pdf", sep="/"))

print(paste("output.dir =", output.dir))

#######################################################################################
#######################################################################################
#######################################################################################
#######################################################################################
# Data preparation.

source(file="routine_data_preparation.r")
source(file="routine_groups_ttest.r")

#######################################################################################
# K-fold crossvalidation of prediction error estimation on training data.

source(file="routine_kfold_prediction.r")

#######################################################################################
# Clustering.


source(file="routine_clustering.r")
source(file="routine_clustering_report.r")
source(file="routine_clustering_groups_ttest.r")
source(file="routine_contours_representants.r")



#######################################################################################
# Time transition matrices with SE estimation using bootstrap.

print("COMPUTING TRANSITION MATRICES FOR WHOLE DATA SET")
trans = ComputeTransitions(train, membership.matrix, TransitionMatrixCalculator, 
                           num.repetitions, bootstrap.fraction)
#test.trans = ComputeTransitions(test, test.membership.matrix, TransitionMatrixCalculator,
#                                num.repetitions, bootstrap.fraction)
StoreTransitionMatricesPlots(trans, 2*threshold.counts, threshold.percents, 
                             paste(output.dir,"/whole_data_full_",sep=""), 
                             "Shape clustering transitions")

print(paste("Prediction errors on (TEST) set:", test.data.file))
TranstionErrorsRoutine(trans$matrix, test, test.membership.matrix, PredictionErrorEstimator)

#######################################################################################
# Filtering results to only these from balanced.ids.file (optional).

source(file="routine_subset_reduction.r")
source(file="routine_groups_ttest.r")
source(file="routine_clustering_groups_ttest.r")
source(file="routine_group_distributions_change.r")

#######################################################################################
# K-fold crossvalidation of prediction error estimation on training data.

source(file="routine_kfold_prediction.r")

#######################################################################################
# Time transition matrices with SE estimation using bootstrap.

print("COMPUTING TRANSITION MATRICES FOR WHOLE DATA SET")
trans = ComputeTransitions(train, membership.matrix, TransitionMatrixCalculator, 
                           num.repetitions, bootstrap.fraction)
#test.trans = ComputeTransitions(test, test.membership.matrix, TransitionMatrixCalculator,
#                                num.repetitions, bootstrap.fraction)
StoreTransitionMatricesPlots(trans, 2*threshold.counts, threshold.percents, 
                             paste(output.dir,"/whole_data_",sep=""), 
                             "Shape clustering transitions")

print(paste("Prediction errors on (TEST) set:", test.data.file))
TranstionErrorsRoutine(trans$matrix, test, test.membership.matrix, PredictionErrorEstimator)

#######################################################################################
# Statistical significance of difference between transition matrices for groups.

print("Statistical significance of difference between transition matrices for groups in TRAIN set.")

gid = groups.ids[1]
source(file="routine_group_transition.r")
trans.group1 = trans

gid = groups.ids[2]
source(file="routine_group_transition.r")
trans.group2 = trans

gid1 = groups.ids[1]
gid2 = groups.ids[2]
p.value = CompareTransitionMatrices(train, membership.matrix, 
                                    trans.group1, gid1, trans.group2, gid2, 
                                    num.repetitions.comp.trans.matrices, 
                                    TransitionCalculator = TransitionMatrixCalculator,
                                    statistic = SqrRootSumDiff, 
                                    histogramtitle = "SMD Statistic distribution",
                                    xlab = "SMD value")
StorePlot(paste(output.dir,'/pvalues',sep=''), dpi=90, w=640, h=480) 
print(paste("Group",gid1," vs  Group",gid2,"->  p.value =", p.value))

#######################################################################################
#######################################################################################
#######################################################################################
#######################################################################################
# Cleaning up.

# Turn off sink
#dev.off()
sink()
print(paste("OUTPUT DATA IS STORED IN:", output.dir))
