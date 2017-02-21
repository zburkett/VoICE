function [out] = pan(h,h_t,arg1,arg2)
%PAN Interactively pan the view of a plot
%  PAN ON turns on mouse-based panning.
%  PAN XON turns on x-only panning    
%  PAN YON turns on y-only panning
%  PAN OFF turns it off.
%  PAN by itself toggles the state.
%
%  PAN(FIG,...) works on specified figure handle.
%  
%  Use LINKAXES to link panning across multiple axes.
%
%  See also ZOOM, LINKAXES.

% Undocumented syntax
%  PAN(FIG,STYLE); where STYLE = 'x'|'y'|'xy', Note: syntax doesn't turn pan on like 'xon'
%  OUT = PAN(FIG,'getstyle')  'x'|'y'|'xy'
%  OUT = PAN(FIG,'ison')  true/false

if nargin==0 
    fig = gcf; % caller did not specify handle
    locSetState(fig,'toggle',h,h_t);
elseif nargin==3
    if ishandle(arg1)
        locSetState(arg1,'toggle',h,h_t);
    else
        fig = gcf; % caller did not specify handle
        locSetState(fig,arg1,h,h_t); 
    end 
elseif nargin==4 
    if ~ishandle(arg1), error('Unknown figure.'); end
    switch arg2
        case 'getstyle'   
           out = locGetStyle(arg1,h,h_t);   
        case 'ison'
           out = locIsOn(arg1,h,h_t);
        otherwise
           locSetState(arg1,arg2,h,h_t);
    end
end

%-----------------------------------------------%
function [out] = locIsOn(fig,h,h_t)

pandata = locGetData(fig,h,h_t);
out = strcmp(pandata.enable,'on');

%-----------------------------------------------%
function [out] = locGetStyle(fig,h,h_t)

pandata = locGetData(fig,h,h_t);
out = pandata.style;

%-----------------------------------------------%
function locSetState(target,state,h,h_t)
%Enables/disables panning callbacks
% target = figure || axes
% state = 'on' || 'off'
fig = ancestor(target,'hg.figure');
pandata = locGetData(fig,h,h_t);
uistate = pandata.uistate;

if strcmpi(state,'xon')
    state = 'on';
    pandata.style = 'x';
elseif strcmpi(state,'yon')
    state = 'on';
    pandata.style = 'y';
elseif strcmpi(state,'x')
    pandata.style = 'x';
    locSetData(fig,pandata);
    return; % All done
elseif strcmpi(state,'y')
    pandata.style = 'y';
    locSetData(fig,pandata);
    return; % All done
elseif strcmpi(state,'xy')
    pandata.style = 'xy';
    locSetData(fig,pandata);
    return; % All done
elseif strcmpi(state,'toggle')
    if strcmpi(pandata.enable,'on')
        state = 'off';
    else 
        state = 'on';
    end
end

locSetData(fig,pandata,h,h_t);
   
if strcmpi(state,'on') 
    % turn off all other interactive modes
    if isempty(uistate)
        % Specify deinstaller callback: pan(fig,'off') 
        uistate = uiclearmode(fig,...
                              'docontext_preserve',...
                              'pan',target,'off');
        
        % restore button down functions for uicontrol children of the figure
        uirestore(uistate,'uicontrols');
    
        pandata.uistate = uistate;
        pandata.enable = 'on';
        %locSetData(fig,pandata);
    end
        
    % Create context menu
    c = locUICreateDefaultContextMenu(fig);

    % Add context menu to the figure, axes, and axes children
    % but NOT to uicontrols or other widgets at the figure level.
    if ishandle(c)
         set(fig,'UIContextMenu',c);
         ax_child = findobj(fig,'type','axes');
         for n = 1:length(ax_child)
              kids = findobj(ax_child(n));
              set(kids,'UIContextMenu',c);
              set(ax_child(n),'UIContextMenu',c);                  
         end
    end
    
    % Store context menu handle 
    pandata.uicontextmenu = c;
    % Enable pan mode
    set(fig,'WindowButtonDownFcn',{@locWindowButtonDownFcn,fig,h,h_t});
    set(fig,'WindowButtonMotionFcn',{@locWindowButtonMotionFcn,target,h,h_t});
    set(fig,'WindowButtonUpFcn',{@locWindowButtonUpFcn,fig,h,h_t});
    set(fig,'KeyPressFcn',{@locKeyPressFcn,target,h,h_t});
    setptr(fig,'hand');
         
    locDoPanOn(fig);
    locSetData(fig,pandata);
