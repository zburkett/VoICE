if(.Platform$OS.type=="windows" & file.exists("./.libraries")){.libPaths("./.libraries")}
comArgs <- commandArgs(T)
options(stringsAsFactors=FALSE)
options(warn=-1)
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
}
options(warn=-1)


if(!exists("flashClust")){flashClust <- hclust}

Filedir <- comArgs[1]
deepSplit <- comArgs[2]
merge.start <- comArgs[3]
merge.end <- comArgs[4]
by <- comArgs[5]
 
#import and clean up data
Filedir.in <- Filedir
Filedir <- paste(Filedir,"unassigned_for_cluster/similarity_batch_self.csv",sep="")
input <- read.csv(Filedir,header=FALSE)
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
	input[,2][input[,2]==val]=list.files(paste(Filedir.in,"unassigned_for_cluster",sep=""))[loop]
	input[,1][input[,1]==val]=list.files(paste(Filedir.in,"unassigned_for_cluster",sep=""))[loop]
}
 
#Create global similarity matrix
#print(paste("Creating global similarity matrix."))
 
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
 
#print(paste("Global similarity matrix created."))
    
#Cluster to create dendrogram
#print(paste("Clustering syllables."))
 
#Create distance matrix from GS matrix 
distM=dist(input,method='euclidean')
    
#Create dendrogram and cut using most divisive parameters
out = flashClust(as.dist(distM),method='average')
groupsOut = cutreeDynamic(out,minClusterSize=1,method="hybrid",distM=as.matrix(distM),deepSplit=as.numeric(deepSplit),verbose=0)
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
MEDissThres = 0 #generate as many clusters as possible
merge = mergeCloseModules(t(input),dynamicColors,cutHeight=MEDissThres,verbose=0,unassdColor="grey",trapErrors=TRUE)
mergedColors = merge$colors
names(mergedColors)=names(groupsOut)
mergedMEs = merge$newMEs
mergedMETree=flashClust(as.dist(1-cor(mergedMEs)),method="average")
mergedMEList = moduleEigengenes(t(input),colors=mergedColors,scale=FALSE,trapErrors=TRUE)
colnames(mergedMEList$varExplained)=colnames(mergedMEList$eigengenes)
}
    
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
    
#print(paste("Syllables clustered."))
    
#Iterative tree trimming procedure
#print(paste("Trimming hierarchical cluster tree over desired merging threshold range. This may take some time."))
IGS.out <- list()
merge.range <- seq(from=as.numeric(merge.start),to=as.numeric(merge.end),by=as.numeric(by))
pb <- tkProgressBar(title="Progress Bar",min=0,max=length(merge.range),width=300) #spawn progress bar
loop <- 0
for(thresh in merge.range)
{   
    loop <- loop+1
    IGS <- vector()
    n <- vector()
    
    #Merge clusters that correlate above a given merging threshold
	if(.Platform$OS.type=="unix")
	{
		sink("/dev/null")
	    merge=mergeCloseModules(t(out.cluster$data),out.cluster$syntax,cutHeight=thresh,verbose=-1,unassdColor="grey",trapErrors=TRUE)
		sink()
		if(!exists("flashClust")){flashClust <- hclust}
	}else if (.Platform$OS.type=="windows")
	{
		sink(file=paste(comArgs[1],"sink.txt",sep=""))
	    merge=mergeCloseModules(t(out.cluster$data),out.cluster$syntax,cutHeight=thresh,verbose=-1,unassdColor="grey",trapErrors=TRUE)
		
		sink()
		unlink(paste(comArgs[1],"sink.txt",sep=""))
	}
        
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
save(outlist,file=paste(Filedir.in,"igs_assigned.Rdata",sep=""))
 
    
 

