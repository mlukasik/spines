# Manipulation of TIFF images of spines. 
#
# author: tomasz.kusmierczyk(at)gmail.com
#
# Required libraries: tiff
# Ubuntu warning: install libtiff4-dev.deb first

library(tiff)


LoadTifImages = function(images.base.dir, source.files, PathConstructor, inverted=T) {
  tifimgs = list()
  for (source.file in source.files) {
    path = PathConstructor(images.base.dir, source.file) 
    if (file.exists(path)) {
      img = readTIFF(path, convert=T)  
      #img = as.raster(img[,,1:3])
      if (inverted) img = 1-img
      tifimgs[[source.file]] = img
    }  
  }
  return (tifimgs)
}


ExtractSpineImages = function(train, tifimgs, imgsize=50) {
  # Extracts images of spines from time moment t0.
  halfsize = ceil(imgsize/2)
  imgs = list()
  for (id in rownames(train)) {
    source.file = train[id, source0]
    x = train[id, xpos0]
    y = train[id, ypos0]
    if (!is.na(source.file) && !is.na(x) && !is.na(y) ) {
      img = tifimgs[[toString(source.file)]]
      left = max((x-halfsize)+1, 1); right = min(x+halfsize, dim(img)[2])
      bottom = max((y-halfsize)+1, 1); top = min(y+halfsize, dim(img)[1])
      imgs[[id]] = img[bottom:top, left:right, ]
    }
  }
  return (imgs)
}


ExtractSpineImagesT0T1 = function(train, tifimgs, imgsize=50) {
  # Extracts images of spines from time moments t0 and t1.
  halfsize = ceil(imgsize/2)
  imgs = list()
  for (id in rownames(train)) {
    
    source.file = train[id, source0]    
    x = train[id, xpos0]
    y = train[id, ypos0]
    if (!is.na(source.file) && !is.na(x) && !is.na(y) ) {
      img = tifimgs[[toString(source.file)]]
      left = max((x-halfsize)+1, 1); right = min(x+halfsize, dim(img)[2])
      bottom = max((y-halfsize)+1, 1); top = min(y+halfsize, dim(img)[1])
      imgs[[paste(id,spine.id.field.separator,time.t0,sep="")]] = img[bottom:top, left:right, ]
    }
    
    source.file = train[id, source1]
    x = train[id, xpos1]
    y = train[id, ypos1]
    if (!is.na(source.file) && !is.na(x) && !is.na(y) ) {
      img = tifimgs[[toString(source.file)]]
      left = max((x-halfsize)+1, 1); right = min(x+halfsize, dim(img)[2])
      bottom = max((y-halfsize)+1, 1); top = min(y+halfsize, dim(img)[1])
      imgs[[paste(id,spine.id.field.separator,time.t1,sep="")]] = img[bottom:top, left:right, ]
    }
    
  }
  return (imgs)
}


ExtractClusterRepresentantsSimple = function(train.features, imgs, representants.rank, 
                                       output.dir, visualise.num.representants, label="rep") {
  # Stores images of spines selected as cluster representants.
  #
  # Because ranks overlap also selected representants may overlap.
  for (cluster.no in 1:length(representants.rank)) {
    representants = representants.rank[[cluster.no]]
    rank = 1
    representants.count = 0
    for (spine in representants) {
      if (spine %in% names(imgs)) {
        
        path = paste(output.dir, "/", label, "_", cluster.no, "_",rank,"_", spine, ".png", sep="")
        writePNG(imgs[[spine]], path)
        
        representants.count = representants.count + 1
      } #if
      if (representants.count>=visualise.num.representants) {
        break
      }
      rank = rank + 1    
    }
  }
}


ExtractClusterOfChangesRepresentantsSimple = function(train.features, imgs, representants.rank, 
                                                      output.dir, visualise.num.representants, label="rep") {
  # Stores images of spines selected as cluster of changes representants.
  #
  # Because ranks overlap also selected representants may overlap.
  for (cluster.no in 1:length(representants.rank)) {
    representants = representants.rank[[cluster.no]]
    rank = 1
    representants.count = 0
    for (spine in representants) {
      
      spine0 = paste(spine, time.t0, sep=spine.id.field.separator)
      spine1 = paste(spine, time.t1, sep=spine.id.field.separator)
      
      if (spine0 %in% names(imgs) && spine1 %in% names(imgs)) {
        
        path = paste(output.dir, "/", label, "_", cluster.no, "_",rank,"_", spine0, ".png", sep="")
        writePNG(imgs[[spine0]], path)
        
        path = paste(output.dir, "/", label, "_", cluster.no, "_",rank,"_", spine1, ".png", sep="")
        writePNG(imgs[[spine1]], path)
        
        representants.count = representants.count + 1
      } #if
      
      if (representants.count>=visualise.num.representants) {
        break
      }
      rank = rank + 1    
    }
  }
}


ExtractClusterRepresentants = function(train.features, imgs, representants.rank, 
                                       output.dir, visualise.num.representants, label="rep") {
  # Stores images of spines selected as cluster representants.
  #
  # Method prevents overlapping representants. 
  used = c()
  representants.count = rep(0, length(representants.rank))
  for (rank in 1:1000) {
    for (cluster.no in 1:length(representants.rank)) {      
      if (representants.count[cluster.no]<visualise.num.representants) {      
        representants = representants.rank[[cluster.no]]
        spine = representants[rank]    
        
        if ((spine %in% names(imgs)) && !(spine %in% used)) {
          path = paste(output.dir, "/", label, "_", cluster.no, "_",rank,"_", spine, ".png", sep="")
          writePNG(imgs[[spine]], path)
          used = cbind(used, spine)
          representants.count[cluster.no] = representants.count[cluster.no] + 1
        }
      }
    }
    
    finished = sum(representants.count[1:length(representants.rank)]>=visualise.num.representants)
    if (finished >= length(representants.rank)) break
  }  
}


ExtractClusterOfChangesRepresentants = function(train.features, imgs, representants.rank, 
                                       output.dir, visualise.num.representants, label="rep") {
  # Stores images of spines selected as cluster of changes representants.
  #
  # Method prevents overlapping representants. 
  used = c()
  representants.count = rep(0, length(representants.rank))
  for (rank in 1:1000) {
    for (cluster.no in 1:length(representants.rank)) {      
      if (representants.count[cluster.no]<visualise.num.representants) {      
        representants = representants.rank[[cluster.no]]
        spine = representants[rank]    
        spine0 = paste(spine, time.t0, sep=spine.id.field.separator)
        spine1 = paste(spine, time.t1, sep=spine.id.field.separator)
        
        if ((spine0 %in% names(imgs) && spine1 %in% names(imgs)) && !(spine %in% used)) {
          path = paste(output.dir, "/", label, "_", cluster.no, "_",rank,"_", spine0, ".png", sep="")
          writePNG(imgs[[spine0]], path)
          
          path = paste(output.dir, "/", label, "_", cluster.no, "_",rank,"_", spine1, ".png", sep="")
          writePNG(imgs[[spine1]], path)

          used = cbind(used, spine)
          representants.count[cluster.no] = representants.count[cluster.no] + 1
        }
      }
    }
    
    finished = sum(representants.count[1:length(representants.rank)]>=visualise.num.representants)
    if (finished >= length(representants.rank)) break
  }  
}


