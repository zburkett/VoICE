if(.Platform$OS.type=="windows" & file.exists("./.libraries")){.libPaths("./.libraries")}
comArgs <- commandArgs(T)
options(stringsAsFactors=FALSE)

if(.Platform$OS.type=="unix")
{
	sink("/dev/null")
	suppressMessages(library(WGCNA,warn.conflicts=FALSE,verbose=0))
	suppressMessages(library(tcltk))
	options(warn=-1)
	sink()
	if(!exists("flashClust")){flashClust <- hclust}
}else if (.Platform$OS.type=="windows")
{
	sink(file=paste(comArgs[1],"sink.txt",sep=""))
	suppressMessages(library(WGCNA,warn.conflicts=FALSE,verbose=0))
	suppressMessages(library(tcltk))
	options(warn=-1)
	sink()
	unlink(paste(comArgs[1],"sink.txt",sep=""))
	if(!exists("flashClust")){flashClust <- hclust}
}


Filedir = comArgs[1]

#import and clean up data
Filedir.in <- Filedir
Filedir <- paste(Filedir,"similarity_batch_self.csv",sep="")
input <- read.csv(Filedir,header=FALSE)
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
	
#Cluster to create dendrogram
#Create distance matrix from GS matrix 
distM=dist(input,method='euclidean')
	
#Create dendrogram and cut using most divisive parameters
out = flashClust(as.dist(distM),method='average')
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
METree = flashClust(as.dist(MEDiss), method = "average")
MEDissThres = 0 #indicates 1-mergeThresh correlation of eigensyllables for merge
merge = mergeCloseModules(t(input),dynamicColors,cutHeight=MEDissThres,verbose=0,unassdColor="grey",trapErrors=TRUE)
mergedColors = merge$colors
names(mergedColors)=names(groupsOut)
mergedMEs = merge$newMEs
mergedMETree=flashClust(as.dist(1-cor(mergedMEs)),method="average")
mergedMEList = moduleEigengenes(t(input),colors=mergedColors,scale=FALSE)
colnames(mergedMEList$varExplained)=colnames(mergedMEList$eigengenes)
	
if (!length(mergedMEs)==length(MEs))
{
	out.cluster = list(data=input, syntax=dynamicColors,mergedSyntax=merge$colors, eigensyls=mergedMEList$eigengenes, varianceExp=mergedMEList$varExplained)	
	names(out.cluster$varianceExp) <- names(out$eigensyls)
}

if (length(mergedMEs)==length(MEs))
{
	out.cluster = list(data=input, syntax=dynamicColors, eigensyls=MEList$eigengenes, varianceExp=MEList$varExplained)
	names(out.cluster$varianceExp) <- names(out$eigensyls)
}
		
#Iterative tree trimming procedure
IGS.out <- list()
merge.range <- seq(from=0,to=1,by=0.01)
pb <- tkProgressBar(title="Progress Bar",min=0,max=length(merge.range),width=300) #spawn progress bar
loop <- 0
for(thresh in merge.range)
{	
	loop <- loop+1
	IGS <- vector()
	n <- vector()
	
	#Merge clusters that correlate above a given merging threshold
	merge=mergeCloseModules(t(out.cluster$data),out.cluster$syntax,cutHeight=thresh,verbose=0,unassdColor="grey",trapErrors=TRUE)
		
	#Label rows in global similarity by cluster assignment for IGS calculation
	clustData <- as.data.frame(cbind(out.cluster$data,merge$colors))
	clusters <- sort(unique(merge$colors))
		
	#Calculate IGS for each cluster, determine number of syllables in the cluster
	for(cluster in clusters)
	{
		temp.cluster <- subset(clustData,clustData[,ncol(clustData)]==cluster)
		nsyl <- nrow(temp.cluster)
		temp.cluster <- t(temp.cluster)
		temp.cluster <- subset(temp.cluster,rownames(temp.cluster)%in%colnames(temp.cluster))
		diag(temp.cluster) <- NA
		IGS <- c(IGS,mean(as.numeric(temp.cluster),na.rm=TRUE))
		n <- c(n,nsyl)
	}
		
	#Store result at given merge threshold in list for output
	names(IGS) <- clusters
	IGS <- rbind(IGS,n)
	IGS.out[[as.character(thresh)]] <- IGS
	setTkProgressBar(pb,loop,label=paste(round(loop/length(merge.range)*100,0),"% done"))
}
close(pb)
outlist = list(IGS.out=IGS.out,gsMatrix=input)
save(outlist,file=paste(Filedir.in,"igs.Rdata",sep=""))

	

