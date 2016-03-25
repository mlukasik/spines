# Routine that loads and prepares data for global typology generation.

source(file="loading.r")
source(file="pca.r")

print("DATA LOADING AND (PCA) TRANSFORMING")

if (!(exists("test.data.file"))){
  test.data.file = train.data.file
}

# Print parameters
print(paste("train.data.file =", train.data.file))
print(paste("test.data.file =", test.data.file))
print(paste("groups.ids =", groups.ids))
print(paste("features.names.t0 =", paste(features.names.t0, collapse=" ")))
print(paste("features.names.t1 =", paste(features.names.t1, collapse=" ")))
print(paste("features.names.nice =", paste( features.names.nice, collapse=" ")))
print(paste("pca.feature.groups =", paste(pca.feature.groups, collapse=" ")))
print(paste("pca.num.features =", pca.num.features))
print(paste("normalization =", normalization))

if (exists("images.base.dir")) 
  print(paste("images.base.dir =", images.base.dir))
if (exists("iadditional.features.names")) 
  print(paste("additional.features.names =", paste(additional.features.names, collapse=" ")))
if (exists("iadditional.features.names.t0")) 
  print(paste("additional.features.names.t0 =", paste(additional.features.names.t0, collapse=" ")))
if (exists("iadditional.features.names.t1")) 
  print(paste("additional.features.names.t1 =", paste(additional.features.names.t1, collapse=" ")))


# Loads input data.
train = DataLoadingRoutine(train.data.file, groups.ids, features.names.t0, features.names.t1,
                           features.names.nice, additional.features.names, 
                           additional.features.names.t0, additional.features.names.t1, 
                           spine.id.field.separator)
test = DataLoadingRoutine(test.data.file, groups.ids, features.names.t0, features.names.t1,
                          features.names.nice, additional.features.names, 
                          additional.features.names.t0, additional.features.names.t1, 
                          spine.id.field.separator)

description.str = paste('N=',dim(train)[1],',D=',pca.num.features,",#",
                        groups.ids[1],'=',sum(train[,group.id]==groups.ids[1]),',#',
                        groups.ids[2],'=',sum(train[,group.id]==groups.ids[2]), sep='')
print(description.str)
print("summary(train):")
print(summary(train))
print("summary(test):")
print(summary(test))
# since now all features all called features.names.nice and time is stored in time.id

#######################################################################################
#######################################################################################

source(file="routine_contours.r")

#######################################################################################
#######################################################################################


# Changes representation using PCA 

pcs = PCAAnalysisRoutine(train, features.names.nice, pca.feature.groups, output.dir)
train.features = PCAPredictMany(train, pcs, pca.num.features) 
test.features  = PCAPredictMany(test, pcs, pca.num.features) 

if (normalization) {
  train.features = scale(train.features)
  test.features = scale(test.features)  
}
