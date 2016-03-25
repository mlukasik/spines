# Drawing and plotting transition graphs.
#
# author: tomasz.kusmierczyk(at)gmail.com
#
# igraph library is required.


#install.packages("scatterplot3d", dependencies = TRUE)
#library(scatterplot3d)

#install.packages("rgl", dependencies = TRUE)
#library(rgl)


source(file="loading.r")
library(igraph)


TextBoxes = function(xs, ys, labels, transparent=c(), scale=1.4) {
  for (i in 1:length(xs)) {
    tx = xs[i]; ty = ys[i]; txt = labels[i]  
    rwidth  = strwidth(txt, cex=scale)
    rheight = strheight(txt, cex=scale)  
    if (is.na(transparent[i]) | !transparent[i]) {
      rect(tx-1.0*rwidth, ty-1.0*rheight, tx+1.6*rwidth, ty+1.7*rheight, col="white")
    } else {
      rect(tx-1.0*rwidth, ty-1.0*rheight, tx+1.6*rwidth, ty+1.7*rheight)
    }
    text(tx, ty, txt, col="black", cex=scale)      
  }
}

pch_dot = function(features) {
  # Method that can be used for pch_method in ClusteringPlot (always prints dot).  
  return (".") 
}

pch_circle = function(features) {
  # Method that can be used for pch_method in ClusteringPlot (always prints circle).  
  return ("o") 
}

ClusteringPlot = function(features, clustering.assignment, 
                          title="Data clustering", pch_method=pch_circle) {
  par(mar=c(4.5, 5.5, 4, 4))
  plot(features, pch=pch_method(features), col=clustering.assignment, main=title, 
        cex=0.7, cex.lab=1.25)
  stats = AnalyseClusters(clustering.assignment, features, colnames(features)[1:2]) 
  TextBoxes(stats$features.means[,1], stats$features.means[,2], 
            stats$clusters.nos, transparent=stats$sizes<=2, scale=1.2)
}




ConvertToLevels = function(values, num.levels=100) {
  levels = num.levels-round(num.levels*values / max(values))
  return (levels)
}

RandColorsVector = function(colors, len) {
  #return ( sample(colors, len, replace=T) )
  return (rep(colors, 1000)[1:len])
}


PlotTransitionMatrices <- function(t, threshold, v, labels, main.title="Transitions", layout.no=0, root.node=-1) {
  # Plots visualisation of transition matrices. 
  # Run several times to rearrange plot.
  #
  # Args:
  #  t: squared matrix of transions (in rows source nodes, in columns destination nodes)
  #  threshold: only edges equal or greater than threshold will be plotted
  #  v: optional matrix of edges' precision (optional)
  #  labels: nodes' labes (optional)
  
  nodes.size = rowSums(t)   
  g = graph.adjacency( t > threshold )  
  
  V(g)$color = paste("gray",  ConvertToLevels(nodes.size, num.levels=50)+40, sep="")
  V(g)$size  = 10+sqrt(100-ConvertToLevels(nodes.size, num.levels=100))
  if (!missing(labels)) {
    V(g)$label = rownames(t)
  }
  if (!missing(v)) {
    E(g)$label = paste(round(t[get.edges(g, E(g))], digits=2), "+/-",
                       round(v[get.edges(g, E(g))], digits=2))
  } else {
    E(g)$label = round(t[get.edges(g, E(g))], digits=2)
  }
  
  if (layout.no==2) {
    selected.layout = layout.drl(g)
  } else if (layout.no==1) {
    selected.layout = layout.spring(g, root=root.node, niter=10000)
  } else {    
    selected.layout = layout.circle
    #layout.fruchterman.reingold(g, niter=10000, area=100*vcount(g)^2, root=root.node)    
  }
  
  V(g)$label.cex = 1.75
  E(g)$label.cex = 1.25
  E(g)$label.color = RandColorsVector(c("blue", "red", "darkgreen", "black") ,length(E(g)))
  plot(g, layout=selected.layout,
       vertex.label.family="Palatino",
       edge.label.family="Palatino", 
       edge.color="black", edge.label=E(g)$label,
       vertex.label.color="white",
       #edge.label.color="red",
       vertex.color=V(g)$color, vertex.size=V(g)$size)
  title(main.title)
}


Shortnames = function(names) {
  shorts = c()
  for (fields in  strsplit(names, "_")) {
    short = do.call(paste, c(as.list(substr(fields, 1,1)), sep=""))
    shorts = c(shorts, short)
  }
  return (shorts)
}


