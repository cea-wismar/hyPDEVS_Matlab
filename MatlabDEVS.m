function varargout = MatlabDEVS(varargin)
% MATLABDEVS MATLAB code for MatlabDEVS.fig
%      MATLABDEVS, by itself, creates a new MATLABDEVS or raises the existing
%      singleton*.
%
%      H = MATLABDEVS returns the handle to a new MATLABDEVS or the handle to
%      the existing singleton*.
%
%      MATLABDEVS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MATLABDEVS.M with the given input arguments.
%
%      MATLABDEVS('Property','Value',...) creates a new MATLABDEVS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MatlabDEVS_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MatlabDEVS_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MatlabDEVS

% Last Modified by GUIDE v2.5 23-Dec-2016 13:29:29

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MatlabDEVS_OpeningFcn, ...
                   'gui_OutputFcn',  @MatlabDEVS_OutputFcn, ...
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

end
% --- Executes just before MatlabDEVS is made visible.
function MatlabDEVS_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to MatlabDEVS (see VARARGIN)

% Choose default command line output for MatlabDEVS
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes MatlabDEVS wait for user response (see UIRESUME)
% uiwait(handles.figure1);
 RGB = imread('g4630.png');
 image(RGB);
 axes(handles.axes2);
 axis image
 axis off

% set own icon for MatlabDEVS - possibly illegal... ;-)
warning off MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame
jframe=get(hObject,'javaframe');
jIcon=javax.swing.ImageIcon('g5046.png');
jframe.setFigureIcon(jIcon); 

end

% --- Outputs from this function are returned to the command line.
function varargout = MatlabDEVS_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

end
% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
doc PDEVS_home
end

% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1

end

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
end


function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double
f1 = str2double(get(hObject,'String'));
if isnan(f1) || ~isreal(f1)  
     hObject.String = '0';
     uicontrol(hObject)
end
end

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
end


function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double
% Validate that the text in the f1 field converts to a real number
f1 = str2double(get(hObject,'String'));
if isnan(f1) || ~isreal(f1)  
     hObject.String = '12';
     uicontrol(hObject)
end
end

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
end

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.radiobutton2.Value
    debug_mode = 0
elseif handles.radiobutton3.Value
    debug_mode = 1
elseif handles.radiobutton4.Value
    debug_mode = 2
elseif handles.radiobutton5.Value
    debug_mode = 3
end    
tstart = str2double(get(handles.edit1,'String'))
tend = str2double(get(handles.edit2,'String'))
contents = cellstr(get(handles.popupmenu1,'String'));
exampelstrg = contents{get(handles.popupmenu1,'Value')};
disp(exampelstrg);
switch exampelstrg
       case 'Assembly Line' 
           init_assembly_line;
           modeltype = 1;
       case 'Testcase: two Outputs to one Input'
           init_2_out_1_in;
           modeltype = 1;
       case 'Single Server'
           init_singleserver;
           modeltype = 1;
       case 'Bouncing Ball QSS'
           init_qss1_ball_simple;
           modeltype = 1;
       case 'Sine QSS'
           init_sine_qss1;
           modeltype = 1;
       case 'Step QSS'
            init_steptest_qss1;
            modeltype = 1;
       case 'Bouncing Balls (hybrid)'
            init_3_balls;
            modeltype = 2;
       case 'Orange Juice Canning (hybrid)'
            init_orange_juice_canning;
            modeltype = 2;
end
if handles.radiobutton6.Value
    set_debug(root_model,debug_mode,1);
elseif handles.radiobutton7.Value
    set_debug(root_model,debug_mode,2);
elseif handles.radiobutton8.Value    
    set_debug(root_model,debug_mode,fopen('debug.txt','w'));
end
if modeltype == 1
    root_model = r_c_discrete(root_model,tstart,tend);
else
    [root_model,tout,yout,teout,yeout,ieout] = r_c_hybrid(root_model,tstart,tend,plot_params);
end
end




% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
contents = cellstr(get(handles.popupmenu1,'String'));
exampelstrg = contents{get(handles.popupmenu1,'Value')};
% disp(exampelstrg);
switch exampelstrg
       case 'Assembly Line' 
           %RGB = imread('doc/html/examples/discrete/img/assembly_line.png');
           doc init_assembly_line;
       case 'Testcase: two Outputs to one Input'
           %RGB = imread('doc/html/examples/discrete/img/two_out_1_in.png');
            doc init_2_out_1_in;
       case 'Single Server'
           %RGB = imread('doc/html/examples/discrete/img/single_server.png');
            doc init_singleserver;
       case 'Bouncing Ball QSS'
           %RGB = imread('doc/html/examples/discrete/img/ball_qss.png');
            doc init_qss1_ball_simple;
       case 'Sine QSS'
           %RGB = imread('doc/html/examples/discrete/img/sine_qss.png');
            doc init_sine_qss1;
       case 'Step QSS'
           %RGB = imread('doc/html/examples/discrete/img/step_qss.png');
            doc init_steptest_qss1;
       case 'Bouncing Balls (hybrid)'
            doc init_3_balls;
       case 'Orange Juice Canning (hybrid)'
            doc init_orange_juice_canning;
end

end


% --- Executes during object creation, after setting all properties.
function axes2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes2
end


% --------------------------------------------------------------------
function Untitled_1_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
end