else 
    if ~isempty(uistate)
        % restore figure and non-uicontrol children
        % don't restore uicontrols because they were restored
        % already when rotate3d was turned on
        uirestore(uistate,'nouicontrols');
    end
    pandata.uistate = [];
    pandata.enable = 'off';
    locSetData(fig,pandata);
    
    % Turn off UI
    locDoPanOff(fig);
    if ishandle(pandata.uicontextmenu)
        delete(pandata.uicontextmenu);
    end
end

%-----------------------------------------------%
function locWindowButtonDownFcn(obj,evd,fig,h,h_t)
% Begin panning
pandata = locGetData(fig,h,h_t);
ax = locGetAxes(fig);
if isempty(ax) || ~ishandle(ax)
    return;
end

% Register view with axes for "Reset to Original View" support
resetplotview(ax,'InitializeCurrentView'); 
    
sel_type = lower(get(fig,'selectiontype'));

switch sel_type
    case 'normal' % left click
        pandata.axes = ax;
        setptr(fig,'closedhand');
    case 'open' % double click (left or right)
        locReturnHome(ax);
    case 'alt' % right click
        % do nothing, reserved for context menu
    case 'extend' % center click
        % do nothin
end

% Store original axis limits
pandata.orig_axlim = axis(ax);

locSetData(fig,pandata,h,h_t);

%-----------------------------------------------%
function locReturnHome(ax,h,h_t)
% Fit plot to axes                
resetplotview(ax,'ApplyStoredView');

%-----------------------------------------------%
function [cmd] = locDoPan(ax,origlim,newlim,h,h_t)

% Pan
axis(ax,newlim);

% Create command structure
cmd.Function = @axis;
cmd.Varargin = {ax,newlim};
cmd.Name = 'Pan';
cmd.InverseFunction = @axis;
cmd.InverseVarargin = {ax,origlim};

% Register with undo
hFigure = ancestor(ax,'hg.figure');
uiundo(hFigure,'function',cmd);

%-----------------------------------------------%
function locWindowButtonUpFcn(obj,evd,fig,h,h_t)
% Stop panning

setptr(fig,'hand');
pandata = locGetData(fig,h,h_t);

% Axes may be empty if we are double clicking
if ishandle(pandata.axes)
    newlim = axis(pandata.axes);
    origlim = pandata.orig_axlim;
    ax = pandata.axes;

    if ~isequal(newlim,origlim)
        locDoPan(ax,origlim,newlim,h,h_t);
    end
end

% Clear all transient pan state
pandata.axes = [];
pandata.last_pixel = [];

locSetData(fig,pandata,h,h_t);

%-----------------------------------------------%
function locWindowButtonMotionFcn(obj,evd,target,h,h_t)
% This gets called everytime we move the mouse in pan mode, 
% regardless of whether any buttons are pressed. 
fig = ancestor(target,'hg.figure');
pandata = locGetData(fig,h,h_t);
ax = pandata.axes;

if isempty(ax) | ~ishandle(ax)
    return;
else
    fig = ancestor(ax,'figure');
end

% Only pan if we have a previous pixel point
ok2pan = ~isempty(pandata.last_pixel); 

curr_pixel = get(fig,'currentpoint');
    
if ok2pan         
    delta_pixel = curr_pixel - pandata.last_pixel;

    orig_units = get(ax,'units');
    set(ax,'units','pixel');
    range_pixel = get(ax,'position');
    set(ax,'units',orig_units);
    
    locDataPan(ax,delta_pixel(1),delta_pixel(2),pandata.style,h,h_t);
