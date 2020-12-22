%% COUPLED PDEVS cm_g
%  stored in DEVS_PATH/01-modelbase/cm_g.m

%%
classdef cm_g < coupled
   %% Description
    % Class definition file of a *coupled PDEVS model*
    % with seven atomic subcomponents of type _am_g_ .
    %
    % <<img/cm_g.png>>
    %
    % Generators emit workpieces/parts at deterministic times.
    %
    % constructor call: |obj =
    % cm_g(name,interarrival_time1,...,interarrival_time7)|
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
    % has no input |x| (is pure source)
    %
    % has seven outputs |y|: p1...p7 to emit workpieces
    %
    %% Subcomponents
    % has seven atomic subcomponents of type _am_g_, named 'am_g1'
    % ... 'am_g7'
    %
    %% Coupling Matrix (Zid)
    % structure is as follows: FROM _component_name_ _port_name_ TO _component_name_ _port_name_
    % (EICs and IOCs require the component name 'parent')
    %
%    Zid = {'am_g1','p1','parent','p1';...
%           'am_g2','p1','parent','p2';...
%           'am_g3','p1','parent','p3';...
%           'am_g4','p1','parent','p4';...
%           'am_g5','p1','parent','p5';...
%           'am_g7','p1','parent','p7';...
%           'am_g6','p1','parent','p6'};
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
        function obj = cm_g(name,varargin)
            obj=obj@coupled(name); % incarnate the associated coordinator
            % varargin may be used to pass some sysparams or inistates to atomic
            % subcomponents
            elapsed=0;
            
            % incarnate atomic subcomponents; must be defined as classes in
            % the modelbase
            %interarrival_time1 = 3;
            interarrival_time1 = varargin{1};
            inistates1 = struct('counter',0);
            am_g1 = am_generator('am_g1',inistates1,elapsed,interarrival_time1);
            
            %interarrival_time2 = 4;
            interarrival_time2 = varargin{2};
            inistates2 = struct('counter',0);
            am_g2 = am_generator('am_g2',inistates2,elapsed,interarrival_time2);
            
            %interarrival_time3 = 5;
            interarrival_time3 = varargin{3};
            inistates3 = struct('counter',0);
            am_g3 = am_generator('am_g3',inistates3,elapsed,interarrival_time3);
            
            %interarrival_time4 = 4;
            interarrival_time4 = varargin{4};
            inistates4 = struct('counter',0);
            am_g4 = am_generator('am_g4',inistates4,elapsed,interarrival_time4);
            
            %interarrival_time5 = 3;
            interarrival_time5 = varargin{5};
            inistates5 = struct('counter',0);
            am_g5 = am_generator('am_g5',inistates5,elapsed,interarrival_time5);
            
            %interarrival_time6 = 2;
            interarrival_time6 = varargin{6};
            inistates6 = struct('counter',0);
            am_g6 = am_generator('am_g6',inistates6,elapsed,interarrival_time6);
            
            %interarrival_time7 = 2;
            interarrival_time7 = varargin{7};
            inistates7 = struct('counter',0);
            am_g7 = am_generator('am_g7',inistates7,elapsed,interarrival_time7);
            
            
            % add all atomic and coupled subcomponents to the model
            % Attention: subcomponents' names need to be unique
            addcomponents(obj,{am_g1,am_g2,am_g3,am_g4,am_g5,am_g6,am_g7});
            
            
            % add inports, portnames must be unique on this level
            set_x_ports(obj, {});
            
            % add portnames must be unique on this level
            set_y_ports(obj, {'p1','p2','p3','p4','p5','p6','p7'});
            
            
            % define the couplings in matrix Zid
            % lines in Zid are
            % EICs and IOCs require the portname 'parent'
            Zid = {'am_g1','p1','parent','p1';...
                'am_g2','p1','parent','p2';...
                'am_g3','p1','parent','p3';...
                'am_g4','p1','parent','p4';...
                'am_g5','p1','parent','p5';...
                'am_g7','p1','parent','p7';...
                'am_g6','p1','parent','p6'};
            set_Zid(obj, Zid);
        end
    end
end

