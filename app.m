function varargout = app(varargin)
% APP MATLAB code for app.fig
%      APP, by itself, creates a new APP or raises the existing
%      singleton*.
%
%      H = APP returns the handle to a new APP or the handle to
%      the existing singleton*.
%
%      APP('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in APP.M with the given input arguments.
%
%      APP('Property','Value',...) creates a new APP or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before blank_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to blank_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help app

% Last Modified by GUIDE v2.5 28-Sep-2018 14:34:00

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @app_OpeningFcn, ...
                   'gui_OutputFcn',  @app_OutputFcn, ...
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

% --- Executes just before app is made visible.
function app_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to app (see VARARGIN)

    % Com-ports
    instrreset;
    comscan = instrhwinfo('serial');
    comlist = comscan.AvailableSerialPorts;
    set(handles.COM, 'String', string(comlist));

    % Sweep setup:
    global sweep_span;
    global chan;

    chan = linspace(4404e6,4994e6,60);
    sweep_span = 30e6;

    set(handles.Points_num,'String',101);
    
    % Axes1 setup
    xlabel(handles.axes1,'Частота (Гц)')
    ylabel(handles.axes1,'Мощность (дБм)')
    set(handles.axes1,'fontsize',8)

    % Choose default command line output for app
    handles.output = hObject;

    % Update handles structure
    guidata(hObject, handles);

    % This sets up the initial plot - only do when we are invisible
    % so window can get raised using app.
    if strcmp(get(hObject,'Visible'),'off')

    end

% UIWAIT makes app wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = app_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in sweep.
function sweep_Callback(hObject, eventdata, handles)
% hObject    handle to sweep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global sweep_span;
    global chan;
    global s;
    global rf_cal
    global if_cal
    
    if get(hObject,'Value') == 1
        
        set(hObject,'Enable','inactive');
        
        iffreq = str2double(get(handles.IF,'String'));
        points = str2double(get(handles.Points_num,'String'));
        lofreq = chan + iffreq;
        averaging = str2double(get(handles.Average_num,'String'));

        % Make sure you have installed NI VISA 15.0 or newer with .NET support
        % This example does not require MATLAB Instrument Control Toolbox
        % It is based on using .NET assembly called Ivi.Visa
        % that is istalled together with NI VISA   
        
        % Get data from ip gui
        h = findobj('Tag','IP_gui');
        if ~isempty(h)
            ip = guidata(h);
        end
        
        % Connect to RF generator
        try
            % If OK was pressed in ip gui, the connect to ip from gui,
            % otherwise proceed with devices from app gui
            switch get(handles.ip_push,'Value')
                case 0
                    switch get(handles.Gen,'Value')
                        case 1
                            gen = VISA_Instrument('TCPIP::192.168.1.53::INSTR'); % Adjust the VISA Resource string to fit your instrument
                        case 2
                            gen = VISA_Instrument('TCPIP::192.168.1.68::INSTR'); % Adjust the VISA Resource string to fit your instrument
                    end
                case 1
                    if ~isempty(getappdata(ip.IP_gui,'GEN_IP'))
                        gen = VISA_Instrument(strcat('TCPIP::',getappdata(ip.IP_gui,'GEN_IP'),'::INSTR')); % Adjust the VISA Resource string to fit your instrument
                    else
                        switch get(handles.Gen,'Value')
                            case 1
                                gen = VISA_Instrument('TCPIP::192.168.1.53::INSTR'); % Adjust the VISA Resource string to fit your instrument
                            case 2
                                gen = VISA_Instrument('TCPIP::192.168.1.68::INSTR'); % Adjust the VISA Resource string to fit your instrument
                        end
                    end
            end
            setappdata(hObject,'gen',gen); % https://www.mathworks.com/help/matlab/creating_guis/share-data-among-callbacks.html
            gen.SetTimeoutMilliseconds(3000); % Timeout for VISA Read Operations
            % gen.AddLFtoWriteEnd = false;
        catch ME
            error ('Error initializing the instrument:\n%s', ME.message);
        end
        
        % Connect to SA
        try
            % If OK was pressed in ip gui, the connect to ip from gui,
            % otherwise proceed with devices from app gui
            switch get(handles.ip_push,'Value')
                case 0
                    switch get(handles.SA,'Value')
                        case 1
                            sa = VISA_Instrument('TCPIP::192.168.1.71::INSTR'); % Adjust the VISA Resource string to fit your instrument
                        case 2
                            sa = VISA_Instrument('TCPIP::192.168.1.45::INSTR'); % Adjust the VISA Resource string to fit your instrument
                    end
                case 1
                    if ~isempty(getappdata(ip.IP_gui,'SA_IP'))
                        sa = VISA_Instrument(strcat('TCPIP::',getappdata(ip.IP_gui,'SA_IP'),'::INSTR')); % Adjust the VISA Resource string to fit your instrument
                    else
                        switch get(handles.Gen,'Value')
                            case 1
                                sa = VISA_Instrument('TCPIP::192.168.1.71::INSTR'); % Adjust the VISA Resource string to fit your instrument
                            case 2
                                sa = VISA_Instrument('TCPIP::192.168.1.45::INSTR'); % Adjust the VISA Resource string to fit your instrument
                        end
                    end
            end
            setappdata(hObject,'sa',sa); % https://www.mathworks.com/help/matlab/creating_guis/share-data-among-callbacks.html
            sa.SetTimeoutMilliseconds(3000); % Timeout for VISA Read Operations
            % sa.AddLFtoWriteEnd = false;
        catch ME
            error ('Error initializing the instrument:\n%s', ME.message);
        end
        
        % Ext LO
        if get(handles.LO, 'Value') == 2 % If LO external
            % Connecto to LO generator
            try
                switch get(handles.ip_push,'Value')
                    case 0
                       lo = VISA_Instrument('TCPIP::192.168.1.53::INSTR'); % Adjust the VISA Resource string to fit your instrument
                    case 1
                        if ~isempty(getappdata(ip.IP_gui,'LO_IP'))
                            lo = VISA_Instrument(strcat('TCPIP::',getappdata(ip.IP_gui,'LO_IP'),'::INSTR')); % Adjust the VISA Resource string to fit your instrument
                        else
                            lo = VISA_Instrument('TCPIP::192.168.1.53::INSTR'); % Adjust the VISA Resource string to fit your instrument
                        end
                end
                lo.SetTimeoutMilliseconds(3000); % Timeout for VISA Read Operations
                % lo.AddLFtoWriteEnd = false;
                setappdata(hObject,'lo',lo); % https://www.mathworks.com/help/matlab/creating_guis/share-data-among-callbacks.html
            catch ME
                error ('Error initializing the instrument:\n%s', ME.message);
            end
        end
        
        % Ext SYNC
        if get(handles.Sync, 'Value') == 2 % If Sync external
            try
                switch get(handles.ip_push,'Value')
                    case 0
                       wavegen = VISA_Instrument('TCPIP::192.168.1.63::INSTR'); % Adjust the VISA Resource string to fit your instrument
                    case 1
                        if ~isempty(getappdata(ip.IP_gui,'SYNC_IP'))
                            wavegen = VISA_Instrument(strcat('TCPIP::',getappdata(ip.IP_gui,'SYNC_IP'),'::INSTR')); % Adjust the VISA Resource string to fit your instrument
                        else
                            wavegen = VISA_Instrument('TCPIP::192.168.1.63::INSTR'); % Adjust the VISA Resource string to fit your instrument
                        end
                end
                wavegen.SetTimeoutMilliseconds(3000); % Timeout for VISA Read Operations
                % wavegen.AddLFtoWriteEnd = false;
                setappdata(hObject,'wavegen',wavegen); % https://www.mathworks.com/help/matlab/creating_guis/share-data-among-callbacks.html
            catch ME
                error ('Error initializing the instrument:\n%s', ME.message);
            end
        end

        try
            %----------------------------------------------------------
            % Generator initialization
            %----------------------------------------------------------
            gen.ClearStatus();
            idnResponse = gen.QueryString('*IDN?');
            fprintf('\nInstrument Identification string: %s\n', idnResponse);
            gen.Write('*RST;*CLS'); % Reset the instrument, clear the Error queue

            gen.ErrorChecking(); % Error Checking after Initialization block
            %-----------------------------------------------------------
            % Generator basic Settings:
            %-----------------------------------------------------------
            gen.Write('SOUR:FREQ:CW %.2f',chan(length(chan)/2));
            Power = str2double(get(handles.Power,'String'));
            gen.Write('SOUR:POW:LEV:IMM:AMPL %s',num2str(Power));
            gen.ErrorChecking(); % Error Checking after Basic Settings block
            %----------------------------------------------------------
            % sa initialization
            %----------------------------------------------------------
            sa.ClearStatus();
            idnResponse = sa.QueryString('*IDN?');
            fprintf('\nInstrument Identification string: %s\n', idnResponse);
            sa.Write('*RST;*CLS'); % Reset the instrument, clear the Error queue
            sa.Write('SYST:DISP:UPD ON'); % Display update ON - switch OFF after debugging     
            sa.ErrorChecking(); % Error Checking after Initialization block
            %-----------------------------------------------------------
            % sa basic Settings:
            %-----------------------------------------------------------
            sa.Write('INST:SEL SAN'); % Switch to Spectrum Analyzer mode
            sa.QueryString('*OPC?'); % Synchronization command *OPC? to wait for command completion
            if str2double(sa.QueryString('INST:NSEL?')) ~= 1
                fprintf('\nSpectrum Analyzer option ZVL-K1 is not installed\n');
            end
            sa.Write('INIT:CONT OFF'); % Switch to single sweep
        %   sa.Write('INP:ATT:AUTO OFF'); % Turn off auto attenuator
        %   sa.Write('INP:ATT 0 dB'); % Manual attenuator value
            sa.Write('DISP:WIND:TRAC:Y:RLEV %0.2f', -10.0); % Setting the Reference Level
            sa.Write('DISP:WIND:TRAC:Y:RPOS 70 PCT'); % Scale
            sa.Write('FREQ:CENT %f',iffreq); % Setting the center frequency
            sa.Write('FREQ:SPAN %f',sweep_span); % Setting the span
            sa.Write('BAND %f', 50e3); % Setting the RBW
            sa.Write('BAND:VID %f', 50e3); % Setting the VBW
            sa.Write('SWE:POIN %d', points); % Setting the number of sweep points
            sa.ErrorChecking(); % Error Checking after Basic Settings block

            if exist('lo') == 1 % If LO external
                %----------------------------------------------------------
                % LO initialization
                %----------------------------------------------------------
                lo.ClearStatus();
                idnResponse = lo.QueryString('*IDN?');
                fprintf('\nInstrument Identification string: %s\n', idnResponse);
                lo.Write('*RST;*CLS'); % Reset the instrument, clear the Error queue
                fprintf('\nInstrument Error string: %s\n', lo.QueryString('SYST:ERR?'));
                lo.Write('SYST:DISP:UPD ON'); % Display update ON - switch OFF after debugging
                lo.ErrorChecking(); % Error Checking after Initialization block
                %-----------------------------------------------------------
                % LO basic Settings:
                %-----------------------------------------------------------
                lo.Write('SOUR:FREQ:CW %f',lofreq(length(lofreq)/2));
                lo.Write('SOUR:POW:LEV:IMM:AMPL 13');
                lo.ErrorChecking(); % Error Checking after Basic Settings block
            end

            if get(handles.Sync, 'Value') == 2 % If Sync external
                %----------------------------------------------------------
                % Sync initialization
                %----------------------------------------------------------
                wavegen.ClearStatus();
                idnResponse = wavegen.QueryString('*IDN?');
                fprintf('\nInstrument Identification string: %s\n', idnResponse);
                wavegen.Write('*RST;*CLS'); % Reset the instrument, clear the Error queue
                fprintf('\nInstrument Error string: %s\n', wavegen.QueryString('SYST:ERR?'));
                wavegen.ErrorChecking(); % Error Checking after Initialization block
                %-----------------------------------------------------------
                % Sync Basic Settings:
                %-----------------------------------------------------------
                wavegen.Write('SOUR:FUNC DC');
    %           wavegen.Write('SOUR:FREQ 100KHZ');
                wavegen.Write('OUTPUT1:LOAD INF');
                volt = 3.3;
    %           wavegen.Write('SOUR:VOLT %f', volt);
                wavegen.Write('SOUR:VOLT:OFFSET %f', volt);
                wavegen.ErrorChecking(); % Error Checking after Basic Settings block
            end
            %----------------------------------------------------------
            % SyncPoint 'SettingsApplied' - all the settings were applied
            %----------------------------------------------------------

            %-----------------------------------------------------------
            % Sweep:
            %-----------------------------------------------------------
            % It is recommended that you switch off the "Start/Stop Display Update" for optimum
            % sweep performance, especially with short dwell times
            
            currDate = strrep(strrep(datestr(datetime), ':', '_'), ' ', '-');
            setappdata(hObject,'currDate',currDate); % https://www.mathworks.com/help/matlab/creating_guis/share-data-among-callbacks.html
            set(handles.Date,'String',currDate);
            
            set(hObject,'String','Стоп'); set(hObject,'Enable','on');
            
            for c = 1:length(chan) % Sweep channels
                if get(hObject,'Value') == 0
                    break
                end
                setappdata(hObject,'c',c);
                axes = (handles.axes1); setappdata(hObject,'axes',axes);
                if get(handles.Cal,'Value') == 1
                    Power = str2double(get(handles.Power,'String'))-rf_cal(c);
                else
                    Power = str2double(get(handles.Power,'String'));
                end
                gen.Write('SOUR:POW:LEV:IMM:AMPL %s',num2str(Power));
                switch get(handles.Gen,'Value')
                    case 1
                        gen.Write('SOUR:FREQ:CENT %2.f',chan(c)); % Center frequency
                        gen.Write('SOUR:FREQ:SPAN %2.f',sweep_span); % Sweep span
                        gen.Write('SOUR:SWE:DWEL 60MS'); % Pause for auto sweep
                        gen.Write('SOUR:SWE:POINTS %d', points); % Number of sweep points
                        gen.Write('SOUR:FREQ:MODE LIST');
                        gen.Write('INIT:CONT OFF'); % Select the operation count for the Sweep/List function from Continuous/Single 
                        gen.Write('SOUR:LIST:TYPE STEP'); % Selects the Sweep function  
                        gen.Write('SOUR:LIST:MODE AUTO'); % Manual sweep OFF
                        gen.Write('SOUR:LIST:TRIG ON'); % Enables the trigger on Sweep/List function
                        gen.Write('SOUR:LIST:TRIG:MODE POIN'); % Set the trigger mode
                        gen.Write('SOUR:LIST:TRIG:SOUR BUS'); % Sets the trigger source on Sweep/List function to Remote command *TRG
                        
                        fprintf('\nInstrument Error string: %s\n', gen.QueryString('SYST:ERR?'));
                        disp(gen.QueryString('SOUR:FREQ:CENT?')); % Query the current sweep point 

                        gen.Write('OUTP:STAT ON');  % Activate the RF out
                        set(handles.edit1,'String',sprintf('Source RF out is now %s', gen.QueryLongString('OUTP:STAT?')));
                        gen.Write('INIT');  % Activate Sweep
                        gen.Write('TSW');  % Activate Sweep
                    case 2
                        gen.Write('SOUR:FREQ:CENT %f',chan(c)); % Center frequency
                        gen.Write('SOUR:FREQ:SPAN %f',sweep_span); % Sweep span
                        gen.Write('SOUR:SWE:DWEL 60 ms'); % Pause for auto sweep
                        gen.Write('SOUR:SWE:SPAC LIN'); % Sets linear sweep spacing anritsu error
                        gen.Write('SOUR:SWE:STEP %f', sweep_span/(points-1)); % Sets the step width for linear sweep spacing
                        gen.Write('SOUR:SWE:MODE MAN'); % Manual sweep
                        gen.Write('TRIG:FSW:SOUR SING'); % Single sweep
                        gen.QueryString('*OPC?');
                        fprintf('\nInstrument Error string: %s\n', gen.QueryString('SYST:ERR?')); % Error check after sweep set up

                        gen.Write('SOUR:FREQ:MODE SWE'); % Activate sweep mode, the frequency is set to "Start Freq".
                        disp(gen.QueryString('SOUR:FREQ?'));
                        gen.Write('OUTP:STAT ON;*OPC?');  % Activate the RF out
                        set(handles.edit1,'String',sprintf('Source RF out is now %s', gen.QueryLongString('OUTP:STAT?')));
                end

                % Internal or external LO:
                switch get(handles.LO, 'Value')
                    case 1
                        %  Send LO frequency to synthesizer
                        fopen(s); % 
                        byteBuf(s,c);
                        pause(0.02) % pause 20 ms
                        if get(handles.Sync, 'Value') == 2 % If Sync external
                            wavegen.Write('OUTPUT1 ON'); % External Sync on
                            wavegen.QueryString('*OPC?');
                        end
                    case 2
                     %  Send LO frequency to external generator
                        lo.Write('SOUR:FREQ:CW %f',lofreq(c));
                        lo.QueryString('*OPC?');
                        lo.Write('OUTP:STAT ON;*OPC?');  % Activate the RF out
                        output = sprintf('LO RF out is now %s', lo.QueryLongString('OUTP:STAT?'));
                        set(handles.edit1,'String',output);
                end

                % Start sweep
                for j = 1:averaging % Average of j sweeps
                    if get(hObject,'Value') == 0
                        break
                    end
                    sa.Write('INIT;*WAI'); % First sweep
                    y(1,j) = str2double(sa.QueryString('CALC:MARK:MAX;Y?')); % Y @ sweep_start
                    x(1,j) = str2double(sa.QueryString('CALC:MARK:MAX;X?')); % X @ sweep_start
                end
                if get(handles.Cal,'Value') == 1
                    data_cal = [mean(x)-if_cal(1) mean(y)];
                    setappdata(hObject,'data_cal',data_cal);
                end
                data = [mean(x) mean(y)];
                setappdata(hObject,'data',data);
                set(axes,'NextPlot','replacechildren'); % https://www.mathworks.com/matlabcentral/answers/11719-overwrite-data-in-figure-but-keep-axis-labels-title-and-legend
                if get(handles.Cal,'Value') == 1
                    plot(data_cal(1),data_cal(2),'Parent',axes); % plot calibrated data
                else
                    plot(data(1),data(2),'Parent',axes); % plot data
                end
                output = sprintf('Channel %d: %f MHz, LO: %f MHz, IF: %f MHz, Sweep: %f MHz',c,str2double(gen.QueryString('SOUR:FREQ:CENT?'))/1e6,(str2double(gen.QueryString('SOUR:FREQ:CENT?'))+str2double(sa.QueryString('FREQ:CENT?')))/1e6,str2double(sa.QueryString('FREQ:CENT?'))/1e6,str2double(gen.QueryString('SOUR:FREQ?'))/1e6);
                set(handles.edit1,'String',output);
                set(hObject,'String','Стоп');
                set(hObject,'Enable','on');
                for i = 2:points % Sweep inside channel
                    if get(hObject,'Value') == 0
                        break
                    end
                    switch get(handles.Gen,'Value')
                        case 1
                           gen.Write('*TRG'); % Step up generator
                           pause(0.01); % pause 10 ms
                        case 2
                           gen.Write('SOUR:FREQ:MAN UP'); % Step up generator
                           opcResponse = gen.QueryString('*OPC?'); % Synchronization command *OPC? to wait for command completion
                    end  
                    output = sprintf('Channel %d: %f MHz, LO: %f MHz, IF: %f MHz, Sweep: %f MHz',c,str2double(gen.QueryString('SOUR:FREQ:CENT?'))/1e6,(str2double(gen.QueryString('SOUR:FREQ:CENT?'))+str2double(sa.QueryString('FREQ:CENT?')))/1e6,str2double(sa.QueryString('FREQ:CENT?'))/1e6,str2double(gen.QueryString('SOUR:FREQ?'))/1e6);
                    set(handles.edit1,'String',output);
                    if str2double(opcResponse) > 0
                        for j = 1:averaging % Average of j sweeps
                            if get(hObject,'Value') == 0
                                break
                            end
                            sa.Write('INIT;*WAI'); % Next sweep
                            y(1,j) = str2double(sa.QueryString('CALC:MARK:MAX;Y?')); % Y @ sweep_start
                            x(1,j) = str2double(sa.QueryString('CALC:MARK:MAX;X?')); % X @ sweep_start
                        end
                        
                        if get(handles.Cal,'Value') == 1
                            data_cal(i,:) = [mean(x)-if_cal(i) mean(y)];
                            setappdata(hObject,'data_cal',data_cal);
                        end
                        data(i,:) = [mean(x) mean(y)];
                        setappdata(hObject,'data',data);
                        % Plot in real time
                        if get(handles.Cal,'Value') == 1
                            plot(data_cal(:,1),data(:,2),'Parent',axes);
                        else
                            plot(data(:,1),data(:,2),'Parent',axes);
                        end
                        pause(0.01); % pause 10 ms
                    else
                        return
                    end
                end
                if get(hObject,'Value') == 1
                    %----------------------------
                    % RF out off, close COM-port
                    %----------------------------
                    gen.Write('SOUR:FREQ:MODE CW'); gen.QueryString('*OPC?');
                    if get(handles.Sync, 'Value') == 2 % If Sync external
                        wavegen.Write('OUTPUT1 OFF'); % External Sync off
                        wavegen.QueryString('*OPC?');
                    end
                    if exist('s') == 1
                        fclose(s);
                    end
                    gen.Write('OUTP:STAT OFF');  % Deactivate the RF out
                    output = sprintf('Source RF out is now %s', gen.QueryString('OUTP:STAT?'));
                    set(handles.edit1,'String',output);   
                    if exist('lo') == 1
                        lo.Write('OUTP:STAT OFF;*OPC?');  % Deactivate the RF out     
                        set(handles.edit1,'String',sprintf('LO RF out is now %s', gen.QueryString('OUTP:STAT?')));
                    end
                    %------------------------------------
                    % Make a directory, save channel data
                    %------------------------------------
                    filepath = fullfile('Measurements',currDate);
                    if ~exist(filepath,'dir')
                        mkdir(filepath);
                    end
                    if get(handles.Cal,'Value') == 1
                        data = data_cal;
                    end
                    filename = strcat('Channel_',num2str(c),'_',num2str(chan(c)/1e6));
                    csvwrite(fullfile(filepath,strcat(filename,'.csv')), data); % save data in csv
                    export_fig(axes,fullfile(filepath,strcat(filename,'.png'))); % export figure
                    filenum = dir(fullfile('Measurements',currDate,'*.csv'));
                    filenames = {filenum.name};
                    set(handles.channels, 'String', string(filenames));
                end
            end
            if get(hObject,'Value') == 1
                %-------------------------
                % Reset instruments
                %-------------------------
                gen.Write('*RST;*CLS;*OPC?'); % Reset the instrument, clear the Error queue
                sa.Write('*RST;*CLS;*OPC?'); % Reset the instrument, clear the Error queue
                if exist('s') == 1
                   fclose(s);
                end
                if exist('lo') == 1
                    lo.Write('*RST;*CLS;*OPC?'); % Reset the instrument, clear the Error queue
                end
                if exist('wavegen') == 1
                    wavegen.Write('*RST;*CLS;*OPC?'); % Reset the instrument, clear the Error queue
                end
                gen.Write('*RST;*CLS;*OPC?'); % Reset the instrument, clear the Error queue
            end
        catch ME
            switch ME.identifier
                case 'VISA_Instrument:ErrorChecking'
                % Perform your own additional steps here
                    rethrow(ME);
                otherwise
                    rethrow(ME)
            end
        end
    else
        if get(hObject,'String') == 'Стоп'
            set(hObject,'String','Свип');
            set(hObject,'Enable','inactive');
            %----------------------------
            % RF out off, close COM-port
            %----------------------------
            % https://www.mathworks.com/help/matlab/creating_guis/share-data-among-callbacks.html
            gen = getappdata(hObject,'gen');
            sa = getappdata(hObject,'sa'); 
            if exist('wavegen')
                wavegen = getappdata(hObject,'wavegen');
            end
            if exist('lo')
                lo = getappdata(hObject,'lo');
            end
            currDate = getappdata(hObject,'currDate');
            axes = getappdata(hObject,'axes');
            gen.Write('SOUR:FREQ:MODE CW'); gen.QueryString('*OPC?');
            if get(handles.Sync, 'Value') == 2 % If Sync external
                wavegen.Write('OUTPUT1 OFF'); % External Sync off
                wavegen.QueryString('*OPC?');
            end
            if exist('s') == 1
                fclose(s);
            end
            gen.Write('OUTP:STAT OFF');  % Deactivate the RF out
            output = sprintf('Source RF out is now %s', gen.QueryString('OUTP:STAT?'));
            set(handles.edit1,'String',output);   
            if exist('lo') == 1
                lo.Write('OUTP:STAT OFF;*OPC?');  % Deactivate the RF out     
                set(handles.edit1,'String',sprintf('LO RF out is now %s', gen.QueryString('OUTP:STAT?')));
            end
            %------------------------------------
            % Make a directory, save channel data
            %------------------------------------
            filepath = fullfile('Measurements',currDate);
            if ~exist(filepath,'dir')
                mkdir(filepath);
            end
            if get(handles.Cal,'Value') == 1
                data = getappdata(hObject,'data_cal');
            else
                data = getappdata(hObject,'data');
            end
            c = getappdata(hObject,'c');
            filename = strcat('Channel_',num2str(c),'_',num2str(chan(c)/1e6));
            csvwrite(fullfile(filepath,strcat(filename,'.csv')), data); % save data in csv
            export_fig(axes,fullfile(filepath,strcat(filename,'.png'))); % export figure
            filenum = dir(fullfile('Measurements',currDate,'*.csv'));
            filenames = {filenum.name};
            set(handles.channels, 'String', string(filenames));
            set(hObject,'Enable','on');
        end
        %-------------------------
        % Reset instruments
        %-------------------------
        gen.Write('*RST;*CLS;*OPC?'); % Reset the instrument, clear the Error queue
        sa.Write('*RST;*CLS;*OPC?'); % Reset the instrument, clear the Error queue
        if exist('s') == 1
           fclose(s);
        end
        if exist('lo') == 1
            lo.Write('*RST;*CLS;*OPC?'); % Reset the instrument, clear the Error queue
        end
        if exist('wavegen') == 1
            wavegen.Write('*RST;*CLS;*OPC?'); % Reset the instrument, clear the Error queue
        end
        gen.Write('*RST;*CLS;*OPC?'); % Reset the instrument, clear the Error queue    
    end

% --- Executes during object creation, after setting all properties.
function axes1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns calle

%Hint: place code in OpeningFcn to populate axes1

% --------------------------------------------------------------------
function FileMenu_Callback(hObject, eventdata, handles)
% hObject    handle to FileMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function OpenMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to OpenMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
file = uigetfile('*.fig');
if ~isequal(file, 0)
    open(file);
end

% --------------------------------------------------------------------
function PrintMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to PrintMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
printdlg(handles.figure1)

% --------------------------------------------------------------------
function CloseMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to CloseMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selection = questdlg(['Close ' get(handles.figure1,'Name') '?'],...
                     ['Close ' get(handles.figure1,'Name') '...'],...
                     'Yes','No','Yes');
if strcmp(selection,'No')
    return;
end

delete(handles.figure1)

function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double

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

% --- Executes on button press in protocol.
function protocol_Callback(hObject, eventdata, handles)
% hObject    handle to protocol (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global selpath
    
    currDate = get(handles.Date,'String');
    
    if selpath ~= 0
        filepath = selpath;
    else
        filepath = fullfile('Measurements',currDate);
    end
	if ~exist(fullfile(filepath,'Protocol'),'dir')
        mkdir(fullfile(filepath,'Protocol'));
	end
    filenum = dir(fullfile(filepath,'*.csv'));
    filenames = {filenum.name};
    for c = 1:length(filenames)
        protocol = csvread(fullfile(filepath,char(filenames(c))));
        gain_min = min(protocol(:,2)); gain_max = max(protocol(:,2));
        gain_flatness(c,1) = round(abs(gain_max - gain_min),2);
    end
    csvwrite(fullfile(filepath,'Protocol',strcat(currDate,'.csv')),gain_flatness);
    set(handles.edit1,'String',strcat(currDate,'.csv') + " " + "was created in " + fullfile(filepath,'Protocol'));
    if get(handles.latex,'Value') == 1
        copyfile('latex_protocol', fullfile(filepath,'Protocol','latex_protocol'));
        protocol_tex = fullfile(filepath,'Protocol','latex_protocol',strcat(currDate,'.tex'));
        copyfile(fullfile(filepath,'Protocol','latex_protocol','protocol.tex'), protocol_tex);
        fid = fopen(protocol_tex,'r','n','UTF-8');
        content = textscan(fid,'%s','delimiter','\n'); fclose(fid);
        match = regexp(content{1,1}{13},'/(.*?)\.csv','tokens');
        content{1,1}{13} = regexprep(content{1,1}{13},match{1}{:},currDate);
        fid = fopen(protocol_tex,'w','n','UTF-8');
        fprintf(fid,'%s\n',content{1,1}{:}); fclose(fid);
        set(handles.edit1,'String','Compiling...');
        system("cd " + "/" + "d " + fullfile(filepath,'Protocol','latex_protocol') + " && " + "pdflatex " + strcat(currDate,'.tex'), '-echo');
        set(handles.edit1,'String','Compiling...');
        system("cd " + "/" + "d " + fullfile(filepath,'Protocol','latex_protocol') + " && " + "pdflatex " + strcat(currDate,'.tex'), '-echo');
        copyfile(fullfile(filepath,'Protocol','latex_protocol',strcat(currDate,'.pdf')), fullfile(filepath,'Protocol'));
        set(handles.edit1,'String',strcat(currDate,'.pdf') + " was created in " + fullfile(filepath,'Protocol'));
    end

% --- Executes on selection change in channels.
function channels_Callback(hObject, eventdata, handles)
% hObject    handle to channels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns channels contents as cell array
%        contents{get(hObject,'Value')} returns selected item from channels

% --- Executes during object creation, after setting all properties.
function channels_CreateFcn(hObject, eventdata, handles)
% hObject    handle to channels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    set(hObject, 'String', {'Файл'});

% --- Executes on button press in plot.
function plot_Callback(hObject, eventdata, handles)
% hObject    handle to plot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global selpath;
    global if_cal;
    global rf_cal;
    
    currDate = get(handles.Date,'String');
    
    axes = (handles.axes1);
    set(axes,'fontsize',8)
    set(axes,'NextPlot','replacechildren');
    
    filenames = get(handles.channels,'String');
    if class(filenames) == 'char'
        filename = filenames;
    else
        filename = filenames{get(handles.channels,'Value')};
    end
    if exist('selpath')
        data = csvread(fullfile(selpath,filename));
    else
        data = csvread(fullfile('Measurements',currDate,filename));
    end
    if size(data,2) == 1
        xlabel(axes,'№ канала')
        ylabel(axes,'Неравномерность (дБ)')
        plot(data,'Parent',axes);
    else
        xlabel(axes,'Частота (Гц)')
        ylabel(axes,'Мощность (дБм)')
        if get(handles.Cal,'Value') == 1
            channel = split(filename,'_');
            plot(data(:,1),data(:,2)-if_cal-rf_cal(str2double(channel{2})),'Parent',axes);
        else
            plot(data(:,1),data(:,2),'Parent',axes);
        end
    end

% --- Executes on selection change in COM.
function COM_Callback(hObject, eventdata, handles)
% hObject    handle to COM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns COM contents as cell array
%        contents{get(hObject,'Value')} returns selected item from COM

% --- Executes during object creation, after setting all properties.
function COM_CreateFcn(hObject, eventdata, handles)
% hObject    handle to COM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in Connect_button.
function Connect_button_Callback(hObject, eventdata, handles)
% hObject    handle to Connect_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global s
    if get(hObject,'Value') == 1
        portname = get(handles.COM, 'String');
        portnum = get(handles.COM, 'Value');
        s = serial(char(portname(portnum)),'BaudRate', 115200);
        output = sprintf(strcat(s.Name,' подключен'));
        set(handles.edit1,'String',output);
        set(hObject,'String','Отсоединить');
    else
        output = sprintf(strcat(s.Name,' отключен'));
        instrreset
        set(handles.edit1,'String',output);
        set(hObject,'String','Соединить');
    end
        

% --- Executes on selection change in LO.
function LO_Callback(hObject, eventdata, handles)
% hObject    handle to LO (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    switch get(hObject, 'Value')
        case 1 % LO Internal
            set(handles.Connect_button, 'Enable', 'on');
            set(handles.COM, 'Enable', 'on');
            set(handles.Sync, 'Enable', 'on')
        case 2 % LO External
            set(handles.Connect_button, 'Enable', 'off');
            set(handles.COM, 'Enable', 'off');
            set(handles.Sync, 'Enable', 'off');
    end
% Hints: contents = cellstr(get(hObject,'String')) returns LO contents as cell array
%        contents{get(hObject,'Value')} returns selected item from LO

% --- Executes during object creation, after setting all properties.
function LO_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LO (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in Sync.
function Sync_Callback(hObject, eventdata, handles)
% hObject    handle to Sync (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Sync contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Sync

% --- Executes during object creation, after setting all properties.
function Sync_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Sync (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in Browse.
function Browse_Callback(hObject, eventdata, handles)
global currDate
% hObject    handle to Browse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global selpath;

    selpath = uigetdir(); % Browse folder with csv
    pathparts = strsplit(selpath,filesep); % Split folder path
    set(handles.Date,'String',pathparts{end}); % Get folder name
    filenum = dir(fullfile(selpath,'*.csv')); % Find csv in folder
    filenames = {filenum.name}; % List file csv files
    lastwarn('');
    set(handles.channels, 'String', string(filenames)); % Show csv files in popup
    [warnmsg, msgid] = lastwarn;
    if ~isempty(warnmsg)
        set(handles.edit1,'String','Ошибка: в выбранной папке отсутствуют .csv файлы'); % Show warning
    else
        set(handles.edit1,'String',selpath); % Show full folder path
    end
    
function Date_Callback(hObject, eventdata, handles)
% hObject    handle to Date (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Date as text
%        str2double(get(hObject,'String')) returns contents of Date as a double

% --- Executes during object creation, after setting all properties.
function Date_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Date (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in latex.
function latex_Callback(hObject, eventdata, handles)
% hObject    handle to latex (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of latex

% --- Executes on button press in Cable_RF.
function Cable_RF_Callback(hObject, eventdata, handles)
% hObject    handle to Cable_RF (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global chan;
    global rf_s21_db

    [selfile,path] = uigetfile();
    rf_sparam = sparameters(fullfile(path,selfile));
    rf_extrap = rfinterp1(rf_sparam,chan);
    rf_mag = abs(rf_extrap.Parameters(2,1,:));
    rf_s21_db = 20*log10(rf_mag);
    set(handles.edit1,'String',"Выбран кабель ВЧ-тракта " + fullfile(path,selfile));

% --- Executes on button press in Cable_IF.
function Cable_IF_Callback(hObject, eventdata, handles)
% hObject    handle to Cable_IF (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global if_s21_db
    global sweep_span;
    iffreq = str2double(get(handles.IF,'String'));
    points = str2double(get(handles.Points_num,'String'));

    [selfile,path] = uigetfile();
    if_sparam = sparameters(fullfile(path,selfile));
    if_extrap = rfinterp1(if_sparam,linspace(iffreq-sweep_span/2,iffreq+sweep_span/2,points));
    if_mag = abs(if_extrap.Parameters(2,1,:));
    if_s21_db = 20*log10(if_mag);
    set(handles.edit1,'String',"Выбран кабель ПЧ-тракта " + fullfile(path,selfile));

function Power_Callback(hObject, eventdata, handles)
% hObject    handle to Power (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Power as text
%        str2double(get(hObject,'String')) returns contents of Power as a double

% --- Executes during object creation, after setting all properties.
function Power_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Power (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in SA.
function SA_Callback(hObject, eventdata, handles)
% hObject    handle to SA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns SA contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SA

% --- Executes during object creation, after setting all properties.
function SA_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in Gen.
function Gen_Callback(hObject, eventdata, handles)
% hObject    handle to Gen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Gen contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Gen

% --- Executes during object creation, after setting all properties.
function Gen_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Gen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function IF_Callback(hObject, eventdata, handles)
% hObject    handle to IF (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of IF as text
%        str2double(get(hObject,'String')) returns contents of IF as a double


% --- Executes during object creation, after setting all properties.
function IF_CreateFcn(hObject, eventdata, handles)
% hObject    handle to IF (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Points_num_Callback(hObject, eventdata, handles)
% hObject    handle to Points_num (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Points_num as text
%        str2double(get(hObject,'String')) returns contents of Points_num as a double

% --- Executes during object creation, after setting all properties.
function Points_num_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Points_num (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Average_num_Callback(hObject, eventdata, handles)
% hObject    handle to Average_num (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Average_num as text
%        str2double(get(hObject,'String')) returns contents of Average_num as a double

% --- Executes during object creation, after setting all properties.
function Average_num_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Average_num (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in Cal.
function Cal_Callback(hObject, eventdata, handles)
% hObject    handle to Cal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global rf_s21_db
global rf_cal
global if_s21_db
global if_cal

if get(hObject,'Value') == 1
    rf_cal = squeeze(rf_s21_db);
    if_cal = squeeze(if_s21_db);
    set(handles.edit1,'String','Калибровка будет применена');
    set(hObject,'String','Отменить');
    if isempty(rf_cal)
        rf_cal = 0;
    end
    if isempty(if_cal)
        if_cal = 0;
    end
else
    rf_cal = 0;
    if_cal = 0;
    set(handles.edit1,'String','Калибровка отменена');
    set(hObject,'String','Применить');
end


% --- Executes on button press in ip_push.
function ip_push_Callback(hObject, eventdata, handles)
% hObject    handle to ip_push (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(hObject,'Value') == 1
    set(handles.edit1,'String','Введите IP-адрес СИ, нажмите "OK" и оставьте окно "ip" открытым');
    ip
else
    h=findobj('Tag','IP_gui');
    close(h);
    set(handles.edit1,'String','Будут использованы IP-адреса по умолчанию');
end
% Hint: get(hObject,'Value') returns toggle state of ip_push
