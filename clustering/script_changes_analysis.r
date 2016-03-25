# Script for analysis of spines bahaviour using PCA and Relative Change Clusters model.
#
# author: tomasz.kusmierczyk(at)gmail.com

source(file="loading.r")
source(file="pca.r")
source(file="clustering.r")
source(file="drawing.r")
source(file="changes.r")
source(file="predictions.r")

#######################################################################################
#######################################################################################
#######################################################################################
#######################################################################################
# Script configuration.

# Input data:
#train.data.file = "~/spines_bitbucket/data/140303_olddata/filtered_300/ALL.txt" 
#test.data.file = "~/spines_bitbucket/data/140303_olddata/filtered_300/ALL.txt" 

#train.data.file = "~/spines_bitbucket/data/140303_olddata/ALL_triple.txt"
#test.data.file = "~/spines_bitbucket/data/140303_olddata/ALL_triple.txt" 

train.data.file = "~/spines_bitbucket/data/140303_140803_merged/ALL_triple.txt"
test.data.file = "~/spines_bitbucket/data/140303_140803_merged/ALL_triple.txt"

#train.data.file = "~/spines_bitbucket/data/140403_dane_treningowe_testowe_300_2/train.txt"
#test.data.file = "~/spines_bitbucket/data/140403_dane_treningowe_testowe_300_2/valid_test.txt" 

#train.data.file = "~/spines_bitbucket/data/140403_dane_treningowe_testowe_300_2/train_valid.txt"
#test.data.file = "~/spines_bitbucket/data/140403_dane_treningowe_testowe_300_2/test.txt" 

#train.data.file = "~/spines_bitbucket/data/140403_dane_treningowe_testowe/validation_and_train.txt"
#test.data.file = "~/spines_bitbucket/data/140403_dane_treningowe_testowe/test.txt"

#train.data.file = "~/spines_bitbucket/data/140403_dane_treningowe_testowe3/validation_and_train.txt"
#test.data.file = "~/spines_bitbucket/data/140403_dane_treningowe_testowe3/test.txt"

# file with ids (must have column spine.id) of selected subset of data
# set to NaN if you want to construct transition matrices basing on whole data
#balanced.ids.file = NaN
#balanced.ids.file = "~/spines_bitbucket/data/140303_olddata/filtered_300/ALL.txt" 
balanced.ids.file = "~/spines_bitbucket/data/140303_140803_merged/filtered_300.txt" 



# names of features describing inital time moment
features.names.t0 =  c("0MIN_length", "0MIN_head_width", "0MIN_max_width_location", 
                       "0MIN_max_width", "0MIN_width_length_ratio", "0MIN_length_width_ratio", 
                       "0MIN_neck_width", "0MIN_foot", "0MIN_circumference", "0MIN_area", 
                       "0MIN_length_area_ratio") 

# names of features describing final time moment
features.names.t1 = c("10_MIN_length", "10_MIN_head_width", "10_MIN_max_width_location", 
                      "10_MIN_max_width", "10_MIN_width_length_ratio", "10_MIN_length_width_ratio", 
                      "10_MIN_neck_width", "10_MIN_foot", "10_MIN_circumference", "10_MIN_area", 
                      "10_MIN_length_area_ratio") 

# names of features will be changed to this below
features.names.nice = c("length", "hw", "mwl", "mw", "wlr", "lwr", 
                        "nw", "foot", "circumference", "area", "lar")

# description of identificator field
spine.id = 'unique_id'
group.id = 'group_id'
spine.id.field.separator = '-'
#spine.id.fields = c('data_id', 'animal_id', 'nencki_id', 'group_id')

# ids of groups to be considered
groups.ids = c('f', 'd') 



# spine images:
source0 = "source0"
source1 = "source10"
xpos0 = "0MIN_x_m"
ypos0 = "0MIN_y_m"
xpos1 = "10_MIN_x_m"
ypos1 = "10_MIN_y_m"
image.features.t0 = c(source0, xpos0, ypos0)
image.features.t1 = c(source1, xpos1, ypos1)

# TO TURN OFF IMAGES SUPPORT COMMENT LINE BELOW
images.base.dir = "~/140719_dane_ze_wspolrzednymi/spiny/"
spine.image.size = 70
visualise.num.representants = 3

# features that should be kept while splitting data according to time moments
additional.features.names = c(spine.id, 'animal_id', 'nencki_id', group.id, 
                              image.features.t0, image.features.t1)


# PCA:
# what size of (PCA) representation should be used
pca.num.features = 3



# Clustering parameters:

#clustering.method = "hierarchical"
clustering.method = "cmeans"
#clustering.method = "kmeans"

k = 8
m = 4

# number of bootstrap repetitions for comparison of membership matrices
num.repetitions.comp.membership.matrices = 10000


