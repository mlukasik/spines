# Comparing transition matrices using bootstrap.
#
# author: michal.mateusz.lukasik (at) gmail.com
# stubs: tomasz.kusmierczyk (at) gmail.com

source(file="transitions.r")
library(boot)

SqrRootSumDiff <- function(mat1, mat2){
  sum(rowSums((mat1 - mat2)^2))
}

SqrRootSumDiffVec <- function(vec1, vec2){
  sum((vec1 - vec2)^2)
}

MaxDiff <- function(mat1, mat2){
  max(((mat1 - mat2)^2))
}

CompareTransitionMatricesByRow = function(train, membership.matrix, 
                                     trans.group1, gid1,
                                     trans.group2, gid2,
                                     repetitions,
                                     TransitionCalculator=BuildNonnegativeTransitionMatrixLeastSquares,
                                     statistic=SqrRootSumDiffVec, histogramtitle="Example title", row=1) {
  # Comparing transition matrices by row using bootstrap.
  #
  # Args:
  #  train - training data (each row is a single spine in one time moment)
  #  membership.matrix - each column represent clustering.r membership 
  #  trans.group1/2 - transition matrices for groups
  #  gid1/2 - group ids
  #  repetitions - how many bootstrap samples to be drawn
  #  TransitionCalculator(train, membership.matrix) - returns (weights) transition matrix
  #  statistic - a function taking 2 vectors (rows) and returning some measure of difference between them
  #  histogramtitle - what title to put on the histogram of statistics from bootstrap sampling
  #  row - number of row to compare
  statistic_rows <- function(mat1, mat2){
    statistic(mat1[row,], mat2[row,])
  }
    
  return(CompareTransitionMatrices(train, membership.matrix, 
                                          trans.group1, gid1,
                                          trans.group2, gid2,
                                          repetitions,
                                          TransitionCalculator,
                                          statistic_rows, histogramtitle))
}


CompareTransitionMatrices = function(train, membership.matrix, 
                                     trans.group1, gid1,
                                     trans.group2, gid2,
                                     repetitions,
                                     TransitionCalculator=BuildNonnegativeTransitionMatrixLeastSquares,
                                     statistic = SqrRootSumDiff, 
                                     histogramtitle="Statistic distribution",
                                     xlab = "Statistic") {
  # Comparing transition matrices using bootstrap.
  # 
  # Args:
  #  train - training data (each row is a single spine in one time moment)
  #  membership.matrix - each column represent clustering.r membership 
  #  trans.group1/2 - transition matrices for groups
  #  gid1/2 - group ids
  #  repetitions - how many bootstrap samples to be drawn
  #  TransitionCalculator(train, membership.matrix) - returns (weights) transition matrix
  #  statistic - a function taking 2 matrices and returning some measure of difference between them
  #  histogramtitle - what title to put on the histogram of statistics from bootstrap sampling
  
  # Masks that select proper subgroups (rows) in data (both train and membership.matrix)
  group1.rows.mask  = train[ , group.id]==gid1
  group2.rows.mask  = train[ , group.id]==gid2
  
  #time.t0/t1 defined in loading.r
  time.t0.rows.mask = train[ , time.id]==time.t0
  time.t1.rows.mask = train[ , time.id]==time.t1
  # Ids of spines in data  (equal for two spines: one from time t0 and one from time t1)
  spines.ids        = train[ , spine.id]
  
  
  sampstatistic <- function(data, i, lenx, membership.matrix, train){
    indices.first = i[1:lenx]
    subsample1 = train[train$unique_id %in% data[indices.first], ]
    alltime.rownames = c(paste(data[indices.first],"-t0", sep=""), paste(data[indices.first],"-t1", sep=""))
    membership.matrix.sample.subset1 =  membership.matrix[rownames(membership.matrix) %in% alltime.rownames,]
    transitionsmatrix1 = TransitionCalculator(subsample1, membership.matrix.sample.subset1)
    transitionsmatrix1.percents = ScaleByRowSum(transitionsmatrix1)
    
    indices.second = i[(lenx+1):length(i)]
    subsample2 = train[train$unique_id %in% data[indices.second], ]
    alltime.rownames = c(paste(data[indices.second],"-t0", sep=""), paste(data[indices.second],"-t1", sep=""))
    membership.matrix.sample.subset2 =  membership.matrix[rownames(membership.matrix) %in% alltime.rownames,]
    transitionsmatrix2 = TransitionCalculator(subsample2, membership.matrix.sample.subset2)
    transitionsmatrix2.percents = ScaleByRowSum(transitionsmatrix2)
    
    return(statistic(transitionsmatrix1.percents, transitionsmatrix2.percents))
  }
  
  
  unique_ids = unique(train$unique_id)
  bootobj = boot(data=unique_ids, statistic=sampstatistic,# strata=stratum, 
                 R=repetitions, lenx = length(unique_ids)/2, membership.matrix=membership.matrix, train=train)
  
  #ci = boot.ci(bootobj, type = c("basic"))
  statistic.value = statistic(trans.group1$matrix.percents, trans.group2$matrix.percents)
  p.value = sum(abs(bootobj$t) >= abs(statistic.value))/length(bootobj$t)
  
  #draw a histogram of bootstrap statistics:
  #hist(bootobj$t, main=histogramtitle, xlab="Statistic")
  #abline(v = residual.matrix.sum, col = "blue", lwd = 2)
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

