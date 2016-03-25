#Script for PCA analysis of spines for relative changes.

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
paths = paths.fd100 #files 
group.ids = group.ids.fd100 #filed ids
features.names = features.0.names #features in start time
features2.names = features.40.names #features in end time

########################################################################################

#Loads data
x = ReadMany(paths, group.ids)
x = FilterOut(x, all.features.names)
#Shuffle rows
#x = x[sample(nrow(x)),]
#Replaces values of features.names with relative changes
x = CalcChanges(x, features.names, features2.names)
#Split into forskolina and dmso groups
x.f = SelRows(x, 'f') 
x.d = SelRows(x, 'd') 

########################################################################################

#Draw PCA for 2 components
pc = PCA(x.f, features.names)
features = PCAPredict(x, pc, num.features=2)

plot(features, pch=x$uid,  col=ifelse(substr(x$uid,1,1)=='f',1,2))
#plot(features, pch="x",  col=ifelse(substr(x$uid,1,1)=='f',1,2))
#plot(SelRows(features,'f'), pch="x",  col=1, xlim=c(-5,15), ylim=c(-10,10)) #forskolina
#plot(SelRows(features,'d'), pch="x",  col=2, xlim=c(-5,15), ylim=c(-10,10)) #dmos

########################################################################################

#Draw PCA for 3 components
pc = PCA(x.f, features.names)
features = PCAPredict(x, pc, num.features=3)

scatterplot3d(features, pch=x$uid) #3D
plot3d(features, col=ifelse(RFirstLetter(features)=='f',1,2), main="Data groups marked with different colours") #3D

########################################################################################

#Draw PCA for k components with clustering
pc = PCA(x, features.names)
features = PCAPredict(x, pc, num.features=2)
clustering = CClustering(features, num.clustering=20, normalization=F)

stats         = ClusteringPlot(features, clustering, "Clustering of relative changes t=40min vs t=0min")
#stats$sizes
#Draw clustering' representants
representants = ElectRepresentants(clustering, features) 
#points(features[representants,], pch="X", col="red")

#scatterplot3d(features, pch=x$uid) #3D
#plot3d(features, pch=x$uid, col=clustering,  main="Clusters marked with different colours") #3D

#Print clustering raport
raport = cbind(clustering.r=stats$clustering.nos, size=stats$sizes, x[representants,descriptors.names])
print("CLUSTER REPRESENTANTS")
print(raport)

#Print clustering stats
stats = AnalyseClusters(clustering, x, features.names)
print(stats)

#Store assignments
write.table(clustering, "/tmp/changes_assignment_all_t0_t40.txt")