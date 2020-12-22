%% ATOMIC PDEVS sine_qss1
%  stored in DEVS_PATH/01-modelbase/qss/sine_qss1.m

%%
classdef sine_qss1 < atomic
    %% Description
    % Class definition file for an *atomic PDEVS model*
    % for generating a quantized sine wave.
    %
    % <<img/sine_qss1.png>>
    %
    % constructor call: |obj = sine_qss1(name,inistates,elapsed,A,omega,phi,delta_u)|
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
    % has one output |y| : p1 for quantized sine signal
    %
    %% States in s
    % |s.sigma| : for time advance
    %
    % |s.tau| : phase shift time
    %
    % |s.traj| : to record exact sine values (X/t pairs)
    %
    % |s.qtraj|: to record quantized sine values (q/t pairs)
    %
      %% System Parameters in sysparams
    % |sysparams.A| : amplitude
    %
    % |sysparams.omega| : angular frequency
    %
    % |sysparams.phi| : phase shift
    %
    % |sysparams.delta_u| : quantization of sine
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
       
        function obj =sine_qss1(name,inistates,elapsed,A,omega,phi,delta_u)
            if nargin == 7
                x = {};       % no inputs
                y = {'p1'};% one output to propagate current sine value
                s = {'sigma','tau','traj','qtraj'};% states
                sysparams =struct('A',A,'omega',omega,'phi',phi,'delta_u',delta_u);
            else
                error('mistake at constructor method for sine_qss1');
            end
            
            obj = obj@atomic(name,x,y,s,elapsed,sysparams);% incarnate the associated simulator
            
            % initialize the states
            obj.s.sigma = inistates.sigma;
            obj.s.tau = inistates.tau;
            obj.s.traj = inistates.traj;
            obj.s.qtraj = inistates.qtraj;
        end

        
        function ta = tafun(obj)
            ta = obj.s.sigma;
        end
        
        
        function deltaconffun(obj,gt)  %#ok<*INUSD>
            % nothing to do here, because external events and therefore simultaneous events don't take place
        end

        
        function deltaextfun(obj,gt)
            % never called for pure sources
        end
        
        
        function deltaintfun(obj)
            if (((sin(obj.sysparams.omega * obj.s.tau) + obj.sysparams.delta_u/obj.sysparams.A <= 1) && (cos(obj.sysparams.omega * obj.s.tau) > 0)) || (sin(obj.sysparams.omega * obj.s.tau) - obj.sysparams.delta_u/obj.sysparams.A < -1))
                obj.s.sigma = asin(sin(obj.sysparams.omega * obj.s.tau) + obj.sysparams.delta_u/obj.sysparams.A) / obj.sysparams.omega - obj.s.tau;
            else
                if obj.s.tau > 0
                    obj.s.sigma = (pi - asin(sin(obj.sysparams.omega * obj.s.tau) - obj.sysparams.delta_u / obj.sysparams.A)) / obj.sysparams.omega - obj.s.tau;
                else
                    obj.s.sigma = (-pi - asin(sin(obj.sysparams.omega * obj.s.tau) - obj.sysparams.delta_u / obj.sysparams.A)) / obj.sysparams.omega - obj.s.tau;
                end
            end
            % for plotting
            obj.s.traj=[obj.s.traj;obj.tnext, obj.sysparams.A * sin(obj.sysparams.omega * obj.s.tau)]; % add q/t-pair to q-trajectorie
            obj.s.qtraj=[obj.s.qtraj;obj.tnext, obj.sysparams.A * sin(obj.sysparams.omega * obj.s.tau)]; % add q/t-pair to q-trajectorie
            obj.s.tau = obj.s.tau + obj.s.sigma;
            if obj.s.tau * obj.sysparams.omega >= pi
                obj.s.tau = obj.s.tau - 2*pi/obj.sysparams.omega;
            end
        end
               
        
        function lambdafun(obj)
            obj.y.p1 = {obj.sysparams.A * sin(obj.sysparams.omega * obj.s.tau)};
        end
        
    end
        
        
 end

