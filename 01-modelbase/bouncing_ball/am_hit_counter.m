%% ATOMIC PDEVS am_hit_counter
%  stored in DEVS_PATH/01-atomic-modelbase/bouncing_ball/am_hit_counter.m

%%
classdef am_hit_counter < atomic
    %% Description
    % Class definition file for an *atomic PDEVS model*
    % that implements a counter for number of hits to the ground of hybrid ball models.
    % Up to 10 balls can be connected to the counter.
    % It acts as a pure sink. 
    %
    % <<img/am_hit_counter.png>>
    %
    % constructor call: |obj =
    % am_hit_counter(name,inistates,elapsed)|
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
    % * |s|         : structure, set of states% * |sysparams| : structure, set of system parameters, can be set only once at instantiation
    % * |sysparams| : structure, set of system parameters, can be set only once at instantiation
    % * |elapsed|   : float, time elapsed since last 
    %                 transition (only for initialization)
    %
    % * |debug_flag|: 0|1|2|3, no messages|messages|steps|visualize x, y, and s (default 0)
    % * |observe_flag|: 0|1, log states of atomic subcomponents or not (default 0)
    % * |observed|  : cell array including time stamps and a copy of s (structure of states)
    %
    %% Ports
    % has 10 inputs |x|: p1 to p10, each for one bouncing ball
    %
    % has no output |y|: (is pure sink)
    %
    %% States in s
    %
    % |s.sigma|: for time advance (always inf)
    %
    % |s.num_hits|: count the number of hits (array)
    %
    %% System Parameters in sysparams
    % none
    %
    %% More
    %
    % |global SIMUSTOP| : can be used to stop allover simulation e.g. when a
    % predefined number of jobs has finished. Take a look at the comments in
    % deltaextfun() where you find example usage.
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
        
        function obj = am_hit_counter(name,inistates,elapsed)
            if nargin == 3
                x = {'p1','p2','p3','p4','p5',...
                           'p6','p7','p8','p9','p10'};% 10 ports for hits
                y = {};                     % not outports
                s ={'sigma','num_hits'};
                sysparams = {};
            else
                error('mistake at constructor method for class am_truck_transducer');
            end
            obj = obj@atomic(name,x,y,s,elapsed,sysparams);% incarnate the associated simulator
            % initialize the states
            obj.s.sigma = inistates.sigma;
            obj.s.num_hits = inistates.num_hits;
            disp('pure discrete hit counter constructed');  
            end

       
        function ta = tafun(obj)
           ta = obj.s.sigma; 
        end
        
        
        function deltaconffun(obj,gt)  %#ok<INUSD>
             % not filled, because no internal events
        end

       
        function deltaextfun(obj,gt) %#ok<INUSD>
            for portnum = 1:10
                portname = ['p',num2str(portnum)];
                if ~isempty(obj.x.(portname))
                 if obj.x.(portname){1} == 1  
                     obj.s.num_hits(portnum) = obj.s.num_hits(portnum) + 1; % count hits
                 end
                end
            end
%              if obj.x.p1 == 1
%                  obj.s.num_hits(1) = obj.s.num_hits(1) + 1; % count hits
%              end
%              if obj.x.p2 == 1
%                 obj.s.num_hits(2) = obj.s.num_hits(2) + 1;
%              end
%              if obj.x.p3 == 1
%                 obj.s.num_hits(3) = obj.s.num_hits(3) + 1;
%              end
%              if obj.x.p4 == 1
%                 obj.s.num_hits(4) = obj.s.num_hits(4) + 1;
%              end
%              if obj.x.p5 == 1
%                 obj.s.num_hits(5) = obj.s.num_hits(5) + 1;
%              end
%              if obj.x.p6 == 1
%                 obj.s.num_hits(6) = obj.s.num_hits(6) + 1;
%              end
%              if obj.x.p7 == 1
%                 obj.s.num_hits(7) = obj.s.num_hits(7) + 1;
%              end
%              if obj.x.p8 == 1
%                 obj.s.num_hits(8) = obj.s.num_hits(8) + 1;
%              end
%              if obj.x.p9 == 1
%                 obj.s.num_hits(9) = obj.s.num_hits(9) + 1;
%              end
%              if obj.x.p10 == 1
%                 obj.s.num_hits(10) = obj.s.num_hits(10) + 1;
%              end                 
        end
        
       
        function deltaintfun(obj)  %#ok<MANU>
            % no internal events here            
        end
               
      
        function lambdafun(obj)  %#ok<MANU>
             % not outputs
        end 
        
     
    end
        
        
 end

