# Script for analysis of spines' shapes using PCA.
#
# author: tomasz.kusmierczyk(at)gmail.com

#######################################################################################
#######################################################################################

source(file="drawing.r")

#######################################################################################
#######################################################################################
#######################################################################################
#######################################################################################
# Script configuration.

# Input data:
train.data.file = "~/spines_bitbucket/data/140303_140803_merged/ALL_triple.txt"


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
grid.size.horizontal = 5
grid.size.vertical = 5

# features that should be kept while splitting data according to time moments
additional.features.names = c(spine.id, 'animal_id', 'nencki_id', group.id)
additional.features.names.t0 = image.features.t0
additional.features.names.t1 = image.features.t1


# PCA:
# each group of features will be considered separately while calculating pca
pca.feature.groups = list( 
  c("length",  "circumference", "area"),
  c("hw", "foot", "mwl", "mw", "wlr", "lwr", "lar", "nw") )
#pca.feature.groups = list( c("length",  "circumference", "area","hw", "foot", "mwl", "mw", "wlr", "lwr", "lar", "nw") ) #one group

# what size of (PCA) representation should be used
pca.num.features = 2

# should features be scaled or not
normalization = F 


# Output:
# where output results should be stored
output.dir = paste("/tmp/", format(Sys.time(), "%Y%m%d-%H%M%S"), "pca", sep="_")
dir.create(output.dir, showWarnings = FALSE)
# redirects printing output into file (to turn on/off uncomment/comment below line)
sink(paste(output.dir,"/script_shape_transitions_analysis.log",sep=""), split=T)

# Line wrapping:
options(max.print=1000000)
options(width=1000) 

# Pdf output:
#options(device="pdf")
#pdf(paste(output.dir, "script_pca_shapes.pdf", sep="/"))

print(paste("output.dir =", output.dir))

#######################################################################################
#######################################################################################
#######################################################################################
#######################################################################################
# Data preparation.

source(file="routine_data_preparation.r")
source(file="routine_groups_ttest.r")

#######################################################################################
# PCA spaces representants selection.


if (exists("imgs")) {
  # Are contour images loaded? 
  
  library(png)
  source(file="contours.r")
  
  mins = apply(train.features, 2, min)
  maxs = apply(train.features, 2, max)
  step1 = (maxs[1]-mins[1])/grid.size.horizontal
  step2 = (maxs[2]-mins[2])/grid.size.vertical  
  for (x in seq(from=mins[1]+step1/2, to=maxs[1], by=step1)) {
    for (y in seq(from=mins[2]+step2/2, to=maxs[2], by=step2)) {      
      x = round(x)
      y = round(y)
      
      selected = train.features[ , 1]>=x-step1/2 & train.features[ , 1]<x+step1/2 &
                 train.features[ , 2]>=y-step2/2 & train.features[ , 2]<y+step2/2            
      dst = as.matrix( dist(rbind(me=c(x,y), train.features[selected,1:2]), method="euclidean") )
      dst["me","me"] = Inf    
      representants = names(sort(dst["me",]))
      representants = head(representants, -1)
      print(paste("x =",round(x,2),"y =",round(y,2)," num.reps=",length(representants)))
      
      representants.count = 0
      rank = 1
      for (spine in representants) {
        if (spine %in% names(imgs)) {
          
          path = paste(output.dir, "/grid_", x, "_", y, "_",rank,"_", spine, ".png", sep="")
          writePNG(imgs[[spine]], path)
          
          representants.count = representants.count + 1
        } #if
        if (representants.count>=visualise.num.representants) {
          break
        }
        rank = rank + 1    
      }
      
    }#for y
  }#for x
  
} #if


#######################################################################################
#######################################################################################
#######################################################################################
#######################################################################################
# Cleaning up.

# Turn off sink
#dev.off()
sink()
print(paste("OUTPUT DATA IS STORED IN:", output.dir))
