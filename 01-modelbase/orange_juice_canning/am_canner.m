%% HYBRID ATOMIC PDEVS am_canner
%  stored in DEVS_PATH/01-modelbase/orange_juice_canning/am_canner.m

%%
classdef am_canner < hybridatomic
    %% Description
    % Class definition file for an *hybrid atomic PDEVS model*
    % that implements a canning process that gets juice from the tank,
    % fills to bottles and packs 48 bottles of 1 gallon to a pallet.
    %
    % <<img/am_canner.png>>
    %
    % constructor call: |obj =
    % am_canner(name,inistates,c_inistates,elapsed)|
    %
    %% Superclass
    % |hybridatomic|
    % (superclass acts as associated hybrid simulator)
    %
    %% Class Methods
    %
    % *characteristic functions:*
    % 
    % * |ta = tafun(obj)|              : time advance function -
    %   calculates time until next internal event by
    %   evaluating the states in |s|
    % * |deltaconffun(obj,gt)|   : confluent function -
    %   calculates from states |s|, inputs |x| and elapsed time |elapsed|
    %   the new states |s'|, if there is an internal and an external event
    %   at the same time
    % * |deltaextfun(obj,gt)|    : external transition function - 
    %   calculates from states |s|, inputs |x| and elapsed time
    %   |elapsed| the new states |s'|
    % * |deltaintfun(obj)|       : internal transition function -
    %   calculates from states |s| the new states |s'|
    % * |lambdafun(obj)|         : output function
    %   calculates from states |s| the ouptputs |y|  
    % * |dq = f(obj,gt,x,y)|: rate of change function - returns derivations
    % * |ret = cse(obj,gt,y)|: state event condition function - checks, if
    %   there are events
    % * |deltastatefun(obj,gt,y,event_number)|: state event transition function -
    %   describes the reaction on state events
    % * |cy = lambda_c(obj,gt,y)|: continuous output function
    %
    % *display functions:*
    %
    % * |showall(obj)|      : display the object 
    % * |showxports(obj)|   : display x-ports and values 
    % * |showyports(obj)|   : display y-ports and values
    % * |showstates(obj)|   : display states in s
    % * |showsysparams(obj)|: display system parameters in sysparams
    % * |showcontstates(obj)|: display continuous states
    %
    %% Inherited Properties
    %
    % *inherited from atomic:*
    %
    % * |name|      : string, (unique) name of this model --> for debugging purposes
    %                 max. 12 characters for "nice" debug-look ;-)
    % * |x|         : structure, set of inport name/input value pairs
    % * |y|         : structure, set of outport name/output value pairs
    % * |s|         : structure, set of states
    % * |sysparams| : structure, set of system parameters, can be set only once at instantiation
    % * |elapsed|   : float, time elapsed since last 
    %                 transition (only for initialization)
    %
    % * |debug_flag|: 0|1|2|3, no messages|messages|steps|visualize x, y, and s (default 0)
    % * |observe_flag|: 0|1, log states of atomic subcomponents or not (default 0)
    % * |observed|  : cell array including time stamps and a copy of s (structure of states)
    %
    % *inherited from hybridatomic:*
    %
    % * |c_states|: vector of continuous variables
    % * |output_length|   : length of output-vector returned by lamda_c
    % * |mealy|: 1 or 0, model is of mealy or moore type 
    %
    %% Ports
    %
    % has two inputs |x|: in1 and in2, one for truck arrival signal from truck, one for incoming signal from tank (tank empty), 
    %
    % has one output |y|: out1 to send pallets of juice to counter
    %
    % Note: _continuous couplings need no ports. They are managed via_
    % _continuous variables' indices._
    %
    %% States
    %
    % *discrete in s:*
    %
    % |s.sigma|: for time advance
    %
    % |s.up_time|: for statistics
    %
    % |s.start_time|: record start time of current canning process to
    % calculate up_time later
    %
    %
    % *continuous:*
    %
    % |c_states = [CannerLevel; CannerRate]|
    %
    %
    %% Hybrid Characteristics
    %
    % |mealy = 0|: model is of Moore type (needs no inputs to calculate outputs)
    %
    % |output_length = 1|: the function lamda_c returns 1 element (current
    % CannerRate)
    %
    % *state events:*
    %
    % * if 48 gallons filled
    %
    %
    %% System Parameters in sysparams
    % none
    %
    %% More
    %
    % |global SIMUSTOP| : can be used to stop allover simulation
    %
    %
    %
    % <html>
    % <br><br>
    % <hr>
    % <br>
    % <a href="../../PDEVS_home.html">DEVS Tbx Home</a>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
    % <a href="../../PDEVS_examples.html">Examples</a>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
    % <a href="../../PDEVS_modelbase.html">Modelbase</a>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
    % <a href="javascript:history.back()"><< Back</a>
    % </html>
   
    methods
       
        function obj = am_canner(name,inistates,c_inistates,elapsed)
            if nargin == 4
                x = {'in1','in2'}; % truck arrival signal from truck on port 'in1', incoming signal from tank (tank empty) on port 'in2'
                y = {'out1'};  % 1 to pallets of juice to counter
                s = {'sigma','up_time','start_time'}; % canner up time and start time for statistics
                sysparams = {};
                c_states = [0; 0];    % canner level and canner rate
                mealy = 0; % model is of Moore type (needs  no inputs to calculate outputs)
            else
                error('mistake at constructor method for class am_canner');
            end
            obj = obj@hybridatomic(name,x,y,s,c_states,mealy,elapsed,sysparams);% incarnate the associated hybrid simulator
            % set hybrid parameters
            obj.output_length = 1; % the function lamda_c returns 1 element
            % initialize the continuous states
            obj.c_states = c_inistates;
            % initialize the discrete states
            obj.s.sigma = inistates.sigma;
            obj.s.up_time = inistates.up_time;
            obj.s.start_time = inistates.start_time;
            disp('hybrid canner constructed');
        end

        
        function ta = tafun(obj)
            ta = obj.s.sigma;
        end
        
       
        function deltaconffun(obj,gt)
            deltaintfun(obj);
            deltaextfun(obj,gt)
            % execute first internal function
        end

       
        function deltaextfun(obj,gt)
            if ~isempty(obj.x.in2)
                if (obj.x.in2{1} == 0) % if stop_canning-message from tank, because it's empty
                    
                    obj.c_states(2) = 0;  % CannerRate set to 0 --> stop canning
                    obj.s.up_time = obj.s.up_time + (gt - obj.s.start_time); % calculate up-time until now
                end
            end
            if ~isempty(obj.x.in1)
                if (obj.x.in1{1} == 1) % if truck-arrival-message from truck
                    obj.c_states(2) = 48;  % CannerRate set to 48 --> restart canning
                    obj.s.start_time = gt;% notice canning starting point
                end
            end            
        end
        
        
        function deltaintfun(obj)
            obj.s.sigma = inf;
        end
               
        
        function lambdafun(obj)
            obj.y.out1 = {1};
            % send a pallet à 48 gallons to transducer
        end
        
        
        function dq = f(obj,gt,x,y) %#ok<*INUSL>
            %gt current time, x continuous input vector
            %y local continuous state vector
            dq(1) = y(2); % derivation for CannerLevel this is the current CannerRate
            dq(2) = 0; % CannerRate does not change here
            obj.c_states(1)= y(1);
            obj.c_states(2)= y(2);% put back the state values
        end
        
       
        function ret = cse(obj,gt,y)
                   %continuous state value height
                   % |  integration termination event (1/0)
                   % |  |    zero-crossing direction from + to - (1 if event
                   % |  |    fct increases, -1 if decreases)
                   % |  |    |
           ret = [48-y(1),1,-1]; % event, if CannerLevel reaches 48 --> one pallet filled
        end
        
        
        function deltastatefun(obj,gt,y,event_number) %#ok<*INUSD>
            % state event occurred in THIS atomic
            obj.c_states(1) = 0; % set CannerLevel to zero
            obj.s.sigma = 0; % trigger an internal event to send the pallet to transducer
        end
      
       
        function cy = lambda_c(obj,gt,y)
            cy = y(2); % output of current CannerRate, is input for tank
        end        
        
    end        
        
 end

