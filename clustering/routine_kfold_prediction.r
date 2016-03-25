# Calculates prediction error on training set using k-fold crossvalidation.
# 
# author: tomasz.kusmierczyk(at)gmail.com

source(file="predictions.r")
source(file="clustering.r")


print("K-FOLD CROSSVALIDATION FOR PREDICTION ERROR")
print(paste(" k.fold =", k.fold))
print(paste(" k =", k))
print(paste(" m =", m))

# Save full data set results:
original.train = train
original.train.features = train.features
original.test = test
original.test.features = test.features

if (exists("membership.matrix")) {
  original.membership.matrix = membership.matrix 
  original.clustering.assignment = clustering.assignment
  original.test.membership.matrix = test.membership.matrix
  original.test.clustering.assignment = test.clustering.assignment  
} 


# k-fold evaluation of prediction power on train set:
spines.ids = unique( original.train[ , spine.id] )
N = length(spines.ids)
borders = c(seq(from=1, to=N, by=ceil(N/k.fold)), N)
error.matrix = c()
for (border.ix in 1:k.fold) {
  start.ix = borders[border.ix]
  end.ix = borders[border.ix+1]
  print(paste("Considering k.fold crossvalidation on training set: border.ix =",
              border.ix," startix =",start.ix," end.ix =",end.ix))
  
  # Selection of training and testing subset:
  test.spines.ids.subset = spines.ids[start.ix: end.ix]
  train.spines.ids.subset = spines.ids[!(spines.ids %in% test.spines.ids.subset)]
  
  test.ixs = original.train[ , spine.id] %in% test.spines.ids.subset
  train.ixs = original.train[ , spine.id] %in% train.spines.ids.subset

  train = original.train[train.ixs, ]
  train.features = original.train.features[train.ixs, ]
  test = original.train[test.ixs, ]
  test.features =  original.train.features[test.ixs, ]
  
  # Clustering and prediction:
  source(file="routine_clustering.r")
  transition.matrix = TransitionMatrixCalculator(train, membership.matrix)  
  err = TranstionErrorsRoutine(transition.matrix, test, test.membership.matrix, PredictionErrorEstimator)
  error.matrix = rbind(error.matrix, err)
}

err.means = colMeans(error.matrix)
err.sds = apply(error.matrix, 2, sd)
print(paste("prediction / majority / notrans / rand"))
print(paste("Means:", paste(err.means, collapse=" ")))
print(paste("Sds:", paste(err.sds, collapse=" ")))

# Returned outside value of index (error)
index.value = err.means[1] #prediction error
index.sd = err.sds[1] #prediction error sd

# Restore original data:
train = original.train
train.features = original.train.features
test = original.test
test.features = original.test.features

if (exists("original.membership.matrix")) {
  membership.matrix = original.membership.matrix 
  clustering.assignment = original.clustering.assignment
  test.membership.matrix = original.test.membership.matrix
  test.clustering.assignment = original.test.clustering.assignment
}

