if(.Platform$OS.type=="windows" & file.exists("./.libraries")){.libPaths("./.libraries")}
if(.Platform$OS.type=="unix")
{
	comArgs <- commandArgs(T)
	options(stringsAsFactors=FALSE)
	options(warn=-1)
	sink("/dev/null")
	suppressMessages(library(WGCNA))
	sink()

	folder1 <- comArgs[1]
	pct <- as.numeric(comArgs[2])


	if (file.exists(paste(folder1,"/workspace.Rdata",sep="")))
	{
	load(paste(folder1,"/workspace.Rdata",sep=""))
	}else if (file.exists(paste(folder1,"assign_workspace.Rdata",sep="/"))) #changed to an else if by ZB 9/17/14 to fix reassignment issue
	{
	load(paste(folder1,"assign_workspace.Rdata",sep="/"))
	assignedSyntax <- saveList$out.assign #added by ND 9/16/14 in lieu of loading assigned_workspace_complete
	}

	#if (file.exists(paste(folder1,"assigned_complete_workspace.Rdata",sep="/")))
	#{
	#load(paste(folder1,"assigned_complete_workspace.Rdata",sep="/"))
	#}

	if(file.exists(paste(folder1,"/sorted_syllables_for_batch/",sep="")))
	{
		 unlink(paste(folder1,"/sorted_syllables_for_batch/",sep=""),recursive=TRUE)		
	}
		
	dir.create(paste(folder1,"/sorted_syllables_for_batch/",sep=""))

	final.acoustic <- read.csv(paste(folder1,"/.acoustic_data.csv",sep=""),header=TRUE)

	final.acoustic <-final.acoustic[,c("syllable.duration","mean.pitch","mean.FM","mean.entropy","mean.pitch.goodness","var.pitch","mean.mean.freq","var.FM","var.entropy","var.pitch.goodness","var.mean.freq","var.AM")] 

	    #determine number of clusters depending on syntax input (see lines 12 and 17)

		if(exists("out.cluster.tutor"))
	    {
	        clusters<-unique(out.cluster.tutor$mergedSyntax)
	        assignedSyntax <- out.cluster.tutor$mergedSyntax
	    }
	    if(exists("assignedSyntax")){clusters<-unique(assignedSyntax)} #present in assigned_workspace_complete
	   #the number of clusters
		clusterTable = list() #empty list

		for (value in clusters)
		{
			tempClust = assignedSyntax[assignedSyntax==value] #cycle through clusters
			refs = names(tempClust) #names of the syllables in the cluster
			clusterTable[[value]] = subset(final.acoustic,rownames(final.acoustic)%in%refs)
		}

	cTable <- clusterTable

	newMEs <- vector()
	varExp <- vector()
	for (name in names(cTable))
	{
		temp.ME <- moduleEigengenes(t(cTable[[name]]),colors=rep(name,nrow(cTable[[name]])),scale=FALSE)
		if (name == names(cTable)[1])
		{
			newMEs <- temp.ME$eigengenes
			varExp <- temp.ME$varExplained
		}
		if (name != names(cTable)[1])
		{
			newMEs <- cbind(newMEs,temp.ME$eigengenes)
			varExp <- c(varExp,temp.ME$varExplained)
		}
	}
	names(varExp) <- colnames(newMEs)

	#if(length(assignedSyntax)>4)
	#{
		#goodClusters <- vector()
		#for(cluster in unique(assignedSyntax))
		#{
		#	n.syllables <- sum(assignedSyntax==cluster)
		#	if(n.syllables > 1){goodClusters <- c(goodClusters,cluster)}
		#	if(n.syllables == 1){goodClusters <- goodClusters}
		#}
	
	for(cluster in unique(assignedSyntax))	
	#for(cluster in goodClusters)
		{
			clust.cor <- vector()
			clustNames <- subset(names(assignedSyntax),assignedSyntax==cluster)
			for(name in clustNames)
			{
				eigname <- paste("ME",cluster,sep="")
				clust.cor <- c(clust.cor,cor(t(final.acoustic[name,]),newMEs[,eigname]))
			}
			names(clust.cor) <- clustNames
			clust.cor <- sort(clust.cor,decreasing=TRUE)
			if(length(clust.cor)<=5){final.reps <- names(clust.cor)}
			if(length(clust.cor)>5){final.reps <- names(clust.cor)[1:c(round(length(clust.cor)*(pct/100)))]}
			if(length(final.reps)==1)
			{
				if(length(clust.cor)>5)
				{
					final.reps <- names(clust.cor)[1:5]
				}
				if(length(clust.cor)<=5)
				{
					final.reps <- names(clust.cor)
				}
			}
	
			dir.create(paste(folder1,"/sorted_syllables_for_batch/",cluster,sep=""))
	
			for(name in final.reps)
			{
				name.assign <- paste("%0",nchar(max(as.numeric(names(assignedSyntax)))),"s",sep="")
				name.out <- sprintf(name.assign,name)
			
				file.copy(paste(folder1,"/voice_results/cut_syllables/",name.out,".wav",sep=""),paste(folder1,"/sorted_syllables_for_batch/",cluster,"/",name.out,".wav",sep=""))
			}
		}
	#}
}else if (.Platform$OS.type=="windows")
{
	comArgs <- commandArgs(T)
	options(stringsAsFactors=FALSE)
	options(warn=-1)

	sink(paste(comArgs[1],"sink.txt",sep=""))
	suppressMessages(library(WGCNA))
	sink()
	unlink(paste(comArgs[1],"sink.txt",sep=""))

	folder1 <- comArgs[1]
	pct <- as.numeric(comArgs[2])


	if (file.exists(paste(folder1,"workspace.Rdata",sep="")))
	{
	    load(paste(folder1,"/workspace.Rdata",sep=""))
	}else if (file.exists(paste(folder1,"assign_workspace.Rdata",sep="")))
	{
	    load(paste(folder1,"assign_workspace.Rdata",sep=""))
	    assignedSyntax <- saveList$out.assign #added by ND 9/16/14 in lieu of loading assigned_workspace_complete
	}

	#if (file.exists(paste(folder1,"assigned_complete_workspace.Rdata",sep="/")))
	#{
	#load(paste(folder1,"assigned_complete_workspace.Rdata",sep="/"))
	#}

	if(file.exists(paste(folder1,"sorted_syllables_for_batch",sep="")))
	{
		 unlink(paste(folder1,"sorted_syllables_for_batch",sep=""),recursive=TRUE)		
	}
		
	dir.create(paste(folder1,"sorted_syllables_for_batch",sep=""))

	final.acoustic <- read.csv(paste(folder1,".acoustic_data.csv",sep=""),header=TRUE)

	final.acoustic <-final.acoustic[,c("syllable.duration","mean.pitch","mean.FM","mean.entropy","mean.pitch.goodness","var.pitch","mean.mean.freq","var.FM","var.entropy","var.pitch.goodness","var.mean.freq","var.AM")] 

	    #determine number of clusters depending on syntax input (see lines 12 and 17)

		if(exists("out.cluster.tutor"))
	    {
	        clusters<-unique(out.cluster.tutor$mergedSyntax)
	        assignedSyntax <- out.cluster.tutor$mergedSyntax
	    }
	    if(exists("assignedSyntax")){clusters<-unique(assignedSyntax)} #present in assigned_workspace_complete
	   #the number of clusters
		clusterTable = list() #empty list

		for (value in clusters)
		{
			tempClust = assignedSyntax[assignedSyntax==value] #cycle through clusters
			refs = names(tempClust) #names of the syllables in the cluster
			clusterTable[[value]] = subset(final.acoustic,rownames(final.acoustic)%in%refs)
		}

	cTable <- clusterTable

	newMEs <- vector()
	varExp <- vector()
	for (name in names(cTable))
	{
		temp.ME <- moduleEigengenes(t(cTable[[name]]),colors=rep(name,nrow(cTable[[name]])),scale=FALSE)
		if (name == names(cTable)[1])
		{
			newMEs <- temp.ME$eigengenes
			varExp <- temp.ME$varExplained
		}
		if (name != names(cTable)[1])
		{
			newMEs <- cbind(newMEs,temp.ME$eigengenes)
			varExp <- c(varExp,temp.ME$varExplained)
		}
	}
	names(varExp) <- colnames(newMEs)

	#if(length(assignedSyntax)>4)
	#{
		#goodClusters <- vector()
		#for(cluster in unique(assignedSyntax))
		#{
		#	n.syllables <- sum(assignedSyntax==cluster)
		#	if(n.syllables > 1){goodClusters <- c(goodClusters,cluster)}
		#	if(n.syllables == 1){goodClusters <- goodClusters}
		#}
	
	for(cluster in unique(assignedSyntax))	
	#for(cluster in goodClusters)
		{
			clust.cor <- vector()
			clustNames <- subset(names(assignedSyntax),assignedSyntax==cluster)
			for(name in clustNames)
			{
				eigname <- paste("ME",cluster,sep="")
				clust.cor <- c(clust.cor,cor(t(final.acoustic[name,]),newMEs[,eigname]))
			}
			names(clust.cor) <- clustNames
			clust.cor <- sort(clust.cor,decreasing=TRUE)
			if(length(clust.cor)<=5){final.reps <- names(clust.cor)}
			if(length(clust.cor)>5){final.reps <- names(clust.cor)[1:c(round(length(clust.cor)*(pct/100)))]}
			if(length(final.reps)==1)
			{
				if(length(clust.cor)>5)
				{
					final.reps <- names(clust.cor)[1:5]
				}
				if(length(clust.cor)<=5)
				{
					final.reps <- names(clust.cor)
				}
			}
	
			dir.create(paste(folder1,"sorted_syllables_for_batch/",cluster,sep=""))
	
			for(name in final.reps)
			{
				name.assign <- paste("%0",nchar(max(as.numeric(names(assignedSyntax)))),"s",sep="")
				name.out <- sprintf(name.assign,name)
			
				file.copy(paste(folder1,"voice_results/cut_syllables/",name.out,".wav",sep=""),paste(folder1,"sorted_syllables_for_batch/",cluster,"/",name.out,".wav",sep=""))
			}
		}
	#}
}	