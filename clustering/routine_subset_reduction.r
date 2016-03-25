# Selecting subset of samples according to ids taken from selected balanced.ids.file.
#
# author: tomasz.kusmierczyk(at)gmail.com

if (!is.nan(balanced.ids.file)) {
  print("TRAIN SET IS REDUCED TO SELECTED SUBSET")
  print(paste("balanced.ids.file =", balanced.ids.file))
  
  # save results (original data)
  original.train = train
  original.features = train.features
  original.membership.matrix = membership.matrix
  original.clustering.assignment = clustering.assignment

  #extract subset rows
  selected.ids = ReadInputFile(balanced.ids.file)[ , spine.id]
  selected.rows = ElementsMatchingColumnValue(train, spine.id, selected.ids)

  #select subset
  train = train[selected.rows, ]
  train.features = train.features[selected.rows, ]
  membership.matrix = membership.matrix[selected.rows, ]
  clustering.assignment = clustering.assignment[selected.rows, ] 
  
  #report subset
  description.str = paste('N=',dim(train)[1],',D=',pca.num.features,",#",
                          groups.ids[1],'=',sum(train[,group.id]==groups.ids[1]),',#',
                          groups.ids[2],'=',sum(train[,group.id]==groups.ids[2]), sep='')
  print(description.str)
  print("summary(train):")
  print(summary(train))
} 

# revert to original data:
#train = original.train
#features = original.features
#membership.matrix = original.membership.matrix
#clustering.assignment = original.clustering.assignment
