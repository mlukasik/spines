# Comparing two groups of spines using t.test

CompareTTest = function(data1, data2, column.name) {
  p.value = t.test(data1[ , column.name], data2[ , column.name])$p.value
  print(c(column.name, mean(data1[ , column.name]), mean(data2[ , column.name]), p.value)) 
}

print("COMPARING GROUPS OF SPINES IN TRAINING DATA FOR TIME=T0 USING T-TEST")

rows.group1 = train[,group.id]==groups.ids[1] & train[,time.id]==time.t0
rows.group2 = train[,group.id]==groups.ids[2] & train[,time.id]==time.t0

for (feature.name in colnames(train.features)) {
  CompareTTest(train.features[rows.group1, ],  train.features[rows.group2, ], feature.name)
}
for (feature.name in features.names.nice) {
  CompareTTest(train[rows.group1, ],  train[rows.group2, ], feature.name)
}

print("COMPARING GROUPS OF SPINES IN TRAINING DATA FOR TIME=T1 USING T-TEST")

rows.group1 = train[,group.id]==groups.ids[1] & train[,time.id]==time.t1
rows.group2 = train[,group.id]==groups.ids[2] & train[,time.id]==time.t1

for (feature.name in colnames(train.features)) {
  CompareTTest(train.features[rows.group1, ],  train.features[rows.group2, ], feature.name)
}
for (feature.name in features.names.nice) {
  CompareTTest(train[rows.group1, ],  train[rows.group2, ], feature.name)
}
