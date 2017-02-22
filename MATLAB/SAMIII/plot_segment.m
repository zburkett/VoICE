function []=plot_segment(i)

%[]=plot_segment(i)

% Written by Sigal Saar

cd c:\
    [tablename, table_pathname, filterindex] = uigetfile( ...
       {'*.mat','MAT-files (*.mat)'; ...
        '*.*',  'All Files (*.*)'}, ...
        'Pick saved segment mat file', ...
        'MultiSelect', 'on');
load([table_pathname tablename]);
    h_i=imagesc(add_record(i).image_axes_x,add_record(i).image_axes_y,add_record(i).image);   
   colormap(bone); set(gca,'YDir','normal'); caxis([-add_record(i).cutoff add_record(i).cutoff])

 