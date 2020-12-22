%% HYBRID ATOMIC PDEVS am_truck
%  stored in DEVS_PATH/01-atomic-modelbase/orange_juice_canning/am_truck.m

%%
classdef am_truck < hybridatomic
    %% Description
    % Class definition file for an *hybrid atomic PDEVS model*
    % that implements a truck, that arrives filled with 2000 gallons and is then unloaded.
    %
    % <<img/am_truck.png>>
    %
    % constructor call: |obj =
    % am_truck(name,inistates,c_inistates,elapsed)|
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
    % has two inputs |x|: in1 and in2, 1 for incoming trucks, one for suspend-unloading and restart-unloading signals
    %
    % has two outputs |y|: out1 and out2,  1 to send empty truck to undocking server, 1 to send truck-arrival signal to canner
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
    % |s.active|: 0 or 1, 1 if unloading is allowed, 0 if not
    %
    % |s.arrival|: marks, if last external event was truck arrival
    %
    %
    % *continuous:*
    %
    % |c_states = [TruckLevel; TruckRate]|
    %
    %% Hybrid Characteristics
    %
    % |mealy = 0|: model is of Moore type
    %
    % |output_length = 1|: the function lamda_c returns 1 element (current
    % TruckRate)
    %
    % *state events:*
    %
    % * if truck is empty
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
    
    properties (Access = public)
           
    end
    
    methods
       
        function obj = am_truck(name,inistates,c_inistates,elapsed)
            if nargin == 4
                x = {'in1','in2'};     % 1 for incoming trucks, one for suspend-unloading and restart-unloading signals
                y = {'out1','out2'};     % 1 to send empty truck do undocking server, 1 to send truck-arrival signal to canner
                s = {'sigma','active','arrival'};  
                sysparams = {};
                c_states = [0; 0];               % level and rate
                mealy = 0; % model is of Moore type  
            else
                error('mistake at constructor method for class am_truck');
            end
            obj = obj@hybridatomic(name,x,y,s,c_states,mealy,elapsed,sysparams);% incarnate the associated hybrid simulator
            % set hybrid parameters
            obj.output_length = 1; % the function lamda_c returns 1 element
            % initialize the continuous states
            obj.c_states = c_inistates;
            % initialize the discrete states
            obj.s.sigma = inistates.sigma;
            obj.s.active = inistates.active;  
            obj.s.arrival = inistates.arrival; 
            disp('hybrid truck constructed');
        end

        
        function ta = tafun(obj)
           ta = obj.s.sigma; 
        end
        
        
        function deltaconffun(obj,gt) 
            deltaextfun(obj,gt)
            deltaintfun(obj);
            % execute first external function
        end

        
        function deltaextfun(obj,gt) %#ok<*INUSD>
            if ~isempty(obj.x.in1) && (obj.s.active == 1)% a truck arrives and unloading allowed
                 obj.c_states(1) = 2000; % TruckLevel always 2000 at arrival
                 obj.c_states(2) = -200;  % TruckRate set to 200 gallons/per minute outflow
                 obj.s.arrival = 1; % to later differ between outputs in lambdafun
                 obj.s.sigma = 0; % to send arrival-signal to canner
             end
             if ~isempty(obj.x.in1) && (obj.s.active == 0)% a truck arrives and unloading not allowed
                 obj.c_states(1) = 2000; % TruckLevel always 2000 at arrival
                 obj.c_states(2) = 0;  % TruckRate set to zero
             end
             if ~isempty(obj.x.in2) 
                if obj.x.in2{1} == 0; % signal from tank to stop unloading
                obj.s.active = 0; % unloading not allowed
                obj.c_states(2) =  0;% TruckRate set to zero
                end
             end
             
             if ~isempty(obj.x.in2)
                 if obj.x.in2{1} == 1; % signal from tank to restart unloading
                     obj.s.active = 1; % unloading allowed
                     obj.c_states(2) =  -200;% TruckRate set to 200 outflow
                 end
             end                 
        end
        
      
        function deltaintfun(obj)
               obj.s.sigma = inf;
        end
               
       
        function lambdafun(obj) 
          if obj.s.arrival
                obj.y.out1 = {};
                obj.y.out2 = {1}; % send arrival-signal to canner
                obj.s.arrival = 0;% reset marker
          else
                obj.y.out1 = {1}; % send the truck to undock server
                obj.y.out2 = {}; % no signal for canner
          end
            
        end 
        
       
        function dq = f(obj,gt,x,y) %#ok<*INUSL>
            %gt current time, x continuous input vector
            %y local continuous state vector            
           dq(1) = y(2); % derivation this is the current TruckRate
           dq(2) = 0; % TruckRate does not change here
           
           obj.c_states(1)= y(1);
           obj.c_states(2)= y(2);% put back the state values
         end
        
      
        function ret = cse(obj,gt,y)
                   %continuous state value height
                   % |  integration termination event (1/0)
                   % |  |    zero-crossing direction from + to - (1 if event
                   % |  |    fct increases, -1 if decreases)
                   % |  |    |
             ret = [y(1),1,-1]; % event, if TruckLevel reaches zero
            end
     
        function deltastatefun(obj,gt,y,event_number)
        % state event occurred in THIS atomic 
                obj.c_states(1) = 0; % set TruckLevel to zero
                obj.c_states(2) = 0; % set TruckRate to zero
                obj.s.sigma = 0; % trigger an internal event to send truck to undock-server                               
        end
      
        function cy = lambda_c(obj,gt,y)
               cy = y(2); % output of current TruckRate
            end 
        
        
               
    end
        
        
 end

