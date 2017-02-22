function []=trunk(m_spec_deriv, position_index  , full_view , new_figure ,  m_AM, m_FM ,m_Entropy , m_amplitude , m_Freq, m_PitchGoodness , m_Pitch  ,fs ,sound_bird,old_figure_index)


%[]=trunk(m_spec_deriv, position_index  , full_view , new_figure ,  m_AM, m_FM ,m_Entropy , m_amplitude , m_Freq, m_PitchGoodness , m_Pitch  ,fs ,sound_bird,old_figure_index)

%new_figure is the handler of a current figure
%full_view - the dimension and location of the axis

%        Written by Sigal Saar August 08 2005


global cutoff quit_index1 quit_index2 x axis_x1 axis_x2 axis_y1 axis_y2  add_record figure_table file_name first param

first=1;
load('parameters.mat');
pad=param.pad;
cutoff=param.cutoff;
y_length=param.y_length;
x_length=param.x_length;


axis_x1=1;
axis_x2=x_length;
axis_y1=1;
axis_y2=y_length;

m_spec_deriv=m_spec_deriv';

if isempty(old_figure_index)
    if isempty(new_figure)
        h=figure;
    else 
        h=new_figure;
    end
else
    h=old_figure_index(1);

end


bgcolor=[0.8 0.8 1];
position_h=[
          0 0.65 0.74 0.3 ; 
          0 0.4 0.74 0.3 ;
          0 0.1 0.74 0.3 ;];
position_h_t=[
          0.745 0.65 0.255 0.3 ; 
          0.745 0.4 0.255 0.3 ;
          0.745 0.1 0.255 0.3 ;];

ScreenSize=get(0,'ScreenSize');
ScreenSize=[ScreenSize(3:4) ScreenSize(3:4)];
position_h=position_h.*(ones(3,1)*ScreenSize);
position_h_t=position_h_t.*(ones(3,1)*ScreenSize);
%position_h_t(:,3)=0.255*1024;
position_h_t(:,1)=ScreenSize(3)-position_h_t(1,3);
%position_h(:,3)=position_h_t(:,1)-0.005*1024;
position_h(:,3)=position_h_t(:,1)-0.005*ScreenSize(3);


if full_view==2

%position_h(position_index- floor((position_index)/3)*3+1,:)
%ScreenSize=get(0,'ScreenSize')
    

xt=size(figure_table,1)+1;
if length(file_name)<xt
    file_name(xt).curr=[];
end
if isempty(old_figure_index)
    h_t=figure;
    figure_table=[ figure_table ; [h h_t]];
else
    h_t=old_figure_index(2);
end
    figure(h);
    
    set(h,'Units','pixel',...
    'position', position_h(position_index- floor((position_index)/3)*3+1,:),...
    'NumberTitle','off',...
    'Name',['Spectral derivatives - ' num2str(h) '       ' file_name(xt(end)).curr],...
    'doublebuffer','on',...
    'HandleVisibility','on',...
    'MenuBar','none',...
    'KeyPressFcn', @keypress, ...
    'WindowButtonDownFcn',{@get_pnts,m_spec_deriv,sound_bird, x_length , y_length ,h , h_t , fs , m_AM, m_FM ,m_Entropy , m_amplitude ,m_Freq,  m_PitchGoodness , m_Pitch   },... 
    'CloseRequestFcn',{@S_D_closereq,h,h_t},...
    'Color',bgcolor);

    set(h_t,'Units','pixel',...
    'position', position_h_t(position_index- floor((position_index)/3)*3+1,:),...
    'Name',['Feature table - ' num2str(h)],...
    'NumberTitle','off',...
    'doublebuffer','on',...
    'HandleVisibility','on',...
    'MenuBar','none',...
    'CloseRequestFcn',{@S_D_closereq,h,h_t},...
    'WindowButtonDownFcn',{@fast_pan,m_spec_deriv,h,h_t},...
    'Renderer', 'openGL',...
    'Color',bgcolor);
 setappdata(h, 'position_index', position_index)
 setappdata(h_t, 'position_index', position_index)
else
    set(gcf,'Units','pixel',...
    'position', position_h(position_index,:),...
    'NumberTitle','off',...
    'Name','Spectral derivatives',...
    'doublebuffer','on',...
    'HandleVisibility','on',...
    'KeyPressFcn', @keypress, ...
    'Renderer', 'openGL',...
    'Color',bgcolor);
 
