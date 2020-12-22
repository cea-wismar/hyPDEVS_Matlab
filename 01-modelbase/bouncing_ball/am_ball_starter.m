%% ATOMIC PDEVS am_ball_starter
%  stored in DEVS_PATH/01-atomic-modelbase/bouncing_ball/am_ball_starter.m

%%
classdef am_ball_starter < atomic
    %% Description
    % Class definition file for an *atomic PDEVS model*
    % for activating a bouncing ball. Sends one 'start'-event
    %
    % <<img/am_ball_starter.png>>
    %
    % constructor call: |obj =
    % am_ball_starter(name,inistates,elapsed)|
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
    % * |s|         : structure, set of states% * |sysparams| : structure, set of system parameters, can be set only once at instantiation
    % * |sysparams| : structure, set of system parameters, can be set only once at instantiation
    % * |elapsed|   : float, time elapsed since last 
    %                 transition (only for initialization)
    %
    % * |debug_flag|: 0|1|2|3, no messages|messages|steps|visualize x, y, and s (default 0)
    % * |observe_flag|: 0|1, log states of atomic subcomponents or not (default 0)
    % * |observed|  : cell array including time stamps and a copy of s (structure of states)
    %
    %% Ports
    % has no inputs |x| (is pure source)
    %
    % has one output |y| : p1 to send 'start'-event to ball
    %
    %% States in s
    % |s.sigma| : for time advance
    %
    %% System Parameters in sysparams
    % none
    %
    %% More
    %
    % |global SIMUSTOP| : can be used to stop allover simulation e.g. when a
    % predefined number of jobs has finished. Take a look at the comments in
    % deltaextfun() where you find example usage.
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
    %
    %    
    methods
        function obj = am_ball_starter(name,inistates,elapsed)
            if nargin == 3
                x = {};
                y = {'p1'};
                s = {'sigma'};
                sysparams = {};
            else
                error('mistake at constructor method for class am_generator');
            end
            obj = obj@atomic(name,x,y,s,elapsed,sysparams);% incarnate the associated simulator
            % initialize the states
            obj.s.sigma = inistates.sigma;
            disp('pure discrete ball starter constructed')
        end
        
        function ta = tafun(obj)
             ta = obj.s.sigma;
        end
        
        function deltaconffun(obj,gt) %#ok<*INUSD>
            % nothing to do here, because external events and therefore simultaneous events don't take place
        end
        
        function deltaextfun(obj,gt)
            % nothing to do here, because external events don't take place
        end
        
        function deltaintfun(obj)
           obj.s.sigma = inf; % just one 'start'-event, inactive for rest of simulation 
        end
               
        function lambdafun(obj)
            obj.y.p1 = {'start'}; % send an 'start'-event to output port p1
        end
       
    end
        
        
 end


