# Spines' transitions (in time) between shape clustering.

source(file="loading.r")
source(file="clustering.r")

library(pracma)


ExtractMembershipMatrixTx = function(x, membership.matrix, time.tx) {
  # Returns membership matrix for time moment of time.tx. 
  spine.ids = unique(x[ , spine.id])
  membership.matrix.tx = c()
  for (id in spine.ids) {
    membership.matrix.tx = rbind(membership.matrix.tx, 
                                 membership.matrix[paste(id, time.tx, sep=spine.id.field.separator), ])
  }
  rownames(membership.matrix.tx) = spine.ids
  return (membership.matrix.tx)
}


StoreMembershipMatrixTx = function(membership.matrix.tx, path) {
  write.table(membership.matrix.tx, file=path, row.names=F, col.names=F) 
}
# A = ExtractMembershipMatrixTx(train, membership.matrix, time.t0)
# B = ExtractMembershipMatrixTx(train, membership.matrix, time.t1)
# StoreMembershipMatrixTx(A,"/tmp/A")
# StoreMembershipMatrixTx(B,"/tmp/B")


##################################################################################
##################################################################################
##################################################################################
# Transition matrices computation:

BuildTransitionMatrixLeastSquares = function(x, membership.matrix) {
  # Solves A*P=B where P=transition matrix
  # see http://www.mathworks.se/help/matlab/ref/mldivide.html
  # see http://www.inside-r.org/packages/cran/pracma/docs/mldivide
  A = ExtractMembershipMatrixTx(x, membership.matrix, time.t0)
  B = ExtractMembershipMatrixTx(x, membership.matrix, time.t1)
  P = mldivide(A,B)  
  
  stopifnot(rowSums(P) - 1 < 0.000000001) #make sure that P sums up to ones (CAN BE NEGATIVE)
  
  transition.matrix = colSums(A)*P #convert probabilities into counts
  return (transition.matrix)
}


BuildNonnegativeTransitionMatrixLeastSquares = function(x, membership.matrix) {
  # Solves A*P=B where P=NONEGATIVE transition matrix 
  # see http://www.mathworks.se/help/matlab/ref/lsqnonneg.html
  # see http://www.inside-r.org/node/171155
  A = ExtractMembershipMatrixTx(x, membership.matrix, time.t0)
  B = ExtractMembershipMatrixTx(x, membership.matrix, time.t1)
  k = dim(membership.matrix)[2]
  
  P = c()
  for (c in 1:k) {
    P = cbind(P, lsqnonneg(A,B[,c])$x )
  }
  
  P = P / rowSums(P)
  #stopifnot(rowSums(P) - 1 < 0.000000001) #make sure that P sums up to ones
  
  transition.matrix = colSums(A)*P #convert probabilities into counts
  return (transition.matrix)
}


BuildTransitionMatrix = function(x, membership.matrix) {  
  clustering.assignment = MembershipMatrixToAssignment(membership.matrix)
  clustering.assignment = as.matrix(clustering.assignment)
  #k = max(clustering.assignment)
  k = dim(membership.matrix)[2]
  transitions = matrix(0, k, k)
  spine.ids = unique(x[ , spine.id])
  
  for (id in spine.ids) {
    t0.clust  = clustering.assignment[paste(id, time.t0, sep=spine.id.field.separator), ]
    t1.clust  = clustering.assignment[paste(id, time.t1, sep=spine.id.field.separator), ]
    
    transitions[t0.clust, t1.clust]   = transitions[t0.clust, t1.clust] + 1
  }
  
  rownames(transitions) = 1:k
  colnames(transitions) = 1:k
  return (transitions)
}


SingleElementTranstion = function(t0.membership, t1.membership) {
  # Calculates transition between clustering for single element 
  # assuming transitions proportional to final distribution.
  
  #normalization (optional as we assume that membership are already normalized)
  t0.membership = t0.membership / sum(t0.membership) 
  t1.membership = t1.membership / sum(t1.membership) 
  
  k = length(t0.membership)
  transitions = matrix(0, k, k)
  for (c0 in 1:k) {
    transitions[c0, ] = t0.membership[c0] * t1.membership
  }
  
  return (transitions)
}