end

 
if full_view==1
 axes('position', [0 0 1 1])
elseif full_view==2

else
%    axes('position', [0.02 0.11 0.97 0.89])
end


x=[];

if full_view==2
    quit_index1=1;

%    gui_image([],[],h,h_t,m_spec_deriv);
    gui_image([],[],h,h_t,m_spec_deriv,sound_bird,[], x , fs , m_AM, m_FM ,m_Entropy , m_amplitude ,m_Freq,  m_PitchGoodness , m_Pitch  , x_length,y_length);
    fast_pan([],[],m_spec_deriv,h,h_t)
    figure(h);

    if param.initial_axes==1
         v=axes('position', [0 0 1 1]);
    else
       v=axes('position', [0.03 0.11 0.97 0.89]);
    end
 setappdata(h, 'axes_index', v);
imagesc((1:size(m_spec_deriv,2)),fs*(1:size(m_spec_deriv,1))/1000/pad,m_spec_deriv);     
axis([axis_x1 axis_x2 fs*axis_y1/pad/1000 fs*axis_y2/pad/1000]); 
        ylabel('KHz','Units','normalized','Position',[0,0.05]);
        xlabel('ms','Units','normalized','Position',[0.05,0]);
   if param.initial_axes==0
        axis off;
    else
        axis on;
    end
colormap(bone); set(gca,'YDir','normal'); caxis([-cutoff cutoff])
    set(h_t,'Units','pixel',...
    'position', position_h_t(position_index- floor((position_index)/3)*3+1,:));
    set(h,'Units','pixel',...
    'position', position_h(position_index- floor((position_index)/3)*3+1,:));

     
 
end

return;
 
 
 %=============================================
%==========CALLBACK FUNCTIONS=================
%=============================================



%=========Keypress callback===========
function []=keypress(src, e)
  keypressed=get(gcf,'CurrentCharacter');

  % ignore raw control, shift, alt keys
  if keypressed
    % Quit
    if strcmp( keypressed, 'q')
        evalin('base','stop=1;');
    end
  end
return



      
%=========fast panning callback===========

function []=fast_pan(hObject,eventdata,m_spec_deriv,h,h_t)
   
   figure(h_t)
   
   h_line = findobj(gca,'Type','line');
   ScreenSize=get(0,'ScreenSize');
  if isempty(h_line) 
        load parameters.mat;
        x_length=param.x_length;
        curr_point=0.5*size(m_spec_deriv,2);

  else
      curr_point=get(gcf,'CurrentPoint');
      curr_position=get(gcf,'Position');
      curr_point=(curr_point(1)-17/768*ScreenSize(4))./(curr_position(3)-17/768*ScreenSize(4))*(size(m_spec_deriv,2)-40/768*ScreenSize(4));
%      curr_point=((curr_point(1))./curr_position(3) *size(m_spec_deriv,2)-17/768*ScreenSize(4));
  end
%  m_const=size(m_spec_deriv,2)/0.255/(ScreenSize(3));
  m_const=1;
 
  h_line = findobj(gca,'Type','line');
  if ~isempty(h_line)
      delete(h_line)
  end
  hold on
  h_l=plot([curr_point(1)*m_const curr_point(1)*m_const],[0 500],'r');

%  linkaxes([h,h_l],'x');
  if ~isempty(h_line)
  figure(h)
  curr_axis=axis;
  if curr_point(1)<1
      curr_point(1)=0;
  elseif curr_point(1)>size(m_spec_deriv,2)
      curr_point(1)=size(m_spec_deriv,2);
  end
  axis([curr_point(1)*m_const-floor((curr_axis(2)-curr_axis(1))/2) curr_point(1)*m_const+ceil((curr_axis(2)-curr_axis(1))/2) curr_axis(3) curr_axis(4)])  
  end
%  figure(h)
%  hold on
%  h_l2=plot([curr_point(1)*m_const curr_point(1)*m_const],[0 500],'Color',[0.5 0.5 0.5],'LineWidth',0.0001);
%curr_axis=axis;
% setappdata(h, 'line_index', (curr_axis(2)-curr_axis(1))/2)
% setappdata(h_t, 'line_index', curr_point(1))
%  linkprop([h_l,h_l2],'XData');
 % A = selectmoveresize

%  get(A.Handeles)
return

