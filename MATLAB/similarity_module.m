function varargout = similarity_module(varargin)
% SIMILARITY_MODULE MATLAB code for similarity_module.fig
%      SIMILARITY_MODULE, by itself, creates a new SIMILARITY_MODULE or raises the existing
%      singleton*.
%
%      H = SIMILARITY_MODULE returns the handle to a new SIMILARITY_MODULE or the handle to
%      the existing singleton*.
%
%      SIMILARITY_MODULE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SIMILARITY_MODULE.M with the given input arguments.
%
%      SIMILARITY_MODULE('Property','Value',...) creates a new SIMILARITY_MODULE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before similarity_module_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to similarity_module_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help similarity_module

% Last Modified by GUIDE v2.5 22-Feb-2017 11:16:43

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @similarity_module_OpeningFcn, ...
                   'gui_OutputFcn',  @similarity_module_OutputFcn, ...
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


% --- Executes just before similarity_module is made visible.
function similarity_module_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to similarity_module (see VARARGIN)

% Choose default command line output for similarity_module
handles.output = hObject;
handles.mindur = '6';
handles.winsize = '41';

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes similarity_module wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = similarity_module_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isunix
	[handles.file, handles.path] = uigetfile('*.xls','Select a feature batch .XLS file.');
	handles.fileu = strrep(handles.file,' ','\ ');
	handles.pathu = strrep(handles.path,' ','\ ');
	set(handles.text3,'String',strcat(handles.path,handles.file));
	set(handles.pushbutton2,'BackgroundColor','default');
	guidata(hObject,handles);
elseif ispc
	[handles.file, handles.path] = uigetfile('*.xls','Select a feature batch .XLS file.');
	handles.fileu = strrep(handles.file,'\','/');
	handles.pathu = strrep(handles.path,'\','/');
	set(handles.text3,'String',strcat(handles.path,handles.file));
	set(handles.pushbutton2,'BackgroundColor','default');
	guidata(hObject,handles);
end

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isunix
	set(handles.pushbutton2,'BackgroundColor','yellow');
	set(handles.text6,'String','Cutting .WAV files. Button turns green when done.');
	pause(.0000001)
	setenv('DYLD_LIBRARY_PATH', '/usr/local/bin/');
	system(['R --slave --args' ' ' handles.pathu ' ' handles.fileu ' ' ' < ./R/importFeatureBatch.r']);
	setenv('PATH', [getenv('PATH') ':/usr/local/bin']);
	system(['R --slave --args' ' ' strcat(handles.pathu,'.acoustic_data.csv') ' ' handles.pathu ' ' ' < ./R/getSyllableWavs2.r']);
	pause(.0000001)
	set(handles.pushbutton2,'BackgroundColor','green');
	set(handles.text6,'String','WAV files cut. Similarity batch ready to run.');
	guidata(hObject,handles);
elseif ispc
	set(handles.pushbutton2,'BackgroundColor','yellow');
	set(handles.text6,'String','Cutting .WAV files. Button turns green when done.');
	pause(.0000001)
	%setenv('DYLD_LIBRARY_PATH', '/usr/local/bin/');
	[status,result]=system(['R --slave --args' ' ' char(34) handles.pathu char(34) ' ' char(34) handles.fileu char(34) ' ' ' < ./R/importFeatureBatch.r']);
	%setenv('PATH', [getenv('PATH') ':/usr/local/bin']);
	system(['R --slave --args' ' ' char(34) strcat(handles.pathu,'.acoustic_data.csv') char(34) ' ' char(34) handles.pathu char(34) ' ' ' < ./R/getSyllableWavs2.r']);
	pause(.0000001)
	set(handles.pushbutton2,'BackgroundColor','green');
	set(handles.text6,'String','WAV files cut. Similarity batch ready to run.');
	guidata(hObject,handles);
end

% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.pushbutton3,'BackgroundColor','yellow');
set(handles.text6,'String','Your similarity batch is running. This may take a while. A status bar will spawn in MATLAB Desktop.');
pause(.0000001)
similarity_batch_parallel_pub(handles.path,str2num(handles.mindur),str2num(handles.winsize));
pause(.0000001)
set(handles.pushbutton3,'BackgroundColor','green');
set(handles.text6,'String','Similarity batch is complete. Ready to cluster.');



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double
handles.mindur = get(hObject,'String');
guidata(hObject,handles);


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


function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double
handles.winsize = get(hObject,'String');
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double


% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double


% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% syllable clustering step
if isunix
	setenv('DYLD_LIBRARY_PATH', '/usr/local/bin/');
	setenv('PATH', [getenv('PATH') ':/usr/local/bin']);
	set(handles.pushbutton4,'BackgroundColor','yellow');
	set(handles.text6,'String','Syllables being clustered...a status bar will spawn.');
	pause(0.000001)
	system(['R --slave --args' ' ' handles.pathu ' ' '< ./R/clusterSyllables.r']);
	pause(0.000001)
	set(handles.pushbutton4,'BackgroundColor','green');
	set(handles.text6,'String','Clustering and iterative trimming complete.');
elseif ispc
	set(handles.pushbutton4,'BackgroundColor','yellow');
	set(handles.text6,'String','Syllables being clustered...a status bar will spawn.');
	pause(0.000001)
	system(['R --slave --args' ' ' char(34) handles.pathu char(34) ' ' '< ./R/clusterSyllables.r']);
	pause(0.000001)
	set(handles.pushbutton4,'BackgroundColor','green');
	set(handles.text6,'String','Clustering and iterative trimming complete.');
end

% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isunix
	system(['R --slave --args' ' ' handles.pathu ' ' '< ./R/determineClusters1.r']);
	determine_merging_threshold({handles.path},{handles.pathu});
elseif ispc
	system(['R --slave --args' ' ' char(34) handles.pathu char(34) ' ' '< ./R/determineClusters1.r']);
	determine_merging_threshold({handles.path},{handles.pathu});
end
