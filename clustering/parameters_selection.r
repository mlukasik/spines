# Methods that support selection of parameters.
#
# author: tomasz.kusmierczyk(at)gmail.com


RepRow = function(x, n) {
  matrix(rep(x,each=n), nrow=n)
}


RepCol<-function(x, n){
  matrix(rep(x,each=n), ncol=n, byrow=TRUE)
}


ClusterSSE = function(membership.matrix, train.features) {
  k = dim(membership.matrix)[2]
  clusters.nos  = 1:k
  
  sse = c()
  for (cluster.no in clusters.nos) {
    cluster.weights = membership.matrix[ , cluster.no]
    cluster.weights.matrix = RepCol(cluster.weights, dim(train.features)[2])
    mean.element = colSums(cluster.weights.matrix * train.features) / colSums(cluster.weights.matrix)    
    mean.element[is.na(mean.element)] = 0
    mean.matrix = RepRow(mean.element, dim(train.features)[1])
    
    sse.clust = sum( cluster.weights * diag( (train.features-mean.matrix) %*% t((train.features-mean.matrix)) ) )
    sse = rbind(sse, sse.clust)
  }
  rownames(sse) = clusters.nos
  return (sse)
}



FindKneeIx = function(ks, errs) {
  if (length(ks) <= 1) {
    return (1)
  } 
  
  l1 = lm(errs~ks)  
  b = l1$coefficients[1]
  a = l1$coefficients[2]
  
  if (a<0) {
    d = abs( errs-(a*ks+b) ) 
    d[l1$residuals>0] = -Inf
    ix = which.max(d)  # method1
    #ix = which.min(l1$residuals)  # method 2
  } else {
    d = abs( errs-(a*ks+b) ) 
    d[l1$residuals<0] = -Inf
    ix = which.max(d)  # method1  
  }
  return (as.numeric(ix))
}


FindOptimalKM = function(errmatrix.prediction) {
  kix = 1
  mix = 1
  kixprev = -1
  mixprev = -1
  
  for (i in 1:100) {  
    k = ks[kix]
    m = ms[mix]
    print(paste("[FindOptimalKM] k =",k," m =",m, " prediction error =", errmatrix.prediction[mix,kix]))
    
    #kix = FindKneeIx(ks, ifelse(k.inverted, -errmatrix.prediction[mix,], errmatrix.prediction[mix,]))
    #mix = FindKneeIx(ms, ifelse(m.inverted, -errmatrix.prediction[,kix], errmatrix.prediction[,kix]))  
    kix = FindKneeIx(ks, errmatrix.prediction[mix,])      
    mix = FindKneeIx(ms, errmatrix.prediction[,kix])          
       
    if (kix==kixprev && mix==mixprev) {
      break
    }
    kixprev = kix
    mixprev = mix
  }
  return (list(kix=kix, mix=mix, k=k, m=m))
}


FindKneeArg = function(ks, errs) {
  ix = FindKneeIx(ks, errs)
  return (ks[ix])
}


KneePlot = function(ks, errs, sds,
                     xlab="value", ylab="Error", 
                     main="Err vs. vlaue", sub="") {
  if (sub!="") {
    main = paste(main,"\n(",sub,")")
  } 
  
  plot(ks, errs, xlab=xlab, ylab=ylab, ylim=c(0, max(errs)), main=main)
  lines(ks, errs, col="black")
  
  if (!missing(sds)) {
    lines(ks, errs+sds, col="green")
    lines(ks, errs-sds, col="green")
    
    legend("topright", # places a legend at the appropriate place 
           c("mean","mean +/- sd"), # puts text in the legend          
           lty=c(1,1), # gives the legend appropriate symbols (lines)
           lwd=c(2.5,2.5),col=c("black","green")) # gives the legend lines the correct color and width
  }
  
  l1 = lm(errs~ks)  
  abline(l1, col="red", lty="dashed")
  ix = FindKneeIx(ks, errs)
  points(c(ks[ix]), c(errs[ix]), col="red", pch="O", lwd=10)  
  grid()
}
