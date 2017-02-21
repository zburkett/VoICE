if(.Platform$OS.type=="unix")
{
	options(stringsAsFactors=FALSE)
	comArgs <- commandArgs(T)

	options(warn=-1)

	feature.batch <- read.csv(comArgs[1])
	feature.batch <- feature.batch[,-1]

	feature.batch[,"syllable.start"] <- as.numeric(feature.batch[,"syllable.start"])
	feature.batch[,"syllable.end"] <- as.numeric(feature.batch[,"syllable.end"])
	files = unique(feature.batch[,"file.name"])
	count = 0 
	type = "recursive"
	for(filename in files) #Starts cycling through each .WAV file
	{
		syllables = subset(feature.batch,file.name==filename)
		syllables[,"file.name"] <- dQuote(syllables[,"file.name"])
	
		for(row in rownames(syllables)) 
		{
			if(type=="batch")
			{
				lag.lead = (as.numeric(syllables[row,"syllable.start"])/1000)*2
				lag.tail = (as.numeric(syllables[row,"syllable.start"]/1000))*2.5
				from <- (as.numeric(syllables[row,"syllable.start"])+lag.lead)/1000
				to <- (as.numeric(syllables[row,"syllable.end"])+lag.tail)/1000
				to2 <- to-from
			}
		
			if(type=="manual")
			{
				from <- as.numeric(syllables[row,"syllable.start"])/1000
				to <- as.numeric(syllables[row,"syllable.end"])/1000
				to2 <- to-from
			}
		
			if (type == "recursive") {
				second = floor(as.numeric(syllables[row, "syllable.start"]/1000))
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

				from <- as.numeric(syllables[row, "syllable.start"])/1000 + pad/44100
				to <- as.numeric(syllables[row, "syllable.end"])/1000 + pad/44100
				to2 <- to-from
			}

			
			if (!file.exists(paste(comArgs[2],"cut_syllables",sep="")))
			{
				dir.create(paste(comArgs[2],"cut_syllables",sep=""))
			}
				
			if (file.exists(paste(comArgs[2],"cut_syllables",sep="")))
			{
				count = count+1 #Counting which syllable this is
								
				name.assign <- paste("%0",nchar(max(as.numeric(rownames(feature.batch)))),"s",sep="")
				name.out <- sprintf(name.assign,row)
			
				if(!Sys.info()['sysname']=="Darwin") {name.out <- gsub(" ",0,name.out)}
			
				filename.out <- paste(comArgs[2],filename,sep="")
				filename.out <- gsub(" ","\\\\ ",filename.out)
				output = paste(comArgs[2],"cut_syllables/",paste(name.out,".wav",sep=''),sep="")
				output = gsub(" ","\\\\ ",output)

				#system(paste("/Applications/sox-14.4.1/sox",filename.out,output,"trim",from,to2)) #modified to remove absolute reference to application, should work for Homebrew install of SoX.
				system(paste("sox",filename.out,output,"trim",from,to2))
			
				#if(count%%100==0)
				#{
				#	print(paste("Working on syllable:",count,"of",nrow(feature.batch),sep=" "))
				#}
			
				#if(count/nrow(feature.batch)==1)
				#{
					#print(paste("Done!"))
				#}
			}	
		}				
	}
}else if (.Platform$OS.type=="windows")
{
	options(stringsAsFactors=FALSE)
	comArgs <- commandArgs(T)

	options(warn=-1)

	feature.batch <- read.csv(comArgs[1])
	feature.batch <- feature.batch[,-1]

	feature.batch[,"syllable.start"] <- as.numeric(feature.batch[,"syllable.start"])
	feature.batch[,"syllable.end"] <- as.numeric(feature.batch[,"syllable.end"])
	files = unique(feature.batch[,"file.name"])
	count = 0 
	type = "recursive"
	for(filename in files) #Starts cycling through each .WAV file
	{
		syllables = subset(feature.batch,file.name==filename)
		syllables[,"file.name"] <- dQuote(syllables[,"file.name"])
	
		for(row in rownames(syllables)) 
		{
			if(type=="batch")
			{
				lag.lead = (as.numeric(syllables[row,"syllable.start"])/1000)*2
				lag.tail = (as.numeric(syllables[row,"syllable.start"]/1000))*2.5
				from <- (as.numeric(syllables[row,"syllable.start"])+lag.lead)/1000
				to <- (as.numeric(syllables[row,"syllable.end"])+lag.tail)/1000
				to2 <- to-from
			}
		
			if(type=="manual")
			{
				from <- as.numeric(syllables[row,"syllable.start"])/1000
				to <- as.numeric(syllables[row,"syllable.end"])/1000
				to2 <- to-from
			}
		
			if (type == "recursive") {
				second = floor(as.numeric(syllables[row, "syllable.start"]/1000))
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

				from <- as.numeric(syllables[row, "syllable.start"])/1000 + pad/44100
				to <- as.numeric(syllables[row, "syllable.end"])/1000 + pad/44100
				to2 <- to-from
			}

			
			if (!file.exists(paste(comArgs[2],"cut_syllables",sep="")))
			{
				dir.create(paste(comArgs[2],"cut_syllables",sep=""))
			}
				
			if (file.exists(paste(comArgs[2],"cut_syllables",sep="")))
			{
				count = count+1 #Counting which syllable this is
								
				name.assign <- paste("%0",nchar(max(as.numeric(rownames(feature.batch)))),"s",sep="")
				name.out <- sprintf(name.assign,row)
			
				if(!Sys.info()['sysname']=="Darwin") {name.out <- gsub(" ",0,name.out)}
			
				filename.out <- paste(comArgs[2],filename,sep="")
				#filename.out <- gsub(" ","\\\\ ",filename.out)
				output = paste(comArgs[2],"cut_syllables/",paste(name.out,".wav",sep=''),sep="")
				#output = gsub(" ","\\\\ ",output)

				#system(paste("/Applications/sox-14.4.1/sox",filename.out,output,"trim",from,to2)) #modified to remove absolute reference to application, should work for Homebrew install of SoX.
				system(paste("sox",dQuote(filename.out),dQuote(output),"trim",from,to2))
			
				#if(count%%100==0)
				#{
				#	print(paste("Working on syllable:",count,"of",nrow(feature.batch),sep=" "))
				#}
			
				#if(count/nrow(feature.batch)==1)
				#{
					#print(paste("Done!"))
				#}
			}	
		}				
	}
}	
