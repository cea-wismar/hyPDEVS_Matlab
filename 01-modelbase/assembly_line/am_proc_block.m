%% ATOMIC PDEVS am_proc_block
%  stored in DEVS_PATH/01-modelbase/assembly_line/am_proc_block.m

%%   
classdef am_proc_block < atomic
    %% Description
    % Class definition file for an *atomic PDEVS model*
    % for processing workpieces. 
    %
    % <<img/am_proc_block.png>>
    %
    % This block assembles workpieces from two queues.
    % FIFO queues for workpieces are included.
    %
    % constructor call: |obj =
    % am_proc_block(name,inistates,elapsed,service_time)|
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
    % has two inputs |x| : p1 and p2 for incoming workpieces
    %
    % has one output |y| : p1 for processed (assembled) parts
    %
    %% States in s
    % |s.phase| : active or passive
    %
    % |s.sigma| : for time advance
    %
    % |s.q1| : length of queue for workpieces of type 1
    %
    % |s.q2| : length of queue for workpieces of type 2
    %
    %% System Parameters in sysparams
    % |sysparams.service_time| : time it takes to assemble a part from two workpieces
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
        function obj = am_proc_block(name,inistates,elapsed,service_time)
            if nargin == 4
                x = {'in1','in2'};
                y = {'out1'};
                s = {'phase','sigma','q1','q2'};
                sysparams = struct('service_time', service_time);
            else
                error('mistake at constructor method for class am_proc_block');
            end
            
            obj = obj@atomic(name,x,y,s,elapsed,sysparams);% incarnate the associated simulator
            % user defined input argument
            % obj.sysparams.service_time is copied to obj.s.sigma later
            % initialize the states
            obj.s.phase = inistates.phase;
            obj.s.sigma = inistates.sigma;
            obj.s.q1 = inistates.q1;
            obj.s.q2 = inistates.q2;
        end
        
        function ta = tafun(obj)
            ta=obj.s.sigma; % normally inf OR obj.sysparams.service_time
        end
        
        function deltaconffun(obj,gt)
            deltaintfun(obj);
            obj.tlast = gt; % results in elapsed = 0 in deltaextfun
            deltaextfun(obj,gt);
            % first let job leave from processing block, then let new
            % workpiece come in
        end
        
        function deltaextfun(obj,gt)
            elapsed = gt - obj.tlast;
            if strcmp(obj.s.phase,'passive') && ~isempty(obj.x.in1) && isempty(obj.x.in2)...
                    && obj.s.q2 == 0
                obj.s.q1 = obj.s.q1 + obj.x.in1{1};
            elseif strcmp(obj.s.phase,'passive') && isempty(obj.x.in1) &&...
                    ~isempty(obj.x.in2) && obj.s.q1 == 0
                obj.s.q2 = obj.s.q2 + obj.x.in2{1};
            elseif strcmp(obj.s.phase,'passive') && ~isempty(obj.x.in1) &&...
                    isempty(obj.x.in2) && obj.s.q2~=0
                obj.s.phase = 'active';
                obj.s.sigma = obj.sysparams.service_time;
                obj.s.q1 = obj.s.q1 + obj.x.in1{1}-1;
                obj.s.q2 = obj.s.q2 - 1;
            elseif strcmp(obj.s.phase,'passive') && isempty(obj.x.in1) &&...
                    ~isempty(obj.x.in2) && obj.s.q1~=0
                obj.s.phase = 'active';
                obj.s.sigma = obj.sysparams.service_time;
                obj.s.q1 = obj.s.q1-1;
                obj.s.q2 = obj.s.q2+obj.x.in2{1}-1;
            elseif strcmp(obj.s.phase,'passive') && ~isempty(obj.x.in1) &&...
                    ~isempty(obj.x.in2)
                obj.s.phase = 'active';
                obj.s.sigma = obj.sysparams.service_time;
                obj.s.q1 = obj.s.q1+obj.x.in1{1}-1;
                obj.s.q2 = obj.s.q2+obj.x.in2{1}-1;
            elseif strcmp(obj.s.phase,'active')
                obj.s.sigma=obj.s.sigma-elapsed;
                if ~isempty(obj.x.in1)
                    obj.s.q1 = obj.s.q1+obj.x.in1{1};
                end
                if ~isempty(obj.x.in2)
                    obj.s.q2 = obj.s.q2+obj.x.in2{1};
                end
            end
        end
        
        function deltaintfun(obj)
            if strcmp(obj.s.phase,'passive')
                disp(['error phase in ',obj.name,' is passive at call of deltaintfun']);
                showall(obj);
                pause;
            end
            
            if obj.s.q1 >= 1 && obj.s.q2 >= 1 % if there are jobs waiting in both queues
                obj.s.sigma = obj.sysparams.service_time;% set time until next internal event to service_time
                obj.s.q1 = obj.s.q1-1; % decrement queue 1
                obj.s.q2 = obj.s.q2-1; % decrement queue 2
            else
                obj.s.phase='passive';
                obj.s.sigma=inf;
            end
        end
               
        function lambdafun(obj)
            obj.y.out1 = {1};% send an assembled part to output
        end
            
    end
        
        
 end

