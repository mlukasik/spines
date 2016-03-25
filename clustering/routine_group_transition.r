# Calculates transition matrices for selected groupd (gid).

print(paste("CALCULATING TRANSITION MATRICES FOR GROUP =", gid))

selected.rows   = (train[, group.id] == gid)
train.subset    = train[selected.rows, ]
membership.matrix.subset = membership.matrix[selected.rows, ]

selected.rows = (test[, group.id] == gid)
if (sum(selected.rows) <= 0) {
  print(paste("ERROR: groupd",gid,"is not represented in test data!"))
  break;
}
test.subset = test[selected.rows, ]
test.membership.matrix.subset = test.membership.matrix[selected.rows, ]

trans = ComputeTransitions(train.subset, membership.matrix.subset, 
                           TransitionMatrixCalculator, num.repetitions, bootstrap.fraction)
StoreTransitionMatricesPlots(trans, threshold.counts, threshold.percents, 
                             paste(output.dir,"/group_",gid,"_data_",sep=""), 
                             paste("Shape transitions (group =",gid,")"), layout.no=0)  
TranstionErrorsRoutine(trans$matrix, test.subset, test.membership.matrix.subset, PredictionErrorEstimator)  
