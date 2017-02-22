function []=Call_spectrum_derivative(sound_bird,fs,desired_position_index,old_figure_index)

     
% []=Call_spectrum_derivative(sound_bird,fs,desired_position_index,old_figure_index)
%        Written by Sigal Saar August 08 2005
persistent position_index 

if nargin<4
    old_figure_index=[];
end
if isempty(position_index)
    position_index=1;
elseif nargin>3
    if ~isempty(desired_position_index)
        position_index=desired_position_index;
        re_open=1;
    else
        position_index=position_index+1 ;
    end
else
    position_index=position_index+1 ;
end
if nargin<1
    error('No sound file');
end


if nargin<2
    fs=250000;
    %fs=44100;
end


[m_spec_deriv , m_AM, m_FM ,m_Entropy , m_amplitude , m_Freq, m_PitchGoodness , m_Pitch , Pitch_chose , Pitch_weight ]=segment_data(sound_bird,fs);
%fs=44100;
trunk(m_spec_deriv,  position_index , 2 ,[]  , m_AM, m_FM ,m_Entropy , m_amplitude ,m_Freq, m_PitchGoodness ,  Pitch_chose  , fs , sound_bird,old_figure_index);

    