# Script that allows for selection of parameters in clustering of changes using validation index.
#
# author: tomasz.kusmierczyk(at)gmail.com

#######################################################################################
#######################################################################################

source(file="loading.r")
source(file="pca.r")
source(file="clustering.r")
source(file="drawing.r")
source(file="changes.r")
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
#train.data.file = "~/spines_bitbucket/data/140403_dane_treningowe_testowe3/validation_and_train.txt"

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

# PCA:
# what size of (PCA) representation should be used
pca.num.features = 3


# Clustering parameters:

#clustering.method = "hierarchical"
clustering.method = "cmeans"
#clustering.method = "kmeans"

ms = seq(from=2.0, to=10, by=1)
ks = seq(from=3, to=25, by=1)
#ms = c(1)
#ms = c(2.0, 3.0, 4.0)
#ks = c(8, 10, 12)

# how to compute index value:
#compute.index.value.routine = "routine_silhouettes.r" # should compute: index.value index.sd
#index.label = "Silhouettes width"
compute.index.value.routine = "routine_wss.r" # should compute: index.value index.sd
index.label = "WSS"


# Output:
# where output results should be stored
output.dir = paste("/tmp/", format(Sys.time(), "%Y%m%d-%H%M%S"), "changes_parameters_selection", sep="_")
dir.create(output.dir, showWarnings = FALSE)
# redirects printing output into file (to turn on/off uncomment/comment below line)
sink(paste(output.dir,"/script_pcachanges.log",sep=""), split=T)

# Line wrapping:
options(max.print=1000000)
options(width=1000) 

# Pdf output:
#options(device="pdf")
#pdf(paste(output.dir, "script_global_typology.pdf", sep="/"))

#######################################################################################
# Compatibility required features (will be ignored anyway).

# should features be scaled or not?
normalization = F 

#######################################################################################
#######################################################################################
########################################################################################
# Print out configuration.

if (!exists("test.data.file")) {
  test.data.file = train.data.file
}

# Print parameters
print(paste("train.data.file =", train.data.file))
print(paste("test.data.file =", test.data.file))
print(paste("groups.ids =", groups.ids))
print(paste("features.names.t0 =", paste(features.names.t0, collapse=" ")))
print(paste("features.names.t1 =", paste(features.names.t1, collapse=" ")))
print(paste("features.names.nice =", paste( features.names.nice, collapse=" ")))
print(paste("additional.features.names =", paste(additional.features.names, collapse=" ")))
print(paste("pca.num.features =", pca.num.features))

########################################################################################
########################################################################################
# Data loading and preprocessing.

train = ChangesDataPreparation(train.data.file, group.id, groups.ids, 
                               features.names.t0, features.names.t1, features.names.nice)
test = ChangesDataPreparation(test.data.file, group.id, groups.ids, 
                              features.names.t0, features.names.t1, features.names.nice)

description.str = paste('N=',dim(train)[1],',D=',pca.num.features,",#",
                        groups.ids[1],'=',sum(train[,group.id]==groups.ids[1]),',#',
                        groups.ids[2],'=',sum(train[,group.id]==groups.ids[2]), sep='')

########################################################################################
########################################################################################
# PCA on whole data.

print("PCA on all features")
pc = PCA(train, features.names.nice)
train.features = PCAPredict(train, pc, pca.num.features)
test.features = PCAPredict(test, pc, pca.num.features)

colnames(train.features) = paste("Rel.", colnames(train.features), sep="")
colnames(test.features) = paste("Rel.", colnames(test.features), sep="")

PCALoadingsPlot(pc, paste('PCA loadings\n(',description.str,')',sep=''))
StorePlot( paste(output.dir,'/pca_loadings',sep='') )
PCAVariancePlot(pc, paste('PCA variance explained\n(',description.str,')',sep=''))
StorePlot( paste(output.dir,'/pca_variance',sep='') )
print(pc$loadings)
print(summary(pc))

########################################################################################
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
# Automatic method for parameters selection:

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
