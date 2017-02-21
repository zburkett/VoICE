if(.Platform$OS.type=="windows" & file.exists("./.libraries")){.libPaths("./.libraries")}
comArgs <- commandArgs(TRUE)
options(stringsAsFactors=FALSE)
d1 <- read.table(paste(comArgs[1],"/usedClusters.txt",sep=""))
d2 <- read.table(paste(comArgs[2],"/usedClusters.txt",sep=""))
d3 <- as.vector(unique(c(d1,d2)))
unusedColors <- colors()[!colors()%in%d3]
write.table(unusedColors,file=paste(comArgs[2],"unusedColors.txt",sep=""),row.names=FALSE,col.names=FALSE)