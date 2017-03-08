if(.Platform$OS.type=="windows" & file.exists("./.libraries")){.libPaths("./.libraries")}
comArgs <- commandArgs(T)
arg.mat <- do.call("rbind", strsplit(comArgs, "="))
options(warn = -1)
arg.char <- which(is.na(as.numeric(arg.mat[, 2])))
options(warn = 0)
if (length(arg.char > 0)) 
	arg.mat[arg.char, 2] <- paste("'", arg.mat[arg.char, 2], "'", sep = "")
eval(parse(text = apply(arg.mat, 1, paste, collapse = "=")))
sylls <- unlist(strsplit(arg.mat[2, 2], ","))
options(stringsAsFactors = FALSE)
options(warn = -1)
sink("/dev/null")
suppressMessages(library(WGCNA))
sink()

sylls[1] = gsub("'", "", sylls[1])
sylls[length(sylls)] = gsub("'", "", sylls[length(sylls)])
sylls = as.numeric(sylls)
sylls = sort(sylls, decreasing = TRUE)

#inputs: folder1 (main directory), sylls (syllables to delete)
#creates backup of 'original' workspace and similarity batch before deleting syllables
if (file.exists(paste(folder1, "voice_results/workspace.Rdata", sep = ""))) {
	assign = 0
	load(paste(folder1, "voice_results/workspace.Rdata", sep = ""))
	if (!file.exists(paste(folder1, "voice_results/workspace_original.Rdata", sep = ""))) {
		save(out.cluster.tutor, file = paste(folder1, "voice_results/workspace_original.Rdata", sep = ""))
	}
	vectA = 1:length(out.cluster.tutor$mergedSyntax)

	simbatch.csv = read.csv(paste(folder1, "voice_results/similarity_batch_self.csv", sep = "/"), header = FALSE)
	if (!file.exists(paste(folder1, "voice_results/similarity_batch_self_original.csv", sep = "/"))) {
		write.table(simbatch.csv, paste(folder1, "voice_results/similarity_batch_self_original.csv", sep = "/"),row.names=F,col.names=F,sep=",")
	}
}

if (file.exists(paste(folder1, "voice_results/assign_workspace.Rdata", sep = ""))) {
	assign = 1
	load(paste(folder1, "voice_results/assign_workspace.Rdata", sep = ""))
	if (!file.exists(paste(folder1, "voice_results/assign_workspace_original.Rdata", sep = ""))) {
		save(saveList, file = paste(folder1, "voice_results/assign_workspace_original.Rdata", sep = ""))
	}
	vectA = 1:length(saveList$out.assign)
	simbatch = saveList$assignment.batch
	if (!file.exists(paste(folder1, "voice_results/similarity_batch_assign.csv", sep = "/"))) {
		write.table(simbatch, paste(folder1, "voice_results/similarity_batch_assign_original.csv", sep = "/"),row.names=F,col.names=F,sep=",")
	}

} else if (file.exists(paste(folder1, "voice_results/assigned_complete_workspace.Rdata", sep = ""))) {
	assign = 1
	load(paste(folder1, "voice_results/assigned_complete_workspace.Rdata", sep = ""))
	if (!file.exists(paste(folder1, "voice_results/assigned_complete_workspace_original.Rdata", sep = ""))) {
		save(assignedSyntax, file = paste(folder1, "voice_results/assigned_complete_workspace_original.Rdata", sep = ""))
	}
	vectA = 1:length(assignedSyntax)
	simbatch = saveList$assignment.batch
	if (!file.exists(paste(folder1, "voice_results/similarity_batch_assign.csv", sep = "/"))) {
		write.table(simbatch, paste(folder1, "voice_results/similarity_batch_assign_original.csv", sep = "/"),row.names=F,col.names=F,sep=",")
	}
}

acoustic.data = read.csv(paste(folder1, ".acoustic_data.csv", sep = "/"), header = TRUE)
#acoustic.data = acoustic.data[, -2]
if (!file.exists(paste(folder1, ".acoustic_data_original.csv", sep = "/"))) {
	write.table(acoustic.data, paste(folder1, ".acoustic_data_original.csv", sep = "/"),row.names=T,col.names=T,sep=",")
	if(.Platform$OS.type=="windows"){system(paste('attrib +h',paste(folder1, ".acoustic_data_original.csv", sep = "/")))}
}

