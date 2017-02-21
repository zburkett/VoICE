function out = updateStatusBar(handles)

    f = fopen('parfor_progress.txt', 'a');
    fprintf(f, '1\n');
    fclose(f);

    f = fopen('parfor_progress.txt', 'r');
    progress = fscanf(f, '%d');
    fclose(f);
    percent = (length(progress)-1)/progress(1);

    value = percent;
    axes(handles.waitbar);cla;handles.waitbar=patch([0,value,value,0],[0,0,1,1],'g');
    axis([0,1,0,1]);axis off;drawnow;
    
end
