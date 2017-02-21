comArgs <- commandArgs(T)
options(stringsAsFactors=FALSE)
options(warn=-1)

sink("/dev/null")
suppressMessages(library(WGCNA))
options(warn=-1)
sink()

if(!exists("flashClust")){flashClust <- hclust}

Filedir <- comArgs[1]
if(!strsplit(Filedir,"")[[1]][length(strsplit(Filedir,"")[[1]])]=="/"){comArgs[1] <- paste(comArgs[1],"/",sep="")}
Filedir <- comArgs[1]
if(file.exists(paste(comArgs[1],"workspace.Rdata",sep="")))
{
	load(paste(comArgs[1],"workspace.Rdata",sep=""))
	if("mergedSyntax" %in% names(out.cluster.tutor))
	{
		syntax <- out.cluster.tutor$mergedSyntax
	}else
	{
		syntax <- out.cluster.tutor$syntax
	}
}else if(file.exists(paste(comArgs[1],"assign_workspace.Rdata",sep="")))
{
	load(paste(comArgs[1],"assign_workspace.Rdata",sep=""))
	syntax <- saveList$out.assign
}

originalData <- read.csv(paste(comArgs[1],"acoustic_data.csv",sep=""),header=TRUE,row.names=1)

clusters = unique(syntax)
clusterTable = list()
	
for(value in clusters)
{
	tempClust <- syntax[syntax==value]
	refs <- names(tempClust)
	clusterTable[[value]] <- subset(originalData,rownames(originalData)%in%refs)
}

