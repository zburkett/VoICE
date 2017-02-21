function update_waitbar(handles,value,N)
h=handles.waitbar;

percent = 0;

if N > 0
    f = fopen('progress.txt', 'w');
    if f<0
        error('Do you have write permissions for %s?', pwd);
    end
    fprintf(f, '%d\n', N); % Save N at the top of progress.txt
    fclose(f);
end

f = fopen('parfor_progress.txt', 'a');
fprintf(f, '1\n');
fclose(f);

f = fopen('parfor_progress.txt', 'r');
progress = fscanf(f, '%d');

percent = (length(progress)-1)/progress(1)*100;

value = percent;

set(h,'Visible','On');

axes(h);cla;h=patch([0,value,value,0],[0,0,1,1],'g');

axis([0,1,0,1]);axis off;drawnow;
