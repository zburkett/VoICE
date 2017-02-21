function [mwindow_specs]=parseSpectralFeatures(windows,m_Entropy,m_FM, m_AM, m_Pitch,m_PitchGoodness)

features={m_Entropy; m_FM; m_AM; m_Pitch; m_PitchGoodness};

for j=1:length(features)
    for i=1:length(windows(:,1))
        window_specs{i,j}=features{j}(windows(i,1):windows(i,2));
        mwindow_specs(i,j)=mean(window_specs{i,j});
    end
end
end