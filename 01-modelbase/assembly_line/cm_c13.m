%% COUPLED PDEVS cm_c13
%  stored in DEVS_PATH/01-modelbase/cm_c13.m

%%
classdef cm_c13 < coupled
    %% Description
    % Class definition file of a *coupled PDEVS model*
    % with two atomic subcomponents of type _am_proc_block_ .
    %
    % <<img/cm_c13.png>>
    %
    % Processing blocks assemble workpieces from two queues and are
    % connected in series.
    % FIFO queues for workpieces are included in this subcomponents.
    %
    % constructor call: |obj =
    % cm_c13(name,service_time1, service_time2)|
    %
    %% Superclass
    % |coupled|
    % (superclass acts as associated coordinator)
    %
   %% Inherited Properties 
    %
    % *inherited from coupled (to be set here):*
    %
    % * |name|      : string, (unique) name of this model --> for debugging purposes
    %                 max. 12 characters for "nice" debug-look ;-)
    % * |x|         : cell array of strings, names of inports
    % * |y|         : cell array of strings, names of outports
    % * |components|: array of objects, subcomponents
    % * |Zid|       : cell array of strings, "i-to-d-matrix" (couplings)
    %
    % *inherited from coupled (are set automatically):*
    %
    % * |Da|        : cell array of strings, names of atomic subcomponents
    % * |Dc|        : cell array of strings, names of coupled subcomponents
    %
    %
    %% Class Methods
    % *Methods to Define Components and Couplings*
    %
    % * |add_c_component(obj, comps)|: add one coupled subcomponent 
    % * |add_a_component(obj, comps)|: add one atomic subcomponent
    % * |addcomponents(obj, comps)|: add one or more subcomponents of any kind ;-)
    % * |set_x_ports(obj, ports)|: define input ports
    % * |set_y_ports(obj, ports)|: define output ports
    % * |set_Zid(obj, Zid)|: set Zid (one or more Lines)
    %
    % *Set Methods for Flags*
    %
    % * |set_debug(obj,debug_flag)|: set debug flag to 0|1|2|3
    % * |set_observe(obj,observe_flag)|: set observe flag to 0|1 (for tracking states of atomic subcomponents)
    %
    % *display functions:*
    %
    % * |showall(obj)|              : display the object 
    % * |showxports(obj)|           : display x-ports and values 
    % * |showyports(obj)|           : display y-ports and values
    % * |showssubcomponents(obj)|   : display names of all subcomponents in Da and Dc
    % * |showycouplings(obj)|       : display all couplings in Zid
    % * |showeventlist(obj)|        : display, when subcomponents become imminent
    %
    %    
    %% Ports
    % has three inputs |x|: p1,p2,p3 for incoming workpieces
    %
    % has one output |y|: out1 to emit assembled parts
    %
    %% Subcomponents
    % has two atomic subcomponents of type _am_proc_block_, named 'am_m1'
    % and 'am_m2'
    %
    %% Coupling Matrix (Zid)
    % structure is as follows: FROM _component_name_ _port_name_ TO _component_name_ _port_name_
    % (EICs and IOCs require the component name 'parent')
    %
%   Zid = {'parent','p1','am_m1','in1';...
%           'parent','p2','am_m1','in2';...
%           'parent','p3','am_m2','in2';...
%           'am_m1','out1','am_m2','in1';...
%           'am_m2','out1','parent','out1'};
%
    % After incarnation you can use the method Check(obj) to verify, that
    % all component names and all port names are existent.
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
   
    methods
        function obj = cm_c13(name,varargin)
            obj=obj@coupled(name); % incarnate the associated coordinator
            % varargin may be used to pass some sysparams or inistates to atomic
            % subcomponents
            elapsed=0;
            
            % incarnate atomic subcomponents; must be defined as classes in
            % the modelbase
            inistates = struct('phase','passive','sigma',inf,'q1',0,'q2',0);
            service_time = varargin{1};
            am_m1=am_proc_block('am_m1',inistates,elapsed,service_time);
            
            inistates = struct('phase','passive','sigma',inf,'q1',0,'q2',0);
            service_time = varargin{2};
            am_m2=am_proc_block('am_m2',inistates,elapsed,service_time);
                      
            % add all atomic and coupled subcomponents to the model
            % Attention: subcomponents' names need to be unique
            addcomponents(obj,{am_m1,am_m2});
            
            
            % add inports, portnames must be unique on this level
            set_x_ports(obj, {'p1','p2','p3'});
            
            % add portnames must be unique on this level
            set_y_ports(obj, {'out1'});
            
            
            % define the couplings in matrix Zid
            % lines in Zid are
            % EICs and IOCs require the portname 'parent'
            Zid = {'parent','p1','am_m1','in1';...
                'parent','p2','am_m1','in2';...
                'parent','p3','am_m2','in2';...
                'am_m1','out1','am_m2','in1';...
                'am_m2','out1','parent','out1'};
            set_Zid(obj, Zid);            
        end          
    end
end

