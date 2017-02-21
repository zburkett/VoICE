if(.Platform$OS.type=="windows" & file.exists("./.libraries")){.libPaths("./.libraries")}
comArgs <- commandArgs(T)
options(stringsAsFactors=FALSE)
options(warn=-1)

Filedir <- comArgs[1]

load(paste(Filedir,"igs_assigned.Rdata",sep=""))
input <- outlist$gsMatrix
IGS.out <- outlist$IGS.out

n.break <- vector()
for(value in names(IGS.out))
{
	n.break <- c(n.break,ncol(IGS.out[[value]]))
}
names(n.break) <- names(IGS.out)

n.break.all <- n.break
n.break <- subset(n.break,duplicated(n.break))

out.break <- vector()
for(value in unique(n.break))
{
	temp.break <- subset(n.break,n.break==value)
	out.break <- c(out.break,temp.break[1])
}
	
break.points <- matrix(nrow=length(out.break),ncol=2)
rownames(break.points) <- names(out.break)
colnames(break.points) <- c("n.cluster","thresh.dif")
break.points[,1] <- out.break
for(name in 1:nrow(break.points))
{
	if(!name==nrow(break.points))
	{
		break.points[name,2] <- as.numeric((as.numeric(rownames(break.points)[name+1])*100)-(as.numeric(rownames(break.points)[name])*100))
	}
	
	if(name==nrow(break.points))
	{
		break.points[name,2] <- 100-(as.numeric(rownames(break.points)[name])*100)
	}
}
	
icilist <- list()
for(breaks in rownames(break.points))
{
	icilist[[breaks]] <- IGS.out[breaks]
}

out.mat <- matrix(nrow=nrow(break.points),ncol=(max(break.points[,1])*2)+1)
out.mat[,1] <- rownames(break.points)
 
for(thresh in 1:length(icilist))
{
    loop <- 1
    for(col in 1:ncol(icilist[[thresh]][[1]]))
    {
        for(row in 1:nrow(icilist[[thresh]][[1]]))
        {
            loop <- loop+1
            if(row %% 2 != 0){out.mat[thresh,loop] <- icilist[[thresh]][[1]][1,col]}
            if(row %% 2 == 0){out.mat[thresh,loop] <- icilist[[thresh]][[1]][2,col]}
        }
    }
}
 
out.mat <- as.data.frame(out.mat)
out.mat <- data.matrix(out.mat)
out.mat[is.na(out.mat)]=0
 
write.table(out.mat,paste(comArgs[1],'igsdata_novel.csv',sep=""),row.names=FALSE,col.names=FALSE,sep=",")
 
outnames <- vector()
for(name in colnames(icilist[[1]][[1]]))
{
    outnames <- c(outnames,c(paste(name,"IGS",sep=" "),paste(name,"n",sep=" ")))
}
outnames <- c("Threshold", outnames)
 
write.table(t(outnames),paste(comArgs[1],'colnames_novel.txt',sep=""),row.names=FALSE,col.names=FALSE,sep="\n")
 
pdf(file=paste(comArgs[1],"tree_trim_curve_novel.pdf",sep=""))
png(file=paste(comArgs[1],"tree_trim_curve_novel.png",sep=""))
plot(as.numeric(names(n.break.all)),n.break.all,ylab="Cluster n",xlab="1-merging threshold",main="Iterative Tree Trimming Curve",pch=16)
z <- dev.off()


