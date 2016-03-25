chisq.transitionmat <- function(P1, P2){
  #P1 <- 1st matrix with counts
  #P2 <- 2nd matrix with counts
  #based on: http://sfb649.wiwi.hu-berlin.de/fedc_homepage/xplore/tutorials/xfghtmlnode32.html
  #the variable names are as in the above source
  #Example usage:
  #P0 = matrix(c(10, 10, 5, 5), ncol=2)
  #P = matrix(c(3, 7, 4, 6), ncol=2)
  #chisq.transitionmat(P0, P)
  
  #joint counts:
  cjk_plus = P1+P2
  
  stat = 0
  for(i in 1:nrow(P1))
  {
    #how many observations starting at state i
    nj_p1 = sum(P1[i, ])
    nj_p2 = sum(P2[i, ])
    
    #the vector of joint probabilities for transitions
    pjk_plus = cjk_plus[i,] / sum(cjk_plus[i,])
    
    subres = 0
    for(j in 1:ncol(P1))
    {
      #statistic for a given starting and ending states
      p1_subres = ((P1[i, j] - nj_p1*pjk_plus[j])**2)/(nj_p1*pjk_plus[j])
      p2_subres = ((P2[i, j] - nj_p2*pjk_plus[j])**2)/(nj_p2*pjk_plus[j])
      subres = subres + p1_subres + p2_subres
    }
    stat = stat + subres
  }
  #
  degrees_of_freedom = nrow(P1)*(ncol(P1)-1)#*1 since only 2 matrices are being compared
  pval = 1-pchisq(stat, degrees_of_freedom)
  return(pval)
}