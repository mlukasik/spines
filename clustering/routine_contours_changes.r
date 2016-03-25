# Loading TIFF images of spines. 
#
# author: tomasz.kusmierczyk(at)gmail.com

source(file="contours.r")


ConstructTifImagePath = function(images.base.dir, source.file) {
  paste(images.base.dir, "/", strsplit(source.file, "RGB.csv")[[1]], "contours.tif", sep="")
}

if (exists("images.base.dir")) {
  source.files = c()
  if (exists("source0")) 
    source.files = union(source.files, unique(sort(train[,source0])))
  if (exists("source1")) 
    source.files = union(source.files, unique(sort(train[,source1])))
  
  tifimgs = LoadTifImages(images.base.dir, source.files, PathConstructor=ConstructTifImagePath) 
  imgs = ExtractSpineImagesT0T1(train, tifimgs, imgsize=spine.image.size)  
}
