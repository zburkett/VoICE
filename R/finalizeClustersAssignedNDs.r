if(.Platform$OS.type=="windows" & file.exists("./.libraries")){.libPaths("./.libraries")}
if(.Platform$OS.type=="unix")
{

	comArgs <- commandArgs(T)

	Filedir <- comArgs[1]
	refDir <- comArgs[2]

	options(stringsAsFactors=FALSE)
	suppressMessages(library(gdata))
	options(warn=-1)

	load(paste(Filedir,"assign_workspace.Rdata",sep=""))

	originalData <- read.csv(paste(Filedir,".acoustic_data.csv",sep=""),header=TRUE)
	originalData <- originalData[,-1]
	#originalData <- originalData[-c(1,2),]
	#colnames(originalData) <-c("name","syllable.duration","syllable.start","mean.amplitude","mean.pitch","mean.FM","mean.AM.2","mean.entropy","mean.pitch.goodness","mean.mean.freq","var.pitch","var.FM","var.entropy","var.pitch.goodness","var.mean.freq","var.AM","month","day","hour","minute","second","cluster","file.name","comments")
	
	for(col in 1:ncol(originalData))
	{
		test <- is.numeric(originalData[,col])
		if(sum(is.na(test))>0)
		{
			originalData[,col] <- as.numeric(originalData[,col])
		}
	}
	dupes <- duplicated(originalData)
	originalData <- originalData[!dupes,]
	
	#rownames(originalData) <- 1:nrow(originalData)
	
	#syllable.end <- as.numeric(originalData[,"syllable.duration"])+as.numeric(originalData[,"syllable.start"])
	#originalData <- cbind(originalData[,1:3],syllable.end,originalData[,4:ncol(originalData)])
	
		syntax = saveList$out.assign
		clusters = unique(syntax)
		clusterTable = list()
	
		for(value in clusters)
		{
			tempClust <- syntax[syntax==value]
			refs <- names(tempClust)
			clusterTable[[value]] <- subset(originalData,rownames(originalData)%in%refs)
		}
	
		#getClusterWavs
		if(file.exists(paste(Filedir,"joined_clusters_assigned/",sep="")))
		{
			unlink(paste(Filedir,"joined_clusters_assigned/",sep=""),recursive=TRUE)
		}
	
		dir.create(paste(Filedir,"joined_clusters_assigned/",sep=""))
	
		Filedir <- gsub(" ","\\\\ ",Filedir)
	
		for(group in names(clusterTable))
		{
			#print(paste("Joining syllables for cluster: ",group))
			filename <- paste(Filedir,"joined_clusters_assigned/",group,".wav",sep="")
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
			names <- paste(Filedir,"voice_results/cut_syllables/",names,".wav",sep="")
		
			outwav <- paste(filename)
			tempoutwav <- paste(Filedir,"joined_clusters_assigned/tempout.wav",sep="")
			loop <- 0
			tot <- length(names)-1
		
			if(length(names)==1)
			{
				names <- gsub("\\\\ "," ",names)
				Fdir2 <- gsub("\\\\ "," ",Filedir)
				file.copy(names,paste(Fdir2,"joined_clusters_assigned/",group,".wav",sep=""))
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
					file.copy(gsub("\\\\ "," ",filename),paste(gsub("\\\\ "," ",Filedir),"joined_clusters_assigned/tempout.wav",sep=""),overwrite=TRUE)
				}
				unlink(paste(Filedir,"joined_clusters_assigned/tempout.wav",sep=""))
			}
		}
	
		Filedir <- gsub("\\\\ "," ",Filedir)
		#sortSyllableWavs
		if(file.exists(paste(Filedir,"sorted_syllables_assigned/",sep="")))
		{
			unlink(paste(Filedir,"sorted_syllables_assigned/",sep=""),recursive=TRUE)
		}
		dir.create(paste(Filedir,"sorted_syllables_assigned/",sep=""))
	
		names(syntax) <- grep(".",names(syntax))
		syntax[is.na(syntax)] <- "none"
	
		clusters = unique(syntax)
		all.files <- list.files(paste(Filedir,"voice_results/cut_syllables/",sep=""))
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
				if (!file.exists((paste(Filedir,"sorted_syllables_assigned/",name,sep=''))))
				{
					dir.create(paste(Filedir,"sorted_syllables_assigned/",name,sep=''))
				}
			
				file.copy(from=paste(Filedir,"voice_results/cut_syllables/",wav,sep=''),to=paste(Filedir,"sorted_syllables_assigned/",name,sep=''))
			}		
		}
	
		#clusterAcousticsOut
	
		if(file.exists(paste(Filedir,'cluster_tables_assigned/',sep="")))
		{
			unlink(paste(Filedir,'cluster_tables_assigned/',sep=""),recursive=TRUE)
		}
	
		if(file.exists(paste(Filedir,'.cluster_tables_mat/',sep="")))
		{
			unlink(paste(Filedir,'.cluster_tables_mat/',sep=""),recursive=TRUE)
		}
	
		dir.create(paste(Filedir,".cluster_tables_mat/",sep=''))	
		dir.create(paste(Filedir,"cluster_tables_assigned/",sep=''))
		if(.Platform$OS.type=="windows"){system(paste('attrib +h',paste(Filedir,".cluster_tables_mat/",sep='')))}
	
		for (cluster in names(clusterTable))
		{
			filename = paste(cluster,sep='',".csv")
			write.csv(as.data.frame(clusterTable[[cluster]]),file=paste(Filedir,'cluster_tables_assigned/',filename,sep=""))
			write.table(as.data.frame(clusterTable[[cluster]][,2]),file=paste(Filedir,'.cluster_tables_mat/',filename,sep=""),row.names=FALSE,col.names=FALSE,sep=",")
		}
	
		load(paste(refDir,"/workspace.Rdata",sep=""))
		usedColors <- unique(c(out.cluster.tutor$usedColors,saveList$out.assign))
		write.table(t(colors()[!colors()%in%usedColors]),paste(comArgs[1],'.unusedColors.txt',sep=""),row.names=FALSE,col.names=FALSE,sep="\n")
	
		assignedSyntax <- saveList$out.assign
	
		save(saveList,file=paste(Filedir,"assign_workspace.Rdata",sep=""))
		save(assignedSyntax,file=paste(Filedir,"assigned_complete_workspace.Rdata",sep=""))
}else if (.Platform$OS.type=="windows")
{
	comArgs <- commandArgs(T)

	Filedir <- comArgs[1]
	refDir <- comArgs[2]

	options(stringsAsFactors=FALSE)
	suppressMessages(library(gdata))
	options(warn=-1)

	load(paste(Filedir,"assign_workspace.Rdata",sep=""))

	originalData <- read.csv(paste(Filedir,".acoustic_data.csv",sep=""),header=TRUE)
	originalData <- originalData[,-1]
	#originalData <- originalData[-c(1,2),]
	#colnames(originalData) <-c("name","syllable.duration","syllable.start","mean.amplitude","mean.pitch","mean.FM","mean.AM.2","mean.entropy","mean.pitch.goodness","mean.mean.freq","var.pitch","var.FM","var.entropy","var.pitch.goodness","var.mean.freq","var.AM","month","day","hour","minute","second","cluster","file.name","comments")
	
	for(col in 1:ncol(originalData))
	{
		test <- is.numeric(originalData[,col])
		if(sum(is.na(test))>0)
		{
			originalData[,col] <- as.numeric(originalData[,col])
		}
	}
	dupes <- duplicated(originalData)
	originalData <- originalData[!dupes,]
	
	#rownames(originalData) <- 1:nrow(originalData)
	
	#syllable.end <- as.numeric(originalData[,"syllable.duration"])+as.numeric(originalData[,"syllable.start"])
	#originalData <- cbind(originalData[,1:3],syllable.end,originalData[,4:ncol(originalData)])
	
		syntax = saveList$out.assign
		clusters = unique(syntax)
		clusterTable = list()
	
		for(value in clusters)
		{
			tempClust <- syntax[syntax==value]
			refs <- names(tempClust)
			clusterTable[[value]] <- subset(originalData,rownames(originalData)%in%refs)
		}
	
		#getClusterWavs
		if(file.exists(paste(Filedir,"joined_clusters_assigned/",sep="")))
		{
			unlink(paste(Filedir,"joined_clusters_assigned/",sep=""),recursive=TRUE)
		}
	
		dir.create(paste(Filedir,"joined_clusters_assigned/",sep=""))
	
		#Filedir <- gsub(" ","\\\\ ",Filedir)
	
		for(group in names(clusterTable))
		{
			#print(paste("Joining syllables for cluster: ",group))
			filename <- paste(Filedir,"joined_clusters_assigned/",group,".wav",sep="")
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
			names <- paste(Filedir,"voice_results/cut_syllables/",names,".wav",sep="")
		
			outwav <- paste(filename)
			tempoutwav <- paste(Filedir,"joined_clusters_assigned/tempout.wav",sep="")
			loop <- 0
			tot <- length(names)-1
		
			if(length(names)==1)
			{
				#names <- gsub("\\\\ "," ",names)
				#Fdir2 <- gsub("\\\\ "," ",Filedir)
				file.copy(names,paste(Filedir,"joined_clusters_assigned/",group,".wav",sep=""))
			}
		
			if(length(names)>1)
			{
				for (name in 1:tot)
				{
					loop <- loop + 1
					if (loop > 1)
					{
						system(paste("sox",dQuote(tempoutwav),dQuote(names[loop]),dQuote(filename)))
					}
			
					if (loop==1)
					{
						system(paste("sox",dQuote(names[1]),dQuote(names[2]),dQuote(filename)))
						loop <- loop+1
					}
					file.copy(filename,paste(Filedir,"joined_clusters_assigned/tempout.wav",sep=""),overwrite=TRUE)
				}
				unlink(paste(Filedir,"joined_clusters_assigned/tempout.wav",sep=""))
			}
		}
	
		#Filedir <- gsub("\\\\ "," ",Filedir)
		#sortSyllableWavs
		if(file.exists(paste(Filedir,"sorted_syllables_assigned",sep="")))
		{
			unlink(paste(Filedir,"sorted_syllables_assigned/",sep=""),recursive=TRUE)
		}
		dir.create(paste(Filedir,"sorted_syllables_assigned/",sep=""))
	
		names(syntax) <- grep(".",names(syntax))
		syntax[is.na(syntax)] <- "none"
	
		clusters = unique(syntax)
		all.files <- list.files(paste(Filedir,"voice_results/cut_syllables/",sep=""))
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
				if (!file.exists((paste(Filedir,"sorted_syllables_assigned",name,sep=''))))
				{
					dir.create(paste(Filedir,"sorted_syllables_assigned/",name,sep=''))
				}
			
				file.copy(from=paste(Filedir,"voice_results/cut_syllables/",wav,sep=''),to=paste(Filedir,"sorted_syllables_assigned/",name,sep=''))
			}		
		}
	
		#clusterAcousticsOut
	
		if(file.exists(paste(Filedir,'cluster_tables_assigned',sep="")))
		{
			unlink(paste(Filedir,'cluster_tables_assigned/',sep=""),recursive=TRUE)
		}
	
		if(file.exists(paste(Filedir,'.cluster_tables_mat',sep="")))
		{
			unlink(paste(Filedir,'.cluster_tables_mat/',sep=""),recursive=TRUE)
		}
	
		dir.create(paste(Filedir,".cluster_tables_mat/",sep=''))	
		dir.create(paste(Filedir,"cluster_tables_assigned/",sep=''))
		if(.Platform$OS.type=="windows"){system(paste('attrib +h',paste(Filedir,".cluster_tables_mat/",sep='')))}
	
		for (cluster in names(clusterTable))
		{
			filename = paste(cluster,sep='',".csv")
			write.csv(as.data.frame(clusterTable[[cluster]]),file=paste(Filedir,'cluster_tables_assigned/',filename,sep=""))
			write.table(as.data.frame(clusterTable[[cluster]][,2]),file=paste(Filedir,'.cluster_tables_mat/',filename,sep=""),row.names=FALSE,col.names=FALSE,sep=",")
		}
	
		load(paste(refDir,"/workspace.Rdata",sep=""))
		usedColors <- unique(c(out.cluster.tutor$usedColors,saveList$out.assign))
		write.table(t(colors()[!colors()%in%usedColors]),paste(comArgs[1],'.unusedColors.txt',sep=""),row.names=FALSE,col.names=FALSE,sep="\n")
		if(.Platform$OS.type=="windows"){system(paste('attrib +h',paste(comArgs[1],'.unusedColors.txt',sep="")))}
	
		assignedSyntax <- saveList$out.assign
	
		save(saveList,file=paste(Filedir,"assign_workspace.Rdata",sep=""))
		save(assignedSyntax,file=paste(Filedir,"assigned_complete_workspace.Rdata",sep=""))
}