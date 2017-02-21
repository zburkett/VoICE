if(.Platform$OS.type=="windows" & file.exists("./.libraries")){.libPaths("./.libraries")}
comArgs <- commandArgs(T)
options(stringsAsFactors=FALSE)
options(warn=-1)
excludeGrey=TRUE
#################
#Creates transition probability table and computes weighted and unweighted syntax entropy scores as in Miller et al. (2010).
#################
syntaxEntropy <- function(syntaxIn)
{
	#find the unique syllables and count them
	uniqueSyls <- sort(unique(as.numeric(syntaxIn)))
	nSyls = length(uniqueSyls)
	
	# intialize empty matrix, each row is a syllable
	# columns denote transition probabilities to other syllables and end of motif
	probMatrix = matrix(nrow = nSyls, ncol=nSyls);
	rownames(probMatrix) = paste('syl', uniqueSyls, sep = '');
	colnames(probMatrix) = paste('syl', uniqueSyls, sep = '');
	
	# loop over syllables, treat each as leader in turn
	for (leader in uniqueSyls)
	{
		#cat('leader:',leader,'\n')
		
		# find row for current leader in probability matrix
		leaderRow = match(paste('syl', leader, sep = ''), rownames(probMatrix));
		#cat('leaderRow:',leaderRow,'\n')
		
		# loop over syllables, treat each as follower in turn
		for (follower in uniqueSyls)
		{
			#cat('follower:',follower,', ')
			
			# find column for current follower in probability matrix
			followerCol = match(paste('syl', follower, sep = ''), colnames(probMatrix));
			#cat('followerCol:',followerCol,'\n')
			
			# compute transition probability and store in matrix
			tmp = transProbString(syntaxIn, leader, follower);
			probMatrix[leaderRow, followerCol] = tmp$trans_prob;	
		}
		
		# add termination probability for current leader to vector
		#termProbs[leaderRow] = tmp$terminations / tmp$total_leader;
		#cat('termProbs: ',termProbs,'\n\n')	
	}
	
	#for each syllable type, calculate transition entropy with normalization by motif max possible entropy
	transEntropy <- vector()
	transEntropyNoNorm <- vector()
	for (row in 1:nrow(probMatrix))
	{
		h <- vector()
		
		for (col in 1:ncol(probMatrix))
		{
			if (probMatrix[row,col]==0)
			{
				h <- c(h,0)
			}
			
			if (!probMatrix[row,col]==0)
			{
				tempEntropy <- (-probMatrix[row,col])*log2(probMatrix[row,col])
				h <- c(h,tempEntropy)
			}	
		}
		cols <- ncol(probMatrix)
		h.norm <- sum(h)/(ncol(probMatrix)*((-1/ncol(probMatrix))*log2(1/ncol(probMatrix))))
		transEntropy <- c(transEntropy,h.norm)
		#transEntropyNoNorm <- c(transEntropyNoNorm,sum(h))
	}
	
	#weighted syllable entropy calculation step
	count.totals <- vector()
	for (value in unique(syntaxIn))
	{
		count.temp <- sum(syntaxIn==value)
		count.totals <- c(count.totals,count.temp)
	}
	norm <- count.totals/max(count.totals)
	transEntropyWeighted <- transEntropy*norm
	
	out <- list(transProbs=probMatrix,entropy=mean(transEntropy),stereotypy=1-mean(transEntropy),entropy.weighted=mean(transEntropyWeighted),stereotypy.weighted=1-mean(transEntropyWeighted))
	
	return(out)	
}
#################
#Computes transition probability for string-based analysis.
#################
transProbString = function(data, leader, follower) #Used by syntaxSimilarityDiffs()
{
	#set initial values for # of transitions
	transitions = 0
	terminations = 0
	length=length(data)
	syl = c(1:length(data))
	
	for (pos in syl)
	{
		#check if leader is in current position
		check = data[pos] == leader;
		
		#if leader is in current position
		if (check)
		{
			#check whether current position is the end of the string
			if(is.na(data[pos+1]==follower))
			{
				terminations = terminations+1
			}
			
			else 
			if (data[pos+1]==follower)
			{
				transitions = transitions+1
			}
		}
	}
	
	#compute probability
	total_leader = sum(data == leader)
	prob = transitions/total_leader
	
	output = list(transitions, total_leader, prob);
	names(output) = c('transitions', 'total_leader', 'trans_prob');
	return(output);
}

