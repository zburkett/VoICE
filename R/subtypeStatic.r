if(.Platform$OS.type=="unix")
{
	comArgs <- commandArgs(T)
	options(stringsAsFactors=FALSE)
	options(warn=-1)
	sink("/dev/null")
	suppressMessages(library(WGCNA))
	sink()

	if(!exists("flashClust")){flashClust <- hclust}

	Filedir <- comArgs[1]
	cluster <- comArgs[2]
	splitN <- comArgs[3]

	load(paste(Filedir,"workspace.rdata",sep=""))

	#subset the similarity data for only the cluster in question
	cluster.sub <- subset(out.cluster.tutor$mergedSyntax,out.cluster.tutor$mergedSyntax==cluster)
	cluster.sub <- subset(out.cluster.tutor$data,rownames(out.cluster.tutor$data)%in%names(cluster.sub))
	cluster.sub <- t(cluster.sub)
	cluster.sub <- subset(cluster.sub,rownames(cluster.sub)%in%colnames(cluster.sub))
	rownames(cluster.sub) <- colnames(cluster.sub)

	#correlate similarity data to itself
	cluster.cor <- cor(cluster.sub)

	#cluster based on intracluster correlation
	fc <- flashClust(as.dist(1-cluster.cor),method="average")

	#trim tree using static input argument n
	cut <- cutree(fc,k=splitN)

	#assign subtypes to novel colors
	unusedColors <- colors()[!colors()%in%out.cluster.tutor$usedColors]
	cut1 <- unusedColors[cut]
	names(cut1) <- names(cut)
	cut <- cut1
	rm(cut1)

	#put novel syllables into syntax
	if ("mergedSyntax" %in% names(out.cluster.tutor))
	{
		for (name in names(cut))
		{
			out.cluster.tutor$mergedSyntax[names(out.cluster.tutor$mergedSyntax)==name] = 			cut[names(cut)==name]
		}
		out.cluster.tutor$usedColors <- unique(c(out.cluster.tutor$mergedSyntax,out.cluster.tutor$syntax))
	}

	if(!"mergedSyntax" %in% names(out.cluster.tutor) & "syntax" %in% names(out.cluster.tutor))
	{
		for (name in names(cut))
		{
			out.cluster.tutor$syntax[names(out.cluster.tutor$syntax)==name] = 						cut[names(cut)==name]
		}
	
		out.cluster.tutor$usedColors <- unique(out.cluster.tutor$syntax)
	}

	save(out.cluster.tutor,file=paste(Filedir,"workspace.Rdata",sep=""))
}else if (.Platform$OS.type=="windows")
{
	comArgs <- commandArgs(T)
	options(stringsAsFactors=FALSE)
	options(warn=-1)

	sink(paste(comArgs[1],"sink.txt",sep=""))
	suppressMessages(library(WGCNA))
	sink()
	unlink(paste(comArgs[1],"sink.txt",sep=""))

	Filedir <- comArgs[1]
	cluster <- comArgs[2]
	splitN <- comArgs[3]

	load(paste(Filedir,"workspace.rdata",sep=""))

	#subset the similarity data for only the cluster in question
	cluster.sub <- subset(out.cluster.tutor$mergedSyntax,out.cluster.tutor$mergedSyntax==cluster)
	cluster.sub <- subset(out.cluster.tutor$data,rownames(out.cluster.tutor$data)%in%names(cluster.sub))
	cluster.sub <- t(cluster.sub)
	cluster.sub <- subset(cluster.sub,rownames(cluster.sub)%in%colnames(cluster.sub))
	rownames(cluster.sub) <- colnames(cluster.sub)

	#correlate similarity data to itself
	cluster.cor <- cor(cluster.sub)

	#cluster based on intracluster correlation
	fc <- hclust(as.dist(1-cluster.cor),method="average")

	#trim tree using static input argument n
	cut <- cutree(fc,k=splitN)

	#assign subtypes to novel colors
	unusedColors <- colors()[!colors()%in%out.cluster.tutor$usedColors]
	cut1 <- unusedColors[cut]
	names(cut1) <- names(cut)
	cut <- cut1
	rm(cut1)

	#put novel syllables into syntax
	if ("mergedSyntax" %in% names(out.cluster.tutor))
	{
		for (name in names(cut))
		{
			out.cluster.tutor$mergedSyntax[names(out.cluster.tutor$mergedSyntax)==name] = 			cut[names(cut)==name]
		}
		out.cluster.tutor$usedColors <- unique(c(out.cluster.tutor$mergedSyntax,out.cluster.tutor$syntax))
	}

	if(!"mergedSyntax" %in% names(out.cluster.tutor) & "syntax" %in% names(out.cluster.tutor))
	{
		for (name in names(cut))
		{
			out.cluster.tutor$syntax[names(out.cluster.tutor$syntax)==name] = 						cut[names(cut)==name]
		}
	
		out.cluster.tutor$usedColors <- unique(out.cluster.tutor$syntax)
	}

	save(out.cluster.tutor,file=paste(Filedir,"workspace.Rdata",sep=""))
}