if(.Platform$OS.type=="windows" & file.exists("./.libraries")){.libPaths("./.libraries")}
comArgs <- commandArgs(T)
options(stringsAsFactors=FALSE)

pupil.dir <- comArgs[2]
tutor.dir <- comArgs[1]
thresh <- comArgs[3]

clusterColors <- list.files(paste(tutor.dir,"/sorted_syllables_for_batch",sep=""))
out.colors <- vector()
	
query <- strsplit(paste(tutor.dir,"/sorted_syllables_for_batch",sep=""),"/")
if(sum(query[[1]]=="sorted_syllables_for_batch")==1)
{
	for(color in clusterColors)
	{
		out.colors <- c(out.colors,rep(color,length(list.files(path=paste(tutor.dir,"sorted_syllables_for_batch/",color,sep="/")))))
	}
}
	
assignment.batch <- read.csv(paste(pupil.dir,"similarity_batch_assign.csv",sep=""),header=FALSE)
assignment.batch[,3] <- 100*assignment.batch[,3]
assignment.batch[,4] <- 100*assignment.batch[,4]
assignment.batch[,5] <- 100*assignment.batch[,5]
assignment.batch[,6] <- 100*assignment.batch[,6]
assignment.batch <- assignment.batch[,1:6]
colnames(assignment.batch) <- c("Sound 1", "Sound 2", "Similarity", "Accuracy", "Seq Match", "globalsim")

out.assign <- vector()

for(syllable in unique(assignment.batch[,2]))
{
	#Create subset of data containing a single syllable to be assigned
	sub <- as.data.frame(subset(assignment.batch,assignment.batch[,2]==syllable))
	sub <- cbind(sub,out.colors)
	
	#Determine if each cluster has at least one representative
	n.clusters <- vector()
	for(cluster in unique(out.colors))
	{
		n.clusters <- c(n.clusters,length(subset(out.colors,out.colors==cluster)))
	}
	names(n.clusters) <- unique(out.colors)
	
	for(cluster in names(n.clusters[n.clusters==1]))
	{
		sub <- subset(sub,sub[,"out.colors"]!=cluster)
	}
		
	#Perform one-way ANOVA on similarity batch data
	a1 <- aov(sub[,"globalsim"]~as.factor(sub[,"out.colors"]))
	a2 <- anova(a1)
		
	#Calculate mean global similarity scores
	clusterMeans <- tapply(sub[,"globalsim"],sub[,"out.colors"],mean)
		
	#Perform pairwise comparisons post-hoc test, calculate Bonferroni corrected p-value
	t.result <- pairwise.t.test(sub[,"globalsim"],sub[,"out.colors"],p.adj="bonf")
	p.crit <- 0.05
		
	#Find all clusters whose average global similarity was above threshold 
	matches <- subset(clusterMeans,clusterMeans>thresh)
		
	#If no cluster is above threshold, assign syllable to NA and pass to unassigned syllables queue
	if(length(matches)==0)
	{
		out.assign <- c(out.assign,NA)
	}
		
	#If only one cluster is above threshold, assign syllable to same ID as that cluster
	if(length(matches)==1)
	{
		out.assign <- c(out.assign,names(matches))
	}
		
	#If more than one cluster is above threshold, attempt to determine the best choice
	if(length(matches)>1)
	{
		#Find the cluster with the highest GS
		bestMatch <- subset(names(matches),matches==max(matches))
			
		#If this GS score is significantly greater than the others, assign to that cluster
		#Next "if" statements are for reading the p-value table created in R to determine statistical significance
			
		#If the top cluster match IS the first column name in the p-value table
		if(bestMatch == colnames(t.result[[3]])[1])
		{
			#The p-values are in the first column only
			col.p <- t.result[[3]][,bestMatch]
		}
			
		#If the top cluster match is not in the first column name of the p-value table
		if(bestMatch != colnames(t.result[[3]])[1])
		{
			#If the top cluster match is not in the column names at all
			if(!bestMatch%in%colnames(t.result[[3]]))
			{
				#The p-values are in a single row
				row.p <- t.result[[3]][bestMatch,]
			}
			
			#If the top cluster match IS in the column names somewhere
			if(bestMatch%in%colnames(t.result[[3]]))
			{
				#The p-values are distributed in a row and a column
				row.p <- t.result[[3]][bestMatch,]
				col.p <- t.result[[3]][,bestMatch]
			}	
		}
			
		#We have now found the p-values for the cluster vs. all other clusters
		#If the top cluster match was the first column name of the p-value table
		if(bestMatch==colnames(t.result[[3]])[1])
		{
			#If the greatest p-value possible is less than or equal to the corrected p-value threshold, assign to that cluster
			if(max(col.p)<=p.crit)
			{
				out.assign <- c(out.assign,bestMatch)
			}
			
			#If the greatest p-value possible is greater than the corrected p-value threshold, pass to tiebreaker queue
			if(max(col.p)>p.crit)
			{
				out.assign <- c(out.assign,"ND")
			}
		}
			
		#If the top cluster match is not the first column name but is present in a column name
		if(bestMatch != colnames(t.result[[3]])[1] & bestMatch%in%colnames(t.result[[3]]))
		{
			#If the greatest p-value possible is less than or equal to the corrected p-value threshold, assign to that cluster
			if(max(row.p,na.rm=TRUE)<=p.crit & max(col.p,na.rm=TRUE)<=p.crit)
			{
				out.assign <- c(out.assign,bestMatch)
			}
			
			#If the greatest p-value possible is greater than the corrected p-value threshold, pass to tiebreaker queue
			if(!max(row.p,na.rm=TRUE)<p.crit || !max(col.p,na.rm=TRUE)<p.crit)
			{
				out.assign <- c(out.assign,"ND")
			}
		}
			
		#If the top cluster match is not in a column at all
		if(bestMatch != colnames(t.result[[3]])[1] & !bestMatch%in%colnames(t.result[[3]]))
		{
			#If the greatest p-value possible is less than or equal to the corrected p-value threshold, assign to that cluster
			if(max(row.p)<=p.crit)
			{
				out.assign <- c(out.assign,bestMatch)
			}
			
			#If the greatest p-value possible is greater than the corrected p-value threshold, pass to tiebreaker queue
			if(max(row.p)>p.crit)
			{
				out.assign <- c(out.assign,"ND")
			}
		}
	}
}
names(out.assign) <- unique(assignment.batch[,2])

