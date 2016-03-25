# Cluster analysis.
#
# author: tomasz.kusmierczyk(at)gmail.com


source(file="loading.r")
source(file="drawing.r")

# Required libraries
#install.packages("e1071")
library("e1071")
library("cluster")

##########################
# Various clustering representations:


AssignmentToMembershipMatrixK = function(clusters.assignment, k) {
  num.cols = max(max(clusters.assignment), k)
  num.rows = length(clusters.assignment)
  membership = matrix(data=0, nrow=num.rows, ncol=num.cols)
  for (r in 1:length(clusters.assignment)) {
    c = clusters.assignment[r]
    membership[r, c] = 1
  }
  rownames(membership) = rownames(as.matrix(clusters.assignment))
  return (membership)
}


AssignmentToMembershipMatrix = function(clusters.assignment) {
  return (AssignmentToMembershipMatrixK(clusters.assignment, 1))
}


MembershipMatrixToAssignment = function(membership) {
  clusters.assignment = as.matrix( max.col(membership) )
  rownames(clusters.assignment) = rownames(membership)
  return (clusters.assignment)
}


MapAssignments = function(clusters.assignment1, from.clusters, to.cluster) {
  for (from.cluster in from.clusters) {
    clusters.assignment1[clusters.assignment1==from.cluster] = to.cluster    
  }
  return (clusters.assignment1)
}


##########################
# Clusters summarization:

ClusterCenters = function(clusters.assignment, features, k) {
  if (missing(k)) {
    clusters.nos  = sort(unique(clusters.assignment))    
  } else {
    clusters.nos  = 1:k
  }
  centers = c()
  for (cluster.no in clusters.nos) {
    #print(cluster.no)
    cluster.mask     = clusters.assignment==cluster.no    
    cluster.elements = features[cluster.mask, ]

    if ( sum(cluster.mask) <= 0 ) {
      mean.element     = zeros(1, dim(features)[2])
    } else if ( sum(cluster.mask) <= 1 ) {
      mean.element     = cluster.elements
    } else {
      mean.element     = colMeans(cluster.elements)      
    }
    centers            = rbind(centers, mean.element)
  }
  rownames(centers) = clusters.nos
  return (centers)
}


ClusterCentersMembership = function(membership.matrix, features) {
  k = dim(membership.matrix)[2]  
  centers = c()
  for (cluster.no in 1:k) {
    weights = membership.matrix[ , cluster.no]
    mean.element = colSums(features * weights) / sum(weights)    
    centers            = rbind(centers, mean.element)
  }
  rownames(centers) = 1:k
  return (centers)
}


RankRepresentantsCenterDistance = function(membership.matrix, features) {
  # Anaylyses clusters with given assignment and features 
  # and returns list of sorted elements for each cluster
  # according to the distance from clusters centers.
  
  centers = ClusterCentersMembership(membership.matrix, features)  
  features = data.frame(features)
  clusters.nos  = 1:dim(membership.matrix)[2]
  representants.rank = c()
  for (cluster.no in clusters.nos) {
    dst = as.matrix( dist(rbind(me=centers[cluster.no, ], features), method="euclidean") )
    dst["me","me"] = Inf    
    cluster.rank = names(sort(dst["me",]))
    cluster.rank = head(cluster.rank, -1)
    representants.rank = c(representants.rank, list(cluster.rank) )
  }   
  return(representants.rank)
}


RankRepresentantsMembershipMax = function(membership.matrix, features) {
  # Anaylyses clusters with given assignment and features 
  # and returns list of sorted representants.
  
  features = data.frame(features)
  clusters.nos  = 1:dim(membership.matrix)[2]
  representants.rank = c()
  for (cluster.no in clusters.nos) {    
    cluster.rank = names(sort(membership.matrix[ , cluster.no], decreasing=T))
    representants.rank = c(representants.rank, list(cluster.rank) )
  }   
  return(representants.rank)
}


RankRepresentantsMembershipRatio = function(membership.matrix, features) {
  # Anaylyses clusters with given assignment and features 
  # and returns list of sorted representants.
  
  features = data.frame(features)
  clusters.nos  = 1:dim(membership.matrix)[2]
  representants.rank = c()
  for (cluster.no in clusters.nos) {    
    ratio = membership.matrix[ , cluster.no] / apply((membership.matrix[ , -cluster.no]), 1, max)    
    cluster.rank = names(sort(ratio, decreasing=T))
    representants.rank = c(representants.rank, list(cluster.rank) )
  }   
  return(representants.rank)
}


RankRepresentants = function(clusters.assignment, features) {
  # Anaylyses clusters with given assignment and features 
  # and returns list of sorted elements for each cluster
  # according to the distance from clusters centers.
  
  features = data.frame(features)
  clusters.nos  = sort(unique(clusters.assignment))
  representants.rank = c()
  for (cluster.no in clusters.nos) {
    #print(cluster.no)
    cluster.mask     = clusters.assignment==cluster.no    
    cluster.elements = features[cluster.mask, ]    
    mean.element     = colMeans(cluster.elements)
    
    dst = as.matrix( dist(rbind(me=mean.element,cluster.elements), method="euclidean") )
    dst["me","me"] = Inf
    
    cluster.rank = names(sort(dst["me",]))
    cluster.rank = head(cluster.rank, -1)
    representants.rank = c(representants.rank, list(cluster.rank) )
  }   
  return(representants.rank)
}


