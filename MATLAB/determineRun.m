function determineRun(Filedir2)
if exist(strcat(Filedir2,'voice_results/similarity_batch_assign.csv'),'file')~=0
    sprintf('Similarity batch exists ... preventing overwriting')
    load(strcat(Filedir2,'voice_results/assignment_similarity_batch_completed.mat'))
    
    %if strmatch(folder1,handles.refDir) && strmatch(Filedir2,handles.assignPath)
        f1=findstr('/',folder1);
        refDir=folder1(f1(end)+1:length(folder1));
        
        f2=findstr('/',Filedir2);
        assignDir=Filedir2((f2(end-1)+1):f2(end)-1);
        clear f1 f2
        
        save(strcat(Filedir2,strcat('voice_results/assignment_similarity_batch_completed','_a',assignDir,'_r',refDir)));
        
		if isunix
			simbatchOrig=csvread(strcat(Filedir2,'voice_results/similarity_batch_assign.csv'));
		elseif ispc
	        simbatchOrig=csvread(strcat(Filedir2,'voice_results/similarity_batch_assign.csv'));
		end
        
        dlmwrite(strcat(Filedir2,'voice_results/similarity_batch_assign','_a',assignDir,'_r',refDir,'.csv'),simbatchOrig);
    %end
end

