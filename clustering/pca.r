#PCA Analysis functions.
#
# author: tomasz.kusmierczyk(at)gmail.com

PCA = function(data, features.names) {
  features = data[,features.names]
  pc = princomp(features)  
  return(pc)
}


PCAPredict = function(data, pc, num.features=2) {
  pcfeatures = predict(pc, data)
  pcfeatures = pcfeatures[,1:num.features]
  return(pcfeatures)
}


PCAPredictMany = function(x, pcs, pca.num.features=2) {
  pca.num.features = pca.num.features/length(pcs)
  features = c() # new representation
  for (pc in pcs) {
    features = cbind(features, PCAPredict(x, pc, num.features = pca.num.features))
  }
  colnames(features) = colnames(features, do.NULL = F, prefix = "Comp.")
  return(features)
}


PCAnalysis = function(x, features.names, num.features=2) {
  pc = PCA(x, features.names)
  pcfeatures = PCAPredict(x, pc, num.features)
  return(pcfeatures)
}


PCAAnalysisRoutine = function(x, features.names, pca.feature.groups, output.dir) {
  
  # PCA on whole data
  print("PCA on all features")
  pc = PCA(x, features.names)
  total.variance = sum(pc$sdev^2)
  
  # dumping to output
  PCALoadingsPlot(pc, paste('PCA loadings\n(',description.str,')',sep=''))
  StorePlot( paste(output.dir,'/pca_loadings',sep='') )
  PCAVariancePlot(pc, paste('PCA variance explained\n(',description.str,')',sep=''))
  StorePlot( paste(output.dir,'/pca_variance',sep='') )
  print(pc$loadings)
  print(summary(pc))
  
  #PCA on groups
  pcs = list()
  for (features.group in pca.feature.groups) {
    features.str = do.call(paste, c(as.list(features.group), sep=","))
    print("##############################")
    print(paste("PCA on features:", features.str))
    
    # PCA representation.
    pc = PCA(x, features.group)
    variance.explained = pc$sdev^2/total.variance
    print(list(sdev=pc$sdev, variance=variance.explained, cumulative=cumsum(variance.explained)))
    
    # dumping to output
    PCALoadingsPlot(pc, paste('PCA loadings\n',features.str,sep=''))
    StorePlot( paste(output.dir,'/pca_loadings_',features.str,sep='') )
    PCAVariancePlot(pc, paste('PCA variance explained\n',features.str,sep=''), total.variance)
    StorePlot( paste(output.dir,'/pca_variance_',features.str,sep='') )
    print(pc$loadings)
    print( summary(pc) )

    pcs[[length(pcs)+1]] = pc
  }

  return (pcs)
}