ElectRepresentants = function(clusters.assignment, features) {
  representants.rank = RankRepresentants(clusters.assignment, features)
  representants = c()
  for (l in representants.rank) {
    representants = c(representants, l[1])
  }
  return (representants)
}


PrintRepresentants = function(clusters.assignment, features, num.representants=3) {  
  representants.rank = RankRepresentants(clusters.assignment, features) 
  cluster.no = 1
  for (representants in representants.rank) {  
    rep = representants
    rep = rep[1: min(num.representants, length(rep))]
    print(paste("Cluster ", cluster.no, ":", sep=""))
    print(paste(rep))
    cluster.no = cluster.no + 1
  }
}


AnalyseClusters = function(clusters.assignment, x, features.names, groups.assignment) {
  # Anaylyses clusters with given assignment and features y.
  #
  # Returns statistics such as sizes, means, sds, groups.
  if (missing(groups.assignment)) {
    groups.assignment = rep('?', dim(x)[1])
  }
  
  clusters.nos  = sort(unique(clusters.assignment))
  group.ids = sort(unique( groups.assignment))  
  
  clusters.sizes = c(); features.means = c(); features.sds = c(); groups = c()
  for (cluster.no in clusters.nos) {
    cluster.mask   = clusters.assignment==cluster.no
    clusters.sizes = c(clusters.sizes, sum(cluster.mask) )  
    
    g = c()
    for (group.id in group.ids) {
      g = c(g, sum(groups.assignment==group.id & cluster.mask) )
    }
    groups = rbind(groups, g)
    
    fm = c(); fs = c();
    for (feature in features.names) {
      fm = c(fm, mean(x[cluster.mask, feature]) )
      fs = c(fs, sd(  x[cluster.mask, feature]) )
    }
    features.means = rbind(features.means, fm)
    features.sds   = rbind(features.sds, fs)
  } 
  
  colnames(groups)         = group.ids 
  rownames(groups)         = clusters.nos
  colnames(features.means) = features.names
  rownames(features.means) = clusters.nos
  colnames(features.sds)   = features.names
  rownames(features.sds)   = clusters.nos
  
  stats = list(clusters.nos=clusters.nos, sizes=clusters.sizes, groups=groups, features.means=features.means, features.sds=features.sds)
  return(stats)
}



##########################
# Hierarchical clustering:

GenTree = function(features, normalization=F) {
    if (normalization) {
        features = scale(features) 
    }
  
    d = dist(features, method="euclidean")
    hr = hclust(d, method = "average", members=NULL)   
    return (hr)
}


CutTree = function(hr, num.clusters) {
    clusters.assignment = cutree(hr, k=num.clusters)   
    return(clusters.assignment)
}

##########################
# General interfaces for different clustering methods:

HierarchicalClustering = function(obj, features, num.clusters) {
    assignment = as.matrix( CutTree(obj, num.clusters) )
    rownames(assignment) = rownames(features)
    return (AssignmentToMembershipMatrix(assignment))
}


StartHierarchicalClustering = function(features) {
    clustering.structure = list(obj=GenTree(features, normalization=F), method=HierarchicalClustering, features=features)
    return (clustering.structure)
}


CMeansClustering = function(obj, features, num.clusters) {
  membership.matrix = cmeans(features, centers=obj$centers, iter.max = obj$iter.max, verbose = obj$verbose, dist = obj$dist,
                              method = obj$method, m = obj$m, rate.par = obj$rate.par, weights = obj$weights, control = obj$control)  
  return (membership.matrix)
}


StartCMeansClustering = function(features,  centers=5, iter.max = 10000, verbose = F, dist = "euclidean",
                                 method = "cmeans", m = 2, rate.par = NULL, weights = 1, control = list()) {
  # Calculate clusters centers
  #  with hierarchical clustering:
  #d             = dist(features, method="euclidean")
  #tree          = hclust(d, method = "single", members=NULL)   
  #assignment    = as.matrix( CutTree(tree, centers) )
  #representants = ElectRepresentants(assignment, features)
  #centers       = features[representants, ]
  #  with random selection
  step    = round(dim(features)[1]/(centers+1))
  ixs     = seq(from=step, to=dim(features)[1]-step, by=step)
  centers = features[ixs, ]
  
  clustering.structure = list( obj=list(centers=centers, iter.max=iter.max, verbose=verbose, dist=dist, 
                                        method=method, m=m, rate.par=rate.par, weights=weights, control=control), 
                              method=CMeansClustering, features=features)
  return (clustering.structure)
}


KMeansClustering = function(obj, features, num.clusters) {
  membership.matrix = kmeans(features, centers=obj$centers, iter.max = obj$iter.max)  
  return (membership.matrix)
}


StartKMeansClustering = function(features, centers=5, iter.max = 10000) {
  # Calculate clusters centers with random selection
  step    = round(dim(features)[1]/(centers+1))
  ixs     = seq(from=step, to=dim(features)[1]-step, by=step)
  centers = features[ixs, ]
  
  clustering.structure = list( obj=list(centers=centers, iter.max=iter.max), 
                               method=KMeansClustering, features=features)
  return (clustering.structure)
}


ApplyClustering = function(clustering.structure, num.clusters) {
    obj = clustering.structure$obj
    features = clustering.structure$features
    results =  clustering.structure$method(obj, features, num.clusters) 
    return (results)
}


