%% Template for a pure discrete ATOMIC PDEVS
%  stored in DEVS_PATH/01-modelbase/am_discrete_template.m
%
% Adopt this template to create your own atomic models.

    %% Description
    % Template for a class definition file of an *atomic PDEVS model*
    % with pure discrete behaviour
    %
    % constructor call: |obj =
    % am_discrete_template(name,inistates,elapsed,sysparams)|
    %
    % To define your own model adopt this file. You need to define ports,
    % states, system parameters and fill characteristic
    % functions with your model specific behaviour.
    % First step is to alter the class name in |classdef| section, the
    % constructor call and save the class definition to a new m-file with the name of your
    % user-defined class.
    %
     %% Superclass
    % |atomic|
    % (superclass acts as associated simulator)
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
    %
    % *display functions:*
    %
    % * |showall(obj)|      : display the object 
    % * |showxports(obj)|   : display x-ports and values 
    % * |showyports(obj)|   : display y-ports and values
    % * |showstates(obj)|   : display states in s
    % * |showsysparams(obj)|: display system parameters in sysparams
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
    %% Ports
    % just an example:
    %
    % has three inputs |x|: in1, in2 and in3
    %
    % has two outputs |y|: out1 and out2
    %
    %% States in s
    % |s.sigma| (example state)
    %
    %% System Parameters in sysparams
    % |sysparams.param1| (example system parameter)
    %
    %% More
    %
    % |global SIMUSTOP| : can be used to stop allover simulation, e.g. when
    %  a predifined number of pallets have been produced
    %
    %% Class File
classdef am_discrete_template < atomic
    
    methods
        
        function obj = am_discrete_template(name,inistates,elapsed,sysparams)
            if nargin == 4
                x = {'in1', 'in2','in3'}; % example inports
                y = {'out1','out2'};% example outports
                s = {'sigma'}; % example state
                sysparams = struct('param1',sysparams(1));
            else
                error(['mistake at constructor method for class ',mfilename]);
            end
            obj = obj@atomic(name,x,y,s,elapsed,sysparams);% incarnate the associated simulator
            % initialize the states
            obj.s.sigma = inistates.sigma;
        end
        
        function ta = tafun(obj)
            %**** USER CODE GOES HERE ****
            ta = obj.s.sigma; % example code: set ta by some calculations
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
            % example code: read from input port
            inmessage = obj.x.in2{1};  %#ok<NASGU>
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
            obj.y.out1 = {1};
            obj.y.out2 = {'message'};
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
    

