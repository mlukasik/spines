#Script for PCA analysis of spines for time=0min.

source(file="resload.r")
source(file="pca.r")
source(file="clust.r")
source(file="changes.r")
source(file="params.r")
source(file="drawing.r")

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
#x = x[sample(nrow(x)),]



########################################################################################

#Draw PCA for k components with clustering
pc = PCA(x, features.names)
features = PCAPredict(x, pc, num.features=2)
clusters = CClustering(features, num.clusters=20, normalization=T)

plot(features, pch=rownames(features),  col=ifelse(RFirstLetter(features)=='f',1,2), main="Rozklad w chwili t=0", xlim=c(-20,10), ylim=c(-6, 6))
#plot3d(features, col=ifelse(RFirstLetter(features)=='f',1,2), main="Data groups marked with different colours") #3D
#plot3d(features, col=clusters,  main="Clusters marked with different colours", pch="x") #3D

#Draw clusters
stats         = ClusteringPlot(features, clusters, "Clustering for t=0")
#Draw clusters' representants
representants = ElectRepresentants(clusters, features) 
points(features[representants,], pch="X", col="red")

#Print clusters raport
raport = cbind(cluster=stats$clusters.nos, size=stats$sizes, x[representants,descriptors.names])
print("CLUSTER REPRESENTANTS")
print(raport)

#Store assignments
write.table(clusters, "/tmp/assignment.txt")