PCALoadingsPlot = function(pc, title="PCA Loadings") {  
  plot(pc$loadings, main=title)
  #pos=sample.int(4, dim(pc$loadings)[1], replace=T)
  text(pc$loadings, labels=rownames(pc$loadings), cex=0.75, col="red", pos=4)
  grid()  
}


PCAVariancePlot = function(pc, title="PCA variance explained", total.variance) {
  if (missing(total.variance)) {
    variance = c(0, pc$sdev^2 / sum(pc$sdev^2))
  } else {
    variance = c(0, pc$sdev^2 / total.variance)
  }
  numcomps = 0:dim(pc$loadings)[1]
  total = cumsum(variance)
  plot(numcomps, total, type='l', xlab='Number of components included', ylab='Variance explained', main=title, ylim=c(0,1.0))
  points(numcomps, total)
  grid()  
}


###############################################################################


StorePlot = function(path, dpi=90, w=480, h=480) {
  #dev.copy(svg, filename=paste(path, ".svg", sep=""))
  dev.copy(png, filename=paste(path, ".png", sep=""), width=w, height=h, res=dpi)  
  dev.off()
}


StoreTransitionMatricesPlots = function(transitions, threshold.counts, 
                                        threshold.percents, path.prefix, 
                                        title="Transitions", layout.no=0,
                                        num.repetitions=1) {
  
  print("[ComputeTransitions] transitions.matrix=")
  print(transitions$matrix)
  print("[ComputeTransitions] transitions.SE=")
  print(transitions$SE)
  print("[ComputeTransitions] transitions.matrix.percents=")
  print(transitions$matrix.percents)
  print("[ComputeTransitions] transitions.SE.percents=")
  print(transitions$SE.percents)
  
  #old format:
  write.table(round(transitions$matrix, digits=2), 
              file=paste(path.prefix, "trans_matrix.txt", sep=""), 
              sep="\t&\t", eol="\\\\\n")
  write.table(round(transitions$SE, digits=2), 
              file=paste(path.prefix, "trans_se.txt", sep=""), 
              sep="\t&\t", eol="\\\\\n")
  write.table(round(transitions$matrix.percents, digits=2), 
              file=paste(path.prefix, "trans_matrix_percents.txt", sep=""), 
              sep="\t&\t", eol="\\\\\n")
  write.table(round(transitions$SE.percents, digits=2), 
              file=paste(path.prefix, "trans_se_percents.txt", sep=""), 
              sep="\t&\t", eol="\\\\\n")
  
  #new format:
  d = dim(transitions$matrix.percents)[1]
  m = paste(round(100*transitions$matrix.percents), " (",round(100*transitions$SE.percents),")", sep="")
  m = matrix(m, nrow=d)
  write.table(m, 
              file=paste(path.prefix, "trans_matrix_percents_full.txt", sep=""), 
              sep="\t&\t", eol="\\\\\n")
  
  d = dim(transitions$matrix)[1]
  m = paste(round(transitions$matrix,1), " (",round(transitions$SE,1),")", sep="")
  m = matrix(m, nrow=d)
  write.table(m, 
              file=paste(path.prefix, "trans_matrix_full.txt", sep=""), 
              sep="\t&\t", eol="\\\\\n")

  
  # plotting params:
  dpi = 90
  w = 900
  h = 700
  
  for (i in 1:num.repetitions) {
    # plotting counts:
    PlotTransitionMatrices(round(transitions$matrix,1), threshold.counts, round(transitions$SE,1), 
                           main.title=paste(title,"[for weights >",threshold.counts,"]"), 
                           root.node=1+(i %% dim(transitions$matrix)[1]), 
                           layout.no=layout.no)
    legend(-2.0, 1.25, title="weights", cex=1.3, text.col="black",  bg="transparent", bty="n",
           c(paste("C",1:dim(transitions$matrix)[1],": ",round(rowSums(transitions$matrix), 1),sep="")))
    StorePlot( paste(path.prefix,'_',i,sep=''), dpi, w, h)
    
    # plotting percents:
    PlotTransitionMatrices(round(transitions$matrix.percents*100), 
                           threshold.percents, 
                           round(transitions$SE.percents*100), 
                           main.title=paste(title,"[for percents >",threshold.percents,"]"), 
                           root.node=1+(i %% dim(transitions$matrix)[1]), 
                           layout.no=layout.no) 
    legend(-2.0, 1.25, title="weights", cex=1.3, text.col="black", bg="transparent", bty="n",
           c(paste("C",1:dim(transitions$matrix)[1],": ",round(rowSums(transitions$matrix), 1),sep="")))
    StorePlot( paste(path.prefix,'_percents_',i,sep=''), dpi, w, h)    
  }
}
