%% ATOMIC PDEVS am_t
%  stored in DEVS_PATH/01-atomic-modelbase/2-outputs-to-1-input/am_t.m

%%
classdef am_t < atomic
    %% Description
    % Class definition file for an *atomic PDEVS model*
    % for counting assembled parts
    %
    % <<img/am_t.png>>
    %
    % constructor call: |obj = am_t(name,inistates,elapsed)|
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
    % has one input |x| : p1 to get parts
    %
    % has no output |y| (is pure sink)
    %
    %% States in s
    % |s.q| : counter for incoming workpieces
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
        function obj = am_t(name,inistates,elapsed)
            if nargin == 3
                x = {'p1'};% create one input port
                y = {};% no output ports
                s = {'q'};% counter for incoming jobs
                sysparams = [];
            else
                error('mistake at constructor method for class am_t');
            end
            obj = obj@atomic(name,x,y,s,elapsed,sysparams);% incarnate the associated simulator
            % initialize the state
            obj.s.q = inistates.q;          
        end
        
        
        function ta = tafun(obj) %#ok<*MANU>
            ta = inf; % no internal events
        end
        
        
        function deltaconffun(obj,gt) %#ok<*INUSD>
           % empty, because no internal events
         end
        
       
        function deltaextfun(obj,gt)
            global SIMUSTOP %#ok<NUSED>
            obj.s.q = obj.s.q + obj.x.p1{2};% count the job from input port p1
            % if obj.s.q >= 6 % stop simulation, when 6 jobs are done, SIMUSTOP-test
            %            SIMUSTOP = 1;
            %  end
        end

        
        function deltaintfun(obj)
            % no internal events
        end
               
              
       function lambdafun(obj)
            % lambdafun is never called, since there are no internal events
        end

    end
        
        
 end
