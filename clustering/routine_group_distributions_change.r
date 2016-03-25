# Membership changes in time analysis.

gid1 = groups.ids[1]
gid2 = groups.ids[2]
group1.rows = train[,group.id]==gid1
group2.rows = train[,group.id]==gid2
time0.rows = train[,time.id]==time.t0
time1.rows = train[,time.id]==time.t1
g1.t0.colsums = colSums(membership.matrix[group1.rows & time0.rows, ])
g2.t0.colsums = colSums(membership.matrix[group2.rows & time0.rows, ])
g1.t1.colsums = colSums(membership.matrix[group1.rows & time1.rows, ])
g2.t1.colsums = colSums(membership.matrix[group2.rows & time1.rows, ])

print("GROUPS IN DIFFERENT TIME MOMENTS IN CLUSTERS:")
print(paste("Group", gid1, "time ", time.t0))
print(g1.t0.colsums)
print(paste("Group", gid2, "time ", time.t0))
print(g2.t0.colsums)
print(paste("Group", gid1, "time ", time.t1))
print(g1.t1.colsums)
print(paste("Group", gid2, "time ", time.t1))
print(g2.t1.colsums)

print(paste("Difference between groups (#",gid2,"- #",gid1,") in ", time.t0))
print(g2.t0.colsums-g1.t0.colsums)

print(paste("Relative change in group", gid1))
print((g1.t1.colsums-g1.t0.colsums ) / g1.t0.colsums )
print(paste("Relative change in group", gid2))
print((g2.t1.colsums-g2.t0.colsums ) / g2.t0.colsums )

source(file="groups_clusters_distribution.r")
p.value = CompareGroupsInClusters(train, membership.matrix, 
                                    gid1, gid2,
                                    num.repetitions.comp.distribution.changes,                                     
                                    statistic.calculator = GroupsInClustersRelativeChangeStat, 
                                    histogramtitle="RDC Statistic distribution",
                                    xlab = "RDC value")
print(paste("CompareGroupsInClusters (GroupsInClustersRelativeChangeStat): Group",
            gid1," vs  Group",gid2,"->  p.value =", p.value))
StorePlot(paste(output.dir,'/pvalues_CompareGroupsInClusters',sep=''), dpi=90, w=640, h=480) 