SingleElementTranstionWithIntertion = function(t0.membership, t1.membership) {
  # Calculates transition between clustering for single element 
  # assuming transitions proportional to final distribution
  # but with intertion (we keep as much as it possible in original node).
  
  #normalization (optional as we assume that membership are already normalized)
  t0.membership = t0.membership / sum(t0.membership) 
  t1.membership = t1.membership / sum(t1.membership) 
  
  k = length(t0.membership)
  transitions = matrix(0, k, k)
  kept = pmin(t0.membership, t1.membership)
  diag(transitions) = kept
  t0.membership =  t0.membership - kept
  t1.membership = t1.membership / sum(t1.membership) 
  
  for (c0 in 1:k) {
    transitions[c0, ] = transitions[c0, ] + t0.membership[c0] * t1.membership
  }
  
  return (transitions)
}


BuildTransitionMatrixMM = function(x, membership.matrix, ElementTranstion=SingleElementTranstion) {  
  k = dim(membership.matrix)[2]
  transitions = matrix(0, k, k)
  spine.ids = unique(x[ , spine.id])
  
  for (id in spine.ids) {
    t0.membership  = membership.matrix[paste(id,time.t0, sep=spine.id.field.separator), ]
    t1.membership  = membership.matrix[paste(id,time.t1, sep=spine.id.field.separator), ]    
  
    transitions = transitions + ElementTranstion(t0.membership, t1.membership)
  }
  
  rownames(transitions) = 1:k
  colnames(transitions) = 1:k
  return (transitions)
}


BuildTransitionMatrixMMWitIntertion = function(x, membership.matrix) {
  return( BuildTransitionMatrixMM(x, membership.matrix, 
                                  ElementTranstion=SingleElementTranstionWithIntertion) )
}


BuildTransitionMatrixMMul = function(x, membership.matrix) {  
  k = dim(membership.matrix)[2]
  transitions = matrix(0, k, k)
  spine.ids = unique(x[ , spine.id])
  
  for (id in spine.ids) {
    t0.membership  = membership.matrix[paste(id,time.t0, sep=spine.id.field.separator), ]
    t1.membership  = membership.matrix[paste(id,time.t1, sep=spine.id.field.separator), ]    
    
    transitions = transitions + (as.matrix(t0.membership) %*% t1.membership)
  }
  
  rownames(transitions) = 1:k
  colnames(transitions) = 1:k
  return (transitions)
}


RandomTransitionMatrix = function(x, membership.matrix) {  
  k = dim(membership.matrix)[2]
  transitions = matrix(0, k, k)
  n = dim(membership.matrix)[1]/2
  for (i in 1:n) {
    r = sample(1:k, 1)
    c = sample(1:k, 1)
    transitions[r, c] = transitions[r, c] + 1 
  }
  return (transitions)
}


##################################################################################
##################################################################################
##################################################################################


ScaleByRowSum = function(matrix) {
  matrix = matrix / rowSums(matrix)
  matrix[is.nan(matrix)] = 0
  return(matrix)
}


BootstrapTransitionMatrixSE = function(x, membership.matrix, 
                                       TransitionCalculator = BuildTransitionMatrixMM,
                                       num.repetitions=200, bootstrap.fraction=1.0) {
  spine.ids = unique(x[ , spine.id])
  sample.size = round( bootstrap.fraction*length(spine.ids) )
  
  transitions       = TransitionCalculator(x, membership.matrix)
  transitions.sum   = 0*transitions[,] #empty matrix
  for (i in 1:num.repetitions) {      
    selected.ids        = sample(spine.ids, sample.size, replace=T)
    sample              = KeepSubsetAccordingToColumnValue(x, spine.id, selected.ids)
    transitions.sample  = TransitionCalculator(sample, membership.matrix)    
    transitions.sum     =  transitions.sum + (transitions.sample-transitions)^2
  }  
  transitions.SE    = sqrt(transitions.sum/num.repetitions)
  return (transitions.SE)
}


