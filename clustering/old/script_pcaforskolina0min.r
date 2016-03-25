#Script for PCA analysis (PCA is done only on Forskolina and applied to all spines) of spines for time=0min.

source(file="loading.r")
source(file="pca.r")
source(file="clustering.r")
source(file="changes.r")
source(file="params.r")
#######################################################################################

#install.packages("scatterplot3d", dependencies = TRUE)
library(scatterplot3d)

#install.packages("rgl", dependencies = TRUE)
library(rgl)

#######################################################################################

#Select configuration
paths = paths.fd
group.ids = group.ids.fd
features.names = features.0.names

########################################################################################

#Loads data
x = ReadMany(paths, group.ids)
#Shuffle rows
x = x[sample(nrow(x)),]
#Split into forskolina and dmso groups
x.f = SelRows(x, 'f') 
x.d = SelRows(x, 'd') 

########################################################################################

#Draw PCA for 2 components
pc = PCA(x.f, features.names)
features = PCAPredict(x, pc, num.features=2)

plot(features, pch=rownames(features),  col=ifelse(RFirstLetter(features)=='f',1,2))

########################################################################################

#Draw PCA for k components with clustering
pc = PCA(x.f, features.names)
features = PCAPredict(x, pc, num.features=3)
clustering = CClustering(features, num.clustering=15, normalization=T)

plot(features, pch=x$uid, col=clustering)
plot3d(features, col=ifelse(RFirstLetter(features)=='f',1,2), main="Data groups marked with different colours") #3D
plot3d(features, col=clustering, main="Clusters marked with different colours") #3D

