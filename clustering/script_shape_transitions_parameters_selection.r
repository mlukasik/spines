# Script that allows for selection of parameters in clustering of shapes using validation index.
#
# author: tomasz.kusmierczyk(at)gmail.com

#######################################################################################
#######################################################################################

source(file="loading.r")
source(file="pca.r")
source(file="clustering.r")
source(file="drawing.r")
source(file="transitions.r")
source(file="predictions.r")
source(file="parameters_selection.r")

#######################################################################################
#######################################################################################
#######################################################################################
#######################################################################################
# Script configuration.

# Input data:
#train.data.file = "~/spines_bitbucket/data/140303_olddata/filtered_300/ALL.txt"
#train.data.file = "~/spines_bitbucket/data/140303_olddata/ALL_triple.txt"
train.data.file = "~/spines_bitbucket/data/140303_140803_merged/ALL_triple.txt"
#train.data.file = "~/spines_bitbucket/data/140403_dane_treningowe_testowe_300_2/train.txt"
#train.data.file = "~/spines_bitbucket/data/140403_dane_treningowe_testowe_300_2/train_valid.txt"
#train.data.file = "~/spines_bitbucket/data/140403_dane_treningowe_testowe/validation_and_train.txt"

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

# features that should be kept while splitting data according to time moments
additional.features.names = c(spine.id, 'animal_id', 'nencki_id', group.id)
additional.features.names.t0 = c()
additional.features.names.t1 = c()

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



# Clustering parameters to be considered:

#clustering.method = "hierarchical"
clustering.method = "cmeans"
#clustering.method = "kmeans"

ms = seq(from=1.5, to=10, by=0.5)
ks = seq(from=3, to=20, by=1)
#ms = c(1)
#ks = c(6,8,10)
#ms = c(2.0, 3.0, 4.0)
#ks = c(8, 10, 12)

# how to compute index value:
#compute.index.value.routine = "routine_kfold_prediction.r" # should compute: index.value index.sd
#index.label = "Prediction error"
#compute.index.value.routine = "routine_silhouettes.r" # should compute: index.value index.sd
#index.label = "Silhouettes width"
compute.index.value.routine = "routine_wss.r" # should compute: index.value index.sd
index.label = "WSS"


# For indexes based on transition matrices:
# how to calculate transitions of elements:
#TransitionMatrixCalculator = BuildTransitionMatrix # crisp: transition as change of between major clustering in t0 and t1   
TransitionMatrixCalculator = BuildNonnegativeTransitionMatrixLeastSquares # fuzzy

# how to calculate errors of predictions:
#PredictionErrorEstimator = TotalError # sum of squares of residual matrix elements
PredictionErrorEstimator = AvgElementError # sum of squares of residual matrix elements / number of rows

# how many repetitions:
k.fold = 10


# Output:
# where output results should be stored
output.dir = paste("/tmp/", format(Sys.time(), "%Y%m%d-%H%M%S"), "shapes_parameters_selection", sep="_")
dir.create(output.dir, showWarnings = FALSE)
# redirects printing output into file (to turn on/off uncomment/comment below line)
sink(paste(output.dir,"/script_shape_transitions_parameters_selection.log",sep=""), split=T)

# line wrapping:
options(max.print=1000000)
options(width=1000) 

# pdf output:
#options(device="pdf")
#pdf(paste(output.dir, "script_global_typology_parameters_selection.pdf", sep="/"))


#######################################################################################
#######################################################################################
#######################################################################################
#######################################################################################
# Data preparation.

source(file="routine_data_preparation.r")   
source(file="routine_groups_ttest.r")

#######################################################################################
# Construction of errors matrix.

source(file="routine_clustering_index_matrix.r")

print("Index Matrix:")
print(index.matrix)
print("Index Matrix Std:")
print(index.matrix.sd)

#######################################################################################
#######################################################################################
#######################################################################################
#######################################################################################
# Plotting error matrices.

library(lattice)

levelplot(index.matrix, row.values=ms, column.values=ks, cuts = 50,
          xlab="m", ylab="k", main=index.label, col.regions = gray(1.0-0:100/100))
StorePlot(paste(output.dir,"/index.matrix",sep=""), dpi=90, w=480, h=480)
contourplot(index.matrix, row.values=ms, column.values=ks, cuts = 20,
            xlab="m", ylab="k", main=index.label, col.regions = gray(1.0-0:100/100))
StorePlot(paste(output.dir,"/index.matrix.contour",sep=""), dpi=90, w=480, h=480)

#######################################################################################
#######################################################################################
#######################################################################################
#######################################################################################
# Automatic method for parameters selection.

print("Searching for optimal parameters:")
optimal = FindOptimalKM(index.matrix)
kix = optimal$kix
mix = optimal$mix
k = optimal$k
m = optimal$m
  
KneePlot(ms, index.matrix[ , kix],  index.matrix.sd[ , kix],
          xlab="m", ylab=index.label, main=paste(index.label,"vs. fuzziness"), 
         sub=paste("for k = ",k, ", clustering = ", clustering.method, sep=""))
StorePlot(paste(output.dir,"m_vs_err",sep="/"), dpi=90, w=480, h=480) 

KneePlot(ks, index.matrix[mix, ], index.matrix.sd[mix, ],
         xlab="k", ylab=index.label, main=paste(index.label,"vs. number of clusters"), 
         sub=paste("for m = ",m, ", clustering = ", clustering.method, sep=""))
StorePlot(paste(output.dir,"k_vs_err",sep="/"), dpi=90, w=480, h=480) 


#######################################################################################
#######################################################################################
#######################################################################################
#######################################################################################
# Cleaning up.

# Turn off sink
#dev.off()
sink()
print(paste("OUTPUT DATA IS STORED IN:", output.dir))

