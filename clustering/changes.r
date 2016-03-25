# Relative changes of features calculation.
#
# author: tomasz.kusmierczyk(at)gmail.com

library(boot)

CalcChanges = function(x, time0.features.names, time1.features.names) {
  # Returns:
  #   new version of x data with columns time0.features.names replaced with relative changes.
  y = c()
  for (i in 1:length(time0.features.names)) {
    t0.feature = time0.features.names[i]
    t1.feature = time1.features.names[i]
    col  = (x[,t1.feature]-x[,t0.feature]) / x[,t0.feature]
    y = cbind(y, col)
  }
  colnames(y) = time0.features.names
  
  return(y)
}


ChangesDataPreparation = function(data.path, group.id, groups.ids, 
                           features.names.t0, features.names.t1, features.names.nice,
                           additional.features.names) {
  source(file="loading.r")
  
  x = ReadInputFile(data.path)
  x = KeepSubsetAccordingToColumnValue(x, group.id, groups.ids)
  y = CalcChanges(x, features.names.t0, features.names.t1)
  y = ChangeColumnNames(y, features.names.t0, features.names.nice)
  
  data = cbind(y, x[ , additional.features.names])
  library(functional)
  data = data[apply(y, 1, Compose(is.finite, all)),]
    
  print(paste("Summary for:", data.path))
  description.str = paste('N=',dim(data)[1],',D=',pca.num.features,",#",
                          groups.ids[1],'=',sum(data[,group.id]==groups.ids[1]),',#',
                          groups.ids[2],'=',sum(data[,group.id]==groups.ids[2]), sep='')
  print(description.str)
  print("summary(data):")
  print(summary(data))
    
  return (data)
}


MembershipDiffStatistic = function(membership.matrix1, membership.matrix2) {
  return (sum( (colSums(membership.matrix1)-colSums(membership.matrix2))^2 ))
}


CompareChangesMatrices = function(train, membership.matrix, 
                                  gid1, gid2,
                                  repetitions,                                     
                                  statistic.calculator = MembershipDiffStatistic, 
                                  histogramtitle="Statistic distribution",
                                  xlab="Statistic value") {
  # Comparing membership matrices of changes using bootstrap.
  #
  # Args:
  #  train - training data (each row is a single spine in one time moment)
  #  membership.matrix - each column represent clustering.r membership 
  #  gid1/2 - group ids
  #  repetitions - how many bootstrap samples to be drawn
  #  statistic.calculator - a function taking 2 matrices and returning some measure of difference between them
  #  histogramtitle - what title to put on the histogram of statistics from bootstrap sampling
    
  StatCalculator <- function(data, indices){    
    split.ix = round(length(indices)/2)
    membership.matrix1 = data[indices[1: split.ix], ]
    membership.matrix2 = data[indices[split.ix: length(indices)], ]
    statistic.value = statistic.calculator(membership.matrix1, membership.matrix2)  
    return (statistic.value)
  }
  
  bootobj = boot(data=membership.matrix, 
                 statistic=StatCalculator,  
                 R=repetitions)
  
  membership.matrix1 = membership.matrix[train[ , group.id]==gid1, ]
  membership.matrix2 = membership.matrix[train[ , group.id]==gid2, ]
  statistic.value = statistic.calculator(membership.matrix1, membership.matrix2)    
  p.value = sum(abs(bootobj$t) >= abs(statistic.value))/length(bootobj$t)
  
  #draw a histogram of bootstrap statistics:
  #hist(bootobj$t, breaks=100, main=histogramtitle, 
  #     xlab="Statistic value", xlim=c(0, max(bootobj$t, statistic.value)))
  p = density(bootobj$t)
  plot(p, main=histogramtitle,  xlab=xlab, xlim=c(0, max(bootobj$t, statistic.value)))
  #polygon(p, col="black", border="black")
  adjustement = ifelse(statistic.value < max(p$x)*0.5, c(0, 1), c(1, 1)) 
  text(x=statistic.value, y=max(p$y), col="blue", adj=adjustement,
       labels=paste("\n statistic =",round(statistic.value,4),"\n p-value =", round(p.value,4), ""))
  abline(v = statistic.value, col = "blue", lwd = 2)
  
  return (p.value)
}

