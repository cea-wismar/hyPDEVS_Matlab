%% Template for a hybrid ATOMIC PDEVS
%  stored in DEVS_PATH/01-modelbase/am_hybrid_template.m
%
% Adopt this template to create your own hybrid atomic models.

    %% Description
    % Template for a class definition file of a *hybrid atomic PDEVS model
    %
    % constructor call: |obj =
    % am_hybrid_template(name,inistates,c_inistates,elapsed,~)|
    %
    % To define your own model adopt this file and fill transition
    % functions with your model specific behaviour.
    % First step is to alter the class name in |classdef| section, the
    % constructor call and save the class definition to a new m-file with the name of your
    % user-defined class.
    %
    %% Superclass
    % |hybridatomic|
    % (superclass acts as associated hybrid simulator)
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
    % * |c_states| : vector of continuous variables
    % * |output_length| : length of output-vector returned by lamda_c
    % * |mealy| : 0 or 1, model is of mealy or moore type 
    %
    %% Ports
    % has one input |x| : in1 (example!)
    %
    % has two outputs |y| : out1 and out2  (example!)
    %
    %% States
    %
    % *discrete in s:*
    %
    % |s.sigma| : for time advance
    %
    % |s.state_2| : (example state!)
    %
    % |s.state_3| :  (example state!)
    %
    %
    % *continuous:*
    %
    % |c_states = [c_state1; c_state2]| (examples!)
    %
    %% Hybrid Characteristics
    %
    % |mealy = 1|: model is of Mealy type (example!)
    %
    % |output_length = 1|: the function lamda_c returns 1 element (example!)
    %
    % *state events:*
    %
    % * if c_state1 reaches 200 (example!)
    %
    %
    %
     %% System Parameters in sysparams
    % none
    %
    %% More
    %
    % |global SIMUSTOP| : can be used to stop allover simulation e.g. when a
    % predefined number of jobs has finished
    %
    
   %% Class File
classdef am_hybrid_template < hybridatomic 
   methods
        
        function obj = am_hybrid_template(name,inistates,c_inistates,elapsed)
            if nargin == 4
                x = {'in1'}; % one discrete inport (example!)
                y = {'out1','out2'}; % two discrete outports (example!)
                s = {'sigma','state_2','state_3'}; % three states (example!)
                sysparams = {};
                c_states = [0; 0];               % two continuous state variables (example!)
                mealy = 1; % model is of Mealy type (example!)
            else
                error(['mistake at constructor method for class ',mfilename]);
            end
            obj = obj@hybridatomic(name,x,y,s,c_states,mealy,elapsed,sysparams);% incarnate the associated hybrid simulator
            % set hybrid parameters
            
            obj.output_length = 1; % the function lamda_c returns 1 element (example!)
            % initialize the continuous states
            obj.c_states = c_inistates;
            % initialize the discrete states (example!)
            obj.s.sigma = inistates.sigma;
            obj.s.state_2 = inistates.state_2;
            obj.s.state_3 = inistates.state_3;
            disp('hybrid template constructed');
        end
        
        
        function ta = tafun(obj)
            %**** USER CODE GOES HERE ****
            ta = obj.s.sigma;  % example code: set ta by some calculations
            %**** END USER CODE       ****
        end
        
        
        function deltaconffun(obj,gt)
            %**** USER CODE GOES HERE ****
            % example code: if internal and external events occur simultaneously,
            % first call external transition then internal transition
            deltaextfun(obj,gt);
            deltaintfun(obj);
            %**** END USER CODE
        end
        
        
        function deltaextfun(obj,gt) %#ok<INUSD>
            % gt ist current time, specify reactions on external events
            %**** USER CODE GOES HERE ****
            
            %**** END USER CODE
        end
        
        
        function deltaintfun(obj) %#ok<*MANU>
            % specify reactions on internal events
            %**** USER CODE GOES HERE ****
            
            %**** END USER CODE
        end
        
        
        function lambdafun(obj)
            % specify outputs
            %**** USER CODE GOES HERE ****
            % example code: set the output ports
            obj.y.p1 = {1};
            obj.y.p2 = {'message'};
            %**** END USER CODE
        end
        
        
        function dq = f(obj,gt,x,y) %#ok<*INUSL>
            % calculate derivations here
            %**** USER CODE GOES HERE ****
            % example code
            dq(1) = -x(1)-x(2);% derivation is the the sum of inflow and outflow (example!)
            dq(2) = 0;% this rate does not change (example!)
            obj.c_states(1)= y(1);
            obj.c_states(2)= y(2);% put back the state values (necessary!)
            %**** END USER CODE
        end
        
        
        function ret = cse(obj,gt,y)
            % define events here
            %**** USER CODE GOES HERE ****
            %continuous state value height
            % |  integration termination event (1/0)
            % |  |    zero-crossing direction from + to - (1 if event
            % |  |    fct increases, -1 if decreases)
            % |  |    |
            ret = [200-y(1),1,-1]; % event #1 (example!)
            %**** END USER CODE
        end
        
        function obj = deltastatefun(obj,gt,y,event_number)
            % specify reactions on state events
            %**** USER CODE GOES HERE ****
            if event_number == 1 % if event #1 took place (example!)
                obj.s.sigma = 0;  % do something, example: trigger internal event and output before
            end
            %**** END USER CODE
        end
        
        
        function cy = lambda_c(obj,gt,y,x) %#ok<INUSD>
            % calculate continuous output here
            %**** USER CODE GOES HERE ****
            cy = inf; % just DUMMY output! (example!)
            %**** END USER CODE
        end       
        
    end    
        
end
%%
% <html>
% <br><br>
% <hr>
% <br>
% <a href="../PDEVS_home.html">DEVS Tbx Home</a>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
% <a href="../PDEVS_examples.html">Examples</a>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
% <a href="../PDEVS_modelbase.html">Modelbase</a>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
% <a href="javascript:history.back()"><< Back</a>
% </html>
%