end

pandata.last_pixel = curr_pixel;
locSetData(fig,pandata,h,h_t);

%-----------------------------------------------%
function locKeyPressFcn(obj,evd,target,h,h_t)
% Pan if the user clicks on arrow keys

fig = ancestor(target,'hg.figure');
pandata = locGetData(fig,h,h_t);
ax = get(fig,'CurrentAxes');

% Bail out if no handle to axes
if ~ishandle(ax), return; end

ch = get(fig,'CurrentCharacter');

% Bail out if empty
if isempty(ch), return; end

style = pandata.style;

switch uint16(ch)
  case 28  % ascii left arrow
    locDataPan(ax,-1,0,style,h,h_t);
  case 29 % ascii right arrow
    locDataPan(ax,1,0,style,h,h_t);  
  case 30 % ascii up arrow 
    locDataPan(ax,0,1,style);
  case 31 % ascii down arrow
    locDataPan(ax,0,-1,style);
end

drawnow; % required to prevent "flickering"

%-----------------------------------------------%
function locDataPan(ax,delta_pixel1,delta_pixel2,style,h,h_t)
% This is where the panning computation occurs.

orig_units = get(ax,'units');
set(ax,'units','pixel');
range_pixel = get(ax,'position');
  
set(ax,'units',orig_units);
 
if is2D(ax)        
    [abscissa, ordinate] = locGetOrdinate(ax,h,h_t);
    
    curr_lim1 = get(ax,[abscissa,'lim']);
    curr_lim2 = get(ax,[ordinate,'lim']);

    % For log plots, transform to linear scale
    if strcmp(get(ax,[abscissa,'scale']),'log')
        is_abscissa_log = logical(1);
        curr_lim1 = log10(curr_lim1);
    else
        is_abscissa_log = logical(0);
    end
    if strcmp(get(ax,[ordinate,'scale']),'log')
        is_ordinate_log = logical(1);
        curr_lim2 = log10(curr_lim2);
    else
        is_ordinate_log = logical(0);
    end
    
    range_data1 = abs(diff(curr_lim1));
    range_data2 = abs(diff(curr_lim2));
    
    pixel_width = range_pixel(3);
    pixel_height = range_pixel(4);  
    
    delta_data1 = delta_pixel1 * range_data1 / pixel_width;
    delta_data2 = delta_pixel2 * range_data2 /  pixel_height;

    % Consider direction of axis: [{'normal'|'reverse'}]
    dir1 = get(ax,sprintf('%sdir',abscissa(1)));
    if strcmp(dir1,'reverse')
        new_lim1 = curr_lim1 + delta_data1;
    else
        new_lim1 = curr_lim1 - delta_data1;
    end
    
    dir2 = get(ax,sprintf('%sdir',ordinate(1)));
    if strcmp(dir2,'reverse')
        new_lim2 = curr_lim2 + delta_data2;
    else
        new_lim2 = curr_lim2 - delta_data2;
    end

    % For log plots, untransform limits
    if is_abscissa_log
        new_lim1 = 10.^new_lim1;
    end
    if is_ordinate_log
        new_lim2 = 10.^new_lim2;
    end
    
    % Set new limits 
    if strcmp(style,'x')
       set(ax,[abscissa,'lim'],new_lim1);   
       set(ax,[ordinate,'lim'],curr_lim2);  
    elseif strcmp(style,'y')     
       set(ax,[abscissa,'lim'],curr_lim1);
       set(ax,[ordinate,'lim'],new_lim2);  
    else
       set(ax,[abscissa,'lim'],new_lim1); 
       set(ax,[ordinate,'lim'],new_lim2); 
    end
    %speed paning
    curr_point=mean((new_lim1));
    
    if abs(floor(curr_point/15)*15-curr_point)<1
    figure(h_t)
    
    h_line = findobj(gca,'Type','line');
    delete(h_line);
    h_image = findobj(gca,'Type','image');
    data_length=size(get(h_image,'CData'),2);
     if curr_point(1)<7
      curr_point(1)=7;
      elseif curr_point(1)>data_length-50
      curr_point(1)=data_length-50;
     end
     h_l=plot([curr_point curr_point],[0 500],'r');

    figure(h)
    end
    % Add to undo stack

    % The code below prevents panning beyond data limits.
    % pan_buffer_in_pixels = 0; 
    % pixels_per_data_unit1 = pixel_width / range_data1;
    % pixels_per_data_unit2 = pixel_height / range_data2;
    % pan_data_buffer1 = pan_buffer_in_pixels / pixels_per_data_unit1;
    % pan_data_buffer2 = pan_buffer_in_pixels / pixels_per_data_unit2;
    % bound_lims = objbounds(ax);
    % if  ~((new_lim1(1) + pan_data_buffer1) < bound_lims(1)  |  (new_lim1(2) - pan_data_buffer1) > bound_lims(2)) 
    %   set(ax,abscissa,new_lim1);
    % end
    % if ~((new_lim2(1) + pan_data_buffer2) < bound_lims(3)  |  (new_lim2(2) - pan_data_buffer2) > bound_lims(4)) 
    %   set(ax,ordinate,new_lim2);  
    % end         
    
