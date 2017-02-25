function hAx = addAxis(i,handles,cluster)
    % look for previous axes
    ax = findobj(handles.hPan, 'type','axes');

    if i==1
        %create first axis
        handles.axesDrawn(i) = axes('Parent',handles.hPan, ...
            'Units','normalized', 'Position',[0.13 0.11 0.775 0.815]);
        axis off;
        set(handles.axesDrawn(i), 'Units','pixels');
        pnext = get(handles.axesDrawn(i),'Position');
        
        if exist(strcat(handles.path,'joined_clusters/',cluster,'.wav')) == 2;
             sp = audioread(strcat(handles.path,'joined_clusters/',cluster,'.wav'));
        elseif exist(strcat(handles.path,'joined_clusters_assigned/',cluster,'.wav')) == 2
             sp = audioread(strcat(handles.path,'joined_clusters_assigned/',cluster,'.wav'));
        end
       
        %csvwrite(strcat(handles.path,'pnext.csv'),pnext);
        dlmwrite(strcat(handles.path,'.pnext.csv'),pnext);

        axes(handles.axesDrawn(i)); 
        specgram(sp,512,44100);
        load('speccolormap.mat');
        colormap(cmap);
        hImage = findobj(gca,'type','image');
        set(hImage,'HitTest','Off');
        %handles.axesDrawn(i) = PlotSpectrogram(sp,44100);
        title(handles.clusterNames(i).name);

    else
        
        % increase panel height, and shift it to show new space
        handles.axesDrawn = getappdata(0,'axesDrawn');
        p = get(handles.hPan, 'Position');
        if i == 1
            h=p(4);
        elseif i ~= 1
            h=p(4)/(i-1);
        end
        set(handles.hPan, 'Position',[p(1) p(2)-h p(3) p(4)+h])

        % compute position of new axis: append on top (y-shifted)
        p = csvread(strcat(handles.path,'.pnext.csv'));
        h=p(4);
        p = [p(1,1) p(1,2)+h+50 p(1,3) p(1,4)];

        % create the new axis
        handles.axesDrawn(i) = axes('Parent',handles.hPan, ...
           'Units','pixels', 'Position',p);
        pnext = get(handles.axesDrawn(i),'Position');
       %csvwrite(strcat(handles.path,'pnext.csv'),pnext);
        dlmwrite(strcat(handles.path,'.pnext.csv'),pnext);
        
        if exist(strcat(handles.path,'joined_clusters/',cluster,'.wav')) == 2;
            sp = audioread(strcat(handles.path,'joined_clusters/',cluster,'.wav'));
        elseif exist(strcat(handles.path,'joined_clusters_assigned/',cluster,'.wav')) == 2
            sp = audioread(strcat(handles.path,'joined_clusters_assigned/',cluster,'.wav'));
        end
        
        axes(handles.axesDrawn(i));
        specgram(sp,512,44100);
        ylim([500 8000]);
        load('speccolormap.mat');
        colormap(cmap);
        hImage = findobj(gca,'type','image');
        set(hImage,'HitTest','Off');
        %handles.axesDrawn(i) = PlotSpectrogram(sp,44100);
        
        title(handles.clusterNames(i).name);


        % adjust slider, and call its callback function
        p = get(handles.hPan,'Position');
        sldPos = abs(p(2));
        set(handles.Sld, 'Max',sldPos, 'Min',0, 'Enable','on')
        set(handles.Sld, 'Value',sldPos)       % scroll to new space
    end
    setappdata(0,'axesDrawn',handles.axesDrawn);
end

%offset = 1.755