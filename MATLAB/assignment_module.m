function varargout = assignment_module(varargin)
% ASSIGNMENT_MODULE MATLAB code for assignment_module.fig
%      ASSIGNMENT_MODULE, by itself, creates a new ASSIGNMENT_MODULE or raises the existing
%      singleton*.
%
%      H = ASSIGNMENT_MODULE returns the handle to a new ASSIGNMENT_MODULE or the handle to
%      the existing singleton*.
%
%      ASSIGNMENT_MODULE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ASSIGNMENT_MODULE.M with the given input arguments.
%
%      ASSIGNMENT_MODULE('Property','Value',...) creates a new ASSIGNMENT_MODULE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before assignment_module_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to assignment_module_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help assignment_module

% Last Modified by GUIDE v2.5 19-Sep-2014 12:18:28

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @assignment_module_OpeningFcn, ...
    'gui_OutputFcn',  @assignment_module_OutputFcn, ...
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


% --- Executes just before assignment_module is made visible.
function assignment_module_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to assignment_module (see VARARGIN)

% Choose default command line output for assignment_module
handles.output = hObject;

handles.pct = '50';

set(handles.runBatch,'Enable','off');
set(handles.assign_go,'Enable','off');

handles.mindur = '6';
handles.winsize = '41';
handles.gsfloor = '50';

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes assignment_module wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = assignment_module_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