# Output:
# where output results should be stored
output.dir = paste("/tmp/", format(Sys.time(), "%Y%m%d-%H%M%S"), "changes", sep="_")
dir.create(output.dir, showWarnings = FALSE)
# redirects printing output into file (to turn on/off uncomment/comment below line)
sink(paste(output.dir,"/script_pcachanges.log",sep=""), split=T)

# Line wrapping:
options(max.print=1000000)
options(width=1000) 

# Pdf output:
#options(device="pdf")
#pdf(paste(output.dir, "script_global_typology.pdf", sep="/"))

#######################################################################################

# Compatibility required features (will be ignored anyway):
# should features be scaled or not
normalization = F 

#######################################################################################
#######################################################################################
########################################################################################
# Print parameters.

if (!exists("test.data.file")) {
  test.data.file = train.data.file
}

# Print parameters
print(paste("train.data.file =", train.data.file))
print(paste("test.data.file =", test.data.file))
print(paste("groups.ids =", groups.ids))
print(paste("features.names.t0 =", paste(features.names.t0, collapse=" ")))
print(paste("features.names.t1 =", paste(features.names.t1, collapse=" ")))
print(paste("features.names.nice =", paste( features.names.nice, collapse=" ")))
print(paste("additional.features.names =", paste(additional.features.names, collapse=" ")))
print(paste("pca.num.features =", pca.num.features))
print(paste("num.repetitions.comp.membership.matrices =", num.repetitions.comp.membership.matrices))
if (exists("images.base.dir")) 
  print(paste("images.base.dir =", images.base.dir))

########################################################################################
########################################################################################
# Data loading and preprocessing.

train = ChangesDataPreparation(train.data.file, group.id, groups.ids, 
                               features.names.t0, features.names.t1, 
                               features.names.nice, additional.features.names)
test = ChangesDataPreparation(test.data.file, group.id, groups.ids, 
                              features.names.t0, features.names.t1, 
                              features.names.nice, additional.features.names)

source(file="routine_contours_changes.r")

description.str = paste('N=',dim(train)[1],',D=',pca.num.features,",#",
                        groups.ids[1],'=',sum(train[,group.id]==groups.ids[1]),',#',
                        groups.ids[2],'=',sum(train[,group.id]==groups.ids[2]), sep='')

########################################################################################
########################################################################################
# PCA on whole data.

print("PCA on all features")
pc = PCA(train, features.names.nice)
train.features = PCAPredict(train, pc, pca.num.features)
colnames(train.features) = paste("Rel.", colnames(train.features), sep="")
test.features = PCAPredict(test, pc, pca.num.features)
colnames(test.features) = paste("Rel.", colnames(test.features), sep="")

PCALoadingsPlot(pc, paste('PCA loadings\n(',description.str,')',sep=''))
StorePlot( paste(output.dir,'/pca_loadings',sep='') )
PCAVariancePlot(pc, paste('PCA variance explained\n(',description.str,')',sep=''))
StorePlot( paste(output.dir,'/pca_variance',sep='') )
print(pc$loadings)
print(summary(pc))

########################################################################################
########################################################################################
# Clustering.

source(file="routine_clustering.r")
source(file="routine_clustering_report.r")
source(file="routine_contours_changes_representants.r")

########################################################################################
# Filtering results to only these from balanced.ids.file (optional).

source(file="routine_subset_reduction.r")

########################################################################################
# Statistical analysis.

# Chi2-test for CRISP results.
print("chisq.test for CRISP approximation of results:")
ac = AnalyseClusters(clustering.assignment, train, features.names.nice, train[ , group.id])
counts = t(ac$groups)
colnames(counts) = paste("C", colnames(counts), sep="")

#If simulate.p.value is FALSE, the p-value is computed from the asymptotic 
#chi-squared distribution of the test statistic; continuity correction is 
#only used in the 2-by-2 case (if correct is TRUE, the default). 
#Otherwise the p-value is computed for a Monte Carlo test (Hope, 1968) with B replicates.
chisq.test(counts, simulate.p.value = T)


# Bootstrap-test for FUZZY results.
gid1 = groups.ids[1]
gid2 = groups.ids[2]
p.value = CompareChangesMatrices( train, membership.matrix, 
                                  gid1, gid2,
                                  num.repetitions.comp.membership.matrices,                                     
                                  statistic.calculator = MembershipDiffStatistic, 
                                  histogramtitle="CD Statistic distribution",
                                  xlab="CD value")
print(paste("Group",gid1," vs  Group",gid2,"->  p.value =", p.value))
StorePlot(paste(output.dir,'/cd_pvalues',sep=''), dpi=90, w=640, h=480) 


########################################################################################
########################################################################################
########################################################################################
########################################################################################
# Cleaning up.

# Turn off sink
#dev.off()
sink()
print(paste("OUTPUT DATA IS STORED IN:", output.dir))

