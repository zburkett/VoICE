function varargout = determine_merging_threshold(varargin)
% DETERMINE_MERGING_THRESHOLD MATLAB code for determine_merging_threshold.fig
%      DETERMINE_MERGING_THRESHOLD, by itself, creates a new DETERMINE_MERGING_THRESHOLD or raises the existing
%      singleton*.
%
%      H = DETERMINE_MERGING_THRESHOLD returns the handle to a new DETERMINE_MERGING_THRESHOLD or the handle to
%      the existing singleton*.
%
%      DETERMINE_MERGING_THRESHOLD('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DETERMINE_MERGING_THRESHOLD.M with the given input arguments.
%
%      DETERMINE_MERGING_THRESHOLD('Property','Value',...) creates a new DETERMINE_MERGING_THRESHOLD or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before determine_merging_threshold_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to determine_merging_threshold_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help determine_merging_threshold

% Last Modified by GUIDE v2.5 21-Jul-2014 10:58:26

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @determine_merging_threshold_OpeningFcn, ...
                   'gui_OutputFcn',  @determine_merging_threshold_OutputFcn, ...
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


% --- Executes just before determine_merging_threshold is made visible.
function determine_merging_threshold_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to determine_merging_threshold (see VARARGIN)

% Choose default command line output for determine_merging_threshold
handles.output = hObject;

handles.path = varargin{1}{1};
handles.pathu = varargin{2}{1};

dat = csvread(strcat(handles.path,'.igsdata.csv'));
fid = fopen(strcat(handles.path,'.colnames.txt'));
s = textscan(fid,'%s','Delimiter','\n');
s = strrep(s{1}(:,1),'"','');
set(handles.uitable2,'Data',dat,'ColumnName',s);
set(handles.popupmenu1,'String',{'Select a threshold...',dat(:,1)})  
handles.curve = imread(strcat(handles.path,'.tree_trim_curve.png'),'png');
imshow(handles.curve,'Parent',handles.axes1);
handles.threshold = 'default';

set(handles.pushbutton3,'Enable','off');

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes determine_merging_threshold wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = determine_merging_threshold_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double
thresh = get(hObject,'String');
thresh = thresh{1};
handles.threshold = thresh;
guidata(hObject,handles);

% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if strcmp(handles.threshold,'Select a threshold...') || strcmp(handles.threshold,'default')
    h = errordlg('No merging threshold selected. Choose one from the dropdown menu.');
else
    set(handles.statusdlg,'String','Generating clusters.');
    set(handles.pushbutton1,'BackgroundColor','Yellow');
    pause(0.00001);
	if isunix
    	system(['R --slave --args' ' ' handles.pathu ' '  handles.threshold ' ' '< ./R/determineClusters2.r']);
	elseif ispc
		system(['R --slave --args' ' ' char(34) handles.pathu char(34) ' ' handles.threshold ' ' '< ./R/determineClusters2.r']);
	end
    pause(0.00001);
    set(handles.pushbutton1,'BackgroundColor','Green');
    set(handles.statusdlg,'String','Clusters generated. Click "Reassign Syllables" to view/edit. BEWARE: Hitting "Generate Clusters" again will wipe all reassignments!');
    set(handles.pushbutton3,'Enable','on');
end

% --- Executes during object creation, after setting all properties.
function axes1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes1

% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

reassign_syllables({handles.path},{handles.path},{0})


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1
contents = cellstr(get(hObject,'String'));
handles.threshold = contents{get(hObject,'Value')};
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
