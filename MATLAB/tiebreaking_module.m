function varargout = tiebreaking_module(varargin)
% TIEBREAKING_MODULE MATLAB code for tiebreaking_module.fig
%      TIEBREAKING_MODULE, by itself, creates a new TIEBREAKING_MODULE or raises the existing
%      singleton*.
%
%      H = TIEBREAKING_MODULE returns the handle to a new TIEBREAKING_MODULE or the handle to
%      the existing singleton*.
%
%      TIEBREAKING_MODULE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TIEBREAKING_MODULE.M with the given input arguments.
%
%      TIEBREAKING_MODULE('Property','Value',...) creates a new TIEBREAKING_MODULE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before tiebreaking_module_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to tiebreaking_module_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help tiebreaking_module

% Last Modified by GUIDE v2.5 04-Aug-2014 14:40:07

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @tiebreaking_module_OpeningFcn, ...
                   'gui_OutputFcn',  @tiebreaking_module_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before tiebreaking_module is made visible.
function tiebreaking_module_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to tiebreaking_module (see VARARGIN)
if isunix
	%get directories
	handles.assignPath = varargin{1}{1};
	handles.assignPathu = strrep(handles.assignPath,' ','\ ');
	handles.refDir = varargin{2}{1};
	handles.refDiru = strrep(handles.refDir,' ','\ ');

	%find .png images for tiebreaking
	pattern = strcat(handles.assignPath,'final_spectro/','*.png');
	handles.imgs = dir(pattern);

	%set first .png to axes; update counter
	[I,map] = imread(strcat(handles.assignPath,'final_spectro/',handles.imgs(1).name));
	axes(handles.axes1);
	imshow(I,map);
	handles.count = 1;
	set(handles.currentsyl,'String',handles.count);
	set(handles.totalsyl,'String',length(handles.imgs));

	%populate dropdown menu with possible cluster assignments
	system(['R --slave --args ' handles.refDiru ' < ./R/getClusterIDs.r']);

	fid = fopen(strcat(handles.refDir,'/.usedClusters.txt'));
	s = textscan(fid,'%s','Delimiter','\n');
	s = strrep(s{1}(:,1),'"','');
	pat = fullfile(strcat(handles.refDir,'/.spectrograms/'),'*.csv');
	csvs = dir(pat);
	csv = csvread(strcat(handles.refDir,'/.spectrograms/',csvs(handles.count).name));
	j = {'novel',s{:}};

	for u = 1:length(j)-1
	    j{u+1} = strcat(j{u+1},' = ', num2str(csv(u)));
	end

	%set(handles.popupmenu1,'String',{'novel',s{:}});
	set(handles.popupmenu1,'String',j);

	%default variables and buttons
	set(handles.finalize,'Enable','Off');
	set(handles.back,'Enable','Off');
	handles.assignment = 'novel';

	%NA handling
	handles.NAs = str2num(varargin{3}{1});

	%query assignment
	handles.assignRun = varargin{4}{1};

	set(handles.confirm,'Enable','on');
elseif ispc
	%get directories
	handles.assignPath = varargin{1}{1};
	%handles.assignPathu = strrep(handles.assignPath,' ','\ ');
	handles.refDir = varargin{2}{1};
	%handles.refDiru = strrep(handles.refDir,' ','\ ');

	%find .png images for tiebreaking
	pattern = strcat(handles.assignPath,'final_spectro/','*.png');
	handles.imgs = dir(pattern);

	%set first .png to axes; update counter
	[I,map] = imread(strcat(handles.assignPath,'final_spectro/',handles.imgs(1).name));
	axes(handles.axes1);
	imshow(I,map);
	handles.count = 1;
	set(handles.currentsyl,'String',handles.count);
	set(handles.totalsyl,'String',length(handles.imgs));

	%populate dropdown menu with possible cluster assignments
	system(['R --slave --args ' char(34) handles.refDir char(34) ' < ./R/getClusterIDs.r']);

	fid = fopen(strcat(handles.refDir,'/.usedClusters.txt'));
	s = textscan(fid,'%s','Delimiter','\n');
	s = strrep(s{1}(:,1),'"','');
	pat = fullfile(strcat(handles.refDir,'/.spectrograms/'),'*.csv');
	csvs = dir(pat);
	csv = csvread(strcat(handles.refDir,'/.spectrograms/',csvs(handles.count).name));
	j = {'novel',s{:}};

	for u = 1:length(j)-1
	    j{u+1} = strcat(j{u+1},' = ', num2str(csv(u)));
	end

	%set(handles.popupmenu1,'String',{'novel',s{:}});
	set(handles.popupmenu1,'String',j);


	%default variables and buttons
	set(handles.finalize,'Enable','Off');
	set(handles.back,'Enable','Off');
	handles.assignment = 'novel';

	%NA handling
	handles.NAs = str2num(varargin{3}{1});

	%query assignment
	handles.assignRun = varargin{4}{1};

	set(handles.confirm,'Enable','on');
