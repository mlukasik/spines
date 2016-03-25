# Computes WSS width.
#
# author: tomasz.kusmierczyk(at)gmail.com

print("COMPUTING WSS")  
source(file="routine_clustering.r")

s = ClusterSSE(membership.matrix, train.features)
#s = silhouette(clustering.assignment, dist=dist(train.features, method = "euclidean"))[,3] / k    
#s = silhouette(clustering.assignment, dist=dist(train.features, method = "euclidean"))[,3]    
#s = fclustIndex(clustering.results, train.features, "separation.index")  
#s = fclustIndex(clustering.results, train.features, "xie.beni")
index.value = mean(s)
index.sd = sd(as.vector(s)) 
