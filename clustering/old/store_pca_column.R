#Script for storage of PCA columns of spines for time=0min.
OUT_FORSKOLIN = "FORSKOLIN_pca_triple.txt"
OUT_DMSO = "CONTROLTEST_DMSO_pca_triple.txt"
source(file="loading.r")
source(file="pca.r")
source(file="clustering.r")
source(file="changes.r")
source(file="params.r")
source(file="drawing.r")

#######################################################################################

#install.packages("scatterplot3d", dependencies = TRUE)
library(scatterplot3d)

#install.packages("rgl", dependencies = TRUE)
library(rgl)


add_pca_cols = function(features_old, features_new, pc, numfeatures, prefix_name) {
  features_pca = PCAPredict(features_old, pc, num.features=numfeatures)
  for(feature_ind in seq(1:numfeatures)){
    features_new[paste(prefix_name, "_", feature_ind, sep="")] = features_pca[,feature_ind]
  }
  return(features_new)
}


#######################################################################################

#Select configuration
paths = paths.fd
group.ids = group.ids.fd
features.names = features.0.names

########################################################################################

#Loads data
x = ReadMany(paths, group.ids)
#Shuffle rows
#x = x[sample(nrow(x)),]

forskolin = read.table(paths[1], header=T, check.names=FALSE)
dmso = read.table(paths[2], header=T, check.names=FALSE)

########################################################################################

#Draw PCA for k components with clustering
pc = PCA(x, features.names)
fpc = PCAPredict(forskolin, pc, 2)
fpc[1:3,1]

########################################################################################
#store column for time 0
forskolin_new = forskolin
forskolin_new = add_pca_cols(forskolin, forskolin_new, pc, 2, "0MIN_pca")

#store column for time 10
colnames(forskolin) = c(nencki.descriptors.names, features.10.names, features.0.names, features.40.names)
forskolin_new = add_pca_cols(forskolin, forskolin_new, pc, 2, "10_MIN_pca")

#store column for time 40
colnames(forskolin) = c(nencki.descriptors.names, features.40.names, features.10.names, features.0.names)
forskolin_new = add_pca_cols(forskolin, forskolin_new, pc, 2, "40_MIN_pca")

write.table(forskolin_new, OUT_FORSKOLIN, row.names=F, col.names=T, quote=F)
########################################################################################
#store column for time 0
dmso_new = dmso
dmso_new = add_pca_cols(dmso, dmso_new, pc, 2, "0MIN_pca")

#store column for time 10
colnames(dmso) = c(nencki.descriptors.names, features.10.names, features.0.names, features.40.names)
dmso_new = dmso = add_pca_cols(dmso, dmso_new, pc, 2, "10_MIN_pca")

#store column for time 40
colnames(dmso) = c(nencki.descriptors.names, features.40.names, features.10.names, features.0.names)
dmso_new = add_pca_cols(dmso, dmso_new, pc, 2, "40_MIN_pca")

write.table(dmso_new, OUT_DMSO, row.names=F, col.names=T, quote=F)