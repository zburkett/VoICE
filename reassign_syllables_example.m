function varargout = reassign_syllables(varargin)
% REASSIGN_SYLLABLES MATLAB code for reassign_syllables.fig
%      REASSIGN_SYLLABLES, by itself, creates a new REASSIGN_SYLLABLES or raises the existing
%      singleton*.
%
%      H = REASSIGN_SYLLABLES returns the handle to a new REASSIGN_SYLLABLES or the handle to
%      the existing singleton*.
%
%      REASSIGN_SYLLABLES('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in REASSIGN_SYLLABLES.M with the given input arguments.
%
%      REASSIGN_SYLLABLES('Property','Value',...) creates a new REASSIGN_SYLLABLES or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before reassign_syllables_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to reassign_syllables_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help reassign_syllables

% Last Modified by GUIDE v2.5 01-Jul-2014 16:40:00

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @reassign_syllables_OpeningFcn, ...
                   'gui_OutputFcn',  @reassign_syllables_OutputFcn, ...
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


% --- Executes just before reassign_syllables is made visible.
function reassign_syllables_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to reassign_syllables (see VARARGIN)

sp = audioread('~/Desktop/test_cluster.wav');
handles.im = PlotSpectrogram(sp,44100);
%a = handles.axes1;

syllableTimes = csvread('~/Desktop/test_cluster.csv');

handles.startstop = zeros(length(syllableTimes),2);
for i = 1:length(syllableTimes)
    if i == 1
        handles.startstop(1,:) = [0 syllableTimes(1)];
    else
        handles.startstop(i,:) = [sum(syllableTimes(1:(i-1))) sum(syllableTimes(1:(i)))]; 
    end
end

handles.startstop = handles.startstop;

handles.drawn = zeros(length(syllableTimes));

%set(a,'ButtonDownFcn','disp(''axes button down'')')
% %the button down fcn will not work until the image hit test is off
set(handles.im,'HitTest','off');
% 
% %now set an image button down fcn
%set(im,'ButtonDownFcn','disp(''image button down'')')
set(handles.im, 'ButtonDownFcn', {@im_ButtonDownFcn, handles});

% 
% %the image funtion will not fire until hit test is turned on
set(handles.im,'HitTest','on'); %now image button function will work

% Choose default command line output for reassign_syllables
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes reassign_syllables wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = reassign_syllables_OutputFcn(hObject, eventdata, handles) 
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


function im_ButtonDownFcn(im, eventdata, handles)
% hObject    handle to im (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = guidata(handles.im);
format shortG
axesHandle = get(handles.im,'Parent');
coordinates = get(axesHandle,'CurrentPoint');
coordinates = coordinates(1,1:2);
x2=coordinates;
X = [0 1];
M = (handles.startstop) > (x2(1)*1000);
[~,idx]=ismember(X,M,'rows'); %need to use an if statement in case of exact boundary click
hold on
if handles.drawn(idx)==0
    handles.drawn(idx)  = fill([handles.startstop(idx)/1000 handles.startstop(idx)/1000 handles.startstop(idx,2)/1000 handles.startstop(idx,2)/1000], [0 22072 22072 0],'k','FaceAlpha',0.4,'HitTest','Off');
    hold on
else
    delete(handles.drawn(idx));
    handles.drawn(idx)=0;
    hold on
end
guidata(im,handles);
