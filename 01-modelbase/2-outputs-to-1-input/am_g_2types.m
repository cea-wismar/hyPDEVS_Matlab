%% ATOMIC PDEVS am_g_2types
%  stored in DEVS_PATH/01-atomic-modelbase/2-outputs-to-1-input/am_g_2types.m

%%
classdef am_g_2types < atomic
    %% Description
    % Class definition file for an *atomic PDEVS model*
    % for generating workpieces of different types with deterministic interarrival times.
    %
    % <<img/am_g_2types.png>>
    %
    % constructor call: |obj =
    % am_g_2types(name,inistates,elapsed,outtype)|
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
    % has one output |y| : p1 to send workpieces
    %
    %% States in s
    % |s.sigma| : for time advance; is interarrival time of workpieces
    %
    % |s.counter| : to count number of workpieces generated
    %
    %% System Parameters in sysparams
    % |sysparams.outtype|: 'type1' or 'type2'
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
        function obj = am_g_2types(name,inistates,elapsed,outtype)
            if nargin == 4
                x = {};
                y = {'p1'}; % to emit workpieces
                s = {'sigma','counter'};
                sysparams = struct('outtype',outtype); % values 'type1' | 'type2'
             else
                error('mistake at constructor method for class am_generator');
            end
            obj = obj@atomic(name,x,y,s,elapsed,sysparams);% incarnate the associated simulator
            % initialize the states
            obj.s.sigma = inistates.sigma; % sigma equates interarrival_time
            obj.s.counter = inistates.counter;
            
            obj.observed =1;
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
           obj.s.counter = obj.s.counter + 1;
        end
               
        function lambdafun(obj)
          obj.y.p1 = {obj.sysparams.outtype,1}; % generate a workpiece and send to output port p1
        end
       
    end
        
        
 end


