# Routine that prints out clustering results.
#
# author: tomasz.kusmierczyk(at)gmail.com

source(file="clustering.r")
source(file="drawing.r")

# Calc stats & representants
representants = ElectRepresentants(clustering.assignment, train.features) 
print("CLUSTERS' REPRESENTANTS:")
PrintRepresentants(clustering.assignment, train.features)
print("CLUSTERS STATISTICS:")
AnalyseClusters(clustering.assignment, train, features.names.nice, train[ , group.id])
print("MEMBERSHIP MATRIX:")
print(membership.matrix)
print("CLUSTERS ASSIGNMENT:")
print(clustering.assignment)

Captialize = function(x) { 
  s <- strsplit(x, " ")[[1]]
  paste(toupper(substring(s, 1,1)), substring(s, 2), sep="", collapse=" ")
}

ClusteringPlot(train.features[ , 1:2], clustering.assignment, 
               paste(Captialize(clustering.method)," clustering\n(k=",k,", m=",m,")", sep=""),
               pch_method = function(train.features) { return (as.matrix(train[ , group.id])) } )
StorePlot( paste(output.dir,'/clustering',sep=''), dpi=90, w=480, h=480)
points(train.features[representants,], pch="x", col="red") #mark representants on plot
StorePlot( paste(output.dir,'/clustering_representants',sep=''), dpi=90, w=480, h=480)

ClusteringPlot(train.features[ , 1:2], clustering.assignment, 
               paste(Captialize(clustering.method)," clustering\n(k=",k,", m=",m,")", sep=""),
               pch_circle)
StorePlot( paste(output.dir,'/clustering_detailed',sep=''), dpi=90, w=480, h=480)


