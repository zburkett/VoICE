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

% Last Modified by GUIDE v2.5 06-Oct-2014 16:15:03

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

setenv('DYLD_LIBRARY_PATH', '/usr/local/bin/');
setenv('PATH', [getenv('PATH') ':/usr/local/bin']);

set(handles.uipanel8,'Visible','off');

handles.path = varargin{1}{1};
sz = size(handles.path);
if(handles.path(sz(2)) ~= '/')
    handles.path = strcat(handles.path,'/');
end
handles.pathu = strrep(handles.path,' ','\ ');
handles.clusterOut = 'Select a cluster...';
handles.newCluster = 'Create a cluster...';

handles.assignRun = varargin{3}{1};

handles.refDir = varargin{2}{1};
handles.refDiru = strrep(handles.refDir,' ','\ ');

if exist(strcat(handles.path,'sorted_syllables_assigned/'))
    set(handles.uipanel7,'Visible','Off');
elseif exist(strcat(handles.path,'/sorted_syllables_assigned'))
    set(handles.uipanel7,'Visible','Off');
end

if handles.assignRun == 1
    system(['R --slave --args ' handles.pathu ' < ./R/getClusterIDs.r']);
    fidPupil = fopen(strcat(handles.path,'usedClusters.txt'));
    if(fidPupil == -1)
        fidPupil = fopen(strcat(handles.path,'/usedClusters.txt'));
    end
    s = textscan(fidPupil,'%s','Delimiter','\n');
    sPupil = strrep(s{1}(:,1),'"','');
    system(['R --slave --args ' handles.refDiru ' < ./R/getClusterIDs.r']);
    fidTutor = fopen(strcat(handles.refDir,'/usedClusters.txt'));
    if(fidTutor == -1)
        fidTutor = fopen(strcat(handles.refDir,'/usedClusters.txt'));
    end
    s = textscan(fidTutor,'%s','Delimiter','\n');
    sTutor = strrep(s{1}(:,1),'"','');
    [I, J] = setdiff(sTutor,sPupil);
    
    if ~isempty(I)
        set(handles.uipanel8,'Visible','On');
        set(handles.uipanel7,'Visible','Off');
        set(handles.popupmenu8,'String',{'Choose a cluster...',I{:}});
    end
    
    %update unusedColors.txt
    system(['R --slave --args ' handles.refDiru ' ' handles.pathu ' < ./R/updateColors.r']);
    system(['R --slave --args ' handles.pathu ' < ./R/recreateClusters2.r']);
end

fid = fopen(strcat(handles.path,'/unusedColors.txt'));
s = textscan(fid,'%s','Delimiter','\n');
s = strrep(s{1}(:,1),'"','');
set(handles.popupmenu3,'String',{'Create a cluster...',s{:}});

%read in duration information for syllables, calculate start/stop for each
%syllable in each cluster

handles.clusterNames = dir(strcat(handles.path,'cluster_tables_mat/*.csv'));
for i = 1:length(handles.clusterNames)
    handles.clusterNames(i).name = strrep(handles.clusterNames(i).name,'.csv','');
    handles.clusterNames(i).starts = csvread(strcat(handles.path,'cluster_tables_mat/',handles.clusterNames(i).name,'.csv'));
    %handles.clusterNames(i).starts = dlmread(strcat(handles.path,'cluster_tables_mat/',handles.clusterNames(i).name,'.csv'),',');
    handles.clusterNames(i).starts = [handles.clusterNames(i).starts zeros(length(handles.clusterNames(i).starts),1)];
    handles.clusterNames(i).starts(1,2) = handles.clusterNames(i).starts(1,1);
    handles.clusterNames(i).starts(1,1) = 0;
    cndim = size(handles.clusterNames(i).starts);
    if cndim(1) > 1
        for j = 2:length(handles.clusterNames(i).starts)
            ci = handles.clusterNames(i).starts(j,1);
            handles.clusterNames(i).starts(j,1) = handles.clusterNames(i).starts(j-1,2)+0.01;
            handles.clusterNames(i).starts(j,2) = handles.clusterNames(i).starts(j,1)+ci+0.01;
        end
    end
    handles.clusterNames(i).drawn = zeros(1,length(handles.clusterNames(i).starts));
