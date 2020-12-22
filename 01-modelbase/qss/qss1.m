%% ATOMIC PDEVS qss1
%  stored in DEVS_PATH/01-modelbase/qss/qss1.m

%%
classdef qss1 < atomic
    %% Description
    % Class definition file for an *atomic PDEVS model*
    % which acts as QSS1 integrator. State event retection is provided in a model of a bouncing ball.
    %
    % It is not an universal QSS1 integrator, because reaction on state events depends on
    % model. THIS integrator reverses direction and attenuates the movement, when a state event message arrives at input in2.
    % It could act as blueprint to develop QSS1 integrators for other
    % purposes.
    % But as long as you just want to integrate and leave the input in2
    % just unconnected, then it is fine ;-) ;
    %
    % <<img/qss1.png>>
    %
    % constructor call: |obj = qss1(name,inistates,elapsed,epsilon,dq)|
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
    % has two inputs |x| : in1 and in2, one for input of rate of change, one
    % for state events
    %
    % has one output |y| : out1, output for quantized states
    %
    %% States in s
    % |s.sigma| : for time advance
    %
    % |s.X| : X values
    %
    % |s.dX| : derivation
    %
    % |s.q| :  quantized state
    %
    % |s.se| : marks, if state event occurred
    %
    % |s.traj| : to manually record exact values (X/t pairs)
    %
    % |s.qtraj| : to manually record quantized  values (q/t pairs)
    %
    %
     %% System Parameters in sysparams
    % |sysparams.epsilon| : hysteresis
    %
    % |sysparams.dq| : quantum --> accuracy = quantization level of QSS1-Integrator
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
        
        function obj = qss1(name,inistates,elapsed,epsilon,dq)
            if nargin == 5
                x = {'in1','in2'};
                y = {'out1'};
                s = {'sigma','X','dX','q','se','traj','qtraj'};%states
                sysparams = struct('epsilon',epsilon, 'dq',dq);
            else
                error('mistake at constructor method for qss1');
            end
            
            obj = obj@atomic(name,x,y,s,elapsed,sysparams);% incarnate the associated simulator
            
            % initialize the states
            obj.s.sigma = inistates.sigma;
            obj.s.X = inistates.X;
            obj.s.dX = inistates.dX;
            obj.s.q = inistates.q;
            obj.s.se = inistates.se;
            obj.s.traj = inistates.traj;
            obj.s.qtraj = inistates.qtraj;
            
        end

       
        function ta = tafun(obj)
            ta = obj.s.sigma;
        end
        
        
        function deltaconffun(obj,gt)
            deltaintfun(obj);% xxx
            obj.tlast=gt;
            deltaextfun(obj,gt); % if external and internal event at the same time, execute internal event first
            %deltaintfun(obj);
        end

        function deltaextfun(obj,gt)
            obj.elapsed = gt - obj.tlast;% calculate time since last event
            obj.s.X = obj.s.X + obj.s.dX * obj.elapsed; % calculate actual state from state before this event and rate of change until now
            obj.s.traj = [obj.s.traj; gt,obj.s.X,1]; % add X/t-pair to trajectory
            if ~isempty(obj.x.in2) && (obj.x.in2{1} == 1) % if state event
                % changes in X just in internal
                obj.s.se = obj.x.in2{1};% copy event to state se
                obj.s.sigma = 0;
                obj.x.in2 = {0};% reset
                %else
            elseif ~isempty (obj.x.in1) %test, test, sonst nur else
                if (obj.x.in1{1} > 0 ) % if there is a positive rate of change at input-port
                    obj.s.sigma = (obj.s.q + obj.sysparams.dq - obj.s.X) / obj.x.in1{1}; % calculate time of next internal event
                elseif (obj.x.in1{1} < 0 ) % if there is a negative rate of change at input-port
                    obj.s.sigma = (obj.s.q - obj.sysparams.epsilon - obj.s.X) / obj.x.in1{1}; % calculate time of next internal event
                else % if there is no change at input-port
                    obj.s.sigma = inf ;
                end
                obj.s.dX = obj.x.in1{1};
            end
        end
        
       
        function deltaintfun(obj)
            obj.s.X = obj.s.X + obj.s.sigma * obj.s.dX; % calculate actual state
            if obj.s.se ==1
                % what happens, if an event is detected depends on model
                % BOC user-defined
                disp(['internal event after on floor at tnext= ', num2str(obj.tnext)]);
                disp(['X before direction change:',num2str(obj.s.X)])
                obj.s.X = - obj.s.X * 0.95; % reverse direction and damping
                disp(['X after direction change:',num2str(obj.s.X)]);
                % EOC user-defined
            end
            if (obj.s.dX > 0) % for positive change
                obj.s.sigma = obj.sysparams.dq / obj.s.dX; % calculate time until next internal event
                if obj.s.se
                    disp(['q before direction change:',num2str(obj.s.q)]);
                    
                end
                obj.s.q = obj.s.q + obj.sysparams.dq; % add a quantum to quantized state
                if obj.s.se
                    obj.s.q= floor(-obj.s.q*0.95/obj.sysparams.dq)*obj.sysparams.dq;
                    disp(['q after direction change:',num2str(obj.s.q)]);
                end
            elseif (obj.s.dX < 0) % for negative change
                obj.s.sigma = - obj.sysparams.dq / obj.s.dX; % calculate time until next internal event
                if obj.s.se
                    disp(['q before direction change:',num2str(obj.s.q)]);
                    
                end
                obj.s.q = obj.s.q - obj.sysparams.dq; % substract a quantum from quantized state
                if obj.s.se
                    %obj.s.q=- obj.s.q*0.95;
                    obj.s.q= floor(-obj.s.q*0.95/obj.sysparams.dq)*obj.sysparams.dq;
                    disp(['q after direction change:',num2str(obj.s.q)]);
                end
            else
                obj.s.sigma = inf;
            end
            %obj.s.traj=[obj.s.traj;obj.tnext, obj.s.X,2]; % add X/t-pair to X-trajectorie
            obj.s.qtraj=[obj.s.qtraj;obj.tnext, obj.s.q]; % add q/t-pair to q-trajectorie
            obj.s.se=0; %reset state event
        end
               
       
        function lambdafun(obj)
            if (obj.s.dX == 0) %if there is no change at the moment
                if obj.s.se
                    % obj.y.out1 = - obj.s.q*0.95;
                    obj.y.out1= {floor(-obj.s.q*0.95/obj.sysparams.dq)*obj.sysparams.dq};
                else
                    obj.y.out1 = obj.s.q; % copy actual quantized state to output-port
                end
            else
                if obj.s.se
                    % obj.y.out1 = - obj.s.q*0.95 + obj.sysparams.dq * obj.s.dX / abs(obj.s.dX); % add or substract a quantum and copy value to output-port
                    obj.y.out1 = {floor(-obj.s.q*0.95/obj.sysparams.dq)*obj.sysparams.dq + obj.sysparams.dq * obj.s.dX / abs(obj.s.dX)};
                else
                    obj.y.out1 = {obj.s.q + obj.sysparams.dq * obj.s.dX / abs(obj.s.dX)}; % add or substract a quantum and copy value to output-port
                end
            end
        end
       
    end        
        
 end

