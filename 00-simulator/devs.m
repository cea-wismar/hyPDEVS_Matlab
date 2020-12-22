%% Abstract Base Class for PDEVS
%  stored in DEVS_PATH/00-simulator/devs.p
%
% Is provided as p-code.
%

%%
% <html>
% <table border=0><tr><td>Based on modified parallel DEVS algorithms (Zeigler, Schwatinski).</td></tr>
% <tr><td>This base class implements properties which are in common for atomic
% models and their associated simulators and for coupled models and their associated coordinators.</td></tr>
% <tr><td>C. Deatcu 2016</td></tr></table>
% </html>
% 
%% Description
% Class definition file of the base class for all PDEVS associated
% *simulators*, *coordinators* and *models*.
%
% constructor call:  |obj = devs()|
%
%
%% Superclass
% |handle|
%
%% Properties
%
% * |name|      : string, (unique) name of this model
% * |x|         : structure, set of inport name/input value pairs
% * |y|         : structure, set of outport name/output value pairs 
%
% * |sub_of|     : string, name of the superordinate model --> for debugging purposes
% * |tnext|      : float, time of next event
% * |tlast|      : float, time of last event
% * |debug_flag| : 0|1|2|3, no messages|messages|steps|visualize x, y, and s of atomics (default 0)
% * |observe_flag| : 0|1, log states of atomics or not (default 0)
% 
% *constant, hidden:*
%
% * |epsi|      : float, 1.0000e-08, accuracy for comparisons of simulation
% time. If two event times differ less than this value, these events will be
% identified as simultaneous events.
% 
%% Class methods
%
% *Set Methods for Ports*
%
% * |set_x_ports(obj, ports)|: initializes the structure obj.x (the inports) with fields
% defined in ports
% * |set_y_ports(obj, ports)|: initializes the structure obj.y (the outports) with fields
% defined in ports
% * |set.y(obj,yvalues)|:          safe setting of output values in y
%

classdef devs < handle
    properties (Constant, Hidden = true)
        epsi = 0.00000001;   %//type:numeric  //accuracy for comparisons of simulation time
    end
    properties (SetAccess = protected, GetAccess = public)%SetAccess = public bei BIRGER??
       name    %//type: string       //name of the model        
    end
    properties (SetObservable, SetAccess = protected, GetAccess = public)% Observable for debug-display %SetAccess = public bei BIRGER??
        x       %//type: structure    //set of input ports and values
        y       %//type: structure    //set of output ports and values
    end
    properties (SetAccess = {?atomic, ?coupled}, GetAccess = public)
        sub_of  %//type: string       //name of superordinate model
        tnext   %//type:numeric       //time of last event
        tlast   %//type:numeric       //time of next event
        debug_flag %//type: 0|1|2     //no messages|messages|steps (default 0)
        observe_flag %// type: 0|1    //log states of atomics or not (default 0)
        debug_obj  % Object for printing debug-messages
    end
    
    methods
            function obj = devs()
                obj.sub_of = '';
                obj.tlast = [];
                obj.tnext = inf;
                obj.debug_flag = 0;
                obj.observe_flag = 0;
                obj.debug_obj = db_empty(); %create a debug-message object doing nothing
            end

        function set.y(obj,yvalues)
            if isempty(obj.y)
                obj.y = yvalues;
            else
                if numel(fieldnames(obj.y)) == numel(fieldnames(yvalues))
                    obj.y = yvalues;
                else
                    error('yport doesn''t exist')
                end
            end
        end

        function set_x_ports(obj, ports) % ports is list of portnames = cell array
            if iscellstr(ports)
                if ~isempty(ports)
                    for j=1:length(ports)
                        xports.(ports{j}) = {};
                    end
                    obj.x = xports;
                end
            else
                error('Invalid value for input argument ''ports''. Must be a cellstring.');
            end
        end

        function set_y_ports(obj, ports) % ports is list of portnames = cell array
             if iscellstr(ports)
                if ~isempty(ports)
                    for j=1:length(ports)
                        yports.(ports{j}) = {};
                    end
                    obj.y = yports;
                end
            else
                error('Invalid value for input argument ''ports''. Must be a cellstring.');
            end
        end       


    end
end
%%
%
%
%
% <html>
% <br><br>
% <hr>
% <br>
% <a href="../PDEVS_home.html">DEVS Tbx Home</a>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
% <a href="../PDEVS_examples.html">Examples</a>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
% <a href="../PDEVS_modelbase.html">Modelbase</a>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
% <a href="javascript:history.back()"><< Back</a>
% </html>