end

% Choose default command line output for tiebreaking_module
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes tiebreaking_module wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = tiebreaking_module_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in finalize.
function finalize_Callback(hObject, eventdata, handles)
% hObject    handle to finalize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
assignments = {handles.imgs.assignment};

if isunix
	%apply assignments to R workspace
	filename = strcat(handles.assignPath,'assignmentsOut.txt');
	fid = fopen(filename,'w');
	for col = 1:length(assignments)
	    fprintf(fid,'%s\n',char(assignments{col}));
	end
	fclose(fid);
	system(['R --slave --args ' handles.assignPathu ' < ./R/assignTiebreaks.r']);

	%NAs.csv is updated if NAs were dictated in reassignment

	%Delete NDs.csv since all syllables are now novel or assigned
	delete(strcat(handles.assignPath,'NDs.csv'));

	novelSyls = 0;
	for i = 1:length(assignments)
	    if strcmp(assignments{i},'novel')
	        novelSyls = novelSyls+1;
	    end
	end

	if novelSyls > 0
	    handles.NAs = 1;
	elseif handles.NAs ~= 0
	    handles.NAs=handles.NAs;
	else
	    handles.NAs = 0;
	    warning off
	    delete(strcat(handles.assignPath,'NAs.csv'));
	    warning on
	end

	%if there are novel syllables, launch the gui to handle it; otherwise
	%proceed to reassignment
	if handles.NAs == 0
	    close
	    reassign_syllables({handles.assignPath},{handles.refDir},{1});
	elseif handles.NAs ~= 0
	    close
	    novelty_module({handles.assignPath},{handles.refDir});
	end
elseif ispc
	%apply assignments to R workspace
	filename = strcat(handles.assignPath,'assignmentsOut.txt');
	fid = fopen(filename,'w');
	for col = 1:length(assignments)
	    fprintf(fid,'%s\n',char(assignments{col}));
	end
	fclose(fid);
	system(['R --slave --args ' char(34) handles.assignPath char(34) ' < ./R/assignTiebreaks.r']);
	%NAs.csv is updated if NAs were dictated in reassignment

	%Delete NDs.csv since all syllables are now novel or assigned
	delete(strcat(handles.assignPath,'NDs.csv'));

	if sum(strcmp('novel',assignments)) > 0
	    handles.NAs = 1;
	elseif handles.NAs ~= 0 %ND added lines 132-133 to force novelty module
	    handles.NAs=handles.NAs;
	else
	    handles.NAs = 0;
	    warning off
	    delete(strcat(handles.assignPath,'NAs.csv'));
	    warning on
	end

	%if there are novel syllables, launch the gui to handle it; otherwise
	%proceed to reassignment
	if handles.NAs == 0
	    close
	    reassign_syllables({handles.assignPath},{handles.refDir},{1});
	elseif handles.NAs ~= 0
	    close
	    novelty_module({handles.assignPath},{handles.refDir});
	end
end


