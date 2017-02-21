function [wv]=LPFilter(wv,fs,freqRange);
%function [bporder,bp,q,qorder]=LPFilter(wv, fs,freqRange)

%% Design low-pass filter

% %make filter for making song amplitude envelope***************:
% qorder=2048;
% q=fir1(qorder,50/(44100/2));%50
% 
% %% Design band-pass filter
% 
% %make bandpass filter for taking band of frequencies not covered by masking noise***************:
% %1.0 should correspond to half the sample rate
% lo=300/floor(22050);%1000
% hi=11025/floor(22050);%8000
% bporder=256;
% bp=fir1(bporder,[lo hi],'bandpass');

if ~exist('freqRange','var')
    freqRange=[500 11025];
end;

if ~exist('fs','var')
    fs=44100;
end;


%% Design band-pass filter
        %make bandpass filter for taking band of frequencies not covered by masking noise***************:
        %1.0 should correspond to half the sample rate
        lo=freqRange(1)/floor(fs/2);
        hi=freqRange(2)/floor(fs/2);
        bporder=512;%2048
        bpe=fir1(bporder,[lo hi],'bandpass');
        
        %% filter the data
        wv=conv(wv,bpe);%filter
        wv=wv(bporder/2+1:length(wv)-bporder/2);