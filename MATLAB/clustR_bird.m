function varargout = clustR_bird(varargin)
% CLUSTR_BIRD MATLAB code for clustR_bird.fig
%      CLUSTR_BIRD, by itself, creates a new CLUSTR_BIRD or raises the existing
%      singleton*.
%
%      H = CLUSTR_BIRD returns the handle to a new CLUSTR_BIRD or the handle to
%      the existing singleton*.
%
%      CLUSTR_BIRD('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CLUSTR_BIRD.M with the given input arguments.
%
%      CLUSTR_BIRD('Property','Value',...) creates a new CLUSTR_BIRD or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before clustR_bird_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to clustR_bird_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help clustR_bird

% Last Modified by GUIDE v2.5 19-Jun-2014 12:46:41

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @clustR_bird_OpeningFcn, ...
                   'gui_OutputFcn',  @clustR_bird_OutputFcn, ...
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


% --- Executes just before clustR_bird is made visible.
function clustR_bird_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to clustR_bird (see VARARGIN)

installdir = which('clustR_bird');
f = findstr('/',installdir);
installdir = installdir(1:max(f));
cd(installdir);

% Choose default command line output for clustR_bird
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes clustR_bird wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = clustR_bird_OutputFcn(hObject, eventdata, handles) 
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
close
similarity_module


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close
assignment_module


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close
misc_module
