# Computes clustering validation index matrix for grid of parameters m x k.
#
# author: tomasz.kusmierczyk(at)gmail.com

print("BUILDING CLUSTERING INDEX MATRIX")
print(paste(" compute.index.value.routine =", compute.index.value.routine))
print(paste(" ks =", paste(ks, collapse=" ")))
print(paste(" ms =", paste(ms, collapse=" ")))

# Compute means and stds for different k and m.
index.matrix = c()
index.matrix.sd = c()
for (m in ms) {
  print(paste("Analysis for m =", m))
  
  index.row = c()  
  index.row.sd = c()  
  for (k in ks) {
    print(paste("Analysis for k =", k))        
    source(file=compute.index.value.routine)
    
    index.row     = c(index.row, index.value)  
    index.row.sd  = c(index.row.sd, index.sd)  
  }
  index.matrix    = rbind(index.matrix, index.row)
  index.matrix.sd = rbind(index.matrix.sd, index.row.sd)
}

# Label columns and rows
rownames(index.matrix) = ms
colnames(index.matrix) = ks
rownames(index.matrix.sd) = ms
colnames(index.matrix.sd) = ks

