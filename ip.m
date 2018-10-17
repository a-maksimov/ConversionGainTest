function varargout = ip(varargin)
% IP MATLAB code for ip.fig
%      IP, by itself, creates a new IP or raises the existing
%      singleton*.
%
%      H = IP returns the handle to a new IP or the handle to
%      the existing singleton*.
%
%      IP('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in IP.M with the given input arguments.
%
%      IP('Property','Value',...) creates a new IP or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ip_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ip_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ip

% Last Modified by GUIDE v2.5 28-Sep-2018 15:22:28

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ip_OpeningFcn, ...
                   'gui_OutputFcn',  @ip_OutputFcn, ...
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


% --- Executes just before ip is made visible.
function ip_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ip (see VARARGIN)

% Choose default command line output for ip
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ip wait for user response (see UIRESUME)
% uiwait(handles.IP_gui);


% --- Outputs from this function are returned to the command line.
function varargout = ip_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function gen_ip_Callback(hObject, eventdata, handles)
% hObject    handle to gen_ip (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of gen_ip as text
%        str2double(get(hObject,'String')) returns contents of gen_ip as a double


% --- Executes during object creation, after setting all properties.
function gen_ip_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gen_ip (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function sa_ip_Callback(hObject, eventdata, handles)
% hObject    handle to sa_ip (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sa_ip as text
%        str2double(get(hObject,'String')) returns contents of sa_ip as a double


% --- Executes during object creation, after setting all properties.
function sa_ip_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sa_ip (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function sync_ip_Callback(hObject, eventdata, handles)
% hObject    handle to sync_ip (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sync_ip as text
%        str2double(get(hObject,'String')) returns contents of sync_ip as a double


% --- Executes during object creation, after setting all properties.
function sync_ip_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sync_ip (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in gen_ip_ok.
function gen_ip_ok_Callback(hObject, eventdata, handles)
% hObject    handle to gen_ip_ok (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
setappdata(handles.IP_gui,'GEN_IP',get(handles.gen_ip,'String'));

% --- Executes on button press in sa_ip_ok.
function sa_ip_ok_Callback(hObject, eventdata, handles)
% hObject    handle to sa_ip_ok (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
setappdata(handles.IP_gui,'SA_IP',get(handles.sa_ip,'String'));


% --- Executes on button press in sync_ip_ok.
function sync_ip_ok_Callback(hObject, eventdata, handles)
% hObject    handle to sync_ip_ok (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
setappdata(handles.IP_gui,'SYNC_IP',get(handles.sync_ip,'String'));



function lo_ip_Callback(hObject, eventdata, handles)
% hObject    handle to lo_ip (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of lo_ip as text
%        str2double(get(hObject,'String')) returns contents of lo_ip as a double


% --- Executes during object creation, after setting all properties.
function lo_ip_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lo_ip (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in lo_ip_ok.
function lo_ip_ok_Callback(hObject, eventdata, handles)
% hObject    handle to lo_ip_ok (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
setappdata(handles.IP_gui,'LO_IP',get(handles.lo_ip,'String'));
