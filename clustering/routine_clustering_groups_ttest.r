# Comparing two groups in clustering of spines using t.test
#
# author: tomasz.kusmierczyk(at)gmail.com

CompareTTest = function(data1, data2, column.name) {
  p.value = t.test(data1[ , column.name], data2[ , column.name])$p.value
  print(c(column.name, mean(data1[ , column.name]), mean(data2[ , column.name]), p.value)) 
}

CompareGroupsClusters = function(rows.group1, rows.group2) {
  print("Comparing membership matrices")
  for (cluster.no in 1:dim(membership.matrix)[2]) {
    CompareTTest(membership.matrix[rows.group1, ],  membership.matrix[rows.group2, ], cluster.no)
  }
  
  print("Comparing features for crisp clustering")
  for (cluster.no in 1:dim(membership.matrix)[2]) {
    crows = clustering.assignment==cluster.no
    
    print(paste(" cluster =", cluster.no,":"))
    if (sum(rows.group1&crows)<=1) {
      print("Group1 to small")
    } else if (sum(rows.group2&crows)<=1) {
      print("Group2 to small")
    } else {
      for (feature.name in colnames(train.features)) {
        CompareTTest(train.features[rows.group1&crows, ],  train.features[rows.group2&crows, ], feature.name)
      }
      for (feature.name in features.names.nice) {
        CompareTTest(train[rows.group1&crows, ],  train[rows.group2&crows, ], feature.name)
      }
    }
  }
}


print("COMPARING CLUSTERS OF SPINES IN TRAINING DATA FOR TIME=T0 USING T-TEST")

rows.group1 = train[,group.id]==groups.ids[1] & train[,time.id]==time.t0
rows.group2 = train[,group.id]==groups.ids[2] & train[,time.id]==time.t0
CompareGroupsClusters(rows.group1, rows.group2)

print("COMPARING CLUSTERS OF SPINES IN TRAINING DATA FOR TIME=T1 USING T-TEST")

rows.group1 = train[,group.id]==groups.ids[1] & train[,time.id]==time.t1
rows.group2 = train[,group.id]==groups.ids[2] & train[,time.id]==time.t1
CompareGroupsClusters(rows.group1, rows.group2)