ComputeTransitions = function(x, membership.matrix, TransitionCalculator = BuildTransitionMatrixMM,
                              num.repetitions=200, bootstrap.fraction=1.0, output=F) {
  transitions.matrix = TransitionCalculator(x, membership.matrix)
  transitions.SE = BootstrapTransitionMatrixSE(x, membership.matrix, TransitionCalculator,
                                               num.repetitions, bootstrap.fraction)
  transitions.matrix.percents = ScaleByRowSum(transitions.matrix)
  transitions.SE.percents = transitions.SE/rowSums(transitions.matrix)
  
  transitions.matrix[is.nan(transitions.matrix)] = 0
  transitions.SE[is.nan(transitions.SE)] = 0
  transitions.matrix.percents[is.nan(transitions.matrix.percents)] = 0
  transitions.SE.percents[is.nan(transitions.SE.percents)] = 0
  
  if (output) {
    print("[ComputeTransitions] transitions.matrix=")
    print(transitions.matrix)
    print("[ComputeTransitions] transitions.SE=")
    print(transitions.SE)
    print("[ComputeTransitions] transitions.matrix.percents=")
    print(transitions.matrix.percents)
    print("[ComputeTransitions] transitions.SE.percents=")
    print(transitions.SE.percents)
  }
  
  result = list(matrix=transitions.matrix,  
                SE=transitions.SE, 
                matrix.percents=transitions.matrix.percents, 
                SE.percents=transitions.SE.percents)
  return (result)
}


##################################################################################


TransitionsErrorAvgPercentSE = function(trans) {
  return ( mean(trans$SE.percents) )
}


TransitionsErrorAvgSE = function(trans) {
  return ( mean(trans$SE) )
}

##################################################################################
##################################################################################
##################################################################################
##################################################################################
# Legacy code:

build.transition.matrices = function(sel.ids, clustering.assignment, k) {  
  t0.t10.transitions = matrix(0, k, k)
  t0.t40.transitions = matrix(0, k, k)
  t10.t40.transitions = matrix(0, k, k)  
  for (id in sel.ids) {
    t0.clust  = clustering.assignment[paste(id,"t0",sep="")]
    t10.clust = clustering.assignment[paste(id,"t10",sep="")]
    t40.clust = clustering.assignment[paste(id,"t40",sep="")]
    
    t0.t10.transitions[t0.clust, t10.clust]   = t0.t10.transitions[t0.clust, t10.clust] + 1
    t0.t40.transitions[t0.clust, t40.clust]   = t0.t40.transitions[t0.clust, t40.clust] + 1
    t10.t40.transitions[t10.clust, t40.clust] = t10.t40.transitions[t10.clust, t40.clust] + 1
  }
  
  return( list(t0t10=t0.t10.transitions, t0t40=t0.t40.transitions, t10t40=t10.t40.transitions) )
}

transitions = function(paths.sel, groups.ids.sel, clustering.assignment) {
  k = max(clustering.assignment)  
  x.sel = ReadMany(paths.sel, groups.ids.sel) 
  sel.ids = x.sel[,uid] 
  return( build.transition.matrices(sel.ids, clustering.assignment, k) )
}

transitions.bootstrap = function(paths.sel, groups.ids.sel, clustering.assignment, bootstrap.fraction=1.0) {
  k = max(clustering.assignment)  
  x.sel = ReadMany(paths.sel, groups.ids.sel) 
  sel.ids = x.sel[,uid]
  
  subsample.size = round( bootstrap.fraction*length(sel.ids) )
  selected.indexes = sample(1:length(sel.ids), subsample.size, replace=T)
  sel.ids = sel.ids[selected.indexes]
  
  return( build.transition.matrices(sel.ids, clustering.assignment, k) )  
}

########################################################################

normalize.by.rowsum = function(matrix) {
  matrix = matrix / rowSums(matrix)
  matrix[is.nan(matrix)] = 0
  return(matrix)
}

format.trans.matrix = function(matrix, numdigits=0, multiply.by=100) {
  matrix = round(matrix*multiply.by, digits=numdigits)
  maxCol = max( (1:ncol(matrix))[colSums(matrix) > 0] )
  maxRow = max( (1:nrow(matrix))[rowSums(matrix) > 0] )
  return (matrix[1:maxRow, 1:maxCol])
}