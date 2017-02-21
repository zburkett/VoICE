function [scaledOutput]=scaleFeatures(m_Entropy,m_FM, m_AM, m_Pitch,m_PitchGoodness,m_amplitude)

load MADs

% discard windows with low amplitude (less than 18.5)
    amp_cut=min(m_amplitude);%18.5; %anything lower likely signals silence
    amplitude=m_amplitude;
    windowstouse=find(amplitude(:,1)>=amp_cut);

%to scale features, subtract median and then multiply by MAD
features=[m_Entropy(windowstouse)  m_FM(windowstouse)  m_AM(windowstouse)  m_Pitch(windowstouse)  m_PitchGoodness(windowstouse)];

totwins=length(m_Entropy); %any feature will do

for j=1:size(features,2)
    for i=1:totwins
    window_Scaled(i,j)=(features(i,j)-median_allsyllsOfer(j))/mad_allsyllsOfer(j);
    end
end

m_Entropy=window_Scaled(:,1);
m_FM=window_Scaled(:,2);
m_AM=window_Scaled(:,3);
m_Pitch=window_Scaled(:,4);
m_PitchGoodness=window_Scaled(:,5);

scaledOutput=[m_Entropy m_FM m_AM m_Pitch m_PitchGoodness];