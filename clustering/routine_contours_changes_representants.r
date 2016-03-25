# Plotting representants of clusters.
#
# author: tomasz.kusmierczyk(at)gmail.com

if (exists("imgs")) {
  # Are contour images loaded? 
  
library(png)
source(file="contours.r")
source(file="clustering.r")

representants.rank = RankRepresentantsCenterDistance(membership.matrix, train.features)
ExtractClusterOfChangesRepresentants(train.features, imgs, representants.rank, 
                            output.dir, visualise.num.representants, label="center_distance")

representants.rank = RankRepresentantsMembershipMax(membership.matrix, train.features)
ExtractClusterOfChangesRepresentants(train.features, imgs, representants.rank, 
                            output.dir, visualise.num.representants, label="membership_max")

representants.rank = RankRepresentantsMembershipRatio(membership.matrix, train.features)
ExtractClusterOfChangesRepresentants(train.features, imgs, representants.rank, 
                            output.dir, visualise.num.representants, label="membership_ratio")

}

