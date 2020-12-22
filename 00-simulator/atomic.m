%% Atomic Object with Simulator Functionalities
%  stored in DEVS_PATH/00-simulator/atomic.p
%
% Is provided as p-code.

%%
% <html>
% <table border=0><tr><td>Based on modified parallel DEVS
% algorithms (Zeigler, Schwatinski).</td></tr>
% <tr><td>All user defined atomic models have to be derived from class
% atomic.</td></tr>
% <tr><td>C. Deatcu 2016</td></tr></table>
% </html>
%
%% 
classdef atomic < devs
    %% Description
    % Class definition file for an *associated simulator* for
    % atomic PDEVS models
    %
    % constructor call:  |obj =
    % atomic(name,x,y,s,elapsed,sysparams)|
    %
    %
    %% Superclass
    % |devs|
    %
    %% Inherited properties
    %
    % * |sub_of|    : string, name of the superordinate model --> for debugging purposes
    % * |tnext|     : float, time of next event
    % * |tlast|     : float, time of last event
    % * |name|      : string, (unique) name of this model --> for debugging purposes
    %                 max. 12 characters for "nice" debug-look ;-)
    % * |x|         : structure, set of inport name/input value (cell array) pairs
    % * |y|         : structure, set of outport name/output value (cell array) pairs
    % * |debug_flag|: 0|1|2|3, no messages|messages|steps|visualize x, y, and s (default 0)
    % * |observe_flag|: 0|1, log states of atomic subcomponents or not (default 0)
    %
    %% Properties
    %
    % * |s|         : structure, set of states
    % * |elapsed|   : float, time elapsed since last 
    %                 transition (only for initialization)
    % * |sysparams| : structure, set of system parameters, can be set only once at instantiation
    % * |observed|  : cell array including time stamps and a copy of s (structure of states)
    %
    %% Class Methods
    %
    % *Simulation Messages*
    %
    % * |i_msg(obj,gt)|   : initialization message -
    %   sets tlast and calls tafun() of model to calculate tnext
    % * |s_msg(obj,gt,flag)|: star message - called when atomic is
    %   imminent, calls deltaint() and tafun() of model, sets tlast and
    %   tnext
    % * |x_msg(obj,gt)|  : x message - called, if external event
    %   arrives, calls deltaconffun() or deltaextfun() of model    
    % * |y_msg(obj,gt)|  : inperpellation y message - calls lambdafun
    %   of model
    %
    % *Set Methods for Flags*
    %
    % * |set_debug(obj, debug_flag)|: set flag for debug messages to
    % 0|1|2|3
    % * |set_observe(obj, observe_flag)|: set flag for tracking states to 0|1
    %
    % *Set Methods for States*
    %
    % * |set_states(obj, statenames)|: initializes the structure obj.s. with fields defined in statenames
    % * |set.s(obj,svalues)|:          safe setting of state values in s
    %
    % *Display Methods*
    %
    % * |showall(obj)|      : display the object 
    % * |showxports(obj)|   : display x-ports and values 
    % * |showyports(obj)|   : display y-ports and values
    % * |showstates(obj)|   : display states in s
    % * |showsysparams(obj)|: display system parameters in sysparams
    
    properties (SetAccess = {?atomic, ?coupled}, GetAccess = public)      
        elapsed 
        observed
    end
    properties (SetObservable,SetAccess = {?atomic, ?coupled}, GetAccess = public)% Observable for debug-display
        s       
    end
    properties (SetAccess = immutable, GetAccess = public)
        sysparams % structure of system parameters as e.g. a service time
    end
    properties (Hidden)%for debug-display
        x_table
        s_table
        y_table
    end
      
    methods
        % constructor
        function obj = atomic(name,x,y,s,elapsed,sysparams)
            obj = obj@devs();
            if nargin < 6
                warning('constructor of base class <<atomic>> called with less than 6 input parameters');
            else
                obj.name = name;
                set_x_ports(obj,x);
                set_y_ports(obj,y);
                set_states(obj,s);
                obj.sysparams = sysparams;
                
                obj.elapsed = elapsed;
            end
        end
        
        
        %######################### SIMULATOR FUNCTIONS #########################
        %% i_MSG  
        %  function i_msg(obj,gt)
        %%
        % WHAT HAPPENS IN I_MSG?
        %%
        % * set time |tlast| by calculating from current simulation time |gt| and |elapsed| |tnext| at all objects
        % * call time advance function of associated model 
        % * set time for next internal event |tnext|
        %
        function i_msg(obj,gt)
            % gt = current time
            if obj.observe_flag % track states versus time
                obj.observed = {gt , obj.s};% initialize state recording
            end
            
            obj.debug_obj.dbprint(gt,100,obj,'');% begin i-msg debug-message
            
            obj.tlast = gt - obj.elapsed;
            
            obj.debug_obj.dbprintcall(gt,1,obj); % call tafunc. debug-message
            
            obj.tnext = obj.tlast + tafun(obj); % execute time advance function and set next event time
            
            obj.debug_obj.dbprint(gt,101,obj,'');% end i-msg debug-message
            
        end
        
         %% S_MSG  
         %  function obj=s_msg(obj,gt,flag)
         %%
         % WHAT HAPPENS IN S_MSG?
         %%
         % * call internal transition function of associated model
         % * set time |tlast| to current time |gt|
         % * call time advance function of associated model 
         % * set time for next internal event |tnext|
         %  
         %%
         % |flag == 1| --> s_msg from ROOT, |flag == 0| --> s_msg from
         % other
         %
         % flag here just for adapting debug-message, no different reactions depending on if from root or other components!
         %
        function s_msg(obj,gt,flag)
            % gt = current time; flag = 1 from root coordinator, = 0 from upper component
            % flag here just for adapting debug-message, no different reactions depending on if from root or other components!
            if obj.debug_flag
                if flag == 1
                    % sender = 'ROOT';
                    obj.debug_obj.dbprint(gt,102,obj,'');% receive s-msg from ROOT debug-message
                else
                    % sender = 'upper component';
                    obj.debug_obj.dbprint(gt,103,obj,'');% receive s-msg from other coordinator debug-message
                end
            end
            
            if abs(obj.tnext - gt) > obj.epsi
                disp(['error: bad synchronization at atomic_simulator of <',obj.name,'> in s_msg']);
                disp (['Values are: tnext = ',num2str(obj.tnext), ' and current time = ',num2str(gt)]);
                disp(obj);
            end
            
            obj.debug_obj.dbprintcall(gt,2,obj); % call deltaintfunc. debug-message
            
            deltaintfun(obj); % execute internal transition function
            
            if obj.observe_flag % track states versus time
                obj.observed = [obj.observed; {gt , obj.s}];
            end
            
            obj.tlast = gt;
            
            obj.debug_obj.dbprintcall(gt,1,obj); % call tafunc. debug-message
            
            
            obj.tnext= gt + tafun(obj); % execute time advance function and set next event time
            
            obj.debug_obj.dbprint(gt,104,obj,'');% end s-msg debug-message
        end
        

         %% X_MSG
         %  function x_msg(obj,gt)
         %
         % WHAT HAPPENS IN X_MSG?
         %%
         % * if there is an external and internal event at the same time
         % (current time |gt == tnext|), call confluent function of
         % associated model
         % * if there is just an external event, call external transition
         % function of associated model
         % * set time |tlast| to current time |gt|
         % * call time advance function of associated model 
         % * set time for next internal event |tnext|
         %
        function x_msg(obj,gt)
            
            % gt = current time
            obj.debug_obj.dbprint(gt,105,obj,'');% begin x-msg debug-message
            
            if (obj.tlast-gt) > obj.epsi || (gt-obj.tnext) > obj.epsi
                disp(['error: bad synchronization at atomic_simulator of <',obj.name,'> in x_msg']);
            end
            obj.debug_obj.dbprintout(gt,2,obj,[])% print x-ports debug-message
            if abs(obj.tnext - gt) <= obj.epsi % if there is also an pending internal event
                
                obj.debug_obj.dbprintcall(gt,3,obj); % call deltaconffunc. debug-message
                
                deltaconffun(obj,gt); % carry out confluent function
                if obj.observe_flag % track states versus time
                    obj.observed = [obj.observed; {gt , obj.s}];
                end
                
                
            else
                
               
                obj.debug_obj.dbprintcall(gt,4,obj); % call deltaextfunc. debug-message
                
                
                deltaextfun(obj,gt); % execute external transition function
                if obj.observe_flag % track states versus time
                    obj.observed = [obj.observed; {gt , obj.s}];
                end
            end
            obj.tlast = gt;
            
            obj.debug_obj.dbprintcall(gt,1,obj); % call tafunc. debug-message
            
            obj.tnext = gt + tafun(obj); % execute time advance function
            
            obj.debug_obj.dbprint(gt,106,obj,'');% end x-msg debug-message
        end

       
        %% Y_MSG
        %  function y_msg(obj,gt)
        %
        % WHAT HAPPENS IN Y_MSG?
        %%
        % * call output function of associated model
        % * propagate output to superordinate coordinator
        %
        function y_msg(obj,gt)
            % gt = current time
            obj.debug_obj.dbprint(gt,108,obj,[]);% receive interp. y-msg an begin y-msg debug-message
            %obj.debug_obj.dbprint(gt,13,obj,[]);% begin y-msg debug-message
            
            % if obj.tnext~=gt
            if abs(obj.tnext - gt) > obj.epsi
                disp( ['error: bad synchronization at atomic_simulator of <',obj.name,'> in y_msg']);
                disp (['Values are: tnext = ',num2str(obj.tnext), ' and current time = ',num2str(gt)]);
            end
            
            obj.debug_obj.dbprintcall(gt,5,obj); % call lambdafunc. debug-message
            
            lambdafun(obj);
            
            
            obj.debug_obj.dbprint(gt,107,obj,[]);% send y-msg to superordinate--> propagate output debug-message
            obj.debug_obj.dbprint(gt,109,obj,[]);% end y-msg debug-message
            
        end

       
        %######################## end SIMULATOR FUNCTIONS #######################
        
       
        %######################### Functions for setting properties #########################
        % 
        % * |function set_debug(obj,debug_flag)|: set debug flag to 0|1|2
        % * |function set_observe(obj,observe_flag)|: set observe flag to 0|1
        % * |set_states(obj, statenames)|: initialize the structure for the states
        % * |set.s(obj,svalues)|: safe setting of new values for states
        % * |function set_sysparams(obj,paramnames)|: initialize the system
        %    parameters (if any) as empty cells array
        %
        function set_debug(obj, debug_flag,descriptor)
            if ismember(debug_flag,[0, 1, 2, 3])
                obj.debug_flag = debug_flag; % set the flag for THIS atomic
                
                if (debug_flag == 1) || (debug_flag == 2)
                    if nargin == 3
                        obj.debug_obj = db_m(descriptor);
                    else
                        obj.debug_obj = db_m(1);% std-out, if noc descriptor is specified
                    end
                end
                
                if debug_flag == 3 % online grafical debug
                    ggDebug(obj)
                    if  isstruct(obj.s)
                        obj.s_update();
                        addlistener(obj,'s','PreSet',@obj.s_update);
                    end
                    if  isstruct(obj.x)
                        obj.x_update();
                        addlistener(obj,'x','PreSet',@obj.x_update);
                    end
                    if  isstruct(obj.y)
                        obj.y_update();
                        addlistener(obj,'y','PreSet',@obj.y_update);
                    end
                end
           
            else
                error('debug_flag needs to be 0|1|2|3');
            end
        end

        function set_observe(obj, observe_flag)
            if observe_flag == 0 ||  observe_flag == 1
                obj.observe_flag=observe_flag; % set the flag for THIS atomic
            else
                error('observe_flag needs to be 0|1');
            end
        end


        
        function set_states(obj, statenames) % statenames is list of state names = cellstring
            % create an empty structure
            if iscellstr(statenames)
                for j=1:length(statenames)
                    states.(statenames{j}) = [];
                end
                obj.s = states;
            else
                error('Invalid value for input argument ''statenames''. Must be a cellstring.');
            end
        end
        
        function set.s(obj,svalues)
           if isempty(obj.s)
               obj.s = svalues;
           else
               if numel(fieldnames(obj.s)) == numel(fieldnames(svalues))
                   obj.s = svalues;
               else
                   error('state s doesn''t exist')
               end
           end
        end
        
        %####################### end SET FUNCTIONS #######################
        
        %######################### DISPLAY HELPER FUNCTIONS #########################
        % functions for displaying the atomic objects
        % * |function showxports(obj)|: display x-ports
        % * |function showyports(obj)|: display y-ports
        % * |showstates(obj)|: display states
        %
        % These functions *can* be called to get some information during
        % or after simulation.       

        function showxports(obj)
            disp('Set of inputs x'),disp('------------------'),disp(obj.x);
            fprintf(1,'\n');
        end
        
        function showyports(obj)
            disp('Set of outputs y '),disp('------------------'),disp(obj.y);
            fprintf(1,'\n');
        end
        
        function showstates(obj)
            disp('Set of states s '),disp('------------------'),disp(obj.s);
            fprintf(1,'\n');
        end
        
        function showsysparams(obj)
            disp('System parameters '),disp('------------------'),disp(obj.sysparams);
            fprintf(1,'\n');
        end
        
        function showall(obj)
            disp(obj);
            fprintf(1,'\n');
            showsysparams(obj);
            showxports(obj);
            showyports(obj);
            showstates(obj);
        end
        %####################### end DISPLAY HELPER FUNCTIONS #######################
        
        
        %######################### GRAPHICAL DEBUG FUNCTIONS #########################
        function  ggDebug(obj)
            %just pass all arguments        
            
            % {
            g = groot;
            TF = true;
            for i = 1:numel(g.Children)    
                if strcmp(g.Children(i).Name,'DEVS DEBUG')
                    TF = false;
                    Grid = g.Children(i).Children;       
                    break
                end
            end

            if TF
                f = figure(...
                    'Name',         'DEVS DEBUG',...
                    'NumberTitle',  'off',...        
                    'MenuBar',      'none');
                
                javaFr = get(handle(f),'JavaFrame');
                pause(0.1)
                javaFr.setMaximized(true)
               
                Grid = uix.Grid(...
                    'Parent',           f,...
                    'Spacing',          2,...
                    'BackgroundColor',  [0 0 0]);       
            end            
            
            uicontrol(...
                'Parent',           Grid,...
                'Style',            'text',...
                'FontWeight',       'bold',...
                'BackgroundColor',  [1 0.7 0.7],...
                'String',           [obj.sub_of, ' : ',obj.name]);
            
            HBox = uix.HBox(...
                'Parent',           Grid,...
                'Padding',          0);
            
            obj.x_table = uitable(...
                'Parent',           HBox,...
                'data',             {}, ...        
                'Units',            'normalized',... 
                'ColumnWidth',      {40 70},...
                'RowName',          '',...
                'BackgroundColor',  [0.7 0.7 0.7],...
                'ColumnName',       {'Port','Value'});
            obj.s_table = uitable(...
                'Parent',           HBox,...
                'data',             {}, ...        
                'Units',            'normalized',... 
                'ColumnWidth',      {40 70},...
                'RowName',          '',...
                'BackgroundColor',  [0.7 0.7 0.7],...
                'ColumnName',       {'State','Value'});
            obj.y_table = uitable(...
                'Parent',           HBox,...
                'data',             {}, ...        
                'Units',            'normalized',... 
                'ColumnWidth',      {40 70},...
                'RowName',          '',... 
                'BackgroundColor',  [0.7 0.7 0.7],...
                'ColumnName',       {'Port','Value'});
            
            numCh = numel(Grid.Children);
            T = [20 -1]';
            if numCh < 8
                H = T*ones(1,numCh/2);                
            else
                H = T*ones(1,4);                                      
            end 
            set(Grid,'Heights', H(:)')             
            %}
        end
        
        
         
        function x_update(obj,varargin)
            set(obj.x_table,'data',statestruct2cell(obj.x));            
            drawnow();            
        end
        
        function y_update(obj,varargin)            
            set(obj.y_table,'data',statestruct2cell(obj.y));
            drawnow();            
        end
        
        function s_update(obj,varargin)            
            set(obj.s_table,'data',statestruct2cell(obj.s));
            drawnow(); 
        end
                
    end
end


% {
function tmpCell = statestruct2cell(s)

    FldNames = fieldnames(s);
    tmpCell  = cell(numel(FldNames),2);
    j = 1;

    for i = FldNames'
        value = s.(i{:});
        if isempty(value)
            if ischar(value)
                tmpVal = '''''';
            elseif iscell(value)
                tmpVal = '{ }';
            else
                tmpVal = '[ ]';
            end
        elseif ischar(value)
            tmpVal = ['''',value,''''];
        elseif isnumeric(value)
            tmpVal = num2str(value);
        elseif iscell(value)
            if iscellstr(value)
                tmpVal = ['{''',value{1},'''}'];
            elseif isnumeric(value{1}) || islogical(value{1})
                tmpVal = ['{[',num2str(value{1}),']}'];
            elseif isstruct(value{1})
                [zz,ss] = size(value{1});
                tmpVal = sprintf('{[%dx%d struct]}',zz,ss);
            else
                tmpVal = 'never mind 1';
            end
        elseif isstruct(value)
            [zz,ss] = size(value);
            tmpVal = sprintf('%dx%d struct',zz,ss);
        elseif islogical(value)
            if value
            	tmpVal = 'TRUE';
            else
                tmpVal = 'FALSE';
            end                
        else
            tmpVal = sprintf('%dx%d %s',size(value),class(value));
        end

        tmpCell{j,1} = i{:};
        tmpCell{j,2} = tmpVal;
        j = j+1;
    end
end
    
%}
 %####################### end GRAPHICAL DEBUG FUNCTIONS #######################       
  

%%
%
%
%
% <html>
% <br><br>
% <hr>
% <br>
% <a href="../PDEVS_home.html">DEVS Tbx Home</a>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
% <a href="../PDEVS_examples.html">Examples</a>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
% <a href="../PDEVS_modelbase.html">Modelbase</a>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
% <a href="javascript:history.back()"><< Back</a>
% </html>


