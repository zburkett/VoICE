if(.Platform$OS.type=="windows" & file.exists("./.libraries")){.libPaths("./.libraries")}
comArgs <- commandArgs(TRUE)
tutDir <- comArgs[1]
if(file.exists(paste(comArgs[1],"/workspace.Rdata",sep="")))
{
	load(paste(comArgs[1],"/workspace.Rdata",sep=""))
	clusterIDs <- gsub("ME","",names(out.cluster.tutor$eigensyls))
	write.table(clusterIDs,file=paste(comArgs[1],"/.usedClusters2.txt",sep=""),row.names=FALSE,col.names=FALSE)
}else if(file.exists(paste(comArgs[1],"assign_workspace.Rdata",sep="")))
{
	load(paste(comArgs[1],"/assign_workspace.Rdata",sep=""))
	clusterIDs <- unique(saveList$out.assign)
	write.table(clusterIDs,file=paste(comArgs[1],"/.usedClusters.txt",sep=""),row.names=FALSE,col.names=FALSE)
}else if(file.exists(paste(comArgs[1],"/assign_workspace.Rdata",sep="")))
{
	load(paste(comArgs[1],"/assign_workspace.Rdata",sep=""))
	clusterIDs <- unique(saveList$out.assign)
	write.table(clusterIDs,file=paste(comArgs[1],"/.usedClusters.txt",sep=""),row.names=FALSE,col.names=FALSE)
}

if(.Platform$OS.type=="windows"){system(paste('attrib +h',paste(comArgs[1],"/.usedClusters.txt",sep="")))}
