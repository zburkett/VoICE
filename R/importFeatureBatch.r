if(.Platform$OS.type=="windows" & file.exists("./.libraries")){.libPaths("./.libraries")}
comArgs <- commandArgs(T)
options(stringsAsFactors=FALSE)
suppressMessages(library(gdata))
options(warn=-1)

if(.Platform$OS.type=="unix")
{
	sink("/dev/null")
	data.path <- paste(comArgs[1],comArgs[2],sep="")
	sink()
}else if (.Platform$OS.type=="windows")
{
	sink(paste(comArgs[1],"sink.txt",sep=""))
	data.path <- paste(comArgs[1],comArgs[2],sep="")
	sink()
    unlink(paste(comArgs[1],"sink.txt",sep=""))
}

data.out <- read.xls(data.path,header=FALSE)
data.out <- data.out[,-1]
data.out <- data.out[-c(1,2),]
colnames(data.out) <- c("name","syllable.duration","syllable.start","mean.amplitude","mean.pitch","mean.FM","mean.AM.2","mean.entropy","mean.pitch.goodness","mean.mean.freq","var.pitch","var.FM","var.entropy","var.pitch.goodness","var.mean.freq","var.AM","month","day","hour","minute","second","cluster","file.name","comments")
	
for(col in 1:ncol(data.out))
{
	test <- is.numeric(data.out[,col])
	if(sum(is.na(test))>0)
	{
		data.out[,col] <- as.numeric(data.out[,col])
	}
}
dupes <- duplicated(data.out)
data.out <- data.out[!dupes,]
data.out <- subset(data.out,as.numeric(data.out[,"syllable.duration"])>12) #remove syllables < 12 msec to prevent MATLAB error in similarity scoring
	
rownames(data.out) <- 1:nrow(data.out)
	
syllable.end <- as.numeric(data.out[,"syllable.duration"])+as.numeric(data.out[,"syllable.start"])
data.out <- cbind(data.out[,1:3],syllable.end,data.out[,4:ncol(data.out)])
	
write.csv(data.out,paste(comArgs[1],"acoustic_data.csv",sep=""))
