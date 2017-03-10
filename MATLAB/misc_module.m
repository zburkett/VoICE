function varargout = misc_module(varargin)
% MISC_MODULE MATLAB code for misc_module.fig
%      MISC_MODULE, by itself, creates a new MISC_MODULE or raises the existing
%      singleton*.
%
%      H = MISC_MODULE returns the handle to a new MISC_MODULE or the handle to
%      the existing singleton*.
%
%      MISC_MODULE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MISC_MODULE.M with the given input arguments.
%
%      MISC_MODULE('Property','Value',...) creates a new MISC_MODULE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before misc_module_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to misc_module_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help misc_module

% Last Modified by GUIDE v2.5 17-Sep-2014 16:49:15

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @misc_module_OpeningFcn, ...
                   'gui_OutputFcn',  @misc_module_OutputFcn, ...
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


% --- Executes just before misc_module is made visible.
function misc_module_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to misc_module (see VARARGIN)

% Choose default command line output for misc_module
handles.output = hObject;

set(handles.pushbutton2,'Enable','off');

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes misc_module wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = misc_module_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.comp1 = uigetdir(cd,'Select directory containing existing clusters.');
set(handles.text8,'String',handles.comp1);
guidata(hObject,handles);


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.comp2 = uigetdir(cd,'Select directory containing existing clusters.');
set(handles.text9,'String',handles.comp2);
guidata(hObject,handles);


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.path = uigetdir(cd,'Select directory containing existing clusters.');
set(handles.text2,'String',handles.path);
if exist(strcat(handles.path,'/workspace.Rdata'))
    set(handles.pushbutton2,'Enable','on')
elseif exist(strcat(handles.path,'/assign_workspace.Rdata'))
    set(handles.pushbutton2,'Enable','on')
elseif exist(strcat(handles.path,'/voice_results/workspace.Rdata'))
    set(handles.pushbutton2,'Enable','on')
elseif exist(strcat(handles.path,'/voice_results/assign_workspace.Rdata'))
    set(handles.pushbutton2,'Enable','on')
else
    h = errordlg('No clustering or assignment workspace found in the selected directory.');
end
guidata(hObject,handles);


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
s = regexp(handles.path, '/', 'split');
if strcmp(s{end},'voice_results')
    parent = cd;
    cd(handles.path);
    cd('..');
    handles.path = cd;
    cd(parent);
end

handles.pathu = strrep(handles.path,' ','\ ');
handles.pathu = strcat(handles.pathu,'/');
set(handles.text24,'String','Reassignment module will launch momentarily...please wait.');
if(exist(strcat(handles.path,'/assign_workspace.Rdata')))
    reassign_syllables({handles.path},{handles.path},{1});
elseif exist(strcat(handles.path,'/voice_results/assign_workspace.Rdata'))
    reassign_syllables({handles.path},{handles.path},{1});
elseif exist(strcat(handles.path,'/workspace.Rdata'))
    reassign_syllables({handles.path},{handles.path},{0});
elseif exist(strcat(handles.path,'/voice_results/workspace.Rdata'))
    reassign_syllables({handles.path},{handles.path},{0});
end


% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~isfield(handles,'comp1')
    h = errordlg('No Session 1 directory selected.')
else
    
    s = regexp(handles.comp1, '/', 'split');
    if strcmp(s{end},'voice_results')
        parent = cd;
        cd(handles.comp1);
        cd('..');
        handles.comp1 = cd;
        cd(parent);
    end
    
    handles.comp1u = strrep(handles.comp1,' ','\ ');
    if handles.comp1u(end) ~= '/'
        handles.comp1u = strcat(handles.comp1u,'/');
    end
    
    if ~exist(strcat(handles.comp1,'/workspace.Rdata')) & ~exist(strcat(handles.comp1,'/assign_workspace.Rdata')) & ~exist(strcat(handles.comp1,'/voice_results/workspace.Rdata')) & ~exist(strcat(handles.comp1,'/voice_results/assign_workspace.Rdata'))
        h = errordlg('No valid cluster or assignment workspace found in selected Session 1 directory.')
    end
end

if ~isfield(handles,'comp2')
    h = errordlg('No Session 2 directory selected.')
else
    
    s = regexp(handles.comp2, '/', 'split');
    if strcmp(s{end},'voice_results')
        parent = cd;
        cd(handles.comp2);
        cd('..');
        handles.comp2 = cd;
        cd(parent);
    end
    
    handles.comp2u = strrep(handles.comp2,' ','\ ');
    if handles.comp2u(end) ~= '/'
       handles.comp2u = strcat(handles.comp2u,'/');
    end
    if ~exist(strcat(handles.comp2,'/workspace.Rdata')) & ~exist(strcat(handles.comp2,'/assign_workspace.Rdata')) & ~exist(strcat(handles.comp2,'/voice_results/workspace.Rdata')) & ~exist(strcat(handles.comp2,'/voice_results/assign_workspace.Rdata'))
        h = errordlg('No valid cluster or assignment workspace found in selected Session 2 directory.')
    end
end

%if ~exist(strcat(handles.comp1,'/workspace.Rdata')) || ~exist(strcat(handles.comp1,'/assign_workspace.Rdata')
system(['R --slave --args ' handles.comp1u ' ' handles.comp2u ' < ./R/calculateSyntaxSimilarity.r']);
set(handles.text24,'String','Syntax and acoustic plots generated and stored in the Session 1 directory.');


% --- Executes on button press in pushbutton11.
function pushbutton11_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton9.
function pushbutton9_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
