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

	Filedir <- comArgs[2]
	tutorDir <- comArgs[3]
	thresh <- comArgs[1]

	if(!thresh=="none")
	{
		input <- read.csv(paste(Filedir,"voice_results/unassigned_for_cluster/similarity_batch_self.csv",sep=""),header=FALSE)
		input <- input[,1:6]
		colnames(input) <- c("Sound 1", "Sound 2","Similarity","Accuracy","Seq. Match","globalsim")
		input[,3] <- 100*input[,3]
		input[,4] <- 100*input[,4]
		input[,5] <- 100*input[,5]
		input[,6] <- 100*input[,6]
	
		loop=0
		for(val in unique(input[,2]))
		{
			loop=loop+1
			input[,2][input[,2]==val]=list.files(paste(Filedir,"voice_results/unassigned_for_cluster",sep=""))[loop]
			input[,1][input[,1]==val]=list.files(paste(Filedir,"voice_results/unassigned_for_cluster",sep=""))[loop]
		}
	
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
		MEList = moduleEigengenes(t(input),colors=dynamicColors,scale=FALSE,excludeGrey=FALSE,trapErrors=TRUE)
		MEs = MEList$eigengenes
		MEnames = gsub("ME",'',names(MEs))
		
		#Determine correlations between eigensyllables and merges based on mergeThresh (see function arguments)
		MEDiss = 1-cor(MEs)
		if (nrow(MEDiss)==1)
		{
		    mergedMEs <- MEs
		    dynamicColors <- MEList$validColors
		}else{
		METree = flashClust(as.dist(MEDiss), method = "average")
		MEDissThres = thresh #indicates 1-mergeThresh correlation of eigensyllables for merge
		sink("/dev/null")
		merge = mergeCloseModules(t(input),dynamicColors,cutHeight=thresh,verbose=0,unassdColor="grey",trapErrors=TRUE)
		sink()
		mergedColors = merge$colors
		names(mergedColors)=names(groupsOut)
		mergedMEs = merge$newMEs
		mergedMETree=flashClust(as.dist(1-cor(mergedMEs)),method="average")
		mergedMEList = moduleEigengenes(t(input),colors=mergedColors,scale=FALSE)
		colnames(mergedMEList$varExplained)=colnames(mergedMEList$eigengenes)
		}
	
		originalData <- read.csv(paste(Filedir,".acoustic_data.csv",sep=""),header=TRUE)
		originalData <- originalData[,-1]	
		rownames(originalData) <- 1:nrow(originalData)
	
		#Change color names so that they don't duplicate original cluster color names
		#load(paste(tutorDir,"/workspace.Rdata",sep=""))
		if(file.exists(paste(tutorDir,"/voice_results/workspace.Rdata",sep="")))
		{
			load(paste(tutorDir,"/voice_results/workspace.Rdata",sep=""))
			syntaxStr=out.cluster.tutor$mergedSyntax
		} else if(file.exists(paste(tutorDir,"/voice_results/assign_workspace.Rdata",sep=""))) #(file.exists(paste(tutorDir,"/assigned_complete_workspace.Rdata",sep="")))
		{
			load(paste(tutorDir,"/voice_results/assign_workspace.Rdata",sep="")) #load(paste(tutorDir,"/assigned_complete_workspace.Rdata",sep=""))
			syntaxStr=saveList$out.assign #syntaxStr=assignedSyntax
		} 
	
		derivedAssignments <- mergedMEList$validColors
		syntaxStr[names(syntaxStr)%in%names(derivedAssignments)] = derivedAssignments
		mergedColors <- derivedAssignments
	
		#usedColors <- unique(out.cluster.tutor$mergedSyntax)
		usedColors <- unique(syntaxStr)
		usableColors <- colors()[!colors()%in%usedColors]
		newColorIndex <- sample(1:length(usableColors),length(unique(mergedColors)))
	
		loop <- 0
		for(color in unique(mergedColors))
		{
			loop <- loop+1
			mergedColors[mergedColors==color] <- colors()[as.numeric(newColorIndex[loop])]
		}
	
		load(paste(Filedir,"voice_results/assign_workspace.Rdata",sep=""))
		names(mergedColors) <- as.numeric(gsub(".wav","",names(mergedColors)))
	
		for(name in names(mergedColors))
		{
			saveList$out.assign[name] <- subset(mergedColors,names(mergedColors)==name)
		}
	
	
		out.cluster = list(data=input, syntax=saveList$out.assign,mergedSyntax=saveList$out.assign, eigensyls=mergedMEList$eigengenes, varianceExp=mergedMEList$varExplained)	
	
		names(out.cluster$varianceExp) <- names(out$eigensyls)
	
		syntax = out.cluster$mergedSyntax
		clusters = unique(syntax)
		clusterTable = list()
	
		for(value in clusters)
		{
			tempClust <- syntax[syntax==value]
			refs <- names(tempClust)
			clusterTable[[value]] <- subset(originalData,rownames(originalData)%in%refs)
		}
	}	

	if(thresh=="none")
	{
	    originalData <- read.csv(paste(Filedir,".acoustic_data.csv",sep=""),header=TRUE)
	    originalData <- originalData[,-1]	
	    rownames(originalData) <- 1:nrow(originalData)

	    load(paste(Filedir,"voice_results/assign_workspace.rdata",sep=""))
	    clusters <- unique(saveList$out.assign)

	    clusterTable <- list()
	    syntax <- saveList$out.assign
	    for(value in clusters)
		{
			tempClust <- syntax[syntax==value]
			refs <- names(tempClust)
			clusterTable[[value]] <- subset(originalData,rownames(originalData)%in%refs)
		}
	}

		#getClusterWavs
		if(file.exists(paste(Filedir,"voice_results/joined_clusters_assigned/",sep="")))
		{
			unlink(paste(Filedir,"voice_results/joined_clusters_assigned/",sep=""),recursive=TRUE)
		}
	
		dir.create(paste(Filedir,"voice_results/joined_clusters_assigned/",sep=""))
	
		Filedir <- gsub(" ","\\\\ ",Filedir)
	
		for(group in names(clusterTable))
		{
			#print(paste("Joining syllables for cluster: ",group))
			filename <- paste(Filedir,"voice_results/joined_clusters_assigned/",group,".wav",sep="")
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
			tempoutwav <- paste(Filedir,"voice_results/joined_clusters_assigned/tempout.wav",sep="")
			loop <- 0
			tot <- length(names)-1
		
			if(length(names)==1)
			{
				file.copy(gsub("\\\\ "," ",names),paste(gsub("\\\\ "," ",Filedir),"voice_results/joined_clusters_assigned/",group,".wav",sep=""))
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
					file.copy(gsub("\\\\ "," ",filename),paste(gsub("\\\\ "," ",Filedir),"voice_results/joined_clusters_assigned/tempout.wav",sep=""),overwrite=TRUE)
				}
				unlink(paste(Filedir,"voice_results/joined_clusters_assigned/tempout.wav",sep=""))
			}
		}
	
		Filedir <- gsub("\\\\ "," ",Filedir)
		#sortSyllableWavs
		if(file.exists(paste(Filedir,"voice_results/sorted_syllables_assigned/",sep="")))
		{
			unlink(paste(Filedir,"voice_results/sorted_syllables_assigned/",sep=""),recursive=TRUE)
		}
		dir.create(paste(Filedir,"voice_results/sorted_syllables_assigned/",sep=""))
	
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
				if (!file.exists((paste(Filedir,"voice_results/sorted_syllables_assigned/",name,sep=''))))
				{
					dir.create(paste(Filedir,"voice_results/sorted_syllables_assigned/",name,sep=''))
				}
			
				file.copy(from=paste(Filedir,"voice_results/cut_syllables/",wav,sep=''),to=paste(Filedir,"voice_results/sorted_syllables_assigned/",name,sep=''))
			}		
		}
	
		#clusterAcousticsOut
	
		if(file.exists(paste(Filedir,'voice_results/cluster_tables_assigned/',sep="")))
		{
			unlink(paste(Filedir,'voice_results/cluster_tables_assigned/',sep=""),recursive=TRUE)
		}
	
		if(file.exists(paste(Filedir,'.cluster_tables_mat/',sep="")))
		{
			unlink(paste(Filedir,'.cluster_tables_mat/',sep=""),recursive=TRUE)
		}
	
		dir.create(paste(Filedir,".cluster_tables_mat/",sep=''))	
		dir.create(paste(Filedir,"voice_results/cluster_tables_assigned/",sep=''))
		if(.Platform$OS.type=="windows"){system(paste('attrib +h',paste(Filedir,".cluster_tables_mat/",sep='')))}
	
		for (cluster in names(clusterTable))
		{
			filename = paste(cluster,sep='',".csv")
			write.csv(as.data.frame(clusterTable[[cluster]]),file=paste(Filedir,'voice_results/cluster_tables_assigned/',filename,sep=""))
			write.table(as.data.frame(clusterTable[[cluster]][,2]),file=paste(Filedir,'.cluster_tables_mat/',filename,sep=""),row.names=FALSE,col.names=FALSE,sep=",")
		}
	
		if(!thresh=="none")
	    {
	        assignedSyntax <- out.cluster$mergedSyntax
	    }else{
	        assignedSyntax <- syntax
	    }
	
		assignedSyntax <- out.cluster$mergedSyntax
		save(assignedSyntax,file=paste(Filedir,"voice_results/assigned_complete_workspace.Rdata",sep=""))
		load(paste(Filedir,"voice_results/assign_workspace.Rdata",sep=""))
		saveList$out.assign <- assignedSyntax
		save(saveList,file=paste(Filedir,"voice_results/assign_workspace.Rdata",sep=""))
	
		usedColors <- unique(assignedSyntax)
	
		write.table(t(colors()[!colors()%in%usedColors]),paste(comArgs[2],'voice_results/.unusedColors.txt',sep=""),row.names=FALSE,col.names=FALSE,sep="\n")
	
		if(!thresh=="none")
	    {
			pdf(file=paste(Filedir,"voice_results/novel_syllable_dendrogram.pdf",sep=""))
			plotDendroAndColors(dendro=out,colors=cbind(dynamicColors,merge$colors),dendroLabels=FALSE,groupLabels=c("unmerged","merged"))
		z=dev.off()
		}
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

	Filedir <- comArgs[2]
	tutorDir <- comArgs[3]
	thresh <- comArgs[1]

	if(!thresh=="none")
	{
	    input <- read.csv(paste(Filedir,"voice_results/unassigned_for_cluster/similarity_batch_self.csv",sep=""),header=FALSE)
	    input <- input[,1:6]
	    colnames(input) <- c("Sound 1", "Sound 2","Similarity","Accuracy","Seq. Match","globalsim")
	    input[,3] <- 100*input[,3]
	    input[,4] <- 100*input[,4]
	    input[,5] <- 100*input[,5]
	    input[,6] <- 100*input[,6]

	    loop=0
	    for(val in unique(input[,2]))
	    {
	        loop=loop+1
	        input[,2][input[,2]==val]=list.files(paste(Filedir,"voice_results/unassigned_for_cluster",sep=""))[loop]
	        input[,1][input[,1]==val]=list.files(paste(Filedir,"voice_results/unassigned_for_cluster",sep=""))[loop]
	    }

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
	    MEList = moduleEigengenes(t(input),colors=dynamicColors,scale=FALSE,excludeGrey=FALSE,trapErrors=TRUE)
	    MEs = MEList$eigengenes
	    MEnames = gsub("ME",'',names(MEs))

	    #Determine correlations between eigensyllables and merges based on mergeThresh (see function arguments)
	    MEDiss = 1-cor(MEs)
	    if (nrow(MEDiss)==1)
	    {
	        mergedMEs <- MEs
	        dynamicColors <- MEList$validColors
	    }else{
	    METree = hclust(as.dist(MEDiss), method = "average")
	    MEDissThres = thresh #indicates 1-mergeThresh correlation of eigensyllables for merge
	    sink(paste(comArgs[1],"sink.txt",sep=""))
	    merge = mergeCloseModules(t(input),dynamicColors,cutHeight=thresh,verbose=0,unassdColor="grey",trapErrors=TRUE)
	    sink()
	    unlink(paste(comArgs[1],"sink.txt",sep=""))

	    mergedColors = merge$colors
	    names(mergedColors)=names(groupsOut)
	    mergedMEs = merge$newMEs
	    mergedMETree=hclust(as.dist(1-cor(mergedMEs)),method="average")
	    mergedMEList = moduleEigengenes(t(input),colors=mergedColors,scale=FALSE)
	    colnames(mergedMEList$varExplained)=colnames(mergedMEList$eigengenes)
	    }

	    originalData <- read.csv(paste(Filedir,".acoustic_data.csv",sep=""),header=TRUE)
	    originalData <- originalData[,-1]	
	    rownames(originalData) <- 1:nrow(originalData)

	    #Change color names so that they don't duplicate original cluster color names
	    #load(paste(tutorDir,"/workspace.Rdata",sep=""))
	    if(file.exists(paste(tutorDir,"/voice_results/workspace.Rdata",sep="")))
	    {
	        load(paste(tutorDir,"/voice_results/workspace.Rdata",sep=""))
	        syntaxStr=out.cluster.tutor$mergedSyntax
	    } else if(file.exists(paste(tutorDir,"/voice_results/assign_workspace.Rdata",sep=""))) #(file.exists(paste(tutorDir,"/assigned_complete_workspace.Rdata",sep="")))
	    {
	        load(paste(tutorDir,"/voice_results/assign_workspace.Rdata",sep="")) #load(paste(tutorDir,"/assigned_complete_workspace.Rdata",sep=""))
	        syntaxStr=saveList$out.assign #syntaxStr=assignedSyntax
	    } 

	    derivedAssignments <- mergedMEList$validColors
	    syntaxStr[names(syntaxStr)%in%names(derivedAssignments)] = derivedAssignments
	    mergedColors <- derivedAssignments


	    #usedColors <- unique(out.cluster.tutor$mergedSyntax)
	    usedColors <- unique(syntaxStr)
	    usableColors <- colors()[!colors()%in%usedColors]
	    newColorIndex <- sample(1:length(usableColors),length(unique(mergedColors)))

	    loop <- 0
	    for(color in unique(mergedColors))
	    {
	        loop <- loop+1
	        mergedColors[mergedColors==color] <- colors()[as.numeric(newColorIndex[loop])]
	    }

	    load(paste(Filedir,"voice_results/assign_workspace.Rdata",sep=""))
	    names(mergedColors) <- as.numeric(gsub(".wav","",names(mergedColors)))

	    for(name in names(mergedColors))
	    {
	        saveList$out.assign[name] <- subset(mergedColors,names(mergedColors)==name)
	    }
	
	
		out.cluster = list(data=input, syntax=saveList$out.assign,mergedSyntax=saveList$out.assign, eigensyls=mergedMEList$eigengenes, varianceExp=mergedMEList$varExplained)	

		names(out.cluster$varianceExp) <- names(out$eigensyls)
	
		syntax = out.cluster$mergedSyntax
		clusters = unique(syntax)
		clusterTable = list()
	
		for(value in clusters)
		{
			tempClust <- syntax[syntax==value]
			refs <- names(tempClust)
			clusterTable[[value]] <- subset(originalData,rownames(originalData)%in%refs)
		}
	}

	if(thresh=="none")
	{
	    originalData <- read.csv(paste(Filedir,".acoustic_data.csv",sep=""),header=TRUE)
	    originalData <- originalData[,-1]	
	    rownames(originalData) <- 1:nrow(originalData)

	    load(paste(Filedir,"assign_workspace.rdata",sep=""))
	    clusters <- unique(saveList$out.assign)

	    clusterTable <- list()
	    syntax <- saveList$out.assign
	    for(value in clusters)
		{
			tempClust <- syntax[syntax==value]
			refs <- names(tempClust)
			clusterTable[[value]] <- subset(originalData,rownames(originalData)%in%refs)
		}
	}
    
		#getClusterWavs
		if(file.exists(paste(Filedir,"voice_results/joined_clusters_assigned",sep="")))
		{
			unlink(paste(Filedir,"voice_results/joined_clusters_assigned/",sep=""),recursive=TRUE)
		}
	
		dir.create(paste(Filedir,"voice_results/joined_clusters_assigned/",sep=""))
	
		#Filedir <- gsub(" ","\\\\ ",Filedir)
	
		for(group in names(clusterTable))
		{
			#print(paste("Joining syllables for cluster: ",group))
			filename <- paste(Filedir,"voice_results/joined_clusters_assigned/",group,".wav",sep="")
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
			tempoutwav <- paste(Filedir,"voice_results/joined_clusters_assigned/tempout.wav",sep="")
			loop <- 0
			tot <- length(names)-1
		
			if(length(names)==1)
			{
				file.copy(names,paste(Filedir,"voice_results/joined_clusters_assigned/",group,".wav",sep=""))
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
					file.copy(filename,paste(Filedir,"voice_results/joined_clusters_assigned/tempout.wav",sep=""),overwrite=TRUE)
				}
				unlink(paste(Filedir,"voice_results/joined_clusters_assigned/tempout.wav",sep=""))
			}
		}
	
		#Filedir <- gsub("\\\\ "," ",Filedir)
		#sortSyllableWavs
		if(file.exists(paste(Filedir,"voice_results/sorted_syllables_assigned",sep="")))
		{
			unlink(paste(Filedir,"voice_results/sorted_syllables_assigned",sep=""),recursive=TRUE)
		}
		dir.create(paste(Filedir,"voice_results/sorted_syllables_assigned/",sep=""))
	
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
				if (!file.exists((paste(Filedir,"voice_results/sorted_syllables_assigned/",name,sep=''))))
				{
					dir.create(paste(Filedir,"voice_results/sorted_syllables_assigned/",name,sep=''))
				}
			
				file.copy(from=paste(Filedir,"voice_results/cut_syllables/",wav,sep=''),to=paste(Filedir,"voice_results/sorted_syllables_assigned/",name,sep=''))
			}		
		}
	
		#clusterAcousticsOut
	
		if(file.exists(paste(Filedir,'voice_results/cluster_tables_assigned',sep="")))
		{
			unlink(paste(Filedir,'voice_results/cluster_tables_assigned',sep=""),recursive=TRUE)
		}
	
		if(file.exists(paste(Filedir,'.cluster_tables_mat',sep="")))
		{
			unlink(paste(Filedir,'.cluster_tables_mat',sep=""),recursive=TRUE)
		}
	
		dir.create(paste(Filedir,".cluster_tables_mat/",sep=''))	
		dir.create(paste(Filedir,"voice_results/cluster_tables_assigned/",sep=''))
		if(.Platform$OS.type=="windows"){system(paste('attrib +h',paste(Filedir,".cluster_tables_mat/",sep='')))}
	
		for (cluster in names(clusterTable))
		{
			filename = paste(cluster,sep='',".csv")
			write.csv(as.data.frame(clusterTable[[cluster]]),file=paste(Filedir,'voice_results/cluster_tables_assigned/',filename,sep=""))
			write.table(as.data.frame(clusterTable[[cluster]][,2]),file=paste(Filedir,'.cluster_tables_mat/',filename,sep=""),row.names=FALSE,col.names=FALSE,sep=",")
		}
	
	    if(!thresh=="none")
	    {
	        assignedSyntax <- out.cluster$mergedSyntax
	    }else{
	        assignedSyntax <- syntax
	    }

		save(assignedSyntax,file=paste(Filedir,"voice_results/assigned_complete_workspace.Rdata",sep=""))
		load(paste(Filedir,"voice_results/assign_workspace.Rdata",sep=""))
		saveList$out.assign <- assignedSyntax
		save(saveList,file=paste(Filedir,"voice_results/assign_workspace.Rdata",sep=""))
	
		usedColors <- unique(assignedSyntax)
	
		write.table(t(colors()[!colors()%in%usedColors]),paste(comArgs[2],'.unusedColors.txt',sep=""),row.names=FALSE,col.names=FALSE,sep="\n")
		if(.Platform$OS.type=="windows"){system(paste('attrib +h',paste(comArgs[2],'.unusedColors.txt',sep="")))}
		
	    if(!thresh=="none")
	    {
	        pdf(file=paste(Filedir,"voice_results/novel_syllable_dendrogram.pdf",sep=""))
	        plotDendroAndColors(dendro=out,colors=cbind(dynamicColors,merge$colors),dendroLabels=FALSE,groupLabels=c("unmerged","merged"))
	        z=dev.off()
	    }
	
}