else % 3-D 
    % Force ax to be in vis3d to avoid wacky resizing
    axis(ax,'vis3d');
    
    % For now, just do the same thing as camera toolbar panning. 
    junk = nan;    
    camdolly(ax,-delta_pixel1,-delta_pixel2, junk, 'movetarget', 'pixels');
end

%-----------------------------------------------%
function [abscissa, ordinate] = locGetOrdinate(ax,h,h_t)
% Pre-condition: 2-D plot
% Determines abscissa and ordinate as 'x','y',or 'z'

test1 = (camtarget(ax)-campos(ax))==0;
test2 = camup(ax)~=0;
ind = find(test1 & test2);

dim1 = ind(1);
dim2 = find(xor(test1,test2));

key = {'x','y','z'};

abscissa = key{dim2};
ordinate = key{dim1};

%-----------------------------------------------%
function [ax] = locGetAxes(fig,h,h_t)
% Return the axes that the mouse is currently over
% Return empty if no axes found (i.e. axes has hidden handle)

% TBD, this code is replicated in zoom.m and rotate3d.m

ax = [];
if ~ishandle(fig)
    return;
end

% Determine which axes mouse ptr hits. We can't use the 
% figure's "currentaxes" property since the current
% axes may not be under the mouse ptr.
allAxes = findobj(datachildren(fig),'type','axes');
orig_fig_units = get(fig,'units');
set(fig,'units','pixels');
for i=1:length(allAxes),
   candidate_ax=allAxes(i);
   
   % Check behavior support
   b = hggetbehavior(candidate_ax,'Pan','-peek');
   doIgnore = false;
   if ~isempty(b) & ishandle(b)
      if ~get(b,'Enable')
          doIgnore = true;
      end
   end
        
   if ~doIgnore
       cp = get(fig,'CurrentPoint');
       orig_ax_units = get(candidate_ax,'units');
       set(candidate_ax,'units','pixels')
       pos = get(candidate_ax,'position');
       set(candidate_ax,'units',orig_ax_units)
       if cp(1) >= pos(1) & cp(1) <= pos(1)+pos(3) & ...
          cp(2) >= pos(2) & cp(2) <= pos(2)+pos(4)
            set(fig,'currentaxes',candidate_ax);
            ax = candidate_ax;
            break
       end %if
    end %if
end % for

% restore state
set(fig,'units',orig_fig_units)

%-----------------------------------------------%
function [pandata] = locGetData(fig,h,h_t)
pandata = getappdata(fig,'PanFigureState');
if isempty(pandata)
    pandata.uistate = [];
    pandata.axes = [];
    pandata.orig_axlim = [];
    pandata.last_pixel = [];
    pandata.style = 'xy';
    pandata.uicontextmenu = [];
    pandata.enable = 'off';
