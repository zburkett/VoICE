if(.Platform$OS.type=="windows" & file.exists("./.libraries")){.libPaths("./.libraries")}
comArgs <- commandArgs(T)
options(stringsAsFactors=FALSE)

Filedir <- comArgs[1]

load(paste(Filedir,".igs.Rdata",sep=""))
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

if(file.exists(paste(comArgs[1],'.igsdata.csv',sep=""))){unlink(paste(comArgs[1],'.igsdata.csv',sep=""))}
write.table(out.mat,paste(comArgs[1],'.igsdata.csv',sep=""),row.names=FALSE,col.names=FALSE,sep=",")
if(.Platform$OS.type=="windows"){system(paste('attrib +h',paste(comArgs[1],'.igsdata.csv',sep="")))}

outnames <- vector()
for(name in colnames(icilist[[1]][[1]]))
{
    outnames <- c(outnames,c(paste(name,"IGS",sep=" "),paste(name,"n",sep=" ")))
}
outnames <- c("Threshold", outnames)

if(file.exists(paste(comArgs[1],'.colnames.txt',sep=""))){unlink(paste(comArgs[1],'.colnames.txt',sep=""),force=T)}
write.table(t(outnames),paste(comArgs[1],'.colnames.txt',sep=""),row.names=FALSE,col.names=FALSE,sep="\n")
if(.Platform$OS.type=="windows"){system(paste('attrib +h',paste(comArgs[1],'.colnames.txt',sep="")))}

if(file.exists(paste(comArgs[1],".tree_trim_curve.pdf",sep=""))){unlink(paste(comArgs[1],".tree_trim_curve.pdf",sep=""))}
if(file.exists(paste(comArgs[1],".tree_trim_curve.png",sep=""))){unlink(paste(comArgs[1],".tree_trim_curve.png",sep=""))}
pdf(file=paste(comArgs[1],".tree_trim_curve.pdf",sep=""))
png(file=paste(comArgs[1],".tree_trim_curve.png",sep=""))
if(.Platform$OS.type=="windows"){system(paste('attrib +h',paste(comArgs[1],".tree_trim_curve.pdf",sep="")))}
if(.Platform$OS.type=="windows"){system(paste('attrib +h',paste(comArgs[1],".tree_trim_curve.png",sep="")))}
plot(as.numeric(names(n.break.all)),n.break.all,ylab="Cluster n",xlab="1-merging threshold",main="Iterative Tree Trimming Curve",pch=16)
z <- dev.off()


