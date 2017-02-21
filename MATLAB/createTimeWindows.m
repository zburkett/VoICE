function [windows]=createTimeWindows(totwins, winsize,mindur)

winNum=totwins-(winsize-1);
windows=[];

if totwins>winsize
    for i=1:winNum
        window=[i i+(winsize-1)];
        windows=[windows; window];
    end
else
    windows=[1 totwins];
end
end