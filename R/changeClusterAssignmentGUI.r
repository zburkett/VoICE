rm(list=ls())
if(.Platform$OS.type=="windows" & file.exists("./.libraries")){.libPaths("./.libraries")}
comArgs <- commandArgs(T)
options(stringsAsFactors=FALSE)
options(warn=-1)

#input arguments are a cluster name to change files to and a directory to CSVs containing binary notations of which members of each cluster are supposed to be changed to input argument cluster

if(file.exists(paste(comArgs[1],'voice_results/workspace.Rdata',sep='')))
{
	#print('Found workspace.Rdata')
	load(paste(comArgs[1],'voice_results/workspace.Rdata',sep='')) #load workspace
}else if(file.exists(paste(comArgs[1],'voice_results/assign_workspace.Rdata',sep=''))) #load workspace
{
	#print('Found assign_workspace.Rdata')
	load(paste(comArgs[1],'voice_results/assign_workspace.Rdata',sep=''))
}else if (file.exists(paste(comArgs[1],'voice_results/assigned_complete_workspace.Rdata',sep='')))
{
	#print('Found assigned_complete_workspace.Rdata')
	load(paste(comArgs[1],'voice_results/assigned_complete_workspace.Rdata',sep=''))
}

changeList <- list()

for(i in 1:length(dir(paste(comArgs[1],'.reassign',sep=''))))
{
	#read the csv
	clicks <- read.csv(paste(comArgs[1],'.reassign/',gsub('.csv','',dir(paste(comArgs[1],'.reassign',sep=''))[i]),'.csv',sep=''),header=FALSE)
	
	#store names of syllables clicked in changeList
	if(exists("out.cluster.tutor"))
	{
		if("mergedSyntax" %in% names(out.cluster.tutor))
		{
			clicks <- as.logical(clicks)
			names(clicks) <- names(subset(out.cluster.tutor$mergedSyntax,out.cluster.tutor$mergedSyntax==gsub('.csv','',dir(paste(comArgs[1],'.reassign',sep=''))[i])))
			changeList[[gsub('.csv','',dir(paste(comArgs[1],'.reassign',sep=''))[i])]] <- names(clicks)[clicks]
		}
	
		if(!"mergedSyntax" %in% names(out.cluster.tutor))
		{
			clicks <- as.logical(clicks)
			colnames(clicks) <- names(subset(out.cluster.tutor$syntax,out.cluster.tutor$syntax==gsub('.csv','',dir(paste(comArgs[1],'.reassign',sep=''))[i])))
			changeList[[gsub('.csv','',dir(paste(comArgs[1],'.reassign',sep=''))[i])]] <- names(clicks)[clicks]
		}	
	}else if(exists("assignedSyntax"))
		{
			clicks <- as.logical(clicks)
			names(clicks) <- names(subset(assignedSyntax,assignedSyntax==gsub('.csv','',dir(paste(comArgs[1],'.reassign',sep=''))[i])))
			changeList[[gsub('.csv','',dir(paste(comArgs[1],'.reassign',sep=''))[i])]] <- names(clicks)[clicks]
	}else if(exists("saveList"))
		{
			clicks <- as.logical(clicks)
			names(clicks) <- names(subset(saveList$out.assign,saveList$out.assign==gsub('.csv','',dir(paste(comArgs[1],'.reassign',sep=''))[i])))
			changeList[[gsub('.csv','',dir(paste(comArgs[1],'.reassign',sep=''))[i])]] <- names(clicks)[clicks]
		}
}

#print(which(changeList>0))

for(name in names(changeList))
{
	if(exists("out.cluster.tutor"))
	{
		if("mergedSyntax" %in% names(out.cluster.tutor))
		{
			for(i in 1:length(changeList[[name]]))
			{
				out.cluster.tutor$mergedSyntax[names(out.cluster.tutor$mergedSyntax)==changeList[[name]][i]] <- comArgs[2]
			}	
		}
	
		if(!"mergedSyntax" %in% names(out.cluster.tutor))
		{
			for(i in 1:length(changeList[[name]]))
			{
				out.cluster.tutor$syntax[names(out.cluster.tutor$syntax)==changeList[[name]][i]] <- comArgs[2]
			}
		}
	}else if(exists("assignedSyntax"))
	{
			for(i in 1:length(changeList[[name]]))
			{
				assignedSyntax[names(assignedSyntax)==changeList[[name]][i]] <- comArgs[2]
			}
	}else if(exists("saveList"))
	{
			for(i in 1:length(changeList[[name]]))
			{
				saveList$out.assign[names(saveList$out.assign)==changeList[[name]][i]] <- comArgs[2]
			}
	}
}

if(exists("out.cluster.tutor"))
{
	#print("writing workspace.rdata")
	save(out.cluster.tutor,file=paste(comArgs[1],"voice_results/workspace.Rdata",sep=""))
}else if(exists("assignedSyntax"))
{
	#print("writing assigned_complete_workspace.rdata")
	save(assignedSyntax,file=paste(comArgs[1],"voice_results/assigned_complete_workspace.Rdata",sep=""))
	load(paste(comArgs[1],"voice_results/assign_workspace.Rdata",sep=""))
	saveList$out.assign <- assignedSyntax
	save(saveList,file=paste(comArgs[1],"voice_results/assign_workspace.Rdata",sep=""))
}else if(exists("saveList"))
{
	#print("writing assign_workspace.rdata")
	save(saveList,file=paste(comArgs[1],"voice_results/assign_workspace.Rdata",sep=""))
}

