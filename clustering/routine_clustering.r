# Routine that clusters data.
#
# author: tomasz.kusmierczyk(at)gmail.com

if (!exists("clustering.method")) {
  print("Clustering routine requires following parameters to be set:")
  print(" clustering.method (cmeans/kmeans/hierarchical), k, m, train.features, test.features")
}

# Cluster using c-means:
if (clustering.method == "cmeans") {
  if (!exists("clustering.reported")) {
    clustering.reported = T

    print("RUNNING C-MEANS CLUSTERING")
    print(paste("k =", k))
    print(paste("m =", m))
    print("StartCMeansClustering:")
    print(StartCMeansClustering)
  }
  
  clustering.structure = StartCMeansClustering(train.features, k, iter.max = 50000, verbose = F, dist = "euclidean",
                                               method = "cmeans", m = m, rate.par = NULL, weights = 1, control = list())
  clustering.results = ApplyClustering(clustering.structure, k)
  
  clustering.assignment = as.matrix(clustering.results$cluster)
  membership.matrix = as.matrix(clustering.results$membership)
  
  test.membership.matrix = PredictCMeans(clustering.results$centers, test.features, m = m)
  test.clustering.assignment = MembershipMatrixToAssignment(test.membership.matrix)
  
  # sharpening membership matrices (optional)
  #membership.matrix = AssignmentToMembershipMatrix(clustering.assignment)
  #test.membership.matrix = AssignmentToMembershipMatrix(test.clustering.assignment)
}  



# Cluster using k-means:
if (clustering.method == "kmeans") {
  if (!exists("clustering.reported")) {
    clustering.reported = T
    
    print("RUNNING K-MEANS CLUSTERING")
    print(paste("k =", k))
    print("StartKMeansClustering:")
    print(StartKMeansClustering)
  }
  
  clustering.structure = StartKMeansClustering(train.features, k, iter.max = 50000)
  clustering.results = ApplyClustering(clustering.structure, k)
  
  clustering.assignment = as.matrix(clustering.results$cluster)
  membership.matrix = AssignmentToMembershipMatrixK(clustering.assignment, k)
  
  clustering.results$membership =  membership.matrix
  
  test.clustering.assignment = PredictKnn(clustering.assignment, train.features, test.features, k = 1)
  test.membership.matrix = AssignmentToMembershipMatrixK(test.clustering.assignment, k)
}  


# Hierarchical clustering:
if (clustering.method == "hierarchical") {
  if (!exists("clustering.reported")) {
    clustering.reported = T
  
    print("RUNNING HIERARCHICAL CLUSTERING")
    print(paste("k =", k))
    print("StartHierarchicalClustering:")
    print(StartHierarchicalClustering)
  }
  
  clustering.structure = StartHierarchicalClustering(train.features)
  clustering.results = ApplyClustering(clustering.structure, k)
  
  membership.matrix = clustering.results
  clustering.assignment = MembershipMatrixToAssignment(membership.matrix)
  
  clustering.results = list(
    membership =  membership.matrix,
    size = colSums(membership.matrix),
    cluster = clustering.assignment,
    centers = ClusterCenters(clustering.assignment, train.features, k))
  
  test.clustering.assignment = PredictKnn(clustering.assignment, train.features, test.features, k = 1)
  test.membership.matrix = AssignmentToMembershipMatrixK(test.clustering.assignment, k)
}

#######################################################################################
#######################################################################################
#######################################################################################


# Cluster using Fanny:

#clustering.results = fanny(train.features, k, diss = F, memb.exp = 2, metric = "SqEuclidean", stand = F, 
#                           maxit = 10, tol = 1e-15, trace.lev = 0,
#                           iniMem.p = NULL, cluster.only = FALSE, keep.diss = !diss && !cluster.only && n < 100,
#                           keep.data = !diss && !cluster.only)


# Manual postprocessing:

# Manual merging clustering:
#clustering.assignment1 = clustering.assignment
#clustering.assignment1 = MapAssignments(clustering.assignment1, c(2,5,9,16), 2)
#clustering.assignment1 = MapAssignments(clustering.assignment1, c(3,4,7,10), 3)
#clustering.assignment1 = MapAssignments(clustering.assignment1, c(6,8,12,17), 4)
#clustering.assignment1 = MapAssignments(clustering.assignment1, c(11,13,14,15), 5)
#clustering.assignment = clustering.assignment1
#membership.matrix = AssignmentToMembershipMatrix(clustering.assignment)
#print("CLUSTERS ASSIGNMENT:")
#print(clustering.assignment)

