if(.Platform$OS.type=="unix")
{
	comArgs <- commandArgs(T)
	options(stringsAsFactors=FALSE)
	options(warn=-1)

	sink("/dev/null")
	suppressMessages(library(WGCNA))
	options(warn=-1)
	sink()

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

	load(paste(comArgs[1],'/workspace.Rdata',sep=""))

	if("mergedSyntax" %in% names(out.cluster.tutor))
	{
		MEs <- moduleEigengenes(t(out.cluster.tutor$data),colors=out.cluster.tutor$mergedSyntax,scale=FALSE,excludeGrey=FALSE)
		x <- syntaxRename(out.cluster.tutor$mergedSyntax)
	}

	if(!"mergedSyntax" %in% names(out.cluster.tutor))
	{
		MEs <- moduleEigengenes(t(out.cluster.tutor$data),colors=out.cluster.tutor$syntax,scale=FALSE,excludeGrey=FALSE)
		x <- syntaxRename(out.cluster.tutor$syntax)
	}

	out.cluster.tutor$eigensyls <- MEs$eigengenes
	out.cluster.tutor$varianceExp <- MEs$varExplained
	names(out.cluster.tutor$varianceExp) <- names(MEs$eigengenes)

	save(out.cluster.tutor,file=paste(comArgs[1],"workspace.Rdata",sep=""))

	tps <- syntaxEntropy(x[[1]])
	rownames(tps[[1]]) <- names(x$key)
	colnames(tps[[1]]) <- names(x$key)

	if(file.exists(paste(comArgs[1],"syntax_summary.csv",sep="")))
	{
		unlink(paste(comArgs[1],"syntax_summary.csv",sep=""))
	}

	out_file <- file(paste(comArgs[1],"syntax_summary.csv",sep=""), open="a")
	write.table("Transition Probability Matrix",file=out_file,row.names=FALSE,col.names=FALSE)
	write.table(t(c(" ",names(x$key))),file=out_file,row.names=FALSE,col.names=FALSE,sep=",")
	write.table(tps[[1]],file=out_file,sep=",",row.names=names(x$key),col.names=FALSE)
	write.table(" ",file=out_file,row.names=FALSE,col.names=FALSE)
	write.table(tps[[2]],file=out_file,sep=",",row.names="Entropy",col.names=FALSE)
	write.table(tps[[3]],file=out_file,sep=",",row.names="Stereotypy",col.names=FALSE)
	write.table(tps[[4]],file=out_file,sep=",",row.names="Weighted Entropy",col.names=FALSE)
	write.table(tps[[5]],file=out_file,sep=",",row.names="Weighted Stereotypy",col.names=FALSE)
	close(out_file)
}else if (.Platform$OS.type=="windows")
{
	comArgs <- commandArgs(T)
	options(stringsAsFactors=FALSE)
	options(warn=-1)

	sink(paste(comArgs[1],"sink.txt",sep=""))
	suppressMessages(library(WGCNA))
	options(warn=-1)
	sink()
	unlink(paste(comArgs[1],"sink.txt",sep=""))

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

	load(paste(comArgs[1],'workspace.Rdata',sep=""))

	if("mergedSyntax" %in% names(out.cluster.tutor))
	{
		MEs <- moduleEigengenes(t(out.cluster.tutor$data),colors=out.cluster.tutor$mergedSyntax,scale=FALSE,excludeGrey=FALSE)
		x <- syntaxRename(out.cluster.tutor$mergedSyntax)
	}

	if(!"mergedSyntax" %in% names(out.cluster.tutor))
	{
		MEs <- moduleEigengenes(t(out.cluster.tutor$data),colors=out.cluster.tutor$syntax,scale=FALSE,excludeGrey=FALSE)
		x <- syntaxRename(out.cluster.tutor$syntax)
	}

	out.cluster.tutor$eigensyls <- MEs$eigengenes
	out.cluster.tutor$varianceExp <- MEs$varExplained
	names(out.cluster.tutor$varianceExp) <- names(MEs$eigengenes)

	save(out.cluster.tutor,file=paste(comArgs[1],"workspace.Rdata",sep=""))

	tps <- syntaxEntropy(x[[1]])
	rownames(tps[[1]]) <- names(x$key)
	colnames(tps[[1]]) <- names(x$key)

	if(file.exists(paste(comArgs[1],"syntax_summary.csv",sep="")))
	{
		unlink(paste(comArgs[1],"syntax_summary.csv",sep=""))
	}

	out_file <- file(paste(comArgs[1],"syntax_summary.csv",sep=""), open="a")
	write.table("Transition Probability Matrix",file=out_file,row.names=FALSE,col.names=FALSE)
	write.table(t(c(" ",names(x$key))),file=out_file,row.names=FALSE,col.names=FALSE,sep=",")
	write.table(tps[[1]],file=out_file,sep=",",row.names=names(x$key),col.names=FALSE)
	write.table(" ",file=out_file,row.names=FALSE,col.names=FALSE)
	write.table(tps[[2]],file=out_file,sep=",",row.names="Entropy",col.names=FALSE)
	write.table(tps[[3]],file=out_file,sep=",",row.names="Stereotypy",col.names=FALSE)
	write.table(tps[[4]],file=out_file,sep=",",row.names="Weighted Entropy",col.names=FALSE)
	write.table(tps[[5]],file=out_file,sep=",",row.names="Weighted Stereotypy",col.names=FALSE)
	close(out_file)
}
