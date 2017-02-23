function [sylls]=getSyllIDs(folderPath,handles)

%sprintf('sorting syllables')

folderPath = strrep(folderPath,'\','');

if exist([folderPath 'sorted_syllables'],'dir')
    sortedSylls=strcat(folderPath,'sorted_syllables');
else
    sortedSylls=strcat(folderPath,'sorted_syllables_assigned');
end

[sylls2]=getAllFiles(sortedSylls);

if findstr('.DS_Store',sylls2{1})~=0
sylls2=sylls2(2:length(sylls2));
end

num=zeros(length(sylls2),1);
for i=1:length(sylls2)
f=findstr(sylls2{i},'.wav');
nums=str2num(sylls2{i}(f-3:f-1));
num(i)=nums;
end

%make sure handles.clusterNames.drawn = length(sylls2)
for i=1:length(handles.clusterNames)
    if size(handles.clusterNames(i).starts,1)==1 && (handles.clusterNames(i).drawn(1)~=0 || handles.clusterNames(i).drawn(2)~=0)
    handles.clusterNames(i).drawn=1;
    elseif size(handles.clusterNames(i).starts,1)==1 && (handles.clusterNames(i).drawn(1)==0 || handles.clusterNames(i).drawn(2)==0)
     handles.clusterNames(i).drawn=0;   
    end
end

toget=find([handles.clusterNames.drawn]);
toget=toget';
syllNums=zeros(length(toget),1);
for i=1:length(toget)
syllable=num(toget(i,1));
syllNums(i)=syllable;
end

[sylls]=num2str(syllNums);
end

function fileList = getAllFiles(dirName)

    dirData = dir(dirName);      %# Get the data for the current directory
    dirIndex = [dirData.isdir];  %# Find the index for directories
    fileList = {dirData(~dirIndex).name}';  %'# Get a list of the files
    if ~isempty(fileList)
        fileList = cellfun(@(x) fullfile(dirName,x),...  %# Prepend path to files
            fileList,'UniformOutput',false);
    end
    subDirs = {dirData(dirIndex).name};  %# Get a list of the subdirectories
    validIndex = ~ismember(subDirs,{'.','..'});  %# Find index of subdirectories
    %#   that are not '.' or '..'
    for iDir = find(validIndex)                  %# Loop over valid subdirectories
        nextDir = fullfile(dirName,subDirs{iDir});    %# Get the subdirectory path
        fileList = [fileList; getAllFiles(nextDir)];  %# Recursively call getAllFiles
    end
end


%fns = fieldnames(reassign(1));
%fn = fns(i);
%reassign(1).(fn{i})