end

ad = [];
for i = 1:length(handles.clusterNames)
    if i ~= 1
        ad = [ad getappdata(0,'axesDrawn')];
    end
    addAxis(i,handles,handles.clusterNames(i).name)
end

handles.axesDrawn = getappdata(0,'axesDrawn');

for i = 1:length(handles.clusterNames)
    set(handles.axesDrawn(i),'HitTest','off');
    set(handles.axesDrawn(i),'ButtonDownFcn', {@im_ButtonDownFcn, handles});
    set(handles.axesDrawn(i),'HitTest','on');
end

set(handles.popupmenu1,'String',{'Select a cluster...',handles.clusterNames.name})
set(handles.popupmenu5,'String',{'Select a cluster...',handles.clusterNames.name})
set(handles.popupmenu7,'Enable','off');
set(handles.pushbutton3,'Enable','off');

% Choose default command line output for reassign_syllables
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes reassign_syllables wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% --- Executes during object creation, after setting all properties.
function hPan_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hPan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

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

%reassign syllables that are highlighted

%determine which syllables are highlighted

set(handles.pushbutton1,'BackgroundColor','Yellow');
set(handles.text6,'String','Reassigning syllables. Please wait...');
pause(.000001);

reassign = struct;
for i = 1:length(handles.clusterNames)
    reassign.(handles.clusterNames(i).name) = handles.clusterNames(i).drawn>0;
end

if exist(strcat(handles.path,'reassign/'))
    rmdir(strcat(handles.path,'reassign/'),'s');
end

for i = 1:length(fieldnames(reassign(1)))
    fns = fieldnames(reassign(1));
    fn = fns(i);
    if i == 1
        mkdir(strcat(handles.path,'reassign/'));
    end
    
    dlmwrite(strcat(handles.path,'reassign/',fn{1},'.csv'),reassign(1).(fn{1}),',');
end

%if dropdown is unselected AND manual cluster assignment is at default OR
%empty, throw an error
if strcmp(handles.clusterOut, 'Select a cluster...') & (strcmp(handles.newCluster,'Create a cluster...') || isempty(handles.newCluster))
    h = errordlg('No destination cluster selected or input. Try again.');
    
    %if dropdown is selected AND manual cluster is not default or blank, throw an
    %error
elseif ~strcmp(handles.clusterOut, 'Select a cluster...') & (~strcmp(handles.newCluster,'Create a cluster...') & ~isempty(handles.newCluster))
    h = errordlg('Both an existing cluster and a novel cluster are selected. Choose one or the other.');
    
    %if dropdown is not empty AND manual cluster is default OR empty,
    %classify as dropdown
elseif ~strcmp(handles.clusterOut, 'Select a cluster...') & (strcmp(handles.newCluster,'Create a cluster...') || isempty(handles.newCluster))
    %call R code to edit workspace to reflect reassignments
    setenv('DYLD_LIBRARY_PATH', '/usr/local/bin/');
    pathu = strrep(handles.path,' ','\ ');
    system(['R --slave --args ' pathu ' ' handles.clusterOut ' ' '< ./R/changeClusterAssignmentGUI.r']);

    %recreate wav files following reassignment
    setenv('PATH', [getenv('PATH') ':/usr/local/bin']);
    if handles.assignRun == 0
        system(['R --slave --args ' pathu ' < ./R/recreateClusters.r']);
    elseif handles.assignRun == 1
        system(['R --slave --args ' pathu ' < ./R/recreateClusters2.r']);
    end

    %close gui window; relaunch new one 
    close
    reassign_syllables({handles.path},{handles.refDir},{handles.assignRun})
    
    %if dropdown is default AND manual cluster is not default and not
    %empty, classify as manual
