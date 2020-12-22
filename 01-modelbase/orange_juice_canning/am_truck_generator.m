%% ATOMIC PDEVS am_truck_generator
%  stored in DEVS_PATH/01-modelbase/orange_juice_canning/am_truck_generator.m

%%
classdef am_truck_generator < atomic
    %% Description
    % Class definition file for an *atomic PDEVS model*
    % that implements a generator with random interarrival times.
    %
    % <<img/am_truck_generator.png>>
    %
    % constructor call: |obj =
    % am_truck_generator(name,inistates,elapsed,random_seed)|
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
    % has one output |y|: p1
    %
    %% States in s
    %
    % |s.sigma|: for time advance
    %
    % |s.rand_state|: random number generator settings
    %
    % |s.number_generated|: count the number of trucks
    %
    % |s.generation_times|: save the generation times
    %
    %% System Parameters in sysparams
    % |sysparams.random_seed|  : seed for random number generator
    %
    %% More
    %
    % |global SIMUSTOP| : can be used to stop allover simulation e.g. when a
    % predefined number of trucks has been generated.
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
        
        function obj = am_truck_generator(name,inistates,elapsed,random_seed)
            if nargin == 4
                x = {};
                y = {'p1'};      % to emit trucks
                s = {'sigma','rand_state','number_generated','generation_times'};
                sysparams = struct('random_seed', random_seed);
            else
                error('mistake at constructor method for class am_truck_generator');
            end
            obj = obj@atomic(name,x,y,s,elapsed,sysparams);% incarnate the associated simulator
            % initialize the states
            obj.s.sigma = inistates.sigma;
            obj.s.rand_state = inistates.rand_state;
            obj.s.number_generated = inistates.number_generated;
            obj.s.generation_times = inistates.generation_times;
            rng(sysparams.random_seed); % initialize random number generator
            obj.s.rand_state = rng;% save generator settings
            disp('pure discrete truck generator constructed');
        end

        
        function ta = tafun(obj)
            ta = obj.s.sigma;
        end
        
        
        function deltaconffun(obj,gt) %#ok<*INUSD>
            % not filled, because no external events
        end

        
        function deltaextfun(obj,gt)
            % no external events here
        end
        
       function deltaintfun(obj)
            obj.s.number_generated =  obj.s.number_generated + 1;
            % if obj.s.number_generated > 20
            %   SIMUSTOP = 1;
            % end
            obj.s.generation_times =  [obj.s.generation_times;obj.tnext];
            rng(obj.s.rand_state); % restore previous generator settings
            obj.s.sigma = 44*(-log(1-rand));
            % exponential distributed arrival time, mean 44 minutes
            obj.s.rand_state = rng; % save generator settings             
        end
               
        
        function lambdafun(obj) 
            obj.y.p1 = {1};%generate a truck
        end 
    
    end
        
        
 end

