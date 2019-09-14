function varargout = speechproc_gui(varargin)
% SPEECHPROC_GUI MATLAB code for speechproc_gui.fig
%      SPEECHPROC_GUI, by itself, creates a new SPEECHPROC_GUI or raises the existing
%      singleton*.
%
%      H = SPEECHPROC_GUI returns the handle to a new SPEECHPROC_GUI or the handle to
%      the existing singleton*.
%
%      SPEECHPROC_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SPEECHPROC_GUI.M with the given input arguments.
%
%      SPEECHPROC_GUI('Property','Value',...) creates a new SPEECHPROC_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before speechproc_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to speechproc_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help speechproc_gui

% Last Modified by GUIDE v2.5 12-Sep-2019 22:50:49

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @speechproc_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @speechproc_gui_OutputFcn, ...
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


% --- Executes just before speechproc_gui is made visible.
function speechproc_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to speechproc_gui (see VARARGIN)

% Choose default command line output for speechproc_gui
handles.output = hObject;
handles.speed = 1;
handles.pitch = 1;
handles.peak = 0;
handles.sr = 8000;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes speechproc_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = speechproc_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on slider movement.
function slider_speed_Callback(hObject, eventdata, handles)
speed_lg = get(hObject,'Value');
handles.speed = 2^speed_lg;
set(handles.text_speed, 'String', num2str(handles.speed));
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function slider_speed_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider_pitch_Callback(hObject, eventdata, handles)
pitch_lg = get(hObject,'Value');
handles.pitch = 2^pitch_lg;
set(handles.text_pitch, 'String', num2str(handles.pitch));
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function slider_pitch_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider_peak_Callback(hObject, eventdata, handles)
handles.peak = get(hObject,'Value');
set(handles.text_peak, 'String', num2str(handles.peak));
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function slider_peak_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in pushbutton_open.
function pushbutton_open_Callback(hObject, eventdata, handles)
[file, path] = uigetfile('*.pcm');
handles.filename = [path, file];
if file
    set(handles.pushbutton_play, 'Enable', 'on'); 
end
guidata(hObject, handles);


% --- Executes on button press in pushbutton_play.
function pushbutton_play_Callback(hObject, eventdata, handles)
s = speechproc_pro(handles.filename, handles.sr, handles.speed, ...
    handles.pitch, handles.peak);
sound(s, handles.sr);
if (get(handles.checkbox_waveform, 'Value'))
   figure('Name', '∫œ≥…”Ô“Ù≤®–Œ');
   xlabel('Time (s)');
   plot([0:length(s)-1] / handles.sr, s);
end


function edit_sr_Callback(hObject, eventdata, handles)
handles.sr = str2num(get(hObject,'String'));
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function edit_sr_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox_waveform.
function checkbox_waveform_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_waveform (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_waveform
