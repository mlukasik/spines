# Testing prediction of behavioral models.
#
# author: tomasz.kusmierczyk(at)gmail.com

source(file="transitions.r")
library(class)

########################################################################################
# Predicting:

PredictCMeans = function(centers, x,  m = 2) {
  # Predicts membership for data x for CMeans clustering.
  #
  # See: http://stackoverflow.com/questions/20243460/how-to-predict-clusters-membership-with-cmeans
  
  ## compute distances between samples and clusters centers for default setting
  ## dist="euclidean"; use absolute values for dist="manhattan"
  cc <- centers
  dm <- sapply(seq_len(nrow(x)),
               function(i) apply(cc, 1, function(v) sqrt(sum((x[i, ]-v)^2))))
  
 
  ## compute clusters membership values
  ms <- t(apply(dm, 2,
                function(x) {
                  tmp <- 1/((x/sum(x))^(2/(m-1)))  # formula above
                  tmp/sum(tmp)  # normalization
                }))
  rownames(ms) = rownames(x)
  return (ms)
}


PredictKnn = function(clustering.assignment, train.features, test.features, k=3) {
  test.clustering.assignment = as.matrix( as.numeric( knn(train.features, test.features, as.factor(clustering.assignment), 
      k = k, l = 0, prob = FALSE, use.all = TRUE) ) ) 
  rownames(test.clustering.assignment) = rownames(test.features)
  return (test.clustering.assignment)
}


PredictSingleTransition = function(transition.matrix, t0.membership) {  
  transition.matrix = transition.matrix / rowSums(transition.matrix)
  return (t0.membership %*% transition.matrix)
}


PredictTransitions = function(transition.matrix, t0.membership.matrix) {
  transition.matrix = transition.matrix / rowSums(transition.matrix)
  transition.matrix[ is.nan(transition.matrix) ] = 0
  t1.membership.matrix = t0.membership.matrix %*% transition.matrix
  return (t1.membership.matrix)
}

PredictTransitionsWithMajorityCluster= function(transition.matrix, t0.membership.matrix) {
  # majority clusters prediction
  t1.predicted.matrix = zeros(dim(t0.membership.matrix)[1], dim(t0.membership.matrix)[2])
  majority.clusters = which.max(colSums(transition.matrix))
  t1.predicted.matrix[ ,  majority.clusters] = 1
  return (t1.predicted.matrix)  
}

########################################################################################
########################################################################################
########################################################################################
# Comparing predictions to true values:


TotalError = function(predicted.membership.matrix, correct.membership.matrix) {
  # Sum of squares of residual matrix elements
  #print(paste("Num rows:", dim(correct.membership.matrix)[1]))
  return ( sum(rowSums( (predicted.membership.matrix-correct.membership.matrix)^2 )) )
}


AvgElementError = function(predicted.membership.matrix, correct.membership.matrix) {
  # Sum of squares of residual matrix elements / number of rows
  #print(paste("Num rows:", dim(correct.membership.matrix)[1]))
  return ( sum(rowSums( (predicted.membership.matrix-correct.membership.matrix)^2 )) / dim(correct.membership.matrix)[1] )
}


########################################################################################
# Aux submatrices retrieval:

RetrieveT0Data = function(test.membership.matrix, time.vector) {
  t0.membership.matrix = test.membership.matrix[time.vector==time.t0, ]
  t0.ixs = sort.int(rownames(t0.membership.matrix), index.return=T)$ix
  t0.membership.matrix = t0.membership.matrix[t0.ixs, ]
  return (t0.membership.matrix)
}


RetrieveT1Data = function(test.membership.matrix, time.vector) {
  t1.membership.matrix = test.membership.matrix[time.vector==time.t1, ]
  t1.ixs = sort.int(rownames(t1.membership.matrix), index.return=T)$ix
  t1.membership.matrix = t1.membership.matrix[t1.ixs, ]
  return (t1.membership.matrix)
}


########################################################################################
# Errors estimation based on different prediction models:

TestDataTransitionError = function(transition.matrix, test.membership.matrix, time.vector, 
                                   ErrorCalculator = AvgElementError) {
  # time.vector = test[,time.id]
  t0.membership.matrix = RetrieveT0Data(test.membership.matrix, time.vector)
  t1.membership.matrix = RetrieveT1Data(test.membership.matrix, time.vector)
  
  t1.predicted.matrix = PredictTransitions(transition.matrix, t0.membership.matrix)
  return ( ErrorCalculator(t1.predicted.matrix, t1.membership.matrix) )
}

TestDataNoTransitionError = function(test.membership.matrix, time.vector, 
                                   ErrorCalculator = AvgElementError) {
  # time.vector = test[,time.id]
  t0.membership.matrix = RetrieveT0Data(test.membership.matrix, time.vector)
  t1.membership.matrix = RetrieveT1Data(test.membership.matrix, time.vector)
  
  t1.predicted.matrix = t0.membership.matrix
  return ( ErrorCalculator(t1.predicted.matrix, t1.membership.matrix) )
}


TestMajorityClusterTransitionError = function(transition.matrix, 
                                              test.membership.matrix, time.vector, 
                                              ErrorCalculator = AvgElementError) {
  # time.vector = test[,time.id]
  t0.membership.matrix = RetrieveT0Data(test.membership.matrix, time.vector)
  t1.membership.matrix = RetrieveT1Data(test.membership.matrix, time.vector)

  t1.predicted.matrix = PredictTransitionsWithMajorityCluster(transition.matrix, t0.membership.matrix)  
  return ( ErrorCalculator(t1.predicted.matrix, t1.membership.matrix) )
}


TranstionErrorsRoutine = function(transition.matrix, test, test.membership.matrix, ErrorCalculator) {
  element.err = TestDataTransitionError(transition.matrix, test.membership.matrix, 
                                        test[,time.id], ErrorCalculator)
  print(paste("Element behaviour prediction error:", element.err))
  
  major.element.err = TestMajorityClusterTransitionError(transition.matrix, test.membership.matrix, 
                                                         test[,time.id], ErrorCalculator)
  print(paste("Element behaviour majority clusters prediction error:", major.element.err))
  
  no.transition.err = TestDataNoTransitionError(test.membership.matrix, test[,time.id], ErrorCalculator)
  print(paste("Element behaviour error assuming no transitions:", no.transition.err))
  
  rand.transition.err = TestDataTransitionError(RandomTransitionMatrix(test, test.membership.matrix), 
                                                test.membership.matrix, test[,time.id], ErrorCalculator)
  print(paste("Element behaviour error assuming random transitions:", rand.transition.err))
  
  return (c(element.err, major.element.err, no.transition.err, rand.transition.err))
}