#getClusterWavs
	if(file.exists(paste(Filedir,"joined_clusters/",sep="")))
	{
		unlink(paste(Filedir,"joined_clusters/",sep=""),recursive=TRUE)
		dir.create(paste(Filedir,"joined_clusters/",sep=""))
	}else if(file.exists(paste(comArgs[1],"joined_clusters_assigned/",sep="")))
	{
		unlink(paste(comArgs[1],"joined_clusters_assigned/",sep=""),recursive=TRUE)
		dir.create(paste(comArgs[1],"joined_clusters_assigned/",sep=""))
	}else{
		dir.create(paste(comArgs[1],"joined_clusters_assigned/",sep=""))
	}

	Filedir <- gsub(" ","\\\\ ",Filedir)
	
	for(group in names(clusterTable))
	{
		#print(paste("Joining syllables for cluster: ",group))
		if(file.exists(paste(comArgs[1],"joined_clusters/",sep="")))
		{
			filename <- paste(Filedir,"joined_clusters/",group,".wav",sep="")
		}else if(file.exists(paste(comArgs[1],"joined_clusters_assigned/",sep="")))
		{
			filename <- paste(Filedir,"joined_clusters_assigned/",group,".wav",sep="")
		}else{
			dir.create(paste(comArgs[1],"joined_clusters_assigned/",sep=""))
		}
		
		namesIn <- rownames(clusterTable[[group]])
		names <- vector()
			
		for (name in namesIn)
		{
			if(nchar(name)<nchar(max(as.numeric(rownames(originalData)))))
			{
				name.assign <- paste("%0",nchar(max(as.numeric(rownames(originalData)))),"d",sep="")
				newName <- sprintf(name.assign,as.numeric(name))
				if(!Sys.info()['sysname']=="Darwin") {name.assign <- gsub(" ",0,newName)}
				names <- c(names,newName)
			}
			if(nchar(name)==nchar(max(as.numeric(rownames(originalData)))))
			{
				names <- c(names,name)
			}	
		}
		
		names <- paste(Filedir,"cut_syllables/",names,".wav",sep="")
		
		outwav <- paste(filename)
		if(file.exists(paste(comArgs[1],"joined_clusters/",sep="")))
		{
			tempoutwav <- paste(Filedir,"joined_clusters/tempout.wav",sep="")
		}else if(file.exists(paste(comArgs[1],"joined_clusters_assigned/",sep="")))
		{
			tempoutwav <- paste(Filedir,"joined_clusters_assigned/tempout.wav",sep="")
		}
		
		loop <- 0
		tot <- length(names)-1
		
		if(length(names)==1)
		{
			f1 <- gsub("\\\\ "," ",Filedir)
			n1 <- gsub("\\\\ "," ",names)
			if(file.exists(paste(comArgs[1],"joined_clusters/",sep="")))
			{
				file.copy(n1,paste(f1,"joined_clusters/",group,".wav",sep=""))
			}else if(file.exists(paste(comArgs[1],"joined_clusters_assigned/",sep="")))
			{
				file.copy(n1,paste(f1,"joined_clusters_assigned/",group,".wav",sep=""))
			}
		}
		
		if(length(names)>1)
		{
			for (name in 1:tot)
			{
				loop <- loop + 1
				if (loop > 1)
				{
					system(paste("sox",tempoutwav,names[loop],filename))
				}
			
				if (loop==1)
				{
					system(paste("sox",names[1],names[2],filename))
					loop <- loop+1
				}
				
				if(file.exists(paste(comArgs[1],"joined_clusters/",sep="")))
				{
					file.copy(gsub("\\\\ "," ",filename),paste(gsub("\\\\ "," ",Filedir),"joined_clusters/tempout.wav",sep=""),overwrite=TRUE)
				}else if(file.exists(paste(comArgs[1],"joined_clusters_assigned/",sep="")))
				{
					file.copy(gsub("\\\\ "," ",filename),paste(gsub("\\\\ "," ",Filedir),"joined_clusters_assigned/tempout.wav",sep=""),overwrite=TRUE)
				}
				
			}
			if(file.exists(paste(Filedir,"joined_clusters/",sep="")))
			{
				unlink(paste(Filedir,"joined_clusters/tempout.wav",sep=""))
			}else if(file.exists(paste(comArgs[1],"joined_clusters_assigned/",sep="")))
			{
				unlink(paste(Filedir,"joined_clusters_assigned/tempout.wav",sep=""))
			}
		}
	}
	
	Filedir <- gsub("\\\\ "," ",Filedir)
	#sortSyllableWavs
	if(file.exists(paste(comArgs[1],"sorted_syllables/",sep="")))
	{
		unlink(paste(comArgs[1],"sorted_syllables/",sep=""),recursive=TRUE)
		dir.create(paste(comArgs[1],"sorted_syllables/",sep=""))
	}else if(file.exists(paste(comArgs[1],"sorted_syllables_assigned/",sep="")))
	{
		unlink(paste(comArgs[1],"sorted_syllables_assigned/",sep=""),recursive=TRUE)
		dir.create(paste(comArgs[1],"sorted_syllables_assigned/",sep=""))
	}else{
		dir.create(paste(comArgs[1],"sorted_syllables_assigned/",sep=""))
	}
	
	names(syntax) <- grep(".",names(syntax))
	syntax[is.na(syntax)] <- "none"
	
	names(syntax) <- grep(".",names(syntax))
	syntax[is.na(syntax)] <- "none"
	
	clusters = unique(syntax)
	all.files <- list.files(paste(Filedir,"cut_syllables/",sep=""))
	for (name in clusters)
	{
		syls = subset(syntax,syntax==name)
		newnames <- vector()
		for (name2 in names(syls))
		{
			name.assign <- paste("%0",nchar(max(as.numeric(rownames(originalData)))),"s",sep="")
			name.out <- sprintf(name.assign,name2)
			if(!Sys.info()['sysname']=="Darwin") {name.out <- gsub(" ",0,name.out)}
			newnames <- c(newnames,name.out)
		}
		names(syls) <- gsub('\\.',"-",names(syls))
		
		file2 = paste(newnames,"wav",sep=".")
	
		for (wav in file2)
		{
			if(file.exists(paste(comArgs[1],"sorted_syllables/",sep="")))
			{
				if (!file.exists((paste(comArgs[1],"sorted_syllables/",name,sep=''))))
				{
					dir.create(paste(comArgs[1],"sorted_syllables/",name,sep=''))
				}
			}else if(file.exists(paste(comArgs[1],"sorted_syllables_assigned/",sep='')))
			{
				if (!file.exists((paste(comArgs[1],"sorted_syllables_assigned/",name,sep=''))))
				{
					dir.create(paste(comArgs[1],"sorted_syllables_assigned/",name,sep=''))
				}
			}
			if(file.exists(paste(comArgs[1],"sorted_syllables/",sep="")))
			{
				file.copy(from=paste(comArgs[1],"cut_syllables/",wav,sep=''),to=paste(comArgs[1],"sorted_syllables/",name,sep=''))
			}else if(file.exists(paste(comArgs[1],"sorted_syllables_assigned/",sep="")))
			{
				file.copy(from=paste(comArgs[1],"cut_syllables/",wav,sep=''),to=paste(comArgs[1],"sorted_syllables_assigned/",name,sep=''))
			}
		}		
	}
	
	#clusterAcousticsOut
	
	if(file.exists(paste(comArgs[1],'cluster_tables/',sep="")))
	{
		unlink(paste(comArgs[1],'cluster_tables/',sep=""),recursive=TRUE)
		unlink(paste(comArgs[1],'cluster_tables_mat',sep=""),recursive=TRUE)
		dir.create(paste(comArgs[1],"cluster_tables/",sep=''))
    	dir.create(paste(comArgs[1],"cluster_tables_mat/",sep=''))
    	for (cluster in names(clusterTable))
		{
			filename = paste(cluster,sep='',".csv")
			write.csv(as.data.frame(clusterTable[[cluster]]),file=paste(comArgs[1],'cluster_tables/',filename,sep=""))
   		    write.table(as.data.frame(clusterTable[[cluster]][,																								2]),file=paste(comArgs[1],'cluster_tables_mat/',filename,sep=""),row.names=FALSE,col.names=FALSE,sep=",")
		}
		
		input = out.cluster.tutor$data
		distM=dist(input,method='euclidean')
		out = flashClust(as.dist(distM),method='average')
	
		pdf(file=paste(comArgs[1],"cluster_dendrogram.pdf",sep=""))
		if("mergedSyntax" %in% names(out.cluster.tutor))
		{
			plotDendroAndColors(dendro=out,colors=cbind(out.cluster.tutor$syntax,out.cluster.tutor															$mergedSyntax),dendroLabels=FALSE,groupLabels=c("unmerged","merged"))
		
			out.cluster.tutor$usedColors <- unique(c(out.cluster.tutor$mergedSyntax,out.cluster.tutor$syntax))
		}else
		{
			plotDendroAndColors(dendro=out,colors=cbind(out.cluster.tutor$syntax),dendroLabels=FALSE,groupLabels="unmerged")
			out.cluster.tutor$usedColors <- unique(out.cluster.tutor$syntax)
		}
		save(out.cluster.tutor,file=paste(comArgs[1],"workspace.Rdata",sep=""))
		write.table(t(colors()[!colors()%in%out.cluster.tutor																							$usedColors]),paste(comArgs[1],'unusedColors.txt',sep=""),row.names=FALSE,col.names=FALSE,sep="\n")
		z=dev.off()
	}else{
		options(warn=-1)
		unlink(paste(comArgs[1],'cluster_tables_assigned/',sep=""),recursive=TRUE)
		unlink(paste(comArgs[1],'cluster_tables_mat',sep=""),recursive=TRUE)
		dir.create(paste(comArgs[1],"cluster_tables_assigned/",sep=''))
    	dir.create(paste(comArgs[1],"cluster_tables_mat/",sep=''))
    	for (cluster in names(clusterTable))
		{
			filename = paste(cluster,sep='',".csv")
			#write.csv(as.data.frame(clusterTable[[cluster]]),file=paste(comArgs[1],'cluster_tables_assigned/',filename,sep=""))
   		    write.table(as.data.frame(clusterTable[[cluster]][,2]), file=paste(comArgs[1],'cluster_tables_mat/',filename,sep=""),row.names=FALSE,col.names=FALSE,sep=",")
		}
	}

	
	
	
	

