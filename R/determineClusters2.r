if(.Platform$OS.type=="windows" & file.exists("./.libraries")){.libPaths("./.libraries")}
if(.Platform$OS.type=="unix")
{
	comArgs <- commandArgs(T)
	options(stringsAsFactors=FALSE)
	options(warn=-1)

	sink("/dev/null")
	suppressMessages(library(WGCNA))
	suppressMessages(library(gdata))
	options(warn=-1)
	sink()
	if(!exists("flashClust")){flashClust <- hclust}

	Filedir = comArgs[1]
	thresh = as.numeric(comArgs[2])

	input <- read.csv(paste(Filedir,"similarity_batch_self.csv",sep=""),header=FALSE)
	input <- input[,1:6]
	colnames(input) <- c("Sound 1", "Sound 2","Similarity","Accuracy","Seq. Match","globalsim")
	input[,3] <- 100*input[,3]
	input[,4] <- 100*input[,4]
	input[,5] <- 100*input[,5]
	input[,6] <- 100*input[,6]
	n <- sqrt(nrow(input))
	identMat <- matrix(nrow=n,ncol=n)
	rownames(identMat) <- input[1:n,1]
	colnames(identMat) <- input[1:n,1]
		
	count <- 0
	for (col in 1:ncol(identMat))
	{
		count = count+1
		end <- count*ncol(identMat)
		start <- (end-ncol(identMat))+1
		identMat[,col] <- input[start:end,6]
	}
		
	rownames(identMat) <- as.numeric(gsub(".wav","",rownames(identMat)))
	colnames(identMat) <- as.numeric(gsub(".wav","",colnames(identMat)))

	input <- identMat
	rm(identMat)	

	#Create distance matrix from GS matrix 
	distM=dist(input,method='euclidean')
	
	#Create dendrogram and cut using most divisive parameters
	out = flashClust(as.dist(distM),method='average')
	groupsOut = cutreeDynamic(out,minClusterSize=1,method="hybrid",distM=as.matrix(distM),deepSplit=4,verbose=0)
	groupsOut[groupsOut==0] <- max(groupsOut)+1
	names(groupsOut)=rownames(input)
	dynamicColors = labels2colors(groupsOut)
	names(dynamicColors) = names(groupsOut)
	
	#Calculate cluster eigensyllables
	MEList = moduleEigengenes(t(input),colors=dynamicColors,scale=FALSE,excludeGrey=TRUE)
	MEs = MEList$eigengenes
	MEnames = gsub("ME",'',names(MEs))
	
	#Determine correlations between eigensyllables and merges based on mergeThresh (see function arguments)
	MEDiss = 1-cor(MEs)
	METree = flashClust(as.dist(MEDiss), method = "average")
	MEDissThres = 1-thresh #indicates 1-mergeThresh correlation of eigensyllables for merge
	merge = mergeCloseModules(t(input),dynamicColors,cutHeight=thresh,verbose=0,unassdColor="grey",trapErrors=TRUE)
	mergedColors = merge$colors
	names(mergedColors)=names(groupsOut)
	mergedMEs = merge$newMEs
	mergedMETree=flashClust(as.dist(1-cor(mergedMEs)),method="average")
	mergedMEList = moduleEigengenes(t(input),colors=mergedColors,scale=FALSE)
	colnames(mergedMEList$varExplained)=colnames(mergedMEList$eigengenes)

	#originalData <- read.xls(acousticData,header=FALSE)
	originalData <- read.csv(paste(comArgs[1],"acoustic_data.csv",sep=""));
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
	
	rownames(originalData) <- 1:nrow(originalData)
	
	#syllable.end <- as.numeric(originalData[,"syllable.duration"])+as.numeric(originalData[,"syllable.start"])
	#originalData <- cbind(originalData[,1:3],syllable.end,originalData[,4:ncol(originalData)])
	
		out.cluster = list(data=input, syntax=dynamicColors, mergedSyntax=merge$colors, eigensyls=mergedMEList$eigengenes, varianceExp=mergedMEList$varExplained)	
	
		names(out.cluster$varianceExp) <- names(out$eigensyls)
	
		syntax = merge$colors
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
		}
	
		dir.create(paste(Filedir,"joined_clusters/",sep=""))
	
		Filedir <- gsub(" ","\\\\ ",Filedir)
	
		for(group in names(clusterTable))
		{
			#print(paste("Joining syllables for cluster: ",group))
			filename <- paste(Filedir,"joined_clusters/",group,".wav",sep="")
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
			tempoutwav <- paste(Filedir,"joined_clusters/tempout.wav",sep="")
			loop <- 0
			tot <- length(names)-1
		
			if(length(names)==1)
			{
				file.copy(names,paste(Filedir,"joined_clusters/",group,".wav",sep=""))
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
					file.copy(gsub("\\\\ "," ",filename),paste(gsub("\\\\ "," ",Filedir),"joined_clusters/tempout.wav",sep=""),overwrite=TRUE)
				}
				unlink(paste(Filedir,"joined_clusters/tempout.wav",sep=""))
			}
		}
	
		Filedir <- gsub("\\\\ "," ",Filedir)
		#sortSyllableWavs
		if(file.exists(paste(Filedir,"sorted_syllables/",sep="")))
		{
			unlink(paste(Filedir,"sorted_syllables/",sep=""),recursive=TRUE)
		}
		dir.create(paste(Filedir,"sorted_syllables/",sep=""))
	
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
				if (!file.exists((paste(Filedir,"sorted_syllables/",name,sep=''))))
				{
					dir.create(paste(Filedir,"sorted_syllables/",name,sep=''))
				}
			
				file.copy(from=paste(Filedir,"cut_syllables/",wav,sep=''),to=paste(Filedir,"sorted_syllables/",name,sep=''))
			}		
		}
	
		#clusterAcousticsOut
	
		if(file.exists(paste(Filedir,'cluster_tables/',sep="")))
		{
			unlink(paste(Filedir,'cluster_tables/',sep=""),recursive=TRUE)
		}
	
		if(file.exists(paste(Filedir,'cluster_tables_mat/',sep="")))
		{
			unlink(paste(Filedir,'cluster_tables_mat/',sep=""),recursive=TRUE)
		}
	
		dir.create(paste(Filedir,"cluster_tables/",sep=''))
	    dir.create(paste(Filedir,"cluster_tables_mat/",sep=''))
	
		for (cluster in names(clusterTable))
		{
			filename = paste(cluster,sep='',".csv")
			write.csv(as.data.frame(clusterTable[[cluster]]),file=paste(Filedir,'cluster_tables/',filename,sep=""))
	        write.table(as.data.frame(clusterTable[[cluster]][,2]),file=paste(Filedir,'cluster_tables_mat/',filename,sep=""),row.names=FALSE,col.names=FALSE,sep=",")
		}

	    if ("mergedSyntax" %in% names(out.cluster) & "syntax" %in% names(out.cluster))
	    {
	        usedColors <- unique(c(out.cluster$mergedSyntax,out.cluster$syntax))
	    }

	    if ("mergedSyntax" %in% names(out.cluster) & !"syntax" %in% names(out.cluster))
	    {
	        usedColors <- unique(out.cluster$mergedSyntax)
	    }

	    if (!"mergedSyntax" %in% names(out.cluster) & !"syntax" %in% names(out.cluster))
	    {
	        usedColors <- unique(out.cluster$syntax)
	    }

	    write.table(t(colors()[!colors()%in%usedColors]),paste(comArgs[1],'unusedColors.txt',sep=""),row.names=FALSE,col.names=FALSE,sep="\n")

	    out.cluster$usedColors <- usedColors
		out.cluster.tutor <- out.cluster
		save(out.cluster.tutor,file=paste(Filedir,"workspace.Rdata",sep=""))


	pdf(file=paste(Filedir,"cluster_dendrogram.pdf",sep=""))
	plotDendroAndColors(dendro=out,colors=cbind(dynamicColors,merge$colors),dendroLabels=FALSE,groupLabels=c("unmerged","merged"))
	z=dev.off()
}else if (.Platform$OS.type=="windows")
{
    comArgs <- commandArgs(T)
	options(stringsAsFactors=FALSE)
	options(warn=-1)

	sink(paste(comArgs[1],"sink.txt",sep=""))
	suppressMessages(library(WGCNA))
	suppressMessages(library(gdata))
	options(warn=-1)
	sink()
	unlink(paste(comArgs[1],"sink.txt",sep=""))
	
	Filedir = comArgs[1]
	thresh = as.numeric(comArgs[2])
	
	input <- read.csv(paste(Filedir,"similarity_batch_self.csv",sep=""),header=FALSE)
	input <- input[,1:6]
	colnames(input) <- c("Sound 1", "Sound 2","Similarity","Accuracy","Seq. Match","globalsim")
	input[,3] <- 100*input[,3]
	input[,4] <- 100*input[,4]
	input[,5] <- 100*input[,5]
	input[,6] <- 100*input[,6]
	n <- sqrt(nrow(input))
	identMat <- matrix(nrow=n,ncol=n)
	rownames(identMat) <- input[1:n,1]
	colnames(identMat) <- input[1:n,1]
			
	count <- 0
	for (col in 1:ncol(identMat))
	{
		count = count+1
		end <- count*ncol(identMat)
		start <- (end-ncol(identMat))+1
		identMat[,col] <- input[start:end,6]
	}
			
	rownames(identMat) <- as.numeric(gsub(".wav","",rownames(identMat)))
	colnames(identMat) <- as.numeric(gsub(".wav","",colnames(identMat)))
	
	input <- identMat
	rm(identMat)	
	
	#Create distance matrix from GS matrix 
	distM=dist(input,method='euclidean')
		
	#Create dendrogram and cut using most divisive parameters
	out = hclust(as.dist(distM),method='average')
	groupsOut = cutreeDynamic(out,minClusterSize=1,method="hybrid",distM=as.matrix(distM),deepSplit=4,verbose=0)
	names(groupsOut)=rownames(input)
	dynamicColors = labels2colors(groupsOut)
	names(dynamicColors) = names(groupsOut)
		
	#Calculate cluster eigensyllables
	MEList = moduleEigengenes(t(input),colors=dynamicColors,scale=FALSE,excludeGrey=TRUE)
	MEs = MEList$eigengenes
	MEnames = gsub("ME",'',names(MEs))
		
	#Determine correlations between eigensyllables and merges based on mergeThresh (see function arguments)
	MEDiss = 1-cor(MEs)
	METree = hclust(as.dist(MEDiss), method = "average")
	MEDissThres = 1-thresh #indicates 1-mergeThresh correlation of eigensyllables for merge
	merge = mergeCloseModules(t(input),dynamicColors,cutHeight=thresh,verbose=0,unassdColor="grey",trapErrors=TRUE)
	mergedColors = merge$colors
	names(mergedColors)=names(groupsOut)
	mergedMEs = merge$newMEs
	mergedMETree=hclust(as.dist(1-cor(mergedMEs)),method="average")
	mergedMEList = moduleEigengenes(t(input),colors=mergedColors,scale=FALSE)
	colnames(mergedMEList$varExplained)=colnames(mergedMEList$eigengenes)
	
	#originalData <- read.xls(acousticData,header=FALSE)
	originalData <- read.csv(paste(comArgs[1],"acoustic_data.csv",sep=""));
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
		
	rownames(originalData) <- 1:nrow(originalData)
		
	#syllable.end <- as.numeric(originalData[,"syllable.duration"])+as.numeric(originalData[,"syllable.start"])
	#originalData <- cbind(originalData[,1:3],syllable.end,originalData[,4:ncol(originalData)])
		
		out.cluster = list(data=input, syntax=dynamicColors, mergedSyntax=merge$colors, eigensyls=mergedMEList$eigengenes, varianceExp=mergedMEList$varExplained)	
		
		names(out.cluster$varianceExp) <- names(out$eigensyls)
		
		syntax = merge$colors
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
		}
		
		dir.create(paste(Filedir,"joined_clusters/",sep=""))
		
		#Filedir <- gsub(" ","\\\\ ",Filedir)
		
		for(group in names(clusterTable))
		{
			#print(paste("Joining syllables for cluster: ",group))
			filename <- paste(Filedir,"joined_clusters/",group,".wav",sep="")
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
			tempoutwav <- paste(Filedir,"joined_clusters/tempout.wav",sep="")
			loop <- 0
			tot <- length(names)-1
			
			if(length(names)==1)
			{
				file.copy(names,paste(Filedir,"joined_clusters/",group,".wav",sep=""))
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
					file.copy(gsub("\\\\ "," ",filename),paste(gsub("\\\\ "," ",Filedir),"joined_clusters/tempout.wav",sep=""),overwrite=TRUE)
				}
				unlink(paste(Filedir,"joined_clusters/tempout.wav",sep=""))
			}
		}
		
		#Filedir <- gsub("\\\\ "," ",Filedir)
		#sortSyllableWavs
		if(file.exists(paste(Filedir,"sorted_syllables/",sep="")))
		{
			unlink(paste(Filedir,"sorted_syllables/",sep=""),recursive=TRUE)
		}
		dir.create(paste(Filedir,"sorted_syllables/",sep=""))
		
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
				if (!file.exists((paste(Filedir,"sorted_syllables/",name,sep=''))))
				{
					dir.create(paste(Filedir,"sorted_syllables/",name,sep=''))
				}
				
				file.copy(from=paste(Filedir,"cut_syllables/",wav,sep=''),to=paste(Filedir,"sorted_syllables/",name,sep=''))
			}		
		}
		
		#clusterAcousticsOut
		
		if(file.exists(paste(Filedir,'cluster_tables/',sep="")))
		{
			unlink(paste(Filedir,'cluster_tables/',sep=""),recursive=TRUE)
		}
		
		if(file.exists(paste(Filedir,'cluster_tables_mat/',sep="")))
		{
			unlink(paste(Filedir,'cluster_tables_mat/',sep=""),recursive=TRUE)
		}
		
		dir.create(paste(Filedir,"cluster_tables/",sep=''))
	    dir.create(paste(Filedir,"cluster_tables_mat/",sep=''))
		
		for (cluster in names(clusterTable))
		{
			filename = paste(cluster,sep='',".csv")
			write.csv(as.data.frame(clusterTable[[cluster]]),file=paste(Filedir,'cluster_tables/',filename,sep=""))
	        write.table(as.data.frame(clusterTable[[cluster]][,2]),file=paste(Filedir,'cluster_tables_mat/',filename,sep=""),row.names=FALSE,col.names=FALSE,sep=",")
		}
	
	    if ("mergedSyntax" %in% names(out.cluster) & "syntax" %in% names(out.cluster))
	    {
	        usedColors <- unique(c(out.cluster$mergedSyntax,out.cluster$syntax))
	    }
	
	    if ("mergedSyntax" %in% names(out.cluster) & !"syntax" %in% names(out.cluster))
	    {
	        usedColors <- unique(out.cluster$mergedSyntax)
	    }
	
	    if (!"mergedSyntax" %in% names(out.cluster) & !"syntax" %in% names(out.cluster))
	    {
	        usedColors <- unique(out.cluster$syntax)
	    }
	
	    write.table(t(colors()[!colors()%in%usedColors]),paste(comArgs[1],'unusedColors.txt',sep=""),row.names=FALSE,col.names=FALSE,sep="\n")
	
	    out.cluster$usedColors <- usedColors
		out.cluster.tutor <- out.cluster
		save(out.cluster.tutor,file=paste(Filedir,"workspace.Rdata",sep=""))
	
	
	pdf(file=paste(Filedir,"cluster_dendrogram.pdf",sep=""))
	plotDendroAndColors(dendro=out,colors=cbind(dynamicColors,merge$colors),dendroLabels=FALSE,groupLabels=c("unmerged","merged"))
	z=dev.off()
}