syntaxRename=function(syntaxIn)
{
	syntax = syntaxIn
	loop=0
	for(name in unique(syntax))
	{
		loop <- loop + 1
		for (val in 1:length(syntax))
		{
			if (syntax[val]==name)
			{
				syntax[val]=loop
			}
		}
	}
	syntax = as.numeric(syntax)
	key = 1:length(unique(syntaxIn))
	names(key)= unique(syntaxIn)
	namedSyntax = syntax
	names(namedSyntax)=names(syntaxIn)
	out = list(cleanSyntax=syntax, namedSyntax=namedSyntax, key=key)
	return(out)
}

if(!comArgs[1]==comArgs[2])
{
if(file.exists(paste(comArgs[1],"assign_workspace.rdata",sep="")))
{
	load(paste(comArgs[1],"assign_workspace.rdata",sep=""))
	s1 <- saveList$out.assign
}else if(file.exists(paste(comArgs[1],"workspace.rdata",sep="")))
{
	load(paste(comArgs[1],"workspace.rdata",sep=""))
	if("mergedSyntax" %in% names(out.cluster.tutor))
	{
		s1 <- out.cluster.tutor$mergedSyntax
	}else{
		s1 <- out.cluster.tutor$syntax
	}
}
}

if(file.exists(paste(comArgs[2],"/workspace.rdata",sep="")))
{
	load(paste(paste(comArgs[2],"/workspace.rdata",sep="")))
	if("mergedSyntax" %in% names(out.cluster.tutor))
	{
		s2 <- out.cluster.tutor$mergedSyntax
	}else{
		s2 <- out.cluster.tutor$syntax
	}
}else if(file.exists(paste(comArgs[2],"/assign_workspace.rdata",sep="")))
{
	load(paste(comArgs[2],"/assign_workspace.rdata",sep=""))
	s2 <- saveList$out.assign
}

s1 <- syntaxRename(s1)
s2 <- syntaxRename(s2)

all.syllables <- unique(c(names(s1[[3]]),names(s2[[3]])))
all.syllables.num <- 1:length(all.syllables)
names(all.syllables.num) <- all.syllables
all.syllables <- all.syllables.num

s1.out <- s1[[2]]
s2.out <- s2[[2]]

loop <- 0
#loop through the syllables and rebuild syntax
for(syllable in names(all.syllables))
{
	loop <- loop+1
	if(sum(names(s1[[3]])==syllable) > 0) #if the tutor has this syllable in its repertoire...
	{
		#query which tutor syntax number belongs to that syllable name
		syntax.number <- subset(s1[[3]],names(s1[[3]])==syllable)
			
		#query the syllable names that correspond to the syllable number in question
		names.tochange <- subset(names(s1[[2]]),s1[[2]]==syntax.number)
			
		#change all syllables in syntax output with those names to "loop" value
		s1.out[names(s1.out)%in%names.tochange] <- loop
	}
		
	if(sum(names(s2[[3]])==syllable) > 0) #if the pupil has this syllable in its repertoire...
	{
		#query which tutor syntax number belongs to that syllable name
		syntax.number <- subset(s2[[3]],names(s2[[3]])==syllable)
			
		#query the syllable names that correspond to the syllable number in question
		names.tochange <- subset(names(s2[[2]]),s2[[2]]==syntax.number)
			
		#change all syllables in syntax output with those names to "loop" value
		s2.out[names(s2.out)%in%names.tochange] <- loop
	}
}

s1.table <- syntaxEntropy(s1.out)
s2.table <- syntaxEntropy(s2.out)