if(sum(out.assign=="ND",na.rm=TRUE)>0)
{
	ndout <- subset(names(out.assign),out.assign=="ND")
	write.table(as.numeric(ndout),file=(paste(pupil.dir,"NDs.csv",sep="")),row.names=FALSE,col.names=FALSE)
}

if(sum(is.na(out.assign))>0)
{
	naout <- subset(names(out.assign),is.na(out.assign))
	write.table(as.numeric(naout),file=(paste(pupil.dir,"NAs.csv",sep="")),row.names=FALSE,col.names=FALSE)
	
	if(file.exists(paste(pupil.dir,"unassigned_for_cluster",sep=""))){unlink(paste(pupil.dir,"unassigned_for_cluster",sep=""),recursive=TRUE)}
	dir.create(paste(pupil.dir,"unassigned_for_cluster",sep=""))
	
	data <- read.csv(paste(pupil.dir,".acoustic_data.csv",sep=""),header=TRUE)
	
	for(name in subset(names(out.assign),is.na(out.assign)))
	{
		if(.Platform$OS.type=='windows')
		{
			name.assign <- paste("%0",nchar(max(as.numeric(rownames(data)))),"s",sep="")
			name.out <- sprintf(name.assign,name)
			name.out <- gsub(" ","0",name.out)
		}else if(.Platform$OS.type=="unix")
		{
			name.assign <- paste("%0",nchar(max(as.numeric(rownames(data)))),"s",sep="")
			name.out <- sprintf(name.assign,name)
		}else{
			stop(paste('Unable to determine OS.'))
		}
		file.copy(from=paste(pupil.dir,"cut_syllables/",name.out,".wav",sep=""),to=paste(pupil.dir,"unassigned_for_cluster/",name.out,".wav",sep=""))
	}
}

saveList = list(assignment.batch=assignment.batch,out.assign=out.assign,out.colors=out.colors)
save(saveList,file=paste(pupil.dir,"assign_workspace.Rdata",sep=""))