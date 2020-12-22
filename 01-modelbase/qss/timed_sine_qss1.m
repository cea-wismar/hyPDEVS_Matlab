%% ATOMIC PDEVS timed_sine_qss1
%  stored in DEVS_PATH/01-modelbase/qss/timed_sine_qss1.m

%%
classdef timed_sine_qss1 < atomic
 %% Description
    % Class definition file for an *atomic PDEVS model*
    % for generating a timed sine wave. It emits a sine value
    % every sigma units of time.
    %
    % <<img/timed_sine_qss1.png>>
    %
    % constructor call: |obj = timed_sine_qss1(name,inistates,elapsed)|
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
    % has no input |x| (is pure source)
    %
    % has one output |y| : p1 for sine value
    %
    %% States in s
    % |s.sigma| : for time advance (fixed steps)
    %
    % |s.sine| : sine values for each step
    %
     %% System Parameters in sysparams
    % none
    %
     %% More
    %
    % |global SIMUSTOP| : can be used to stop allover simulation e.g. when a
    % predefined number of jobs has finished
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
        
        function obj = timed_sine_qss1(name,inistates,elapsed)
            if nargin == 3
                x = {};
                y ={'p1'};
                s = {'sigma','sine'};
                sysparams= {};
            else
                error('mistake at constructor method for class timed_sine_qss1');
            end
            obj = obj@atomic(name,x,y,s,elapsed,sysparams);% incarnate the associated simulator
            % initialize the states
            obj.s.sigma = inistates.sigma;
            obj.s.sine = inistates.sine;
        end

       
        function ta = tafun(obj)
            ta = obj.s.sigma;
        end
        
        
        function deltaconffun(obj,gt)
            % nothing to do here, because external events and therefore simultaneous events don't take place
        end

        function deltaextfun(obj,gt)
            % nothing to do here, because external events don't take place
        end
        
        
        function deltaintfun(obj)
            obj.s.sine=sin(obj.tnext);
        end
               
        
        function lambdafun(obj)
            obj.y.p1 = {sin(obj.tnext)};
        end        
        
    end        
        
 end

