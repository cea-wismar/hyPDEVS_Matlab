%% ATOMIC PDEVS am_dock_undock_server
%  stored in DEVS_PATH/01-modelbase/orange_juice_canning/am_dock_undock_server.m

%%
classdef am_dock_undock_server < atomic
     %% Description
    % Class definition file for an *atomic PDEVS model* that models a server for the docking and undocking process, service time is uniformly distributed
    %
    % <<img/am_dock_undock_server.png>>
    %
    % constructor call: |obj =
    % am_dock_undock_server(name,inistates,elapsed,service_time,random_seed)|
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
    % has one input |x|: p1 for incoming trucks
    %
    % has two outputs |y|: out1 and out2, first to send jobs to next process step, other for signaling
    %
    %% States in s
    %
    % |s.sigma|: for time advance
    %
    % |s.rand_state|: random number generator settings
    %
    %% System Parameters in sysparams
    % |sysparams.service_time| : interval for uniform distribution of service time
    %
    % |sysparams.random_seed|  : seed for random number generator
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
    %
    %
    
    methods
       
        function obj = am_dock_undock_server(name,inistates,elapsed,service_time,random_seed)
            if nargin == 5
                x = {'p1'};           % incoming jobs
                y = {'out1','out2'};   % 1 to send jobs to next station, other for signaling
                s = {'sigma','rand_state'};
                sysparams = struct('service_time', service_time, 'random_seed', random_seed);
            else
                error('mistake at constructor method for class am_dock_undock_server');
            end
            obj = obj@atomic(name,x,y,s,elapsed,sysparams);% incarnate the associated simulator
            % obj.service_time = service_time;% interval for uniform distribution
            % initialize the states
            obj.s.sigma = inistates.sigma;
            obj.s.rand_state = inistates.rand_state;
            rng(sysparams.random_seed); % initialize random number generator
            obj.s.rand_state = rng;% save generator settings
            disp('pure discrete dock/undock server constructed');
        end

        
        function ta = tafun(obj)
            ta = obj.s.sigma;
        end
        
        
        function deltaconffun(obj,gt)
            deltaintfun(obj);
            deltaextfun(obj,gt);
            % execute first internal function
        end

       
        function deltaextfun(obj,gt) %#ok<INUSD>
            if obj.x.p1{1} == 1 % if this was an truck for unloading, not an empty message
                rng(obj.s.rand_state); % restore previous generator settings
                obj.s.sigma = obj.sysparams.service_time(2) + (obj.sysparams.service_time(1)-obj.sysparams.service_time(2)).*rand;
                % uniformly distributed serving time, interval from
                % obj.service_time
                obj.s.rand_state = rng; % save generator settings
            end
        end
        
        
        function deltaintfun(obj)
            obj.s.sigma = inf;
            % remain inactive till next truck arrives
        end
       
        function lambdafun(obj)
            obj.y.out1 = {1}; % send a truck
            obj.y.out2 = {'send_next'}; % send the queue a signal to send next truck
        end 
               
    end        
        
 end

