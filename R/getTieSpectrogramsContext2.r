if(.Platform$OS.type=="windows" & file.exists("./.libraries")){.libPaths("./.libraries")}
if(.Platform$OS.type=="unix")
{
	comArgs <- commandArgs(T)
	options(stringsAsFactors=FALSE)
	options(warn=-1)
	sink("/dev/null")
	suppressMessages(library(WGCNA))
	suppressMessages(library(png))
	suppressMessages(library(ggmap))
	sink()

	pupilDir <- comArgs[1]
	tutorDir <- comArgs[2]

	#load(paste(tutorDir,"/workspace.Rdata",sep=""))
	if(file.exists(paste(tutorDir,"/workspace.Rdata",sep="")))
	{
		load(paste(tutorDir,"/workspace.Rdata",sep=""))
		syntaxStr=out.cluster.tutor$mergedSyntax
	} else if(file.exists(paste(tutorDir,"/assign_workspace.Rdata",sep=""))) #(file.exists(paste(tutorDir,"/assigned_complete_workspace.Rdata",sep="")))
	{
		load(paste(tutorDir,"/assign_workspace.Rdata",sep="")) #load(paste(tutorDir,"/assigned_complete_workspace.Rdata",sep=""))
		syntaxStr=saveList$out.assign #syntaxStr=assignedSyntax
		rm(saveList)
	}

	load(paste(pupilDir,"assign_workspace.Rdata",sep=""))

	if(file.exists(paste(pupilDir,"temp_spectro/",sep=""))){unlink(paste(pupilDir,"temp_spectro/",sep=""),recursive=TRUE)}

	if(file.exists(paste(pupilDir,"NAs.csv",sep="/"))) {NAs = 1}
	if(!file.exists(paste(pupilDir,"NAs.csv",sep="/"))) {NAs = 0}

	if(NAs==0) {ties <- subset(saveList$out.assign,saveList$out.assign=="ND")}
	if(NAs==1) {ties=read.csv(paste(pupilDir,"/NDs.csv",sep=""),header=FALSE);ties=t(ties);names(ties)=ties[1,]}



	acoustic.data.1.all <- read.csv(paste(tutorDir,"/.acoustic_data.csv",sep=""),header=T)
	acoustic.data.1 <- acoustic.data.1.all[,c("syllable.duration","mean.pitch","mean.FM","mean.entropy","mean.pitch.goodness","var.pitch","mean.mean.freq","var.FM","var.entropy","var.pitch.goodness","var.mean.freq","var.AM")]

	acoustic.data.2.all <- read.csv(paste(pupilDir,".acoustic_data.csv",sep=""),header=T)
	acoustic.data.2 <- acoustic.data.2.all[,c("syllable.duration","mean.pitch","mean.FM","mean.entropy","mean.pitch.goodness","var.pitch","mean.mean.freq","var.FM","var.entropy","var.pitch.goodness","var.mean.freq","var.AM")]

	if(length(syntaxStr)>4)
	{
		clusters = unique(syntaxStr) #the number of clusters
		clusterTable = list() #empty list

		for (value in clusters)
		{
			tempClust = syntaxStr[syntaxStr==value] #cycle through clusters
			refs = names(tempClust) #names of the syllables in the cluster
			clusterTable[[value]] = subset(acoustic.data.1,rownames(acoustic.data.1)%in%refs)
		}
	}

	if(length(syntaxStr)==4)
	{
		clusters = unique(syntaxStr$syntax) #the number of clusters
		clusterTable = list() #empty list

		for (value in clusters)
		{
			tempClust = syntaxStr$syntax[syntaxStr$syntax==value] #cycle through clusters
			refs = names(tempClust) #names of the syllables in the cluster
			clusterTable[[value]] = subset(acoustic.data.1,rownames(acoustic.data.1)%in%refs)
		}
	}

	newMEs <- vector()
	varExp <- vector()
	for (name in names(clusterTable))
	{
		temp.ME <- moduleEigengenes(t(clusterTable[[name]]),colors=rep(name,nrow(clusterTable[[name]])),scale=FALSE)
		if (name == names(clusterTable)[1])
		{
			newMEs <- temp.ME$eigengenes
			varExp <- temp.ME$varExplained
		}
		if (name != names(clusterTable)[1])
		{
			newMEs <- cbind(newMEs,temp.ME$eigengenes)
			varExp <- c(varExp,temp.ME$varExplained)
		}
	}
	names(varExp) <- colnames(newMEs)

	out.center <- vector()
	
	cluster.cor <- vector()
	for(val in 1:length(clusterTable))
	{
		eigen <- newMEs[,val]
		
		temp.cor <- vector()
		for(syllable in 1:nrow(clusterTable[[val]]))
		{
			temp.cor <- c(temp.cor,cor(t(clusterTable[[val]][syllable,]),eigen))
		}
		names(temp.cor) <- rownames(clusterTable[[val]])
		out.center <- c(out.center,subset(names(temp.cor),temp.cor==max(temp.cor)))
	}
	names(out.center) <- names(clusterTable)

	centers <- out.center
	rm(out.center)

	#Create directory for spectrograms
	if(file.exists(paste(tutorDir,"/.spectrograms",sep="")))
	{
		unlink(paste(tutorDir,"/.spectrograms",sep=""),recursive=TRUE)
	}

	tutdir <- paste(tutorDir,"/.spectrograms",sep="")
	dir.create(tutdir)
	if(.Platform$OS.type=="windows"){system(paste('attrib +h',paste(tutorDir,"/.spectrograms",sep="")))}

	#Generate spectrograms for cluster center syllables
	for(file in 1:length(centers))
	{
		name.assign <- paste("%0",nchar(max(as.numeric(rownames(acoustic.data.1)))),"s",sep="")
		name.out <- sprintf(name.assign,centers[file])
		if(!Sys.info()['sysname']=="Darwin"){name.out <- gsub(" ",0,name.out)}
				
		filename <- paste(tutorDir,"/cut_syllables/",name.out,".wav",sep="")
		filename <- gsub(" ","\\\\ ",filename)
				
		output <- paste(tutorDir,"/.spectrograms/",names(centers)[file],".png",sep="")
		output <- gsub(" ","\\\\ ",output)
		system(paste("sox",filename,"-n rate 20k spectrogram -m -l -Z -20 -Y 260 -X 1200 -z 100  ","-t",names(centers)[file], "-o", output)) 
	}

	assignment.batch <- read.csv(paste(pupilDir,"similarity_batch_assign.csv",sep=""),header=FALSE)
	assignment.batch[,3] <- 100*assignment.batch[,3]
	assignment.batch[,4] <- 100*assignment.batch[,4]
	assignment.batch[,5] <- 100*assignment.batch[,5]
	assignment.batch[,6] <- 100*assignment.batch[,6]
	assignment.batch <- assignment.batch[,1:6]
	colnames(assignment.batch) <- c("Sound 1", "Sound 2", "Similarity", "Accuracy", "Seq Match", "globalsim")

	#Generate stitched spectrograms for each syllable and sorted cluster reps
	for(tie in names(ties))
	{
		sub <- subset(assignment.batch,assignment.batch[,2]==as.numeric(tie))
		sub <- cbind(sub,saveList$out.colors)
		colnames(sub)[7] <- "out.colors"
		clusterMeans <- tapply(sub[,"globalsim"],sub[,"out.colors"],mean)
	
		candidates <- sort(clusterMeans,decreasing=TRUE)
		tutor.order <- paste(tutorDir,"/.spectrograms/",names(candidates),".png",sep="")
	
		name.assign <- paste("%0",nchar(max(as.numeric(rownames(acoustic.data.2)))),"s",sep="")
		tiename <- paste(sprintf(name.assign,tie),".wav",sep="")
	
		pupil.file <- paste(pupilDir,"cut_syllables/",tiename,sep="")
		pupil.file <- gsub(" ","\\\\ ",pupil.file)
		outDir <- paste(tutorDir,"/.spectrograms",sep="")
		outDir <- gsub(" ","\\\\ ",outDir)
	
		#system(paste("sox",pupil.file,"-n spectrogram -Y 260 -X 1200 -z 100 ","-t",paste(tiename), "-o", paste(outDir,"/",tiename,".png",sep="")))
	    #system(paste("sox",pupil.file,"-n rate 20k spectrogram -m -l -Z -20 -Y 260 -X 1200 -z 100 ","-t",paste(tiename), "-o", paste(outDir,"/",tiename,".png",sep="")))
	
		pupil.png <- paste(outDir,"/",tiename,".png",sep="")
	
		all.names <- tutor.order
		all.names.out <- vector()
	
		for(name in 1:length(all.names)){all.names[name]<-gsub(" ","\\\\ ",all.names[name])}
	
		for(len in 1:length(all.names))
		{
			all.names.out <- paste(all.names.out,all.names[len])
		}
	
		if(Sys.info()['sysname']=="Darwin")
		{
			system(paste("convert", all.names.out, "+append", paste(outDir,"/",tiename,".png",sep="")))
		}	

	    write.table(round(clusterMeans,2),file=gsub("\\\\ "," ",paste(outDir,"/",sprintf(name.assign,tie),".csv",sep="")),row.names=FALSE,col.names=FALSE,sep=",")
	}

	for(color in names(centers))
	{
	    unlink(paste(tutorDir,'/.spectrograms/',color,'.png',sep=''))
	}

	#underline syllables in their motif context
	for(tie in names(ties))
	{
		#determine start and stop syllables; precede and procede limits can be changed
		tie.file <- acoustic.data.2.all[tie,"file.name"]
		tie.context <- subset(acoustic.data.2.all,acoustic.data.2.all[,"file.name"]==tie.file)
		tie.context[,"X"] <- 1:nrow(tie.context)
	
		if(as.numeric(tie.context[tie,"X"])>=4)
		{
			n.precede <- as.numeric(tie.context[tie,"X"])-4
			if(n.precede<=0){n.precede=1}
			start.syllable <- rownames(subset(tie.context,tie.context[,"X"]==n.precede))
		}else{	
			n.precede = as.numeric(tie.context[tie,"X"])-as.numeric(tie)
			if(n.precede<=0){n.precede=1}
			start.syllable <- rownames(subset(tie.context,tie.context[,"X"]==n.precede))
		}
	
		if(max(tie.context[,"X"])>(tie.context[tie,"X"]+10))
		{
			#end.syllable <- rownames(subset(tie.context,tie.context[,"X"]==tie.context[as.numeric(tie)+10,"X"]))
			end.syllable <- as.numeric(tie)+10
		}else{
			end.syllable <- rownames(subset(tie.context,tie.context[,"X"]==max(tie.context[nrow(tie.context),"X"])))
		}
	
		#clip .wav file for song, draw spectrogram, delete .wav file
		second = as.numeric(tie.context[start.syllable,"syllable.start"]/1000)
		if (second <= 4) {
					pad = second * 176
				} else if (second <= 8) {
					pad = second * 154
				} else if (second <= 12) {
					pad = second * 132
				} else if (second <= 16) {
					pad = second * 110
				} else if (second <= 20) {
					pad = second * 88
				} else pad = second * 66
		#from <- as.numeric(tie.context[start.syllable,"syllable.start"]/1000) + pad/44100
		from <- second + pad/44100
		to <- as.numeric(tie.context[as.character(end.syllable),"syllable.start"]+tie.context[as.character(end.syllable),"syllable.duration"])/1000 + pad/44100
		to2 <- to-from
	
		if(!file.exists(paste(pupilDir,"/temp_spectro",sep="")))
		{
			dir.create(paste(pupilDir,"/temp_spectro",sep=""))
		}
	
		if (file.exists(paste(pupilDir,"/temp_spectro",sep="")))
		{
			#count = count+1 #Counting which syllable this is
								
			#name.assign <- paste("%0",nchar(max(as.numeric(rownames(feature.batch)))),"s",sep="")
			#name.out <- sprintf(name.assign,row)
			
			#if(!Sys.info()['sysname']=="Darwin") {name.out <- gsub(" ",0,name.out)}
			
			#filename.out <- paste(Filename,filename,sep="")
			#filename.out <- gsub(" ","\\\\ ",filename.out)
			filename.in <- paste(pupilDir,tie.file,sep="")
			filename.in <- gsub(" ","\\\\ ",filename.in)
			output <- paste(pupilDir,"temp_spectro/",tie,".wav",sep="")
			output = gsub(" ","\\\\ ",output)

			system(paste("sox",filename.in,output,"trim",from,to2))
		}
	
		#create spectrogram using sox, delete original wav
		system(paste("sox", paste(gsub(" ","\\\\ ",pupilDir),"temp_spectro/",tie,".wav",sep=""), "-n rate 20k spectrogram -m -l -Z -50 -Y 130 -X 600 -l -o", paste(gsub(" ","\\\\ ",pupilDir),"temp_spectro/",tie,".png",sep="")))
	
		unlink(paste(pupilDir,"temp_spectro/",tie,".wav",sep=""))
	
		#plot an underline for the syllable in question
		if(second==0)
		{
			line.start <- ((acoustic.data.2.all[tie,"syllable.start"]/100)*61)+56 #61 pixels per 100 milliseconds, 56 pixel border on the SoX spectrogram file
			line.end <- line.start + ((acoustic.data.2.all[tie,"syllable.duration"]/100)*61)
		}else
		{
			line.start <- (((acoustic.data.2.all[tie,"syllable.start"]-(second*1000))/100)*61)+56
			line.end <- line.start + ((acoustic.data.2.all[tie,"syllable.duration"]/100)*61)
		}
	
		maxChar <- nchar(max(gsub(".wav","",list.files(paste(pupilDir,"cut_syllables",sep="")))))
		name.assign <- paste("%0",maxChar,"s",sep="")
		tieNum <- sprintf(name.assign,tie)
	
		system(paste("convert ",gsub(" ","\\\\ ",pupilDir),"temp_spectro/",tie,".png ", "-fill none -stroke red -strokewidth 3 -draw 'line ", line.start,",162, ", line.end,",162' ", paste(gsub(" ","\\\\ ",pupilDir),"temp_spectro/",tieNum,"-line.png",sep=""), sep=""))
	
		unlink(paste(pupilDir,"temp_spectro/",tie,".png",sep=""))
	}

	if(file.exists(paste(pupilDir,"final_spectro",sep="")))
	{
		unlink(paste(pupilDir,"final_spectro",sep=""),recursive=TRUE)
	}
	dir.create(paste(pupilDir,"final_spectro",sep=""))

	for(file in 1:length(list.files(paste(pupilDir,"temp_spectro",sep=""))))
	{
		system(paste("convert", paste(gsub(" ","\\\\ ",pupilDir),"temp_spectro/",list.files(paste(pupilDir,"temp_spectro",sep=""))[file],sep=""), paste(gsub(" ","\\\\ ",tutorDir),"/.spectrograms/", list.files(paste(tutorDir,"/.spectrograms/",sep=""),pattern="*.png")[file],sep=""), "-append", paste(gsub(" ","\\\\ ",pupilDir),"final_spectro/", gsub(".wav","",list.files(paste(tutorDir,"/.spectrograms/",sep=""),pattern="*.png")[file]),sep="")))
	}
}else if (.Platform$OS.type=="windows")
{
	comArgs <- commandArgs(T)
	options(stringsAsFactors=FALSE)
	options(warn=-1)

	sink(paste(comArgs[1],"sink.txt",sep=""))
	suppressMessages(library(WGCNA))
	suppressMessages(library(png))
	suppressMessages(library(ggmap))
	sink()
	unlink(paste(comArgs[1],"sink.txt",sep=""))

	pupilDir <- comArgs[1]
	tutorDir <- comArgs[2]

	#load(paste(tutorDir,"/workspace.Rdata",sep=""))
	if(file.exists(paste(tutorDir,"/workspace.Rdata",sep="")))
	{
		load(paste(tutorDir,"/workspace.Rdata",sep=""))
		syntaxStr=out.cluster.tutor$mergedSyntax
	} else if(file.exists(paste(tutorDir,"/assign_workspace.Rdata",sep="")))
	{
		load(paste(tutorDir,"/assign_workspace.Rdata",sep=""))
		syntaxStr=saveList$out.assign #syntaxStr=assignedSyntax
		rm(saveList)
	}

	load(paste(pupilDir,"assign_workspace.Rdata",sep=""))

	if(file.exists(paste(pupilDir,"temp_spectro/",sep=""))){unlink(paste(pupilDir,"temp_spectro/",sep=""),recursive=TRUE)}

	if(file.exists(paste(pupilDir,"NAs.csv",sep="/"))) {NAs = 1}
	if(!file.exists(paste(pupilDir,"NAs.csv",sep="/"))) {NAs = 0}

	if(NAs==0) {ties <- subset(saveList$out.assign,saveList$out.assign=="ND")}
	if(NAs==1) {ties=read.csv(paste(pupilDir,"/NDs.csv",sep=""),header=FALSE);ties=t(ties);names(ties)=ties[1,]}



	acoustic.data.1.all <- read.csv(paste(tutorDir,"/.acoustic_data.csv",sep=""),header=T)
	acoustic.data.1 <- acoustic.data.1.all[,c("syllable.duration","mean.pitch","mean.FM","mean.entropy","mean.pitch.goodness","var.pitch","mean.mean.freq","var.FM","var.entropy","var.pitch.goodness","var.mean.freq","var.AM")]

	acoustic.data.2.all <- read.csv(paste(pupilDir,".acoustic_data.csv",sep=""),header=T)
	acoustic.data.2 <- acoustic.data.2.all[,c("syllable.duration","mean.pitch","mean.FM","mean.entropy","mean.pitch.goodness","var.pitch","mean.mean.freq","var.FM","var.entropy","var.pitch.goodness","var.mean.freq","var.AM")]

	if(length(syntaxStr)>4)
	{
		clusters = unique(syntaxStr) #the number of clusters
		clusterTable = list() #empty list

		for (value in clusters)
		{
			tempClust = syntaxStr[syntaxStr==value] #cycle through clusters
			refs = names(tempClust) #names of the syllables in the cluster
			clusterTable[[value]] = subset(acoustic.data.1,rownames(acoustic.data.1)%in%refs)
		}
	}

	if(length(syntaxStr)==4)
	{
		clusters = unique(syntaxStr$syntax) #the number of clusters
		clusterTable = list() #empty list

		for (value in clusters)
		{
			tempClust = syntaxStr$syntax[syntaxStr$syntax==value] #cycle through clusters
			refs = names(tempClust) #names of the syllables in the cluster
			clusterTable[[value]] = subset(acoustic.data.1,rownames(acoustic.data.1)%in%refs)
		}
	}

	newMEs <- vector()
	varExp <- vector()
	for (name in names(clusterTable))
	{
		temp.ME <- moduleEigengenes(t(clusterTable[[name]]),colors=rep(name,nrow(clusterTable[[name]])),scale=FALSE)
		if (name == names(clusterTable)[1])
		{
			newMEs <- temp.ME$eigengenes
			varExp <- temp.ME$varExplained
		}
		if (name != names(clusterTable)[1])
		{
			newMEs <- cbind(newMEs,temp.ME$eigengenes)
			varExp <- c(varExp,temp.ME$varExplained)
		}
	}
	names(varExp) <- colnames(newMEs)

	out.center <- vector()
	
	cluster.cor <- vector()
	for(val in 1:length(clusterTable))
	{
		eigen <- newMEs[,val]
		
		temp.cor <- vector()
		for(syllable in 1:nrow(clusterTable[[val]]))
		{
			temp.cor <- c(temp.cor,cor(t(clusterTable[[val]][syllable,]),eigen))
		}
		names(temp.cor) <- rownames(clusterTable[[val]])
		out.center <- c(out.center,subset(names(temp.cor),temp.cor==max(temp.cor)))
	}
	names(out.center) <- names(clusterTable)

	centers <- out.center
	rm(out.center)

	#Create directory for spectrograms
	if(file.exists(paste(tutorDir,"/.spectrograms",sep="")))
	{
		unlink(paste(tutorDir,"/.spectrograms",sep=""),recursive=TRUE)
	}

	tutdir <- paste(tutorDir,"/.spectrograms",sep="")
	dir.create(tutdir)
	if(.Platform$OS.type=="windows"){system(paste('attrib +h',paste(tutorDir,"/.spectrograms",sep="")))}

	#Generate spectrograms for cluster center syllables
	for(file in 1:length(centers))
	{
		name.assign <- paste("%0",nchar(max(as.numeric(rownames(acoustic.data.1)))),"s",sep="")
		name.out <- sprintf(name.assign,centers[file])
		if(!Sys.info()['sysname']=="Darwin"){name.out <- gsub(" ",0,name.out)}
				
		filename <- paste(tutorDir,"/cut_syllables/",name.out,".wav",sep="")
		#filename <- gsub(" ","\\\\ ",filename)
				
		output <- paste(tutorDir,"/.spectrograms/",names(centers)[file],".png",sep="")
		#output <- gsub(" ","\\\\ ",output)
		system(paste("sox",dQuote(filename),"-n rate 20k spectrogram -m -l -Z -20 -Y 260 -X 1200 -z 100  ","-t",names(centers)[file], "-o", dQuote(output))) 
	}

	assignment.batch <- read.csv(paste(pupilDir,"similarity_batch_assign.csv",sep=""),header=FALSE)
	assignment.batch[,3] <- 100*assignment.batch[,3]
	assignment.batch[,4] <- 100*assignment.batch[,4]
	assignment.batch[,5] <- 100*assignment.batch[,5]
	assignment.batch[,6] <- 100*assignment.batch[,6]
	assignment.batch <- assignment.batch[,1:6]
	colnames(assignment.batch) <- c("Sound 1", "Sound 2", "Similarity", "Accuracy", "Seq Match", "globalsim")

	#Generate stitched spectrograms for each syllable and sorted cluster reps
	for(tie in names(ties))
	{
		sub <- subset(assignment.batch,assignment.batch[,2]==as.numeric(tie))
		sub <- cbind(sub,saveList$out.colors)
		colnames(sub)[7] <- "out.colors"
		clusterMeans <- tapply(sub[,"globalsim"],sub[,"out.colors"],mean)
	
		candidates <- sort(clusterMeans,decreasing=TRUE)
		tutor.order <- paste(tutorDir,"/.spectrograms/",names(candidates),".png",sep="")
	
		name.assign <- paste("%0",nchar(max(as.numeric(rownames(acoustic.data.2)))),"s",sep="")
		tiename <- paste(sprintf(name.assign,tie),".wav",sep="")
	    if(!Sys.info()['sysname']=="Darwin"){tiename <- gsub(" ",0,tiename)}
	
		pupil.file <- paste(pupilDir,"cut_syllables/",tiename,sep="")
		#pupil.file <- gsub(" ","\\\\ ",pupil.file)
		outDir <- paste(tutorDir,"/.spectrograms",sep="")
		#outDir <- gsub(" ","\\\\ ",outDir)
	
		#system(paste("sox",pupil.file,"-n spectrogram -Y 260 -X 1200 -z 100 ","-t",paste(tiename), "-o", paste(outDir,"/",tiename,".png",sep="")))
	    #system(paste("sox",pupil.file,"-n rate 20k spectrogram -m -l -Z -20 -Y 260 -X 1200 -z 100 ","-t",paste(tiename), "-o", paste(outDir,"/",tiename,".png",sep="")))
	
		pupil.png <- paste(outDir,"/",tiename,".png",sep="")
	
		all.names <- tutor.order
		all.names.out <- vector()
	
		#for(name in 1:length(all.names)){all.names[name]<-gsub(" ","\\\\ ",all.names[name])}
	
		for(len in 1:length(all.names))
		{
			all.names.out <- paste(all.names.out,dQuote(all.names[len]))
		}
	
		if(Sys.info()['sysname']=="Darwin")
		{
			system(paste("convert", all.names.out, "+append", paste(outDir,"/",tiename,".png",sep="")))
		}else{
        
	        system(paste("magick", all.names.out, "+append", dQuote(paste(outDir,"/",tiename,".png",sep=""))))
	    }
    
	    write.table(round(clusterMeans,2),paste(outDir,"/",gsub(" ",0,sprintf(name.assign,tie)),".csv",sep=""),row.names=FALSE,col.names=FALSE,sep=",")

	}

	for(color in names(centers))
	{
	    unlink(paste(tutorDir,'/.spectrograms/',color,'.png',sep=''))
	}

	#underline syllables in their motif context
	for(tie in names(ties))
	{
		#determine start and stop syllables; precede and procede limits can be changed
		tie.file <- acoustic.data.2.all[tie,"file.name"]
		tie.context <- subset(acoustic.data.2.all,acoustic.data.2.all[,"file.name"]==tie.file)
		tie.context[,"X"] <- 1:nrow(tie.context)
	
		if(as.numeric(tie.context[tie,"X"])>=4)
		{
			n.precede <- as.numeric(tie.context[tie,"X"])-4
			if(n.precede<=0){n.precede=1}
			start.syllable <- rownames(subset(tie.context,tie.context[,"X"]==n.precede))
		}else{	
			n.precede = as.numeric(tie.context[tie,"X"])-as.numeric(tie)
			if(n.precede<=0){n.precede=1}
			start.syllable <- rownames(subset(tie.context,tie.context[,"X"]==n.precede))
		}
	
		if(max(tie.context[,"X"])>(tie.context[tie,"X"]+10))
		{
			#end.syllable <- rownames(subset(tie.context,tie.context[,"X"]==tie.context[as.numeric(tie)+10,"X"]))
			end.syllable <- as.numeric(tie)+10
		}else{
			end.syllable <- rownames(subset(tie.context,tie.context[,"X"]==max(tie.context[nrow(tie.context),"X"])))
		}
	
		#clip .wav file for song, draw spectrogram, delete .wav file
		second = as.numeric(tie.context[start.syllable,"syllable.start"]/1000)
		if (second <= 4) {
					pad = second * 176
				} else if (second <= 8) {
					pad = second * 154
				} else if (second <= 12) {
					pad = second * 132
				} else if (second <= 16) {
					pad = second * 110
				} else if (second <= 20) {
					pad = second * 88
				} else pad = second * 66
		#from <- as.numeric(tie.context[start.syllable,"syllable.start"]/1000) + pad/44100
		from <- second + pad/44100
		to <- as.numeric(tie.context[as.character(end.syllable),"syllable.start"]+tie.context[as.character(end.syllable),"syllable.duration"])/1000 + pad/44100
		to2 <- to-from
	
		if(!file.exists(paste(pupilDir,"temp_spectro",sep="")))
		{
			dir.create(paste(pupilDir,"temp_spectro",sep=""))
		}
	
		if (file.exists(paste(pupilDir,"temp_spectro",sep="")))
		{
			#count = count+1 #Counting which syllable this is
								
			#name.assign <- paste("%0",nchar(max(as.numeric(rownames(feature.batch)))),"s",sep="")
			#name.out <- sprintf(name.assign,row)
			
			#if(!Sys.info()['sysname']=="Darwin") {name.out <- gsub(" ",0,name.out)}
			
			#filename.out <- paste(Filename,filename,sep="")
			#filename.out <- gsub(" ","\\\\ ",filename.out)
			filename.in <- paste(pupilDir,tie.file,sep="")
			#filename.in <- gsub(" ","\\\\ ",filename.in)
			output <- paste(pupilDir,"temp_spectro/",tie,".wav",sep="")
			#output = gsub(" ","\\\\ ",output)

			system(paste("sox",dQuote(filename.in),dQuote(output),"trim",from,to2))
		}
	
		#create spectrogram using sox, delete original wav
		system(paste("sox", dQuote(paste(pupilDir,"temp_spectro/",tie,".wav",sep="")), " -n rate 20k spectrogram -m -l -Z -50 -Y 130 -X 600 -l -o", dQuote(paste(pupilDir,"temp_spectro/",tie,".png",sep=""))))
	
		unlink(paste(pupilDir,"temp_spectro/",tie,".wav",sep=""))
	
		#plot an underline for the syllable in question
		if(second==0)
		{
			line.start <- ((acoustic.data.2.all[tie,"syllable.start"]/100)*61)+56 #61 pixels per 100 milliseconds, 56 pixel border on the SoX spectrogram file
			line.end <- line.start + ((acoustic.data.2.all[tie,"syllable.duration"]/100)*61)
		}else
		{
			line.start <- (((acoustic.data.2.all[tie,"syllable.start"]-(second*1000))/100)*61)+56
			line.end <- line.start + ((acoustic.data.2.all[tie,"syllable.duration"]/100)*61)
		}
	
		maxChar <- nchar(max(gsub(".wav","",list.files(paste(pupilDir,"cut_syllables",sep="")))))
		name.assign <- paste("%0",maxChar,"s",sep="")
		tieNum <- sprintf(name.assign,tie)
	    if(!Sys.info()['sysname']=="Darwin"){tieNum <- gsub(" ",0,tieNum)}
	
		#system(paste("magick ",dQuote(paste(pupilDir,"temp_spectro/",tie,".png",sep="")), " -fill none -stroke red -strokewidth 3 -draw 'line ", line.start,",162, ", line.end,",162' ", dQuote(paste(pupilDir,"temp_spectro/",tieNum,"-line.png",sep=""))))
		system(paste("magick ",dQuote(paste(pupilDir,"temp_spectro/",tie,".png",sep="")), " -fill none -stroke red -strokewidth 3 -draw ", dQuote(paste("line ",line.start,",",162," ",line.end,",",162,sep=""))," ",dQuote(paste(pupilDir,"temp_spectro/",tieNum,"-line.png",sep="")),sep=""))
		unlink(paste(pupilDir,"temp_spectro/",tie,".png",sep=""))
	}

	if(file.exists(paste(pupilDir,"final_spectro",sep="")))
	{
		unlink(paste(pupilDir,"final_spectro",sep=""),recursive=TRUE)
	}
	dir.create(paste(pupilDir,"final_spectro",sep=""))

	for(file in 1:length(list.files(paste(pupilDir,"temp_spectro",sep=""),pattern="*.png")))
	{
		system(paste("magick", dQuote(paste(pupilDir,"temp_spectro/",list.files(paste(pupilDir,"temp_spectro",sep=""))[file],sep="")), dQuote(paste(tutorDir,"/.spectrograms/", list.files(paste(tutorDir,"/.spectrograms/",sep=""),pattern="*.png")[file],sep="")), "-append", dQuote(paste(pupilDir,"final_spectro/", gsub(".wav","",list.files(paste(tutorDir,"/.spectrograms/",sep=""),pattern="*.png")[file]),sep=""))))
	}
}