for (syll in sylls) { #delete single syllable
	name.assign <- paste("%0", nchar(max(vectA)), "s", sep = "")
	name.out <- sprintf(name.assign, vectA[syll])
	unlink(paste(folder1, "/voice_results/cut_syllables/", name.out, ".wav", sep = "")) #deletes syllable .wav file

	#vect = as.numeric(names(subset(saveList$out.assign, names(saveList$out.assign) != syll))) #create variable name for syllable number
	#vect = 1:length(vect)

	acoustic.data = acoustic.data[-syll, ] #gets rid of syll

	# if syllable is only in Sound 2 (clustR_assign)
	if (assign == 1) {

		#save assigned_complete_workspace file with new syntax
		saveList$out.assign = subset(saveList$out.assign, names(saveList$out.assign) != syll)
		names(saveList$out.assign) <- 1:nrow(acoustic.data)
		vect = 1:length(saveList$out.assign)

		simbatch = saveList$assignment.batch
		new2 = simbatch[, 2]

		newsimbatch = (subset(simbatch, simbatch[, 2] != syll))
		#new2 = newsimbatch[, 2]
		new2 = subset(new2, new2 != new2[length(new2)])
		newsimbatch[, 2] = new2
		saveList$assignment.batch = newsimbatch
	}

	# if syllable is in both Sound 1 and Sound 2 (clustR_self)
	if (assign == 0) {
		#deal with out.cluster.tutor$mergedSyntax
		out.cluster.tutor$mergedSyntax = subset(out.cluster.tutor$mergedSyntax, names(out.cluster.tutor$mergedSyntax) != 
			syll)
		names(out.cluster.tutor$mergedSyntax) <- 1:nrow(acoustic.data)

		#deal with out.cluster.tutor$syntax
		out.cluster.tutor$syntax = subset(out.cluster.tutor$syntax, names(out.cluster.tutor$syntax) != 
			syll)
		names(out.cluster.tutor$syntax) <- 1:nrow(acoustic.data)
		vect = 1:length(out.cluster.tutor$syntax)

		#deal with out.cluster.tutor$data
		simbatch = out.cluster.tutor$data
		out.cluster.tutor$data = simbatch[-syll, -syll]
		rownames(out.cluster.tutor$data) <- 1:nrow(acoustic.data)
		colnames(out.cluster.tutor$data) <- 1:nrow(acoustic.data)

		#for writing new csv simbatch; diff than simbatch matrix
		new2 = simbatch.csv[, 2]
		newsimbatch = (subset(simbatch.csv, simbatch.csv[, 2] != syll))
		new2 = subset(new2, new2 != new2[length(new2)])
		newsimbatch[, 2] = new2

		newsimbatch = (subset(newsimbatch, newsimbatch[, 1] != syll))
		new1 = rep(1:sqrt(nrow(newsimbatch)), sqrt(nrow(newsimbatch)))
		newsimbatch[, 1] = new1
		simbatch.csv = newsimbatch
	}

}

CS = paste(folder1, "voice_results/cut_syllables/", sep = "")
allWavs = dir(CS,pattern=".wav")
totFiles = length(list.files(CS))
name.assign <- paste("%0", nchar(max(vect)), "s", sep = "")

for (number in 1:totFiles) {

	name.out <- sprintf(name.assign, vect[number])

	from = paste(folder1, "voice_results/cut_syllables/", allWavs[number], sep = "")
	to = paste(folder1, "voice_results/cut_syllables/", paste(as.character(name.out), ".wav", sep = ""), sep = "")

	file.rename(from, to)
	#unlink(from)
}

rownames(acoustic.data) <- 1:nrow(acoustic.data)
acoustic.data[, 1] = rownames(acoustic.data)
write.table(acoustic.data, paste(folder1, ".acoustic_data.csv", sep = "/"),row.names=T,col.names=T,sep=",")
if(.Platform$OS.type=="windows"){system(paste('attrib +h',paste(folder1, ".acoustic_data.csv", sep = "/")))}

if (assign == 1) {
	save(saveList, file = paste(folder1, "voice_results/assign_workspace.Rdata", sep = "/"))
	write.table(newsimbatch, paste(folder1, "voice_results/similarity_batch_assign.csv", sep = "/"),row.names=F,col.names=F,sep=",")
}
if (assign == 0) {
	save(out.cluster.tutor, file = paste(folder1, "voice_results/workspace.Rdata", sep = ""))
	write.table(simbatch.csv, paste(folder1, "voice_results/similarity_batch_self.csv", sep = "/"),row.names=F,col.names=F,sep=",")
}
