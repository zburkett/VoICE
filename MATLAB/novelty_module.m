function varargout = novelty_module(varargin)
% NOVELTY_MODULE MATLAB code for novelty_module.fig
%      NOVELTY_MODULE, by itself, creates a new NOVELTY_MODULE or raises the existing
%      singleton*.
%
%      H = NOVELTY_MODULE returns the handle to a new NOVELTY_MODULE or the handle to
%      the existing singleton*.
%
%      NOVELTY_MODULE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in NOVELTY_MODULE.M with the given input arguments.
%
%      NOVELTY_MODULE('Property','Value',...) creates a new NOVELTY_MODULE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before novelty_module_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to novelty_module_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help novelty_module

% Last Modified by GUIDE v2.5 22-Sep-2014 14:28:32

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @novelty_module_OpeningFcn, ...
                   'gui_OutputFcn',  @novelty_module_OutputFcn, ...
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


% --- Executes just before novelty_module is made visible.
function novelty_module_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to novelty_module (see VARARGIN)

% Choose default command line output for novelty_module
handles.output = hObject;

if isunix
	handles.assignPath = varargin{1}{1};
	handles.assignPathu = strrep(handles.assignPath,' ','\ ');
	handles.refDir = varargin{2}{1};
	handles.refDiru = strrep(handles.refDir,' ','\ ');
elseif ispc
	handles.assignPath = varargin{1}{1};
	handles.assignPath = strrep(handles.assignPath,'\','/');
	handles.refDir = varargin{2}{1};
	handles.refDir = strrep(handles.refDir,'\','/');
end

% dat = csvread(strcat(handles.path,'igsdata.csv'));
% fid = fopen(strcat(handles.path,'colnames.txt'));
% s = textscan(fid,'%s','Delimiter','\n');
% s = strrep(s{1}(:,1),'"','');
% set(handles.uitable2,'Data',dat,'ColumnName',s);
% set(handles.popupmenu1,'String',{'Select a threshold...',dat(:,1)})  
% handles.curve = imread(strcat(handles.path,'tree_trim_curve.png'),'png');
% imshow(handles.curve,'Parent',handles.axes1);
% handles.threshold = 'default';
% 
% set(handles.pushbutton3,'Enable','off');

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes novelty_module wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = novelty_module_OutputFcn(hObject, eventdata, handles) 
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
if strcmp(handles.threshold,'default')
    h = errordlg('No merging threshold selected. Choose one from the dropdown menu.');
else
    pause(0.00001);
    set(handles.statusdlg,'String','Generating clusters.');
    set(handles.pushbutton1,'BackgroundColor','Yellow');
    system(['R --slave --args ', handles.threshold ' ' handles.assignPathu ' ' handles.refDiru ' < ./R/determineClustersAssign2.r']);
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
reassign_syllables({handles.assignPath},{handles.refDir},{1})


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


% --- Executes on button press in derive_go.
function derive_go_Callback(hObject, eventdata, handles)
% hObject    handle to derive_go (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

x = dir(strcat(handles.assignPath,'unassigned_for_cluster/*.wav'));

if length(x)==1
    
    system(['R --slave --args ' char(34) handles.assignPath char(34) ' < ./R/assignSingleNA.r']);
    %alert to move on goes here...
    
    h=msgbox('Only a single novel syllable was found and automatically given a unique ID. Click "Generate Clusters" and proceed.');
    
    set(handles.popupmenu1,'String','N/A');
    
    handles.threshold = 'none';
    
elseif length(x)>1 %if more than one novel syllable, cluster them
    
    set(handles.statusdlg,'String','Similarity batch between novel syllables is running.');
    set(handles.derive_go,'BackgroundColor','yellow');

    %run similarity batch between novel syllables
    similarity_batch_parallel_headless_unassigned_pub(strcat(handles.assignPath,'unassigned_for_cluster'));

    %iterate through tree trimming
    system(['R --slave --args ' handles.assignPathu ' ' '4 0 1 0.01 ' '< ./R/clusterSyllablesAssign_pub.r']);

    %prep for GUI
    system(['R --slave --args ' handles.assignPathu ' < ./R/determineClustersAssign1.r']);

    %update GUI
    dat = csvread(strcat(handles.assignPath,'igsdata_novel.csv'));
    fid = fopen(strcat(handles.assignPath,'colnames_novel.txt'));
    s = textscan(fid,'%s','Delimiter','\n');
    s = strrep(s{1}(:,1),'"','');
    set(handles.uitable2,'Data',dat,'ColumnName',s);
    set(handles.popupmenu1,'String',{'Select a threshold...',dat(:,1)})  
    handles.curve = imread(strcat(handles.assignPath,'tree_trim_curve_novel.png'),'png');
    imshow(handles.curve,'Parent',handles.axes1);
    handles.threshold = 'default';


    set(handles.statusdlg,'String','Similarity batch between novel syllables is complete. Choose a merging threshold.');
    set(handles.derive_go,'BackgroundColor','green');
end
guidata(hObject,handles);
