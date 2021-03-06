function varargout = voice(varargin)
% VOICE MATLAB code for voice.fig
%      VOICE, by itself, creates a new VOICE or raises the existing
%      singleton*.
%
%      H = VOICE returns the handle to a new VOICE or the handle to
%      the existing singleton*.
%
%      VOICE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in VOICE.M with the given input arguments.
%
%      VOICE('Property','Value',...) creates a new VOICE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before voice_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to voice_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help voice

% Last Modified by GUIDE v2.5 06-Jan-2015 13:22:53

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @voice_OpeningFcn, ...
                   'gui_OutputFcn',  @voice_OutputFcn, ...
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


% --- Executes just before voice is made visible.
function voice_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to voice (see VARARGIN)

installdir = which('voice.m');

if isunix
    f = findstr('/',installdir);
    f= f(1:(length(f)-1));
    installdir = installdir(1:max(f));
    cd(installdir);
    
    PATH = getenv('PATH');
	setenv('PATH',[PATH ':/usr/local/bin']);
    
    %check for R installation
    [status,result] = system('which Rscript');
    if ~exist(strcat(result))
        error('No R installation detected.')
    end
    
    %check for SoX installation
    [status,result] = system('which sox');
    if ~exist(strcat(result))
        error('No SoX installation detected.')
    end
    
    %check for ImageMagick installation
    [status,result] = system('which convert');
    if ~exist(strcat(result))
        error('No ImageMagick installation detected.')
    end
	
    %check for Perl installation
    % [status,result] = system('which perl');
 %    if ~exist(strcat(result))
 %        error('No Perl installation detected.')
 %    end
    
elseif ispc
    f = findstr('\',installdir);
    f= f(1:(length(f)-1));
    installdir = installdir(1:max(f));
    cd(installdir);
    
    %check for R installation
    [status,result] = system('where Rscript');
    if ~exist(strcat(result))
        error('No R installation detected. Please install R and try again.')
    end
	
    %check for Perl installation
    % [status0,result0] = system('where perl');
%     if ~status0 == 0
%         if exist('.perlFound')
%             pathstr = char(textread('.perlFound','%q'));
%             setenv('PATH',[getenv('PATH') strcat(';',pathstr)]);
%         elseif ~status0 == 0 & ~exist('.perlFound')
%             disp('Perl not found in system path, checking for installation...')
%             [status,result] = system('cd \ & dir /b/s perl.exe');
%             if ~exist(strcat(result))
%                 error('No SoX installation detected in Program Files. Install Perl and try again.')
%             elseif exist(strcat(result))
%                 disp('Found SoX install, adding to PATH...')
%                 [pathstr,name,ext] = fileparts(result);
%                 setenv('PATH',[getenv('PATH') strcat(';',pathstr)]);
%                 [status3,result3] = system('where sox');
%                 if ~status3 == 0
%                     disp('Unable to add Perl to PATH. Please remedy this yourself.')
%                 else
%                     disp('Added Perl to PATH. Proceeding.')
%                     fid = fopen('.perlFound','wt');
%                     out = strrep(pathstr,'\','\\');
%                     fprintf(fid,[char(34) out char(34)]);
%                     fclose(fid);
%                     system('attrib +h .perlFound');
%                 end
%             end
%         end
%     end
    
    %check for SoX installation
    [status0,result0] = system('where sox');
    if ~status0 == 0
        if exist('.soxFound')
            pathstr = char(textread('.soxFound','%q'));
            setenv('PATH',[getenv('PATH') strcat(';',pathstr)]);
        elseif ~status0 == 0 & ~exist('.soxFound')
            disp('SoX not found in system path, checking for installation...')
            [status,result] = system('cd \"Program Files" & dir /b/s sox.exe');
            if ~exist(strcat(result))
                error('No SoX installation detected in Program Files. Install SoX and try again.')
            elseif exist(strcat(result))
                disp('Found SoX install, adding to PATH...')
                [pathstr,name,ext] = fileparts(result);
                setenv('PATH',[getenv('PATH') strcat(';',pathstr)]);
                [status3,result3] = system('where sox');
                if ~status3 == 0
                    disp('Unable to add SoX to PATH. Please remedy this yourself.')
                else
                    disp('Added SoX to PATH. Proceeding.')
                    fid = fopen('.soxFound','wt');
                    out = strrep(pathstr,'\','\\');
                    fprintf(fid,[char(34) out char(34)]);
                    fclose(fid);
                    system('attrib +h .soxFound');
                end
            end
        end
    end
    
    %check for ImageMagick installation
    [status0,result0] = system('where magick');
    if ~status0 == 0
        if exist('.magickFound')
            pathstr = char(textread('.magickFound','%q'));
            setenv('PATH',[getenv('PATH') strcat(';',pathstr)]);
        elseif ~exist('.magickFound')
            disp('ImageMagick not found in system path, checking for installation...')
            [status,result] = system('cd \"Program Files" & dir /b/s magick.exe');
            if ~exist(strcat(result))
                error('No ImageMagick installation detected in Program Files. Install SoX and try again.')
            elseif exist(strcat(result))
                disp('Found ImageMagick install, adding to PATH...')
                [pathstr,name,ext] = fileparts(result);
                setenv('PATH',[getenv('PATH') strcat(';',pathstr)]);
                [status3,result3] = system('where magick.exe');
                if ~status3 == 0
                    disp('Unable to add ImageMagick to PATH. Please remedy this yourself.')
                else
                    disp('Added ImageMagick to PATH. Proceeding.')
                    fid = fopen('.magickFound','wt');
                    out = strrep(pathstr,'\','\\');
                    fprintf(fid,[char(34) out char(34)]);
                    fclose(fid);
                    system('attrib +h .magickFound');
                end
            end
        end
    end
end
system(['RScript ./R/packageCheck.r']);

% Choose default command line output for voice
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes voice wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = voice_OutputFcn(hObject, eventdata, handles) 
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
