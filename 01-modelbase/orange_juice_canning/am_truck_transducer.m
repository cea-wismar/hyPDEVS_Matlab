%% ATOMIC PDEVS am_truck_transducer
%  stored in DEVS_PATH/01-modelbase/orange_juice_canning/am_truck_transducer.m

%%
classdef am_truck_transducer < atomic
    %% Description
    % Class definition file for an *atomic PDEVS model*
    % that implements a transducer and acts as a sink and data collection
    % model.
    %
    % <<img/am_truck_transducer.png>>
    %
    % constructor call: |obj =
    % am_truck_transducer(name,inistates,elapsed)|
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
    % has two inputs |x|: p1 and p2, first port for trucks, second for pallets of juice
    %
    % has no output |y|: (is pure sink)
    %
    %% States in s
    %
    % |s.sigma|: for time advance
    %
    % |s.num_trucks|: count the number of unloaded trucks (after undocking)
    %
    % |s.num_pallets|: count the number of produced pallets
    %
     %% System Parameters in sysparams
    % none
    %
    %% More
    %
    % |global SIMUSTOP| : can be used to stop allover simulation, e.g. when
    %  a predifined number of pallets have been produced
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
        
        function obj = am_truck_transducer(name,inistates,elapsed)
            if nargin == 3
                x = {'p1','p2'};% 1 port for trucks, 1 for pallets of juice
                y = {};                     % not outports
                s = {'sigma','num_trucks','num_pallets'};
                sysparams = {};
            else
                error('mistake at constructor method for class am_truck_transducer');
            end
            obj = obj@atomic(name,x,y,s,elapsed,sysparams);% incarnate the associated simulator
            % initialize the states
            obj.s.sigma = inistates.sigma;
            obj.s.num_trucks = inistates.num_trucks;
            obj.s.num_pallets = inistates.num_pallets;
            disp('pure discrete transducer constructed');  
            end

       
        function ta = tafun(obj)
           ta = obj.s.sigma; 
        end
        
        
        function deltaconffun(obj,gt)  %#ok<INUSD>
             % not filled, because no internal events
        end

       
        function deltaextfun(obj,gt) %#ok<INUSD>
            if ~isempty(obj.x.p1)
                if obj.x.p1{1} == 1
                    obj.s.num_trucks = obj.s.num_trucks + 1; % count trucks
                end
            end
            if ~isempty(obj.x.p2)
                if obj.x.p2{1} == 1
                    obj.s.num_pallets = obj.s.num_pallets +1;% count pallets à 48 gallons
                end
                % if obj.s.num_pallets == 500
                %   SIMUSTOP = 1;
                % end
            end
        end
        
       
        function deltaintfun(obj)  %#ok<MANU>
            % no internal events here            
        end
               
      
        function lambdafun(obj)  %#ok<MANU>
             % not outputs
        end 
        
     
    end
        
        
 end

