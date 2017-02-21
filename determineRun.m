function determineRun(Filedir2)
if exist(strcat(Filedir2,'similarity_batch_assign.csv'),'file')~=0
    sprintf('Similarity batch exists ... preventing overwriting')
    load(strcat(Filedir2,'assignment_similarity_batch_completed.mat'))
    
    %if strmatch(folder1,handles.refDir) && strmatch(Filedir2,handles.assignPath)
        f1=findstr('/',folder1);
        refDir=folder1(f1(end)+1:length(folder1));
        
        f2=findstr('/',Filedir2);
        assignDir=Filedir2((f2(end-1)+1):f2(end)-1);
        clear f1 f2
        
        save(strcat(Filedir2,strcat('assignment_similarity_batch_completed','_a',assignDir,'_r',refDir)));
        
        simbatchOrig=csvread(strcat(Filedir2,'/similarity_batch_assign.csv'));
        dlmwrite(strcat(Filedir2,'similarity_batch_assign','_a',assignDir,'_r',refDir,'.csv'),simbatchOrig);
    %end
end

