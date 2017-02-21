comArgs <- commandArgs(TRUE)
tutDir <- comArgs[1]
if(file.exists(paste(comArgs[1],"/workspace.Rdata",sep="")))
{
	load(paste(comArgs[1],"/workspace.Rdata",sep=""))
	clusterIDs <- gsub("ME","",names(out.cluster.tutor$eigensyls))
	write.table(clusterIDs,file=paste(comArgs[1],"/usedClusters.txt",sep=""),row.names=FALSE,col.names=FALSE)
}else if(file.exists(paste(comArgs[1],"assign_workspace.Rdata",sep="")))
{
	load(paste(comArgs[1],"/assign_workspace.Rdata",sep=""))
	clusterIDs <- unique(saveList$out.assign)
	write.table(clusterIDs,file=paste(comArgs[1],"/usedClusters.txt",sep=""),row.names=FALSE,col.names=FALSE)
}else if(file.exists(paste(comArgs[1],"/assign_workspace.Rdata",sep="")))
{
	load(paste(comArgs[1],"/assign_workspace.Rdata",sep=""))
	clusterIDs <- unique(saveList$out.assign)
	write.table(clusterIDs,file=paste(comArgs[1],"/usedClusters.txt",sep=""),row.names=FALSE,col.names=FALSE)
}


