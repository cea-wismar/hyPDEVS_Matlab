%% HYBRID ATOMIC PDEVS am_tank
%  stored in DEVS_PATH/01-atomic-modelbase/orange_juice_canning/tank.m

%%
classdef am_tank < hybridatomic
    %% Description
    % Class definition file for an *hybrid atomic PDEVS model*
    % that implements a tank.
    %
    % <<img/am_tank.png>>
    %
    % constructor call: |obj =
    % am_tank(name,inistates,c_inistates,elapsed)|
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
    %
    % has no inputs |x|
    %
    % has two outputs |y|: out1 and out2,  1 to send signals to trucks, one to send signals to canning process
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
    % |s.filling_suspended|: 0 or 1, 1 if unloading is allowed, 0 if not
    %
    % |s.event_type|: |'stop_filling'| or |'continue_filling'| or
    % |'stop_canning'|
    %
    %
    % *continuous:*
    %
    % |c_states = [TankLevel; TankRate]|
    %
    %% Hybrid Characteristics
    %
    % |mealy = 1|: model is of Mealy type
    %
    % |output_length = 1|: the function lamda_c returns 1 element
    %
    % *state events:*
    %
    % * if filled with 6000 gallons,
    % * if sunk to 5500 gallons,
    % * if empty 
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
    
    properties (Access = public)
           
    end
    
    methods
        
        function obj = am_tank(name,inistates,c_inistates,elapsed)
            if nargin == 4
                x = {}; % no discrete inport
                y = {'out1','out2'};    % 2 for signals to truck and canning
                s = {'sigma','filling_suspended','event_type'};   
                sysparams = {};
                c_states = [0; 0];               % tanklevel and tankrate
                mealy = 1; % model is of Mealy type
            else
                error('mistake at constructor method for class am_tank');
            end
            obj = obj@hybridatomic(name,x,y,s,c_states,mealy,elapsed,sysparams);% incarnate the associated hybrid simulator
            % set hybrid parameters
            
            obj.output_length = 1; % the function lamda_c returns 1 element
            % initialize the continuous states
            obj.c_states = c_inistates;
            % initialize the discrete states
            obj.s.sigma = inistates.sigma;
            obj.s.filling_suspended = inistates.filling_suspended; 
            obj.s.event_type = inistates.event_type;
            disp('hybrid tank constructed');
          end

        
        function ta = tafun(obj)
           ta = obj.s.sigma; 
        end
        
       
        function deltaconffun(obj,gt)  %#ok<*INUSD>
            % no discrete external events!
        end

        
        function deltaextfun(obj,gt)        
             % no discrete external events!                             
        end
        
       
        function deltaintfun(obj)
             obj.s.sigma = inf;
        end
               
        
        function lambdafun(obj) 
           if strcmp(obj.s.event_type,'stop_filling')
                obj.y.out1 = {0}; % send truck a don't-fill-signal
            elseif strcmp(obj.s.event_type,'continue_filling')
                obj.y.out1 = {1}; % send truck a do-fill-signal
                %pause;
            elseif strcmp(obj.s.event_type,'stop_canning')
                obj.y.out2 = {0}; % send the canning an tank-empty message
            else
                disp('something wrong with lambda of the tank ;-)');
            end
            
        end 
        
       
        function dq = f(obj,gt,x,y) %#ok<*INUSL>
           dq(1) = -x(1)-x(2);% derivation is the the sum of inflow and outflow
           %disp(dq(1));
           dq(2) = 0;% TankRate does not change
           obj.c_states(1)= y(1);
           obj.c_states(2)= y(2);% put back the state values
        end
        
        
        function ret = cse(obj,gt,y)
                   %continuous state value height
                   % |  integration termination event (1/0)
                   % |  |    zero-crossing direction from + to - (1 if event
                   % |  |    fct increases, -1 if decreases)
                   % |  |    |
             ret = [6000-y(1),1,-1;... % event #1, if TankLevel reaches 6000 from down --> tank full
                    5500-y(1),1,1;...% event #2, if TankLevel reaches 5500 from up again
                    5-y(1),1,1];        % event #3, if TankLevel is 5 
                   
            end
       
        function obj = deltastatefun(obj,gt,y,event_number)
           if event_number == 1 % if tank filled up to 6000
               obj.s.event_type = 'stop_filling';
               obj.s.filling_suspended = 1;% to remember, that tank was full
               obj.s.sigma = 0;  % trigger internal event and output before 
            end
            if event_number == 2 % if TankLevel sunk to 5500
                if obj.s.filling_suspended
                    obj.s.filling_suspended = 0;% filling can be continued
                    obj.s.event_type = 'continue_filling';
                    obj.s.sigma = 0;
                end
            end
            if  event_number == 3 % if tank is empty
                obj.s.event_type = 'stop_canning';
                obj.s.sigma = 0;
            end
                                               
        end
      
       
        function cy = lambda_c(obj,gt,y,x)
            cy = inf; % just DUMMY output!           
        end 
        
                     
    end
        
        
 end

