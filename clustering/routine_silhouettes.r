# Computes silhouettes width.
#
# author: tomasz.kusmierczyk(at)gmail.com

print("COMPUTING SILHOUETTES")  
source(file="routine_clustering.r")
s = silhouette(clustering.assignment, dist=dist(train.features, method = "euclidean"))    
index.value = mean(s[,3])
index.sd = sd(s[,3])