if(sum(!rownames(s1.table[[1]])%in%rownames(s2.table[[1]]))>=1 || sum(!rownames(s2.table[[1]])%in%rownames(s1.table[[1]]))>=1)
{
		s1.expand <- matrix(nrow=length(all.syllables),ncol=length(all.syllables))
		rownames(s1.expand) <- paste("syl",1:length(all.syllables),sep="")
		colnames(s1.expand) <- paste("syl",1:length(all.syllables),sep="")
		
		#populate expanded tutor matrix with data from original tutor matrix
		for(row in rownames(s1.table[[1]]))
		{
			for(col in colnames(s1.table[[1]]))
			{
				s1.expand[row,col] <- s1.table[[1]][row,col]
			}
		}
		#change NAs to 0s
		s1.expand[is.na(s1.expand)]=0
		
		#repeat previous loop for pupil
		s2.expand <- matrix(nrow=length(all.syllables),ncol=length(all.syllables))
		rownames(s2.expand) <- paste("syl",1:length(all.syllables),sep="")
		colnames(s2.expand) <- paste("syl",1:length(all.syllables),sep="")
		
		for(row in rownames(s2.table[[1]]))
		{
			for(col in colnames(s2.table[[1]]))
			{
				s2.expand[row,col] <- s2.table[[1]][row,col]
			}
		}
		#change NAs to 0s
		s2.expand[is.na(s2.expand)]=0
}

if(!exists(paste("s2.expand"))){s2.expand <- s2.table[[1]]}
if(!exists(paste("s1.expand"))){s1.expand <- s1.table[[1]]}

#calculate pearson correlations between tutor and pupil syntax table rows
out.cors <- vector()
	
#remove grey syllables if desired
if(sum(names(all.syllables)=="grey")>0 & excludeGrey==TRUE)
{
	greySyl <- subset(all.syllables,names(all.syllables)=="grey")
	greyRow <- paste("syl",greySyl,sep="")
	s1.expand <- s1.expand[-greySyl,]
	s1.expand <- s1.expand[,-greySyl]
	s2.expand <- s2.expand[-greySyl,]
	s2.expand <- s2.expand[,-greySyl]
}
	
for(row in 1:nrow(s1.expand))
{
	out.cors <- c(out.cors,cor(s1.expand[row,],s2.expand[row,]))
}

names(out.cors) <- rownames(s1.expand)
syntax.sim.no.penalty <- mean(out.cors,na.rm=TRUE)
	
out.cors.penalty <- out.cors
out.cors.penalty[is.na(out.cors.penalty)]=0
syntax.sim.penalty <- mean(out.cors.penalty)

syntax.sim.weighted <- matrix(nrow=length(out.cors),ncol=3)
colnames(syntax.sim.weighted) <- c("s1.freq","s2.freq","abs.dif")
rownames(syntax.sim.weighted) <- names(out.cors)

for(name in rownames(syntax.sim.weighted))
	{
		syntax.sim.weighted[name,"s1.freq"] <- sum(s1.out==as.numeric(gsub("syl","",name)))/length(s1.out)
		syntax.sim.weighted[name,"s2.freq"] <- sum(s2.out==as.numeric(gsub("syl","",name)))/length(s2.out)
		syntax.sim.weighted[name,"abs.dif"] <- abs(syntax.sim.weighted[name,"s1.freq"]-syntax.sim.weighted[name,"s2.freq"])
	}
	
	syntax.sim.no.penalty.weighted <- out.cors*(1-syntax.sim.weighted[,"abs.dif"])
	syntax.sim.no.penalty.weighted <- mean(syntax.sim.no.penalty.weighted,na.rm=TRUE)
	
	out.cors.zeroed <- out.cors
	out.cors.zeroed[is.na(out.cors.zeroed)]=0
	weighted.sim.out <- mean(out.cors.zeroed*(1-syntax.sim.weighted[,"abs.dif"]))
	
	rownames(s1.expand) <- names(all.syllables)
	colnames(s1.expand) <- names(all.syllables)
	rownames(s2.expand) <- names(all.syllables)
	colnames(s2.expand) <- names(all.syllables)