elseif strcmp(handles.clusterOut, 'Select a cluster...') & (~strcmp(handles.newCluster,'Default') & ~isempty(handles.newCluster))
    %call R code to edit workspace to reflect reassignments
    setenv('DYLD_LIBRARY_PATH', '/usr/local/bin/');
    pathu = strrep(handles.path,' ','\ ');
    system(['R --slave --args ' pathu ' ' handles.newCluster ' ' '< ./R/changeClusterAssignmentGUI.r']);

    %recreate wav files following reassignment
    setenv('PATH', [getenv('PATH') ':/usr/local/bin']);
    if handles.assignRun == 0
        system(['R --slave --args ' pathu ' < ./R/recreateClusters.r']);
    elseif handles.assignRun == 1
        system(['R --slave --args ' pathu ' < ./R/recreateClusters2.r']);
    end

    %close gui window; relaunch new one 
    close
    reassign_syllables({handles.path},{handles.refDir},{handles.assignRun})
end
  
% --- Executes on slider movement.
function Sld_Callback(hObject, eventdata, handles)
% hObject    handle to Sld (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
onSlide(handles.Sld,[],handles.hPan);

% --- Executes during object creation, after setting all properties.
function Sld_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Sld (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function im_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to im (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%handles = guidata(handles.im);
currentAxes = get(gcf,'CurrentAxes');
a = findall(handles.hPan,'type','axes');
b = 1:length(a);
b = fliplr(b);
c = currentAxes==a;
d = b(c);
format shortG
handles = guidata(handles.axesDrawn(d));
%axesHandle = get(handles.axesDrawn(d),'Parent'); %for PlotSpectrogram.m
axesHandle = handles.axesDrawn(d);
coordinates = get(axesHandle,'CurrentPoint');
coordinates = coordinates(1,1:2);
x2=coordinates;
X = [0 1];
M = (handles.clusterNames(d).starts) > (x2(1)*1000);
[~,idx]=ismember(X,M,'rows');
hold on
if handles.clusterNames(d).drawn(idx) == 0
    handles.clusterNames(d).drawn(idx)  = fill([handles.clusterNames(d).starts(idx)/1000 handles.clusterNames(d).starts(idx)/1000 handles.clusterNames(d).starts(idx,2)/1000 handles.clusterNames(d).starts(idx,2)/1000], [0 22072 22072 0],'k','FaceAlpha',0.4,'HitTest','Off');
    hold on
else
    delete(handles.clusterNames(d).drawn(idx));
    handles.clusterNames(d).drawn(idx)=0;
    hold on
end
guidata(handles.axesDrawn(d),handles);

% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1
contents = cellstr(get(hObject,'String'));
handles.clusterOut = contents{get(hObject,'Value')};
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

function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double
edit2data = get(hObject,'String');
handles.newCluster = edit2data;
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

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.assignRun == 1
    if handles.pathu(end)~='/'
        handles.pathu = strcat(handles.pathu,'/');
    end
    if handles.refDiru(end)~='/'
        handles.refDiru = strcat(handles.refDiru,'/');
    end
    system(['R --slave --args ' handles.pathu ' ' handles.refDiru ' < ./R/calculateSyntaxSimilarity.r']);
    close
elseif handles.assignRun == 0
    system(['R --slave --args ' handles.pathu ' < ./R/finalizeClusters.r']);
    close
end

% --- Executes on selection change in popupmenu3.
function popupmenu3_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu3
contents = cellstr(get(hObject,'String'));
handles.newCluster = contents{get(hObject,'Value')};
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function popupmenu3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in popupmenu5.
function popupmenu5_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu5 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu5
contents = cellstr(get(hObject,'String'));
handles.toSplit = contents{get(hObject,'Value')};
dirName = strcat(handles.path,'sorted_syllables/',handles.toSplit);
pattern = fullfile(dirName,'*.wav');
maxN = length(dir(pattern));
if maxN > 1
    set(handles.popupmenu7,'String',2:maxN);
    set(handles.popupmenu7,'Enable','on');
else
    h = errordlg('The selected cluster contains only 1 syllable and cannot be subtyped.');
end
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function popupmenu5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in popupmenu7.
function popupmenu7_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu7 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu7
contents = cellstr(get(hObject,'String'));
splitN = contents{get(hObject,'Value')};
handles.splitN = splitN;
set(handles.pushbutton3,'Enable','on');
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function popupmenu7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.text6,'String','Probing for subtypes. Please wait...')
set(handles.pushbutton3,'BackgroundColor','Yellow');
pause(.000001)
system(['R --slave --args ' handles.pathu ' ' handles.toSplit ' ' handles.splitN ' ' '< ./R/subtypeStatic.r']);
setenv('PATH', [getenv('PATH') ':/usr/local/bin']);
system(['R --slave --args ' handles.pathu ' < ./R/recreateClusters.r']);
close
reassign_syllables({handles.path},{handles.refDir},{handles.assignRun});

% --- Executes on selection change in popupmenu8.
function popupmenu8_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu8 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu8
contents = cellstr(get(hObject,'String'));
missing = contents{get(hObject,'Value')};
handles.missing = missing;
if exist(strcat(handles.refDir,'/joined_clusters/',handles.missing,'.wav'),'file')==2
    [wav, Fs] = wavread(strcat(handles.refDir,'/joined_clusters/',handles.missing,'.wav'));
else
    [wav, Fs] = wavread(strcat(handles.refDir,'/joined_clusters_assigned/',handles.missing,'.wav'));
end
h2=figure();
PlotSpectrogram(wav,Fs);
title(handles.missing);
%close(h2);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function popupmenu8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
reassign = struct;
for i = 1:length(handles.clusterNames)
    reassign.(handles.clusterNames(i).name) = handles.clusterNames(i).drawn>0;
end

if exist(strcat(handles.path,'reassign/'))
    rmdir(strcat(handles.path,'reassign/'),'s');
end

for i = 1:length(fieldnames(reassign(1)))
    fns = fieldnames(reassign(1));
    fn = fns(i);
    if i == 1
        mkdir(strcat(handles.path,'reassign/'));
    end
    
    dlmwrite(strcat(handles.path,'reassign/',fn{1},'.csv'),reassign(1).(fn{1}),',');
end

%call R code to edit workspace to reflect reassignments
setenv('DYLD_LIBRARY_PATH', '/usr/local/bin/');
pathu = strrep(handles.path,' ','\ ');
system(['R --slave --args ' pathu ' ' handles.missing ' ' '< ./R/changeClusterAssignmentGUI.r']);

%recreate wav files following reassignment
setenv('PATH', [getenv('PATH') ':/usr/local/bin']);
system(['R --slave --args ' pathu ' < ./R/recreateClusters2.r']);

system(['R --slave --args ' pathu ' < ./R/getClusterIDs.r']);

%close gui window; relaunch new one
close
reassign_syllables({handles.path},{handles.refDir},{handles.assignRun})

% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
setenv('PATH', [getenv('PATH') ':/usr/local/bin']);
pathu = strrep(handles.path,' ','\ ');
[sylls]=getSyllIDs(pathu,struct(handles));
set(handles.text6,'String',sylls);
pause(.000001);


% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
setenv('DYLD_LIBRARY_PATH', '/usr/local/bin/');
pathu = strrep(handles.path,' ','\ ');
[deletedSylls]=getSyllIDs(pathu,struct(handles));
deleteSyllable(deletedSylls,pathu)
close
reassign_syllables({handles.path},{handles.refDir},{handles.assignRun})