end

%-----------------------------------------------%
function locSetData(fig,pandata,h,h_t)
setappdata(fig,'PanFigureState',pandata);

%-----------------------------------------------%
function locRmData(fig,h,h_t)
if isappdata(fig,'PanFigureState')
   rmappdata(fig,'PanFigureState');
end

%-----------------------------------------------%
function locDoPanOn(fig,h,h_t)
set(uigettoolbar(fig,'Exploration.Pan'),'State','on');      
set(findall(fig,'tag','figMenuPan'),'Checked','on');

% Remove when uitoolfactory is in place
set(findall(fig,'tag','figToolPan'),'State','on');  

%-----------------------------------------------%
function locDoPanOff(fig,h,h_t)
set(uigettoolbar(fig,'Exploration.Pan'),'State','off'); 
set(findall(fig,'tag','figMenuPan'),'Checked','off');

% Remove when uitoolfactory is in place
set(findall(fig,'tag','figToolPan'),'State','off');

%-----------------------------------------------% 
function [hui] = locUICreateDefaultContextMenu(hFig,h,h_t);
% Create default context menu

props = [];
props_context.Parent = hFig;
props_context.Tag = 'PanContextMenu';
props_context.Callback = {@locUIContextMenuCallback,hFig};
props_context.ButtonDown = {@locUIContextMenuCallback,hFig};
hui = uicontextmenu(props_context);

% Generic attributes for all pan context menus
props.Callback = {@locUIContextMenuCallback,hFig};
props.Parent = hui;

% Full View context menu
props.Label = 'Reset to Original View';
props.Tag = 'ResetView';
props.Separator = 'off';
ufullview = uimenu(props);

% Pan Constraint context menu
props.Callback = '';
props.Label = 'Pan Options';
props.Tag = 'Constraint';
props.Separator = 'on';
uConstraint = uimenu(props);

props.Parent = uConstraint;

props.Callback = {@locUIContextMenuCallback,hFig};
props.Label = 'Unconstrained Pan';
props.Tag = 'PanUnconstrained';
props.Separator = 'off';
uimenu(props);

props.Label = 'Horizontal Pan (Applies to 2-D Plots Only)';
props.Tag = 'PanHorizontal';
uimenu(props);

props.Label = 'Vertical Pan (Applies to 2-D Plots Only)';
props.Tag = 'PanVertical';
uimenu(props);

%-------------------------------------------------%  
function locUIContextMenuCallback(obj,evd,hFig,h,h_t)

tag = get(obj,'tag');

switch(tag)    
    case 'PanContextMenu'
        pandata = locGetData(hFig);
        locUIContextMenuUpdate(hFig,pandata.style);
    case 'ResetView'        
        hObject = hittest(gcbf);
        hAxes = ancestor(hObject,'hg.axes');  
        resetplotview(hAxes,'ApplyStoredView');
    case 'PanUnconstrained'
        locUIContextMenuUpdate(hFig,'xy');
    case 'PanHorizontal'
        locUIContextMenuUpdate(hFig,'x');
    case 'PanVertical'
        locUIContextMenuUpdate(hFig,'y');
end

%-------------------------------------------------%  
function locUIContextMenuUpdate(hFig,pan_Constraint,h,h_t)

ux = findall(hFig,'Tag','PanHorizontal','Type','UIMenu');
uy = findall(hFig,'Tag','PanVertical','Type','UIMenu');
uxy = findall(hFig,'Tag','PanUnconstrained','Type','UIMenu');

pandata = locGetData(hFig);
pandata.style = pan_Constraint;
locSetData(hFig,pandata);

switch(pan_Constraint) 
  case 'xy'
      set(ux,'checked','off');
      set(uy,'checked','off');
      set(uxy,'checked','on');

  case 'x'
      set(ux,'checked','on');
      set(uy,'checked','off');
      set(uxy,'checked','off');

  case 'y'
      set(ux,'checked','off');
      set(uy,'checked','on');
      set(uxy,'checked','off');
end
  
