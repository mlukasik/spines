# Loading of TIFF images of spines. 
#
# author: tomasz.kusmierczyk(at)gmail.com

source(file="contours.r")


ConstructTifImagePath = function(images.base.dir, source.file) {
  paste(images.base.dir, "/", strsplit(source.file, "RGB.csv")[[1]], "contours.tif", sep="")
}

if (exists("images.base.dir")) {
  source.files = unique(sort(train[,source0]))
  tifimgs = LoadTifImages(images.base.dir, source.files, PathConstructor=ConstructTifImagePath) 
  imgs = ExtractSpineImages(train, tifimgs, imgsize=spine.image.size)  
}

