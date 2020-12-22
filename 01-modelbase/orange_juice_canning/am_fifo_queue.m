%% ATOMIC PDEVS am_fifo_queue
%  stored in DEVS_PATH/01-modelbase/orange_juice_canning/am_fifo_queue.m

%%
classdef am_fifo_queue < atomic
    %% Description
    % Class definition file for an *atomic PDEVS model*
    % that implements a first-in-first-out queue
    %
    % <<img/am_fifo_queue.png>>
    %
    % constructor call: |obj =
    % am_fifo_queue(name,inistates,elapsed)|
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
    % has two inputs |x|: in1 and in2, first port for trucks, other one for signal
    %
    % has one output |y|: out1 (send trucks to docking process)
    %
    %% States in s
    % |s.sigma|: for time advance
    %
    % |s.queue_length|: length of queue
    %
    % |s.queue_stats|: queue statistics, t/length pairs
    %
    % |s.requested|: save request for next truck
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
    %
    %
    
    
    methods
        
        function obj = am_fifo_queue(name,inistates,elapsed)
            if nargin == 3
                x = {'in1','in2'};% 1 port for trucks, one for signal
                y = {'out1'};        % to send trucks to docking
                s = {'sigma','queue_length','queue_stats','requested'};
                sysparams = {};
            else
                error('mistake at constructor method for class am_fifo_queue');
            end
            obj = obj@atomic(name,x,y,s,elapsed,sysparams);% incarnate the associated simulator
            % initialize the states
            obj.s.sigma = inistates.sigma;
            obj.s.queue_length = inistates.queue_length;
            obj.s.queue_stats = inistates.queue_stats;
            obj.s.requested = inistates.requested;
            disp('pure discrete fifo queue for trucks constructed');
        end

       
        function ta = tafun(obj)
            ta = obj.s.sigma;
        end
        
        
        function deltaconffun(obj,gt)
            deltaintfun(obj);
            deltaextfun(obj,gt);
            % execute first internal transistion function --> remove item from queue,
            % before a new comes in
        end

        
        function deltaextfun(obj,gt)
            if ~isempty(obj.x.in1)
                if obj.x.in1{1} == 1
                    obj.s.queue_length = obj.s.queue_length + 1; %add an item to queue
                    obj.s.queue_stats = [obj.s.queue_stats;gt,obj.s.queue_length]; %record statistics
                    if obj.s.requested == 1 % if process asked for new item, not yet send
                        obj.s.sigma = 0;
                    else
                        obj.s.sigma = inf; % do nothing
                    end
                end
            end
            if ~isempty(obj.x.in2)
                if strcmp(obj.x.in2{1},'send_next') && (obj.s.queue_length > 0)
                    obj.s.sigma = 0; %time an internal event NOW
                elseif strcmp(obj.x.in2{1},'send_next') && (obj.s.queue_length == 0)
                    obj.s.requested = 1; % process asks for next item, but there is no in queue
                    obj.s.sigma = inf;
                end
            end
        end
        
        
        function deltaintfun(obj)
            obj.s.queue_length = obj.s.queue_length - 1; %remove an item from queue
            obj.s.queue_stats = [obj.s.queue_stats;obj.tnext,obj.s.queue_length]; %record statistics
            obj.s.requested = 0; % reset
            obj.s.sigma = inf;
            % remain inactive till next truck arrives
        end
               
        
        function lambdafun(obj)
            obj.y.out1 = {1}; % send a truck
        end
                       
    end        
        
 end

