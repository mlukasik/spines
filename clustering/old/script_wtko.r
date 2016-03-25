#Script for PCA analysis of WT and KO spines

source(file="loading.r")
source(file="pca.r")
source(file="clustering.r")
source(file="changes.r")
source(file="params_wtko.r")
source(file="drawing.r")




#######################################################################################

#install.packages("scatterplot3d", dependencies = TRUE)
library(scatterplot3d)

#install.packages("rgl", dependencies = TRUE)
library(rgl)

library(xlsx)

#######################################################################################

#Select configuration
paths = paths.wtko
group.ids = group.ids.wtko
features.names = features.WDGT.names#features.0.names

########################################################################################
#simple analysis: t-test for each feature:

#parse the features
wt = Read(paths[1], group.ids)
cat("WT length: ", length(wt[,1]))
ko = Read(paths[2], group.ids)
cat("KO length: ", length(ko[,1]))

#t-test
for(feature in features.names){
  feature.wt = wt[,feature]
  feature.ko = ko[,feature]
  print(c(feature, mean(feature.wt), mean(feature.ko), t.test(feature.wt, feature.ko)$p.value))  
}


########################################################################################
#PCA and clustering:

#Loads data
x = ReadMany(paths, group.ids)
#Shuffle rows
#x = x[sample(nrow(x)),]


########################################################################################

#Draw PCA for k components with clustering
pc = PCA(x, features.names)

#store the loadings info in xlsx
load <- with(pc, unclass(loadings))
write.xlsx(x = load, file = "pca_components.xlsx",
           sheetName = "Sheet1", row.names = TRUE, col.names = TRUE)


features = PCAPredict(x, pc, num.features=2)
clustering = CClustering(features, num.clustering=12, normalization=T)

plot(features, pch=rownames(features),  col=ifelse(RFirstLetter(features)=='w',1,2), main="Rozklad PCA WT vs KO, CEAM")#, xlim=c(-20,10), ylim=c(-6, 6))
#plot3d(features, col=ifelse(RFirstLetter(features)=='f',1,2), main="Data groups marked with different colours") #3D
#plot3d(features, col=clustering,  main="Clusters marked with different colours", pch="x") #3D

########################################################################################
#Draw clustering
stats         = ClusteringPlot(features, clustering, "Clustering, PCA WT vs KO, CEAM, 12 clustering")
#Draw clustering' representants
representants = ElectRepresentants(clustering, features)
points(features[representants,], pch="X", col="red")

########################################################################################
#Prepare the clustering summary:
wt_sizes_list = c()
ko_sizes_list = c()
for(clustering.r_id in stats$clustering.nos){
  clustering.r_elems = clustering[(clustering == clustering.r_id)]
  wt_sizes_list = c(wt_sizes_list, length(clustering.r_elems[substring(names(clustering.r_elems), 1, 1) == 'w']))
  ko_sizes_list = c(ko_sizes_list, length(clustering.r_elems[substring(names(clustering.r_elems), 1, 1) == 'k']))
}

#Print clustering raport
raport = cbind(clustering.r=stats$clustering.nos, size=stats$sizes, WT_count=wt_sizes_list, KO_count=ko_sizes_list, x[representants,descriptors.names])
print("CLUSTER REPRESENTANTS")
print(raport)

########################################################################################
#store the summary in xlsx
write.xlsx(x = raport, file = "clustering_raport2.xlsx",
           sheetName = "Sheet1", row.names = FALSE)

#Store assignments
write.table(clustering, "/tmp/assignment.txt")