function clusterPercent_Callback(hObject, eventdata, handles)
% hObject    handle to clusterPercent (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of clusterPercent as text
%        str2double(get(hObject,'String')) returns contents of clusterPercent as a double
handles.pct = get(hObject,'String');
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function clusterPercent_CreateFcn(hObject, eventdata, handles)
% hObject    handle to clusterPercent (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in runBatch.
function runBatch_Callback(hObject, eventdata, handles)
% hObject    handle to runBatch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
	if isunix
	set(handles.runBatch,'BackgroundColor','yellow');
	set(handles.text33,'String','Your similarity batch is running. This may take a while. A status bar will spawn in MATLAB Desktop after a few moments.');

	setenv('DYLD_LIBRARY_PATH', '/usr/local/bin/');
	setenv('PATH', [getenv('PATH') ':/usr/local/bin']);

	if ~exist(strcat(handles.assignPath,'voice_results/cut_syllables/'))
	    %setenv('DYLD_LIBRARY_PATH', '/usr/local/bin/');
	    system(['R --slave --args' ' ' handles.assignPathu ' ' handles.assignFileu ' ' ' < ./R/importFeatureBatch.r']);
	    %setenv('PATH', [getenv('PATH') ':/usr/local/bin']);
	    system(['R --slave --args' ' ' strcat(handles.assignPathu,'.acoustic_data.csv') ' ' handles.assignPathu ' ' ' < ./R/getSyllableWavs2.r']);
	end

	handles.refDiru = strrep(handles.refDir, ' ', '\ ');
	system(['R --slave --args ' strcat(handles.refDiru,'/') ' ' handles.pct, ' < ./R/sortClusterReps2.r']);
	pause(.0000001)
	if exist(strcat(handles.assignPath,'voice_results/assignment_similarity_batch_completed.mat'),'file')
	    determineRun(handles.assignPath)
	end
	similarity_batch_parallel_assign_pub(handles.refDir,handles.assignPath,str2num(handles.mindur),str2num(handles.winsize));
	pause(.0000001)
	set(handles.runBatch,'BackgroundColor','green');
	setenv('DYLD_LIBRARY_PATH', '/usr/local/bin/');
	setenv('PATH', [getenv('PATH') ':/usr/local/bin']);
	system(['R --slave --args ' handles.refDiru ' ' handles.assignPathu ' ' handles.gsfloor ' < ./R/assignSyllables.r']);
	pattern = strcat(handles.assignPath,'voice_results/cut_syllables/','*.wav');
	handles.totalSyllables = length(dir(pattern));
	if exist(strcat(handles.assignPath,'voice_results/.NDs.csv'))==2;
	    NDs = csvread(strcat(handles.assignPath,'voice_results/.NDs.csv'));
	    set(handles.n_tied,'String',length(NDs));
	    delete(strcat(handles.assignPath,'voice_results/.NDs.csv'));
	else
	    set(handles.n_tied,'String','0');
	end

	if exist(strcat(handles.assignPath,'voice_results/.NAs.csv'))==2
	    NAs = csvread(strcat(handles.assignPath,'voice_results/.NAs.csv'));
	    set(handles.n_novel,'String',length(NAs));
	    delete(strcat(handles.assignPath,'voice_results/.NAs.csv'));
	else
	    set(handles.n_novel,'String','0');
	end

	set(handles.n_assigned,'String', handles.totalSyllables - (str2num(get(handles.n_tied,'String')) + str2num(get(handles.n_novel,'String'))));
	set(handles.text33,'String',strcat('Now showing assignment breakdown for GS threshold ', strcat('= ', handles.gsfloor), '. Ready to assign.'));
	set(handles.runBatch,'BackgroundColor','green');
	set(handles.assign_go,'Enable','on');
elseif ispc
	set(handles.runBatch,'BackgroundColor','yellow');
	set(handles.text33,'String','Your similarity batch is running. This may take a while. A status bar will spawn in MATLAB Desktop after a few moments.');
	%setenv('DYLD_LIBRARY_PATH', '/usr/local/bin/');
	%setenv('PATH', [getenv('PATH') ':/usr/local/bin']);

	if ~exist(strcat(handles.assignPath,'voice_results/cut_syllables/'))
	    %setenv('DYLD_LIBRARY_PATH', '/usr/local/bin/');
	    system(['R --slave --args' ' ' char(34) handles.assignPath char(34) ' ' char(34) handles.assignFile char(34) ' ' ' < importFeatureBatch.r']);
	    %setenv('PATH', [getenv('PATH') ':/usr/local/bin']);
	    system(['R --slave --args' ' ' char(34) strcat(handles.assignPath,'.acoustic_data.csv') char(34) ' ' char(34) handles.assignPath char(34) ' ' ' < getSyllableWavs2.r']);
	end

	%handles.refDiru = strrep(handles.refDir, ' ', '\ ');
	system(['R --slave --args ' char(34) strcat(handles.refDir,'/') char(34) ' ' char(34) handles.pct char(34) ' < sortClusterReps2.r']);
	pause(.0000001)
	if exist(strcat(handles.assignPath,'assignment_similarity_batch_completed.mat'),'file')
	    determineRun(handles.assignPath)
	end
	similarity_batch_parallel_assign_pub(handles.refDir,handles.assignPath,str2num(handles.mindur),str2num(handles.winsize));
	pause(.0000001)
	set(handles.runBatch,'BackgroundColor','green');
	%setenv('DYLD_LIBRARY_PATH', '/usr/local/bin/');
	%setenv('PATH', [getenv('PATH') ':/usr/local/bin']);
	system(['R --slave --args ' char(34) handles.refDir char(34) ' ' char(34) handles.assignPath char(34) ' ' char(34) handles.gsfloor char(34) ' < assignSyllables.r']);
	pattern = strcat(handles.assignPath,'voice_results/cut_syllables/','*.wav');
	handles.totalSyllables = length(dir(pattern));
	if exist(strcat(handles.assignPath,'voice_results/.NDs.csv'))==2;
	    NDs = csvread(strcat(handles.assignPath,'voice_results/.NDs.csv'));
	    set(handles.n_tied,'String',length(NDs));
	    delete(strcat(handles.assignPath,'voice_results/.NDs.csv'));
	else
	    set(handles.n_tied,'String','0');
	end

	if exist(strcat(handles.assignPath,'voice_results/.NAs.csv'))==2
	    NAs = csvread(strcat(handles.assignPath,'voice_results/.NAs.csv'));
	    set(handles.n_novel,'String',length(NAs));
	    delete(strcat(handles.assignPath,'voice_results/.NAs.csv'));
	else
	    set(handles.n_novel,'String','0');
	end

	set(handles.n_assigned,'String', handles.totalSyllables - (str2num(get(handles.n_tied,'String')) + str2num(get(handles.n_novel,'String'))));
	set(handles.text33,'String',strcat('Now showing assignment breakdown for GS threshold ', strcat('= ', handles.gsfloor), '. Ready to assign.'));
	set(handles.runBatch,'BackgroundColor','green');
	set(handles.assign_go,'Enable','on');
end
guidata(hObject,handles);


% --- Executes on button press in selectcAssignmentDir.
function selectAssignmentDir_Callback(hObject, eventdata, handles)
% hObject    handle to selectAssignmentDir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[handles.assignFile, handles.assignPath] = uigetfile(strcat('cd/*.xls'),'Select feature batch.');
str = strsplit(handles.assignPath,'/');
%set(handles.assignDirString,'String',strcat(handles.assignPath,handles.assignFile));
set(handles.assignDirString,'String',str(length(str)-1));
handles.assignFileu = strrep(handles.assignFile,' ','\ ');
handles.assignPathu = strrep(handles.assignPath,' ','\ ');

str = strsplit(handles.assignFile,'.');
q = str{2};
if strcmp(q,'xls')
    handles.validFB = 1;
    set(handles.text33,'String','Valid feature batch selected.');
else
    handles.validFB = 0;
    set(handles.text33,'String','Invalid feature batch selected. Please choose a .xls file.');
end

if isfield(handles,'validFB') & isfield(handles,'validRD')
    if handles.validFB + handles.validRD == 2
        set(handles.text33,'String','Valid assignment feature batch and valid reference directory selected. Similarity batch can now be run.')
        set(handles.runBatch,'Enable','on');
        %if(exist(strcat(
    elseif handles.validFB == 0 & handles.validRD == 1
        set(handles.text33,'String','Invalid feature batch selected. Please choose a .xls file.');
    elseif handles.validFB == 1 & handles.validRD == 0
        set(handles.text33,'String','Invalid reference directory selected. Please make sure the audio in your selected directory has been clustered.')
    end
elseif ~isfield(handles,'validFB') & isfield(handles,'validRD')
    set(handles.text33,'String','Valid reference directory chosen. Please choose a feature batch to assign to these clusters.');
elseif isfield(handles,'validFB') & ~isfield(handles,'validRD')
    set(handles.text33,'String','Valid assignment feature batch chosen. Please choose a reference directory.');
end
guidata(hObject,handles);


% --- Executes on button press in selectRefDir.
function selectRefDir_Callback(hObject, eventdata, handles)
% hObject    handle to selectRefDir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isunix
	handles.refDir = uigetdir(cd,'Select directory containing existing clusters.');
	handles.refDiru = strrep(handles.refDir,' ','\ ');
	set(handles.refDirString,'String',handles.refDir);

	if exist(strcat(handles.refDir,'/voice_results/workspace.Rdata')) || exist(strcat(handles.refDir,'/voice_results/assign_workspace.Rdata')) & exist(strcat(handles.refDir,'/voice_results/sorted_syllables/')) || exist(strcat(handles.refDir,'/voice_results/sorted_syllables_assigned/'))
	    handles.validRD = 1;
	else
	    handles.validRD = 0;
	end

	if isfield(handles,'validFB') & isfield(handles,'validRD')
	    if handles.validFB + handles.validRD == 2
	        set(handles.text33,'String','Valid assignment feature batch and valid reference directory selected. Similarity batch can now be run.')
	        set(handles.runBatch,'Enable','on');
	        if exist(strcat(handles.assignPath,'voice_results/assignment_similarity_batch_completed.mat')) ~=0
	            load(strcat(handles.assignPath,'voice_results/assignment_similarity_batch_completed.mat'))
	            if strmatch(folder1,handles.refDir) == 1 & strmatch(Filedir2,handles.assignPath) == 1
	                set(handles.text33,'String','These two sessions have already been run against each other. Proceed to assignment');
	                set(handles.runBatch,'BackgroundColor','green');
	                setenv('DYLD_LIBRARY_PATH', '/usr/local/bin/');
	                setenv('PATH', [getenv('PATH') ':/usr/local/bin']);
	                system(['R --slave --args ' handles.refDiru ' ' handles.assignPathu ' ' handles.gsfloor ' < ./R/assignSyllables.r']);
	                pattern = strcat(handles.assignPath,'voice_results/cut_syllables/','*.wav');
	                handles.totalSyllables = length(dir(pattern));
	                if exist(strcat(handles.assignPath,'voice_results/NDs.csv'))==2;
	                    NDs = csvread(strcat(handles.assignPath,'voice_results/NDs.csv'));
	                    set(handles.n_tied,'String',length(NDs));
	                    delete(strcat(handles.assignPath,'voice_results/NDs.csv'));
	                else
	                    set(handles.n_tied,'String','0');
	                end
                
	                if exist(strcat(handles.assignPath,'voice_results/NAs.csv'))==2
	                    NAs = csvread(strcat(handles.assignPath,'voice_results/NAs.csv'));
	                    set(handles.n_novel,'String',length(NAs));
	                    delete(strcat(handles.assignPath,'voice_results/NAs.csv'));
	                else
	                    set(handles.n_novel,'String','0');
	                end
                
	                set(handles.n_assigned,'String', handles.totalSyllables - (str2num(get(handles.n_tied,'String')) + str2num(get(handles.n_novel,'String'))));
	                set(handles.text33,'String',strcat('Now showing assignment breakdown for GS threshold ', strcat('= ', handles.gsfloor), '. Ready to assign.'));
	                set(handles.runBatch,'BackgroundColor','green');
	                set(handles.assign_go,'Enable','on');
	            end
	        end
        
	    elseif handles.validFB == 0 & handles.validRD == 1
	        set(handles.text33,'String','Invalid feature batch selected. Please choose a .xls file.');
	    elseif handles.validFB == 1 & handles.validRD == 0
	        set(handles.text33,'String','Invalid reference directory selected. Please make sure the audio in your selected directory has been clustered.')
	    end
	elseif ~isfield(handles,'validFB') & isfield(handles,'validRD')
	    set(handles.text33,'String','Valid reference directory chosen. Please choose a feature batch to assign to these clusters.');
	elseif isfield(handles,'validFB') & ~isfield(handles,'validRD')
	    set(handles.text33,'String','Valid assignment feature batch chosen. Please choose a reference directory.');
	end
elseif ispc
	handles.refDir = uigetdir(cd,'Select directory containing existing clusters.');
	%handles.refDiru = strrep(handles.refDir,' ','\ ');
	handles.refDir = strrep(handles.refDir,'\','/');
	set(handles.refDirString,'String',handles.refDir);

	if exist(strcat(handles.refDir,'voice_results/workspace.Rdata')) || exist(strcat(handles.refDir,'voice_results/assign_workspace.Rdata')) & exist(strcat(handles.refDir,'voice_results/sorted_syllables/')) || exist(strcat(handles.refDir,'voice_results/sorted_syllables_assigned/'))
	    handles.validRD = 1;
	else
	    handles.validRD = 0;
	end

	if isfield(handles,'validFB') & isfield(handles,'validRD')
	    if handles.validFB + handles.validRD == 2
	        set(handles.text33,'String','Valid assignment feature batch and valid reference directory selected. Similarity batch can now be run.')
	        set(handles.runBatch,'Enable','on');
	        if exist(strcat(handles.assignPath,'voice_results/assignment_similarity_batch_completed.mat')) ~=0
	            load(strcat(handles.assignPath,'voice_results/assignment_similarity_batch_completed.mat'))
	            if strmatch(folder1,handles.refDir) == 1 & strmatch(Filedir2,handles.assignPath) == 1
	                set(handles.text33,'String','These two sessions have already been run against each other. Proceed to assignment');
	                set(handles.runBatch,'BackgroundColor','green');
	                system(['R --slave --args ' char(34) handles.refDir char(34) ' ' char(34) handles.assignPath char(34) ' ' handles.gsfloor ' < assignSyllables.r']);
	                pattern = strcat(handles.assignPath,'voice_results/cut_syllables/','*.wav');
	                handles.totalSyllables = length(dir(pattern));
	                if exist(strcat(handles.assignPath,'NDs.csv'))==2;
	                    NDs = csvread(strcat(handles.assignPath,'NDs.csv'));
	                    set(handles.n_tied,'String',length(NDs));
	                    delete(strcat(handles.assignPath,'NDs.csv'));
	                else
	                    set(handles.n_tied,'String','0');
	                end
                
	                if exist(strcat(handles.assignPath,'NAs.csv'))==2
	                    NAs = csvread(strcat(handles.assignPath,'NAs.csv'));
	                    set(handles.n_novel,'String',length(NAs));
	                    delete(strcat(handles.assignPath,'NAs.csv'));
	                else
	                    set(handles.n_novel,'String','0');
	                end
                
	                set(handles.n_assigned,'String', handles.totalSyllables - (str2num(get(handles.n_tied,'String')) + str2num(get(handles.n_novel,'String'))));
	                set(handles.text33,'String',strcat('Now showing assignment breakdown for GS threshold ', strcat('= ', handles.gsfloor), '. Ready to assign.'));
	                set(handles.runBatch,'BackgroundColor','green');
	                set(handles.assign_go,'Enable','on');
	            end
	        end
        
	    elseif handles.validFB == 0 & handles.validRD == 1
	        set(handles.text33,'String','Invalid feature batch selected. Please choose a .xls file.');
	    elseif handles.validFB == 1 & handles.validRD == 0
	        set(handles.text33,'String','Invalid reference directory selected. Please make sure the audio in your selected directory has been clustered.')
	    end
    
	elseif ~isfield(handles,'validFB') & isfield(handles,'validRD')
	    set(handles.text33,'String','Valid reference directory chosen. Please choose a feature batch to assign to these clusters.');
	elseif isfield(handles,'validFB') & ~isfield(handles,'validRD')
	    set(handles.text33,'String','Valid assignment feature batch chosen. Please choose a reference directory.');
	end
end
guidata(hObject,handles);


% --- Executes on button press in assign_go.
function assign_go_Callback(hObject, eventdata, handles)
% hObject    handle to assign_go (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isunix
	
	set(handles.text33,'String','Preparing assignment pipeline. The interface will launch momentarily.');

	pause(.0000001);

	%perform assignments per user dictated gs floor
	system(['R --slave --args ' handles.refDiru ' ' handles.assignPathu ' ' handles.gsfloor ' < ./R/assignSyllables.r']);

	%figure out which pathway to take for analysis:
	%All syllables have been assigned a cluster with no ties or novel syllables; proceed to reassignment
	if str2num(get(handles.n_assigned,'String')) == handles.totalSyllables & str2num(get(handles.n_tied,'String')) == 0 & str2num(get(handles.n_novel,'String')) == 0
	    %insert code to launch reassignment module, then finalize things
	    system(['R --slave --args ' handles.refDiru ' < ./R/getClusterIDs.r']); %get cluster names for ref directory
	    system(['R --slave --args ' handles.assignPathu ' < ./R/getClusterIDs.r']);
	    system(['R --slave --args ' handles.assignPathu ' ' handles.refDiru ' < ./R/finalizeClustersAssignedNDs.r']); %prep for reassignment
	    close
	    reassign_syllables({handles.assignPath},{handles.refDir},{1});
	elseif str2num(get(handles.n_assigned,'String')) + str2num(get(handles.n_tied,'String')) == handles.totalSyllables & str2num(get(handles.n_assigned,'String')) ~= 0 & str2num(get(handles.n_tied,'String')) ~= 0
	    %...or all syllables have been assigned to a cluster or need a tiebreak
	    %insert code to launch tiebreak module; make tiebreak module launch
	    %reassignment to finalize
	    system(['R --slave --args ', handles.assignPathu ' '  handles.refDiru ' < ./R/getTieSpectrogramsContext2.r']);
	    tiebreaking_module({handles.assignPath},{handles.refDir},{get(handles.n_novel,'String')},{1});
	    %think about if NAs arise during tiebreaking...
	elseif str2num(get(handles.n_assigned,'String')) + str2num(get(handles.n_novel,'String')) == handles.totalSyllables & str2num(get(handles.n_novel,'String')) ~= 0
	    %...or all syllables are either assigned or deemed novel
	    %insert code to launch novelty module; then novel launches
	    %reassignment, then finalize
	    novelty_module({handles.assignPath},{handles.refDir});
	else
	    %...or there are all of the above
	    %insert code to tiebreak, then novelty, then reassign, then finalize
	    system(['R --slave --args ', handles.assignPathu ' '  handles.refDiru ' < ./R/getTieSpectrogramsContext2.r']);
	    tiebreaking_module({handles.assignPath},{handles.refDir},{get(handles.n_novel,'String')},{1});
	end
elseif ispc
	set(handles.text33,'String','Preparing assignment pipeline. The interface will launch momentarily.');

	pause(.0000001);

	%perform assignments per user dictated gs floor
	system(['R --slave --args ' char(34) handles.refDir char(34) ' ' char(34) handles.assignPath char(34) ' ' char(34) handles.gsfloor char(34) ' < assignSyllables.r']);

	%figure out which pathway to take for analysis:
	%All syllables have been assigned a cluster with no ties or novel syllables; proceed to reassignment
	if str2num(get(handles.n_assigned,'String')) == handles.totalSyllables & str2num(get(handles.n_tied,'String')) == 0 & str2num(get(handles.n_novel,'String')) == 0
	    %insert code to launch reassignment module, then finalize things
	    system(['R --slave --args ' char(34) handles.refDir char(34) ' < getClusterIDs.r']); %get cluster names for ref directory
	    system(['R --slave --args ' char(34) handles.assignPath char(34) ' < getClusterIDs.r']);
	    system(['R --slave --args ' char(34) handles.assignPath char(34) ' ' char(34) handles.refDir char(34) ' < finalizeClustersAssignedNDs.r']); %prep for reassignment
	    close
	    reassign_syllables({handles.assignPath},{handles.refDir},{1});
	elseif str2num(get(handles.n_assigned,'String')) + str2num(get(handles.n_tied,'String')) == handles.totalSyllables & str2num(get(handles.n_assigned,'String')) ~= 0 & str2num(get(handles.n_tied,'String')) ~= 0
	    %...or all syllables have been assigned to a cluster or need a tiebreak
	    %insert code to launch tiebreak module; make tiebreak module launch
	    %reassignment to finalize
	    system(['R --slave --args ', char(34) handles.assignPath char(34) ' ' char(34) handles.refDir char(34) ' < getTieSpectrogramsContext2.r']);
	    %resume at breakpoint
	    tiebreaking_module({handles.assignPath},{handles.refDir},{get(handles.n_novel,'String')},{1});
	    %think about if NAs arise during tiebreaking...
	elseif str2num(get(handles.n_assigned,'String')) + str2num(get(handles.n_novel,'String')) == handles.totalSyllables & str2num(get(handles.n_novel,'String')) ~= 0
	    %...or all syllables are either assigned or deemed novel
	    %insert code to launch novelty module; then novel launches
	    %reassignment, then finalize
	    novelty_module({handles.assignPath},{handles.refDir});
	else
	    %...or there are all of the above
	    %insert code to tiebreak, then novelty, then reassign, then finalize
	    system(['R --slave --args ', char(34) handles.assignPath char(34) ' '  char(34) handles.refDir char(34) ' < getTieSpectrogramsContext2.r']); %needs char(34)
	    tiebreaking_module({handles.assignPath},{handles.refDir},{get(handles.n_novel,'String')},{1});
	end
end



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double
if isunix
	set(handles.text33,'String','Calculating assignment breakdown...please wait.');
	pause(.0000001)
	handles.gsfloor = get(hObject,'String');
	if str2num(handles.gsfloor) > 99 | str2num(handles.gsfloor) < 1
	    h = errordlg('Enter a GS floor from 1 to 99');
	end
	setenv('DYLD_LIBRARY_PATH', '/usr/local/bin/');
	setenv('PATH', [getenv('PATH') ':/usr/local/bin']);
	system(['R --slave --args ' handles.refDiru ' ' handles.assignPathu ' ' handles.gsfloor ' < ./R/assignSyllables.r']);
	pattern = strcat(handles.assignPath,'voice_results/cut_syllables/','*.wav');
	handles.totalSyllables = length(dir(pattern));

	if exist(strcat(handles.assignPath,'NDs.csv'))==2;
	    NDs = csvread(strcat(handles.assignPath,'NDs.csv'));
	    set(handles.n_tied,'String',length(NDs));
	    delete(strcat(handles.assignPath,'NDs.csv'));
	else
	    set(handles.n_tied,'String','0');
	end

	if exist(strcat(handles.assignPath,'NAs.csv'))==2
	    NAs = csvread(strcat(handles.assignPath,'NAs.csv'));
	    set(handles.n_novel,'String',length(NAs));
	    delete(strcat(handles.assignPath,'NAs.csv'));
	else
	    set(handles.n_novel,'String','0');
	end

	set(handles.n_assigned,'String', handles.totalSyllables - (str2num(get(handles.n_tied,'String')) + str2num(get(handles.n_novel,'String'))));
	set(handles.text33,'String',strcat('Now showing assignment breakdown for GS threshold ', strcat('= ', handles.gsfloor), '. Ready to assign.'));
elseif ispc
	set(handles.text33,'String','Calculating assignment breakdown...please wait.');
	pause(.0000001)
	handles.gsfloor = get(hObject,'String');
	if str2num(handles.gsfloor) > 99 | str2num(handles.gsfloor) < 1
	    h = errordlg('Enter a GS floor from 1 to 99');
	end
	%setenv('DYLD_LIBRARY_PATH', '/usr/local/bin/');
	%setenv('PATH', [getenv('PATH') ':/usr/local/bin']);
	system(['R --slave --args ' char(34) handles.refDir char(34) ' ' char(34) handles.assignPath char(34) ' ' char(34) handles.gsfloor char(34) ' < assignSyllables.r']);
	pattern = strcat(handles.assignPath,'voice_results/cut_syllables/','*.wav');
	handles.totalSyllables = length(dir(pattern));
	if exist(strcat(handles.assignPath,'NDs.csv'))==2;
	    NDs = csvread(strcat(handles.assignPath,'NDs.csv'));
	    set(handles.n_tied,'String',length(NDs));
	    delete(strcat(handles.assignPath,'NDs.csv'));
	else
	    set(handles.n_tied,'String','0');
	end

	if exist(strcat(handles.assignPath,'NAs.csv'))==2
	    NAs = csvread(strcat(handles.assignPath,'NAs.csv'));
	    set(handles.n_novel,'String',length(NAs));
	    delete(strcat(handles.assignPath,'NAs.csv'));
	else
	    set(handles.n_novel,'String','0');
	end

	set(handles.n_assigned,'String', handles.totalSyllables - (str2num(get(handles.n_tied,'String')) + str2num(get(handles.n_novel,'String'))));
	set(handles.text33,'String',strcat('Now showing assignment breakdown for GS threshold ', strcat('= ', handles.gsfloor), '. Ready to assign.'));
end	
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



function edit5_Callback(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit5 as text
%        str2double(get(hObject,'String')) returns contents of edit5 as a double
handles.mindur = get(hObject,'String');
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function edit5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit6_Callback(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit6 as text
%        str2double(get(hObject,'String')) returns contents of edit6 as a double
handles.mindur = get(hObject,'String');
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function edit6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
