# Comapring changes in distribution of groups in clusters using bootstrap.
#
# author: tomasz.kusmierczyk(at)gmail.com

GroupsInClustersRelativeChangeStat = function(g1.t0, g1.t1, g2.t0, g2.t1) {
  g1.t0.colsums = colSums(g1.t0)
  g2.t0.colsums = colSums(g2.t0)
  g1.t1.colsums = colSums(g1.t1)
  g2.t1.colsums = colSums(g2.t1)
  
  v1 = (g2.t1.colsums-g2.t0.colsums ) / g2.t0.colsums 
  v2 = (g1.t1.colsums-g1.t0.colsums ) / g1.t0.colsums
  
  v1[is.na(v1)] = 0
  v2[is.na(v2)] = 0
  v1[Inf == v1] = 0
  v2[Inf == v2] = 0
  
  return (sum((v1-v2)^2))
}


CompareGroupsInClusters = function(train, membership.matrix, 
                                   gid1, gid2,
                                   repetitions,                                     
                                   statistic.calculator = GroupsInClustersRelativeChangeStat, 
                                   histogramtitle="Statistic distribution",
                                   xlab="Statistic value") {
  # Comparing matrices using bootstrap.
  #  train - training data (each row is a single spine in one time moment)
  #  membership.matrix - each column represent clustering.r membership 
  #  gid1/2 - group ids
  #  repetitions - how many bootstrap samples to be drawn
  #  statistic.calculator - a function taking 4 matrices (g1.t0, g1.t1, g2.t0, g2.t1) 
  #                         and returning some measure of difference between them
  #  histogramtitle - what title to put on the histogram of statistics from bootstrap sampling
  
  DistStatCalculator <- function(data, indices){    
    split.ix = round(length(indices)/2)
    
    ids1.t0 = paste(data[indices[1: split.ix]], time.t0, sep=spine.id.field.separator)
    ids1.t1 = paste(data[indices[1: split.ix]], time.t1, sep=spine.id.field.separator)
    
    ids2.t0 = paste(data[indices[split.ix: length(indices)]], time.t0, sep=spine.id.field.separator)
    ids2.t1 = paste(data[indices[split.ix: length(indices)]], time.t1, sep=spine.id.field.separator)
    
    g1.t0 = membership.matrix[ids1.t0, ]
    g1.t1 = membership.matrix[ids1.t1, ]
    
    g2.t0 = membership.matrix[ids2.t0, ]
    g2.t1 = membership.matrix[ids2.t1, ]
    
    statistic.value = statistic.calculator(g1.t0, g1.t1, g2.t0, g2.t1)      
    return (statistic.value)
  }
  
  bootobj = boot(data=train[,spine.id], 
                 statistic=DistStatCalculator,  
                 R=repetitions)
  
  group1.rows = train[,group.id]==gid1
  group2.rows = train[,group.id]==gid2
  time0.rows = train[,time.id]==time.t0
  time1.rows = train[,time.id]==time.t1
  g1.t0 = membership.matrix[group1.rows & time0.rows, ]
  g2.t0 = membership.matrix[group2.rows & time0.rows, ]
  g1.t1 = membership.matrix[group1.rows & time1.rows, ]
  g2.t1 = membership.matrix[group2.rows & time1.rows, ]
  
  statistic.value = statistic.calculator(g1.t0, g1.t1, g2.t0, g2.t1) 
  p.value = sum(abs(bootobj$t) >= abs(statistic.value))/length(bootobj$t)
  
  #draw a histogram of bootstrap statistics:
  #hist(bootobj$t, breaks=100, main=histogramtitle, 
  #     xlab="Statistic value", xlim=c(0, max(bootobj$t, statistic.value)))
  p = density(bootobj$t)
  plot(p, main=histogramtitle,  xlab=xlab, xlim=c(0, max(bootobj$t, statistic.value)))
  #polygon(p, col="black", border="black")
  abline(v = statistic.value, col = "blue", lwd = 2)
  #adjustement = ifelse(statistic.value < max(p$x)*0.5, c(1, 1), c(0, 1)) 
  #text(x=statistic.value, y=max(p$y), col="blue", adj=adjustement,
  #     labels=paste("\n statistic =",round(statistic.value,4),"\n p-value =", round(p.value,4), ""))
  text(x=(max(p$x)+min(p$x))*0.5, y=max(p$y), col="blue", 
       labels=paste("\n statistic =",round(statistic.value,4),"\n p-value =", round(p.value,4), ""))
  
  return (p.value)
}

