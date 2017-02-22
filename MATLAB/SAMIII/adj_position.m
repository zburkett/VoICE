function [new_position]=adj_position(position)
%1680        1050

if max(max(position<1))
    %convert the position from normalized to pixel
    i=size(position,1);
    ScreenSize=get(0,'ScreenSize');
    if length(position)==4
    ScreenSize=[ScreenSize(3:4) ScreenSize(3:4)];
    new_position=position.*(ones(i,1)*ScreenSize);
    elseif length(position)==2
    ScreenSize=[ScreenSize(3:4)];
    new_position=position.*(ones(i,1)*ScreenSize);
    end    
else
    i=size(position,1);
    ScreenSize=get(0,'ScreenSize');
    if length(position)==4
    ScreenSize=[ScreenSize(3:4) ScreenSize(3:4)];
    position=position./(ones(i,1)*[1024         768  1024         768]);
    elseif length(position)==2
    ScreenSize=[ScreenSize(3:4)];
    position=position./(ones(i,1)*[1024         768]);
    end        
    new_position=position.*(ones(i,1)*ScreenSize);
end