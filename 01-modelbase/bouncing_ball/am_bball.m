%% HYBRID ATOMIC PDEVS am_bball
%  stored in DEVS_PATH/01-atomic-modelbase/bouncing_ball/am_bball.m

%%
classdef am_bball < hybridatomic
    %% Description
    % Class definition file for an *hybrid atomic PDEVS model*
    % that implements a simple bouncing ball that can be initiated
    % by a discrete event
    %
    % <<img/am_bball.png>>
    %
    % constructor call: |obj =
    % am_bball(name,inistates,c_inistates,elapsed,attenuation)|
    %
    %% Superclass
    % |hybridatomic|
    % (superclass acts as associated hybrid simulator)
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
    % * |dq = f(obj,gt,x,y)|: rate of change function - returns derivations
    % * |ret = cse(obj,gt,y)|: state event condition function - checks, if
    %   there are events
    % * |deltastatefun(obj,gt,y,event_number)|: state event transition function -
    %   describes the reaction on state events
    % * |cy = lambda_c(obj,gt,y)|: continuous output function
    %
    % *display functions:*
    %
    % * |showall(obj)|      : display the object 
    % * |showxports(obj)|   : display x-ports and values 
    % * |showyports(obj)|   : display y-ports and values
    % * |showstates(obj)|   : display states in s
    % * |showsysparams(obj)|: display system parameters in sysparams
    % * |showcontstates(obj)|: display continuous states
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
    % *inherited from hybridatomic:*
    %
    % * |c_states|: vector of continuous variables
    % * |output_length|   : length of output-vector returned by lamda_c
    % * |mealy|: 1 or 0, model is of mealy or moore type 
    %
    %% Ports
    % has one input |x|: in1 for receiving 'start'-event and
    % then start bouncing
    %
    % has one output |y|: out1 for propagating hits
    %
    % Note: _continuous couplings need no ports. They are managed via_
    % _continuous variables' indices._
    %
    %% States
    %
    % *discrete in s:*
    %
    % |s.sigma|: for time advance
    %
    % |s.active|: 0 or 1, 1 if ball is currently bouncing
    %
    % |s.bounce_start|: time of bounce begin
    %
    % |s.bounce_end|: time of bounce end
    %
    %
    % *continuous:*
    %
    % |c_states = [height;velocity]|
    %
    %% Hybrid Characteristics
    %
    % |mealy = 0|: model is of Moore type (needs  no inputs to calculate outputs)
    %
    % |output_length = 1|: the function lamda_c returns 1 element (current
    % height)
    %
    % *state events:*
    %
    % * if ball hits ground
    %
    %% System Parameters in sysparams
    % |sysparams.attenuation| : attenuation/damping parameter 0.5 - 0.9
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
    
    
    properties (Access = public)
         height_traj =[] % 
         event_values = []
    end
    methods
       
        function obj = am_bball(name,inistates,c_inistates,elapsed,attenuation)
                       
            if nargin == 5
                x = {'in1'};
                y = {'out1'};
                s = {'sigma','active','bounce_start','bounce_end'};
                sysparams = struct('attenuation',attenuation);% attenuation/damping parameter 0.5 - 0.9
                c_states = [0;0];% two continuous state variables [height; velocity]
                mealy = 0; % model is of Moore type
            else
                error('mistake at constructor method for class am_bball');
            end
            obj = obj@hybridatomic(name,x,y,s,c_states,mealy,elapsed,sysparams);
            
                       
            % initialize the states
            obj.s.sigma = inistates.sigma;
            obj.s.active = inistates.active;
            obj.s.bounce_start = inistates.bounce_start;
            obj.s.bounce_end = inistates.bounce_end;
            
            obj.c_states = c_inistates;
            
            disp('hybrid bball constructed');                        
        end

        
        function ta = tafun(obj)
            ta = obj.s.sigma; 
        end
        
         
        function deltaconffun(obj,gt)
            deltaintfun(obj); 
            deltaextfun(obj,gt)
                       
            % execute first external function
        end

        
         function deltaextfun(obj,gt) %#ok<*INUSD>
             if strcmp(obj.x.in1{1},'start') % become active if 'start'-message arrives
                obj.s.active = 1; % activate ball
                obj.s.bounce_start = gt; % record time
             end
         end
        
       
        function deltaintfun(obj)
            % do nothing except setting time until next internal event to inf
            obj.s.sigma = inf; 
        end
               
        
        function lambdafun(obj) 
           obj.y.out1 = {1}; % send a signal, that ball hits ground
        end 
        
        
        function dq = f(obj,gt,x,y) %#ok<*INUSL>
            %gt current time, x continuous input vector
            %q local continuous state vector
           if obj.s.active == 0
               dq = [0;0]; 
           else
                dq = [y(2);-9.81];
           end
            obj.c_states(1)= y(1);
            obj.c_states(2)= y(2);
            obj.height_traj = [obj.height_traj; gt,y(1)]; % record values          
            % x not used here, because it's of Moore type
        end
        
       
        function ret = cse(obj,gt,y)
           
           
            %disp(['state event condition function in ',obj.name,' called at t=', num2str(gt)]);
           
            %continuous state value height
                   % |  integration termination event (1/0)
                   % |  |    zero-crossing direction from + to - (1 if event
                   % |  |    fct increases, -1 if decreases)
                   % |  |    |
            ret = [y(1),1,-1];
         end
        
       
        function deltastatefun(obj,gt,y,event_number)
        % state event occurred in THIS atomic 
                obj.c_states(1) = 0; % set height to zero
                obj.c_states(2) = -obj.sysparams.attenuation*y(2);% reverse direction and calculate new velocity
                
                % find out, if this ball is still bouncing or rather is on
                % ground
                obj.event_values = [obj.event_values; gt,y(1)];
                if size(obj.event_values,1) > 1 % if this was a least second hit to ground
                    %disp([ num2str(size(obj.event_values,1)),'. state event in ',obj.name,' at t= ', num2str(gt)])
                    first_index_matrix = (obj.height_traj == obj.event_values(end-1,1)); % find index of next to last event time in traj
                    [row,col] = find(first_index_matrix);
                    test_interval= obj.height_traj(row:end,:); % extract the test interval from height trajectorie
                    if max(test_interval(:,2)) < 0.001 % if maximum value of height between two hits is smaller than 0.001 m, we consider the ball to be in rest
                        obj.s.active=0; % deactivate ball
                        obj.s.bounce_end = gt; % record time
                    end
                    
                end
                obj.s.sigma = 0; % trigger an internal event to send hit-event to hit counter
                
        end
      
        
        function cy = lambda_c(obj,gt,y) 
                cy = y(1);
             % output of current height
        end 
        
                     
    end
        
        
 end

