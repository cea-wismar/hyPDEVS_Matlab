%% ATOMIC PDEVS event_detect
%  stored in DEVS_PATH/01-modelbase/qss/event_detect.m

%%
classdef event_detect < atomic
    %% Description
    % Class definition file for an *atomic PDEVS model*
    % which acts as QSS1 event detection for model of bouncing ball.
    % Becomes active, when ball hits the ground,
    %
    % It is not an universal QSS1 event detection atomic, because detection of state events depends on
    % model. THIS event detection atomic reacts on a zero-crossing from +
    % to - .
    % It could act as blueprint to develop QSS1 event detection atomics for other
    % purposes.
    %
    % <<img/event_detect.png>>
    %
    % constructor call: |obj = event_detect(name,inistates,elapsed)|
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
    % has one input |x| : in1 for quantized rate of change
    %
    % has one output |y| : out1, output a state event signal
    %
    %% States in s
    % |s.sigma| : for time advance
    %
    % |s.X| : X values
    %
    % |s.dX| : derivation
    %
    % |s.traj| : to manually record exact values (X/t pairs)
    %
    % |s.se| : marks, if an event is possible. Is set to 1, if
    % derivation s.dX is < 0 and set to 0 otherwise.
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
        
        function obj = event_detect(name,inistates,elapsed)
            if nargin == 3
                x = {'in1'};
                y ={'out1'};
                s = {'sigma','X','dX','se','traj','eventtraj'};% states
                sysparams = {};
            else
                error('mistake at constructor method for event_detect');
            end
            
            obj = obj@atomic(name,x,y,s,elapsed,sysparams);% incarnate the associated simulator
            
            % initialize the states
            obj.s.sigma = inistates.sigma;
            obj.s.X = inistates.X;
            obj.s.dX = inistates.dX;
            obj.s.se = inistates.se;
            obj.s.traj = inistates.traj;
            obj.s.eventtraj = inistates.eventtraj;
        end

        
        function ta = tafun(obj)
            ta = obj.s.sigma;
        end
        
        
        function deltaconffun(obj,gt)
            deltaextfun(obj,gt);
            deltaintfun(obj); % if external and internal event at the same time, first execute external event
        end

        
        function deltaextfun(obj,gt)
            obj.elapsed = gt - obj.tlast; % calculate time since last event
            obj.s.X = obj.s.X + obj.elapsed * obj.s.dX; % calculate state
            obj.s.traj = [obj.s.traj;gt, obj.s.X]; % record
            obj.s.dX = obj.x.in1{1}; % safe rate of change from input; input is a QUANTIZED rate of change
            
            if (obj.s.X > 0) % if ball is above floor
                if (obj.s.dX < 0) % if falling down currently
                    dt = - obj.s.X /obj.s.dX;% calculate, when it would become zero and hit the ground
                    obj.s.sigma = dt; % schedule an internal event then
                    obj.s.se = 1; % fill state event variable, because state event is possible
                else % if flying up currently
                    obj.s.sigma = inf; % nothing could happen ;-), so nothing to schedule
                    obj.s.se = 0; % no possible event
                end
            elseif (obj.s.X == 0)
                obj.s.sigma = inf;
            else
                if ((obj.s.X + obj.epsi) < 0)
                    disp(['error in deltaext of ',obj.name,' called at t=', num2str(gt), ' ball should not be under ground' ]);
                    disp(['obj.s.X is ',num2str(obj.s.X)]);
                    disp(['obj.s.dX is ',num2str(obj.s.dX)]);
                end
            end
        end
        
        
        function deltaintfun(obj)
            obj.s.X = obj.s.X + obj.s.sigma * obj.s.dX; % calculate actual state
            obj.s.eventtraj = [obj.s.eventtraj; obj.s.X, obj.tnext];% X-values are all 0, t times, where they become 0
            obj.s.sigma = inf;
        end
               
       
        function lambdafun(obj)
            obj.y.out1 = {obj.s.se}; % send state event
        end
                
    end        
        
 end

