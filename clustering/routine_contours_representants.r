# Plotting representants of clusters.
#
# author: tomasz.kusmierczyk(at)gmail.com

if (exists("imgs")) {
  # Are contour images loaded? 

  library(png)
  source(file="contours.r")
  source(file="clustering.r")
  
  representants.rank = RankRepresentantsCenterDistance(membership.matrix, train.features)
  ExtractClusterRepresentants(train.features, imgs, representants.rank, 
                              output.dir, visualise.num.representants, label="center_distance")
  
  representants.rank = RankRepresentantsMembershipMax(membership.matrix, train.features)
  ExtractClusterRepresentants(train.features, imgs, representants.rank, 
                              output.dir, visualise.num.representants, label="membership_max")
  
  representants.rank = RankRepresentantsMembershipRatio(membership.matrix, train.features)
  ExtractClusterRepresentants(train.features, imgs, representants.rank, 
                              output.dir, visualise.num.representants, label="membership_ratio")
  
  
  #plot(train.features, pch='o', col=clustering.assignment, main="Spine shapes clusters")
  #centers = ClusterCentersMembership(membership.matrix, train.features)
  #d = min(dist(centers, method="euclidean"))*2
  #TextBoxes(stats$features.means[,1], stats$features.means[,2], stats$clusters.nos, transparent=stats$sizes<=2)
  
  
}
