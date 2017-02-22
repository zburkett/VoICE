function  [m_spec_deriv , m_AM, m_FM ,m_Entropy , m_amplitude , m_Freq, m_PitchGoodness , m_Pitch , Pitch_chose , Pitch_weight ]=segment_data(sound_bird,fs);

%[m_spec_deriv , m_AM, m_FM ,m_Entropy , m_amplitude , m_Freq, m_PitchGoodness , m_Pitch , Pitch_chose , Pitch_weight ]=segment_data(sound_bird,fs);

% written by Sigal Saar
 Length_minimal_silence=50;
 load parameters.mat;

 m_spec_deriv=[];   m_AM=[]; m_FM=[]; m_Entropy=[];  m_amplitude=[]; m_Freq=[]; m_PitchGoodness=[];  m_Pitch=[];  Pitch_chose=[];  Pitch_weight=[];
 
 
%initial filter
TS=diff(sound_bird);
TS=TS-mean(TS);


%%%% sampling frequency
if size(TS,2)>size(TS,1)
    TS=TS';
end
TS=TS-prctile_b(TS,5);
TS=TS/prctile_b(TS,95)*2;
TS=TS-1;


if fs==11025
    TS= interp(TS,4);
elseif fs==22050
    TS= interp(TS,2);
elseif fs==44100

else
  TS=interp1(1:length(TS),TS,1:fs/44100:length(TS),'cubic');
    TS=TS';
end
sound_bird=TS;
fs=44100;

 low_amplitude=abs(TS)<param.low_amplitude_th;
 cumsum_low_amplitude=cumsum(low_amplitude);
 there_is_no_sound=(cumsum_low_amplitude(Length_minimal_silence+1:end)-cumsum_low_amplitude(1:end-Length_minimal_silence))>(Length_minimal_silence-5);
 bout_onset=find(diff(there_is_no_sound)==(-1))+Length_minimal_silence;
 bout_offset=find(diff(there_is_no_sound)==(1));
 if there_is_no_sound(1)==0
    bout_onset=[1 ; bout_onset];
 end
 if there_is_no_sound(end)==0
    bout_offset=[bout_offset ; length(TS)];
 else
     bout_onset=[bout_onset ; length(TS)];
 end 
 
 still_bout=find((bout_offset-bout_onset(1:length(bout_offset)))<param.window*2);
 
 bout_onset(still_bout)= bout_onset(still_bout)-param.window;
 bout_offset(still_bout)=bout_offset(still_bout)+param.window;

if length(bout_offset)>0
 for i=1:length(bout_offset)
     if bout_onset(1)==1 & i==1
         if bout_offset(i)<(length(TS)-3)
             length_silence_vector=round((bout_onset(i+1)-bout_offset(i))/param.winstep); 
             m_spec_deriv=[m_spec_deriv ; zeros(length_silence_vector,253)];  m_AM=[m_AM ; zeros(length_silence_vector,1)]; m_FM=[m_FM ; zeros(length_silence_vector,1)]; m_Entropy=[m_Entropy ; zeros(length_silence_vector,1)] ;   m_amplitude=[m_amplitude ; zeros(length_silence_vector,1)]; m_Freq=[m_Freq ; zeros(length_silence_vector,1)] ; m_PitchGoodness=[m_PitchGoodness ; zeros(length_silence_vector,1)] ; m_Pitch=[m_Pitch ; zeros(length_silence_vector,1)];  Pitch_chose=[Pitch_chose ; zeros(length_silence_vector,1)];  Pitch_weight=[Pitch_weight ; zeros(length_silence_vector,1) ];
         end
     end
     
     [m_spec_deriv_segment , m_AM_segment, m_FM_segment ,m_Entropy_segment , m_amplitude_segment ,m_Freq_segment, m_PitchGoodness_segment , m_Pitch_segment , Pitch_chose_segment , Pitch_weight_segment ]=deriv(sound_bird(bout_onset(i):bout_offset(i)),fs);
     m_spec_deriv=[m_spec_deriv ; m_spec_deriv_segment];  m_AM=[m_AM ; m_AM_segment]; m_FM=[m_FM ; m_FM_segment]; m_Entropy=[m_Entropy ; m_Entropy_segment] ;   m_amplitude=[m_amplitude ; m_amplitude_segment]; m_Freq=[m_Freq ; m_Freq_segment] ; m_PitchGoodness=[m_PitchGoodness ; m_PitchGoodness_segment] ; m_Pitch=[m_Pitch ; m_Pitch_segment];  Pitch_chose=[Pitch_chose ; Pitch_chose_segment];  Pitch_weight=[Pitch_weight ; Pitch_weight_segment ];
     if bout_offset(i)<(length(TS)-3)
        length_silence_vector=round((bout_onset(i+1)-bout_offset(i))/param.winstep);
        
        m_spec_deriv=[m_spec_deriv ; zeros(length_silence_vector,253)];  m_AM=[m_AM ; zeros(length_silence_vector,1)]; m_FM=[m_FM ; zeros(length_silence_vector,1)]; m_Entropy=[m_Entropy ; zeros(length_silence_vector,1)] ;   m_amplitude=[m_amplitude ; zeros(length_silence_vector,1)]; m_Freq=[m_Freq ; zeros(length_silence_vector,1)] ; m_PitchGoodness=[m_PitchGoodness ; zeros(length_silence_vector,1)] ; m_Pitch=[m_Pitch ; zeros(length_silence_vector,1)];  Pitch_chose=[Pitch_chose ; zeros(length_silence_vector,1)];  Pitch_weight=[Pitch_weight ; zeros(length_silence_vector,1) ];
     end
 end
else        

    [m_spec_deriv , m_AM, m_FM ,m_Entropy , m_amplitude , m_Freq, m_PitchGoodness , m_Pitch , Pitch_chose , Pitch_weight ]=deriv(sound_bird,fs);
end
