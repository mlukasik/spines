#Data-specific descriptions.

#############################################################################

paths.wtko = c("../DATA/PARSED/130808_WTKO/WT_CEAM.csv",
               "../DATA/PARSED/130808_WTKO/KO_CEAM.csv")

#############################################################################

group.ids.wtko = c("wt", "ko")

#############################################################################



features.0.names = c("X0MIN_length", "X0MIN_head_width", "X0MIN_max_width_location", 
                   "X0MIN_max_width", "X0MIN_width_length_ratio", "X0MIN_length_width_ratio", 
                   "X0MIN_neck_width", "X0MIN_foot", "X0MIN_circumference", "X0MIN_area", 
                   "X0MIN_length_area_ratio")

features.10.names = c("X10_MIN_length", "X10_MIN_head_width", "X10_MIN_max_width_location", 
                    "X10_MIN_max_width", "X10_MIN_width_length_ratio", "X10_MIN_length_width_ratio", 
                    "X10_MIN_neck_width", "X10_MIN_foot", "X10_MIN_circumference", "X10_MIN_area", 
                    "X10_MIN_length_area_ratio")

features.40.names = c("X40_MIN_length", "X40_MIN_head_width", "X40_MIN_max_width_location", 
                    "X40_MIN_max_width", "X40_MIN_width_length_ratio", "X40_MIN_length_width_ratio", 
                    "X40_MIN_neck_width", "X40_MIN_foot", "X40_MIN_circumference", "X40_MIN_area", 
                    "X40_MIN_length_area_ratio")

all.features.names = c(features.0.names, features.10.names, features.40.names)


uid = "uid" #universal id column name
nencki.descriptors.names = c("unique_id", "animal_id", "nencki_id")
descriptors.names = c(uid, "group_id", nencki.descriptors.names)


descriptors.names = c("uid","group_id","unique_id","animal_id","nencki_id")



features.WDGT.names = c('length','head_width', 'max_width_location', 
                        'max_width', 'width_length_ratio', 'length_width_ratio', 'neck_width', 'foot',
                        'circumference', 'area', 'length_area_ratio')

