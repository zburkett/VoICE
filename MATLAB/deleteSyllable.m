function deleteSyllable(deletedSylls,Filedir)
% This function deletes a single syllable from the R workspace,
% /cut_syllables, acoustic_data, and similarity batches

deletedSylls=str2num(deletedSylls);
deletedSylls=deletedSylls';
deletedSylls=sprintf('%.0f,' , deletedSylls);
deletedSylls = deletedSylls(1:end-1);

Filedir = strrep(Filedir,'\','');

% delete syllable and relevent info

system(['R --slave --args', strcat(' folder1=', strrep(Filedir,' ','\ ')), strcat(' sylls=', deletedSylls), ' < ./R/deleteSyll2.r']);

% rewrite joined & save syllables
if exist(strcat(Filedir,'voice_results/assign_workspace_original.Rdata'),'file')~=0 %assigned
    bPath=strcat(Filedir,'voice_results/assignment_similarity_batch_completed.mat');
    load(bPath);
    
    %unix(strcat('R --slave --args', strcat(' Filedir=', Filedir), strcat(' acousticData=', filename), '< finalizeClustersAssigned.r'));
    system(['R --slave --args ' strrep(Filedir,' ','\ ') ' < ./R/recreateClusters2.r']);
    newOut=outmatrix;
    for i=deletedSylls
        %C1 = newOut(:,1)==i;
        C2 = newOut(:,2)==i;
        %Call = C1 | C2;
        %newOut(Call,:)=[];
        newOut(C2,:)=[];
        outmatrix=newOut;
    end
    clear C1 C2 Call newOut
    save(bPath,'-append','outmatrix','deletedSylls')
    
    
else %self
    system(['R --slave --args ' strrep(Filedir,' ','\ ') ' < ./R/recreateClusters.r']);
    bPath=strcat(Filedir,'voice_results/similarity_batch_completed.mat');
    load(bPath)
    
    if exist(strcat(bPath,'_original'),'file')==0
    save(strcat(bPath(1:length(bPath)-4),'_Orig'));
    end
    
    newOut=outmatrix;
    for i=deletedSylls
        C1 = newOut(:,1)==i;
        C2 = newOut(:,2)==i;
        Call = C1 | C2;
        newOut(Call,:)=[];
        outmatrix=newOut;
    end
    clear C1 C2 Call newOut
    save(bPath,'-append','outmatrix','deletedSylls')
    
end




