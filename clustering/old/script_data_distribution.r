#Script for data distribution analysis of spines for selected time moment.

source(file="loading.r")
source(file="drawing.r")

#######################################################################################

#Select configuration

# input data
train.data.file = "~/spines_bitbucket/data/140303_olddata/ALL_triple.txt" 

# names of features describing inital time moment
features.names =  c("0MIN_length", "0MIN_head_width", "0MIN_max_width_location", 
                       "0MIN_max_width", "0MIN_width_length_ratio", "0MIN_length_width_ratio", 
                       "0MIN_neck_width", "0MIN_foot", "0MIN_circumference", "0MIN_area", 
                       "0MIN_length_area_ratio") 
group.id = 'group_id'
group.1 = 'f'
group.2 = 'd'

# description of identificator field
spine.id = 'unique_id'
spine.id.field.separator = '-'

histogram.breaks = 20

# Output:
# where output results should be stored
output.dir = "/tmp/out" 
dir.create(output.dir, showWarnings = FALSE)

# redirects printing output into file (to turn on/off uncomment/comment below line)
sink(paste(output.dir,"/script_data_distribution.log",sep=""))

########################################################################################

#Loads data
x = ReadInputFile(train.data.file)

########################################################################################

#t-test for forskolina and dmso in t=0min
print('Feature  Mean1  Mean2  p-value')
for(feature in features.names){
  feature.f = KeepSubsetAccordingToColumnValue(x, group.id, group.1)[,feature]
  feature.d = KeepSubsetAccordingToColumnValue(x, group.id, group.2)[,feature]
  print(c(feature, mean(feature.f), mean(feature.d), t.test(feature.f, feature.d)$p.value))  
}

########################################################################################

#histograms for forskolina and dmso in t=0min
for(feature in features.names){
  feature.f = KeepSubsetAccordingToColumnValue(x, group.id, group.1)[,feature]
  feature.d = KeepSubsetAccordingToColumnValue(x, group.id, group.2)[,feature]
  
  left = floor( min(c(feature.f, feature.d)) )
  right = ceiling( max(c(feature.f, feature.d)) )
  step =  round((right-left)/histogram.breaks, 2)
  agreed.breaks = seq(from = left, to = right, by = step)
  h = hist(feature.f, breaks=agreed.breaks)
  h2 = hist(feature.d, breaks=agreed.breaks)
  
  h$counts = h$counts/sum(h$counts)
  h2$counts = h2$counts/sum(h2$counts)
  
  plot.new()  
  plot(h, border='black', main=paste("Histogram of ",feature), 
       sub=paste("(black=",group.1,", grey=",group.2,")", sep=""), ylab="Probability", xlab="Value")  
  plot(h2, add=T, border='grey')
  grid() 
  StorePlot(paste(output.dir,"/hist_",feature,".png", sep=""), dpi=90, w=480, h=480)
}


#######################################################################################

# Turn off sink
sink()