% --- Executes on button press in back.
function back_Callback(hObject, eventdata, handles)
% hObject    handle to back (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.count = handles.count-1;

set(handles.finalize,'Enable','Off');
set(handles.confirm,'Enable','On');

if handles.count == 1
    set(handles.back,'Enable','Off');
end

[I,map] = imread(strcat(handles.assignPath,'final_spectro/',handles.imgs(handles.count).name));
axes(handles.axes1);
imshow(I,map);
set(handles.currentsyl,'String',handles.count);

fid = fopen(strcat(handles.refDir,'/.usedClusters.txt'));
s = textscan(fid,'%s','Delimiter','\n');
s = strrep(s{1}(:,1),'"','');
pat = fullfile(strcat(handles.refDir,'/.spectrograms/'),'*.csv');
csvs = dir(pat);
csv = csvread(strcat(handles.refDir,'/.spectrograms/',csvs(handles.count).name));
j = {'novel',s{:}};

for u = 1:length(j)-1
    j{u+1} = strcat(j{u+1},' = ', num2str(csv(u)));
end
set(handles.popupmenu1,'String',j);

guidata(hObject,handles);


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1
contents = cellstr(get(hObject,'String'));
handles.assignment = contents{get(hObject,'Value')};
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in confirm.
function confirm_Callback(hObject, eventdata, handles)
% hObject    handle to confirm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isunix
	%handles.assignment = strsplit(handles.assignment, ' ');
	%handles.assignment = handles.assignment(1);

	% apply whatever is in dropdown menu to syllable ID
	handles.imgs(handles.count).assignment = handles.assignment;

	% activate back button if it is not
	set(handles.back,'Enable','On');

	% add to count or finish
	if handles.count == length(handles.imgs)
	    set(handles.finalize,'Enable','On');
	    set(handles.confirm,'Enable','Off');
	else
	    handles.count = handles.count+1;
	    [I,map] = imread(strcat(handles.assignPath,'final_spectro/',handles.imgs(handles.count).name));
	    axes(handles.axes1);
	    imshow(I,map);
	    set(handles.currentsyl,'String',handles.count);
    
	    fid = fopen(strcat(handles.refDir,'/.usedClusters.txt'));
	    s = textscan(fid,'%s','Delimiter','\n');
	    s = strrep(s{1}(:,1),'"','');
	    pat = fullfile(strcat(handles.refDir,'/.spectrograms/'),'*.csv');
	    csvs = dir(pat);
	    csv = csvread(strcat(handles.refDir,'/.spectrograms/',csvs(handles.count).name));
	    j = {'novel',s{:}};

	    for u = 1:length(j)-1
	        j{u+1} = strcat(j{u+1},' = ', num2str(csv(u)));
	    end
	    set(handles.popupmenu1,'String',j);
	end
elseif ispc
	% apply whatever is in dropdown menu to syllable ID
	handles.imgs(handles.count).assignment = handles.assignment;

	% activate back button if it is not
	set(handles.back,'Enable','On');

	% add to count or finish
	if handles.count == length(handles.imgs)
	    set(handles.finalize,'Enable','On');
	    set(handles.confirm,'Enable','Off');
	else
	    handles.count = handles.count+1;
	    [I,map] = imread(strcat(handles.assignPath,'final_spectro/',handles.imgs(handles.count).name));
	    axes(handles.axes1);
	    imshow(I,map);
	    set(handles.currentsyl,'String',handles.count);

	    fid = fopen(strcat(handles.refDir,'/.usedClusters.txt'));
	    s = textscan(fid,'%s','Delimiter','\n');
	    s = strrep(s{1}(:,1),'"','');
	    pat = fullfile(strcat(handles.refDir,'/.spectrograms/'),'*.csv');
	    csvs = dir(pat);
	    csv = csvread(strcat(handles.refDir,'/.spectrograms/',csvs(handles.count).name));
	    j = {'novel',s{:}};

	    for u = 1:length(j)-1
	        j{u+1} = strcat(j{u+1},' = ', num2str(csv(u)));
	    end
	    set(handles.popupmenu1,'String',j);
	end
end
guidata(hObject,handles);
    
