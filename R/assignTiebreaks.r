comArgs <- commandArgs(TRUE)

options(stringsAsFactors=FALSE)
options(warn=-1)
pupil.dir <- comArgs[1]

load(paste(comArgs[1],"assign_workspace.Rdata",sep=""))

tiebreaks <- read.table(paste(comArgs[1],"assignmentsOut.txt",sep=""),sep=" ")

tiebreakSyllables <- names(subset(saveList$out.assign,saveList$out.assign=="ND"))

for(i in 1:nrow(tiebreaks))
{
    if (tiebreaks[i,]=="novel")
    {
        saveList$out.assign[as.numeric(tiebreakSyllables[i])] <- NA
    }else{
	saveList$out.assign[as.numeric(tiebreakSyllables[i])] <- tiebreaks[i,]
    }
}

if(sum(is.na(saveList$out.assign))>0)
{
	naout <- subset(names(saveList$out.assign),is.na(saveList$out.assign))
	write.table(as.numeric(naout),file=(paste(pupil.dir,"NAs.csv",sep="")),row.names=FALSE,col.names=FALSE)
	
	if(file.exists(paste(pupil.dir,"unassigned_for_cluster",sep=""))){unlink(paste(pupil.dir,"unassigned_for_cluster",sep=""),recursive=TRUE)}
	dir.create(paste(pupil.dir,"unassigned_for_cluster",sep=""))
	
	data <- read.csv(paste(pupil.dir,"acoustic_data.csv",sep=""),header=TRUE)
	
	for(name in subset(names(saveList$out.assign),is.na(saveList$out.assign)))
	{
		name.assign <- paste("%0",nchar(max(as.numeric(rownames(data)))),"s",sep="")
		name.out <- sprintf(name.assign,name)
		file.copy(from=paste(pupil.dir,"cut_syllables/",name.out,".wav",sep=""),to=paste(pupil.dir,"unassigned_for_cluster/",name.out,".wav",sep=""))
	}
}

save(file=paste(comArgs[1],"assign_workspace.Rdata",sep=""),saveList)