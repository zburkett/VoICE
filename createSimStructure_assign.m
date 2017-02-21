function [Sound1,Sound2,same]=createSimStructure(mindur,winsize,sounds1d,sounds2d)

startdir = pwd;

filenum=0;
cd(sounds1d);
sortdir=cd;
%f=findstr('/',sounds1d);
%fldr=sortdir(f(end)+1:end);
%fldr = sounds1d;

% dfiles = dir;
% files = [];
%
% for i = 1:length(dfiles)
%     if ~isempty(findstr(dfiles(i).name, '.wav')) && dfiles(i).isdir==0
%         files = [files i];
%     end;
% end;
% s1_files = dfiles(files);

%if strncmp(fldr,'sorted_syllables_for_batch',2)==1;%this is a sorted_syllables folder
s1_files=0;
clusterdirs = dir(sortdir);
clusterdirs = clusterdirs([clusterdirs.isdir]);
clusterdirs = clusterdirs(arrayfun(@(x) x.name(1), clusterdirs) ~= '.');


for j=1:length(clusterdirs)
    tocd=clusterdirs(j).name;
    cd(tocd);


    dfiles = dir;
    files = [];
    for i = 1:length(dfiles)
        if ~isempty(findstr(dfiles(i).name, '.wav')) && dfiles(i).isdir==0
            files = [files i];
        end;
    end;
    ss_files=dfiles(files);

    for k=1:length(ss_files)
        fn=ss_files(k).name;
        if exist('audioread')~=0;
            wv=audioread(fn);
        else wv=wavread(fn);
        end
        
        filenum=filenum+1;

        [m_AM, m_FM, m_Entropy, m_amplitude, m_PitchGoodness, m_Pitch]=deriv2(wv);

        [wvScaled]=scaleFeatures(m_Entropy,m_FM, m_AM, log(m_Pitch),log(m_PitchGoodness),m_amplitude);
        totwins=length(wvScaled(:,1));

        [windows]=createTimeWindows(totwins,winsize,mindur);

        m_EntropyS1=wvScaled(:,1);
        m_FMS1=wvScaled(:,2);
        m_AMS1=wvScaled(:,3);
        m_PitchS1=wvScaled(:,4);
        m_PitchGoodnessS1=wvScaled(:,5);

        %get mean spectral feature values in windows;
        [global_specs]=parseSpectralFeatures(windows,m_EntropyS1,m_FMS1, m_AMS1, m_PitchS1,m_PitchGoodnessS1);

        Sound1(filenum).fn=fn;
        Sound1(filenum).scaled=wvScaled;
        Sound1(filenum).Dl=global_specs;
        Sound1(filenum).wavlen=length(wv);
    end
    cd ..
end


% Now, Sound Files
cd(sounds2d);

dfiles = dir;
files = [];
for i = 1:length(dfiles)
    if ~isempty(findstr(dfiles(i).name, '.wav')) && dfiles(i).isdir==0
        files = [files i];
    end;
end;
s2_files = dfiles(files);

if ~isequal(s1_files,s2_files)%if structures aren't the same, read in second set of files; otherwise, skip to save time
    same=0;
    for i=1:length(s2_files)
        fn=s2_files(i).name;
        if exist('audioread')~=0;
            wv=audioread(fn);
        else wv=wavread(fn);
        end
        [m_AM, m_FM, m_Entropy, m_amplitude, m_PitchGoodness, m_Pitch]=deriv2(wv);
        
        [wvScaled]=scaleFeatures(m_Entropy,m_FM, m_AM, log(m_Pitch),log(m_PitchGoodness),m_amplitude);
        totwins=length(wvScaled(:,1));
        
        [windows]=createTimeWindows(totwins,winsize,mindur);
        
        m_EntropyS2=wvScaled(:,1);
        m_FMS2=wvScaled(:,2);
        m_AMS2=wvScaled(:,3);
        m_PitchS2=wvScaled(:,4);
        m_PitchGoodnessS2=wvScaled(:,5);
        
        %get mean spectral feature values in windows;
        [global_specs]=parseSpectralFeatures(windows,m_EntropyS2,m_FMS2, m_AMS2, m_PitchS2,m_PitchGoodnessS2);
        
        Sound2(i).fn=fn;
        Sound2(i).scaled=wvScaled;
        Sound2(i).Dl=global_specs;
        Sound2(i).wavlen=length(wv);
        
    end
    cd(startdir);
else
    sprintf('Sound1 and Sound2 files are the same')
    Sound2=Sound1;
    same=1;
end