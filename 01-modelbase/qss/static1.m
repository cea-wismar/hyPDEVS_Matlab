%% ATOMIC PDEVS static1
%  stored in DEVS_PATH/01-modelbase/qss/static1.m

%%
classdef static1 < atomic
    %% Description
    % Class definition file for an *atomic PDEVS model*
    % that implements a QSS1 static bloc.
    %
    % <<img/static1.png>>
    %
    % constructor call: |obj =
    % static1(name,inistates,elapsed,rate_of_change)|
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
    % * |debug_flag|: 0|1|2, no messages|messages|steps (default 0)
    % * |observe_flag|: 0|1, log states of atomic subcomponents or not (default 0)
    % * |observed|  : cell array including time stamps and a copy of s (structure of states)
    %
    %% Ports
    % has one input |x| : in1 to trigger output
    %
    % has one output |y| : out1, output for current value of equation
    %
    %% States in s
    % |s.sigma| : for time advance
    %
    % |s.rate| : rate of change
    %
     %% System Parameters in sysparams
    % |sysparams.rate_of_change| : rate of change does never change, is
    % copied to s.rate
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
        function obj = static1(name,inistates,elapsed,rate_of_change)
            if nargin == 4
                x ={'in1'};
                y = {'out1'};
                s ={'sigma','rate'};% states
                sysparams = struct('rate_of_change',rate_of_change); % rate of change does never change --> could be a system paramter here!
            else
                error('mistake at constructor method for qss1');
            end
            
            obj = obj@atomic(name,x,y,s,elapsed,sysparams);% incarnate the associated simulator
            
            % initialize the states
            obj.s.sigma = inistates.sigma;
            obj.s.rate = inistates.rate;
            obj.s.rate = sysparams.rate_of_change;
        end

       
        function ta = tafun(obj)
            ta = obj.s.sigma;
        end
        
        function deltaconffun(obj,gt)
            deltaintfun(obj);
            deltaextfun(obj,gt); % if external and internal event at the same time, first execute internal event
        end

       
        function deltaextfun(obj,gt) %#ok<*INUSD>
            obj.s.sigma = 0; % schedule an internal event and output event before
        end
        
        
        function deltaintfun(obj)
            obj.s.sigma =inf;
        end
        
        function lambdafun(obj)
            obj.y.out1 = {obj.s.rate}; % output current rate of change
        end 
        
    end       
        
 end