if(file.exists(paste(comArgs[1],"syntax_summary","_assign_",strsplit(comArgs[1],"/")[[1]][length(strsplit(comArgs[1],"/")[[1]])],"_ref_",strsplit(comArgs[2],"/")[[1]][length(strsplit(comArgs[2],"/")[[1]])],".csv",sep="")))
{
	unlink(paste(comArgs[1],"syntax_summary","_assign_",strsplit(comArgs[1],"/")[[1]][length(strsplit(comArgs[1],"/")[[1]])],"_ref_",strsplit(comArgs[2],"/")[[1]][length(strsplit(comArgs[2],"/")[[1]])],".csv",sep=""))
}
out_file <- file(paste(comArgs[1],"syntax_summary","_assign_",strsplit(comArgs[1],"/")[[1]][length(strsplit(comArgs[1],"/")[[1]])],"_ref_",strsplit(comArgs[2],"/")[[1]][length(strsplit(comArgs[2],"/")[[1]])],".csv",sep=""), open="a")
write.table("Transition Probability Matrix - Assignment Session",file=out_file,row.names=FALSE,col.names=FALSE)
write.table(t(c(" ",colnames(s1.expand))),file=out_file,row.names=FALSE,col.names=FALSE,sep=",")
write.table(s1.expand,file=out_file,sep=",",row.names=rownames(s1.expand),col.names=FALSE)
write.table(" ",file=out_file,row.names=FALSE,col.names=FALSE)
write.table("Syntax Entropy Scores - Assignment Session",file=out_file,row.names=FALSE,col.names=FALSE)
write.table(s1.table[[2]],file=out_file,sep=",",row.names="Entropy",col.names=FALSE)
write.table(s1.table[[3]],file=out_file,sep=",",row.names="Stereotypy",col.names=FALSE)
write.table(s1.table[[4]],file=out_file,sep=",",row.names="Weighted Entropy",col.names=FALSE)
write.table(s1.table[[5]],file=out_file,sep=",",row.names="Weighted Stereotypy",col.names=FALSE)
write.table(" ",file=out_file,row.names=FALSE,col.names=FALSE)
write.table("Transition Probability Matrix - Reference Session",file=out_file,row.names=FALSE,col.names=FALSE)
write.table(t(c(" ",colnames(s2.expand))),file=out_file,row.names=FALSE,col.names=FALSE,sep=",")
write.table(s2.expand,file=out_file,sep=",",row.names=rownames(s2.expand),col.names=FALSE)
write.table(" ",file=out_file,row.names=FALSE,col.names=FALSE)
write.table("Syntax Entropy Scores - Reference Session",file=out_file,row.names=FALSE,col.names=FALSE)
write.table(s2.table[[2]],file=out_file,sep=",",row.names="Entropy",col.names=FALSE)
write.table(s2.table[[3]],file=out_file,sep=",",row.names="Stereotypy",col.names=FALSE)
write.table(s2.table[[4]],file=out_file,sep=",",row.names="Weighted Entropy",col.names=FALSE)
write.table(s2.table[[5]],file=out_file,sep=",",row.names="Weighted Stereotypy",col.names=FALSE)
write.table(" ",file=out_file,row.names=FALSE,col.names=FALSE,sep=",")
write.table("Unweighted Syntax Similarity Scores",file=out_file,row.names=FALSE,col.names=FALSE,sep=",")
write.table(syntax.sim.no.penalty,file=out_file,row.names="Syntax Similarity (Unweighted)",col.names=FALSE,sep=",")
write.table(syntax.sim.penalty,file=out_file,row.names="Penalized Syntax Similarity (Unweighted)",col.names=FALSE,sep=",")
write.table(" ",file=out_file,row.names=FALSE,col.names=FALSE,sep=",")
write.table("Syllable Frequencies",file=out_file,row.names=FALSE,col.names=FALSE,sep=",")
write.table(t(c(" ","Assignment Frequency","Reference Frequency","Absolute Diff.")),file=out_file,sep=",",row.names=FALSE,col.names=FALSE)
write.table(syntax.sim.weighted,row.names=rownames(s1.expand),col.names=FALSE,sep=",",file=out_file)
write.table(" ",file=out_file,row.names=FALSE,col.names=FALSE,sep=",")
write.table("Weighted Syntax Similarity Scores",file=out_file,row.names=FALSE,col.names=FALSE,sep=",")
write.table(syntax.sim.no.penalty.weighted,file=out_file,row.names="Syntax Similarity (Weighted)",col.names=FALSE,sep=",")
write.table(weighted.sim.out,file=out_file,row.names="Penalized Syntax Similarity (Weighted)",col.names=FALSE,sep=",")
close(out_file)

