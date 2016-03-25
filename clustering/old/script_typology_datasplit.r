#Script that splits data according to typology assignment.

source(file="loading.r")
source(file="pca.r")
source(file="clustering.r")
source(file="changes.r")
source(file="params.r")
source(file="drawing.r")
source(file="transitions.r")



#######################################################################################

x = ReadMany(paths.fd, group.ids.fd)
x = FilterOut(x, all.features.names)
x.f = SelRows(x, 'f') 
x.d = SelRows(x, 'd') 
x100 = ReadMany(paths.fd100, group.ids.fd100)
x100 = FilterOut(x100, all.features.names)
x.f100 = SelRows(x100, 'f') 
x.d100 = SelRows(x100, 'd') 
x185 = ReadMany(paths.fd185, group.ids.fd185)
x185 = FilterOut(x185, all.features.names)
x.f185 = SelRows(x185, 'f') 
x.d185 = SelRows(x185, 'd') 

# rowname  uid group_id unique_id animal_id nencki_id shape_clustering.r
ta = read.table(global_typology_assignment, head=T)

shape1uids.t0 = SelectUidsForTime(ta$uid[ta$shape_clustering.r==1], time="0")
shape2uids.t0 = SelectUidsForTime(ta$uid[ta$shape_clustering.r==2], time="0")
shape4uids.t0 = SelectUidsForTime(ta$uid[ta$shape_clustering.r==4], time="0")

#######################################################################################

SelSubsetWithUids = function(data, uids, features=c(nencki.descriptors.names, all.features.names) ) {
  return( data[intersect(uids, rownames(data)), features] )
}

write.table(SelSubsetWithUids(x.f, shape1uids.t0),"/tmp/SPINES_FORSKOLIN_SHAPE1.txt")
write.table(SelSubsetWithUids(x.f, shape2uids.t0),"/tmp/SPINES_FORSKOLIN_SHAPE2.txt")
write.table(SelSubsetWithUids(x.d, shape1uids.t0),"/tmp/SPINES_DMSO_SHAPE1.txt")
write.table(SelSubsetWithUids(x.d, shape2uids.t0),"/tmp/SPINES_DMSO_SHAPE2.txt")

write.table(SelSubsetWithUids(x.f100, shape1uids.t0),"/tmp/SPINES_FORSKOLIN100_SHAPE1.txt")
write.table(SelSubsetWithUids(x.f100, shape2uids.t0),"/tmp/SPINES_FORSKOLIN100_SHAPE2.txt")
write.table(SelSubsetWithUids(x.f100, shape4uids.t0),"/tmp/SPINES_FORSKOLIN100_SHAPE4.txt")
write.table(SelSubsetWithUids(x.d100, shape1uids.t0),"/tmp/SPINES_DMSO100_SHAPE1.txt")
write.table(SelSubsetWithUids(x.d100, shape2uids.t0),"/tmp/SPINES_DMSO100_SHAPE2.txt")
write.table(SelSubsetWithUids(x.d100, shape4uids.t0),"/tmp/SPINES_DMSO100_SHAPE4.txt")

write.table(SelSubsetWithUids(x.f185, shape1uids.t0),"/tmp/SPINES_FORSKOLIN185_SHAPE1.txt")
write.table(SelSubsetWithUids(x.f185, shape2uids.t0),"/tmp/SPINES_FORSKOLIN185_SHAPE2.txt")
write.table(SelSubsetWithUids(x.f185, shape4uids.t0),"/tmp/SPINES_FORSKOLIN185_SHAPE4.txt")
write.table(SelSubsetWithUids(x.d185, shape1uids.t0),"/tmp/SPINES_DMSO185_SHAPE1.txt")
write.table(SelSubsetWithUids(x.d185, shape2uids.t0),"/tmp/SPINES_DMSO185_SHAPE2.txt")
write.table(SelSubsetWithUids(x.d185, shape4uids.t0),"/tmp/SPINES_DMSO185_SHAPE4.txt")

