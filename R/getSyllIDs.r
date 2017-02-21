if(.Platform$OS.type=="windows" & file.exists("./.libraries")){.libPaths("./.libraries")}
comArgs <- commandArgs(T)
options(stringsAsFactors=FALSE)
options(warn=-1)

#input arguments are a cluster name to change files to and a directory to CSVs containing binary notations of which members of each cluster are supposed to be changed to input argument cluster

if(file.exists(paste(comArgs[1],'workspace.Rdata',sep='')))
{
	load(paste(comArgs[1],'workspace.Rdata',sep='')) #load workspace
}else if(file.exists(paste(comArgs[1],'assign_workspace.Rdata',sep=''))) #load workspace
{
	load(paste(comArgs[1],'assign_workspace.Rdata',sep=''))
}else if(file.exists(paste(comArgs[1],'assigned_complete_workspace.Rdata',sep='')))
{
	load(paste(comArgs[1],'assigned_complete_workspace.Rdata',sep=''))	
}

changeList <- list()

for(i in 1:length(dir(paste(comArgs[1],'reassign',sep=''))))
{
	#read the csv
	clicks <- read.csv(paste(comArgs[1],'reassign/',gsub('.csv','',dir(paste(comArgs[1],'reassign',sep=''))[i]),'.csv',sep=''),header=FALSE)
	
	#store names of syllables clicked in changeList
	if(exists("out.cluster.tutor"))
	{
		if("mergedSyntax" %in% names(out.cluster.tutor))
		{
			clicks <- as.logical(clicks)
			names(clicks) <- names(subset(out.cluster.tutor$mergedSyntax,out.cluster.tutor																	$mergedSyntax==gsub('.csv','',dir(paste(comArgs[1],'reassign',sep=''))[i])))
			changeList[[gsub('.csv','',dir(paste(comArgs[1],'reassign',sep=''))[i])]] <- names(clicks)[clicks]
		}
	
		if(!"mergedSyntax" %in% names(out.cluster.tutor))
		{
			clicks <- as.logical(clicks)
			colnames(clicks) <- names(subset(out.cluster.tutor$syntax,out.cluster.tutor																		$syntax==gsub('.csv','',dir(paste(comArgs[1],'reassign',sep=''))[i])))
			changeList[[gsub('.csv','',dir(paste(comArgs[1],'reassign',sep=''))[i])]] <- names(clicks)[clicks]
		}	
	}else if(exists("assignedSyntax"))
		{
			clicks <- as.logical(clicks)
			names(clicks) <- names(subset(assignedSyntax,assignedSyntax==gsub('.csv','',dir(paste(comArgs[1],'reassign',sep=''))[i])))
			changeList[[gsub('.csv','',dir(paste(comArgs[1],'reassign',sep=''))[i])]] <- names(clicks)[clicks]
		}else if(exists("saveList"))
		{
			clicks <- as.logical(clicks)
			names(clicks) <- names(subset(saveList$out.assign,saveList$out.assign==gsub('.csv','',dir(paste(comArgs[1],'reassign',sep=''))[i])))
			changeList[[gsub('.csv','',dir(paste(comArgs[1],'reassign',sep=''))[i])]] <- names(clicks)[clicks]
		}
}
