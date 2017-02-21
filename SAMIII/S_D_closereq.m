function []=S_D_closereq(input1,input2,h,h_t)

% []=S_D_closereq(input1,input2,h,h_t)
% written by Sigal Saar


% my_closereq 
% User-defined close request function
% to display a question dialog box

%selection = questdlg('Close Specified Figure?',...
%                     'Close Request Function',...
%                     'Yes','No','Yes');
%switch selection,
%   case 'Yes',
     
     delete(h)
     delete(h_t)
     


%     return
%   case 'No'
%     return
%end