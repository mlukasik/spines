#Data-specific descriptions.

basedir = "../../spine_bitbucket/data/130709_triple_updated_control/"

#############################################################################

paths.f185 = c(paste(basedir,"FORSKOLIN_triple_selected_185",sep=""))
group.ids.f185 = c("f")

paths.d185 = c(paste(basedir,"CONTROLTEST_DMSO_selected_185",sep=""))
group.ids.d185 = c("d")

paths.f = c(paste(basedir,"FORSKOLIN_triple.txt",sep=""))
group.ids.f = c("f")

paths.d = c(paste(basedir,"CONTROLTEST_DMSO_triple.txt",sep=""))
group.ids.d = c("d")

paths.fd = c(paths.f, paths.d)
group.ids.fd = c("f", "d")

group.ids.wtko = c("WT", "KO")


paths.fd100 = c(paste(basedir,"FORSKOLIN_triple_selected_100",sep=""), 
               paste(basedir,"CONTROLTEST_DMSO_selected_100",sep=""))
group.ids.fd100 = c("f", "d")

paths.fd185 = c(paste(basedir,"FORSKOLIN_triple_selected_185",sep=""), 
                paste(basedir,"CONTROLTEST_DMSO_selected_185",sep=""))
group.ids.fd185 = c("f", "d")

#############################################################################

global_typology_assignment = "../../RES_CSV_230213/global_shapes_assigiments.txt"              

#############################################################################


uid = "uid" #universal id column name
nencki.descriptors.names = c("unique_id", "animal_id", "nencki_id")
descriptors.names = c(uid, "group_id", nencki.descriptors.names)


