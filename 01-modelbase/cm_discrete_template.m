%% Template for a pure discrete COUPLED PDEVS
%  stored in DEVS_PATH/01-modelbase/cm_coupled_template.m
%
% Adopt this template to create your own coupled models.

    %% Description
    % Template for a class definition file of a *coupled PDEVS model*
    % with pure discrete behaviour
    %
    % constructor call: |obj =
    % cm_discrete_template(name,~)|
    %
    % To define your own model adopt this file, specify input and output
    % ports, components, and Zid to provide coupling information.
    % First step is to alter the class name in |classdef| section, the
    % constructor call and save the class definition to a new m-file with the name of your
    % user-defined class.
    % Then incarnate subcomponents and add them to the model.
    % Define inports, outports and couplings in Zid via the appropriate
    % methods. Everything is a cellstring there!
    % Varargin may be used to transmit states or system parameters for subcomponents
    % or a value for elapsed.
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
    
   
    %% Why varargin?
    % varargin can be used to get additional input parameters which maybe
    % used as system parameters for atomic subcomponents
    % (e. g. a service time to be transfered to an atomic subcomponent)
    % See the example DEVS_PATH/01-modelbase/assembly_line/cm_c13.m
    % 
    %
    %% Ports
    % just an example:
    %
    % has three inputs |x|: in1, in2 and in3
    %
    % has two outputs |y|: out1 and out2
    % set with the method |set_x_ports(obj, {'inport1','inport2',...})|
    % and |set_y_ports(obj, {'outport1','outport2',...})|
    % portnames must be unique!
    %
    %% Zid
    % *Example Zid*
    %
    % structure is as follows: FROM _component_name_ _port_name_ TO _component_name_ _port_name_
    % (EICs and IOCs require the component name 'parent')
    %
%   Zid = {'parent','in2','am_m1','p1';...
%          'parent','in1','am_m1','p2';...
%          'parent','in3','am_m2','p1';...
%          'subc2','out1','subc','in3';...
%          'am_m1','p1','parent','outport1';...
%          'am_m2','p1','parent','out2'};
%
    % After incarnation you can use the method Check(obj) to verify, that
    % all component names and all port names are existent.
%
 %% Class File
 classdef cm_discrete_template < coupled 
         
         methods
             function obj = cm_discrete_template(name,varargin)
                 obj = obj@coupled(name); % incarnate the associated coordinator
                 % varargin may be used to pass some sysparams or inistates to atomic
                 % subcomponents
                 
                 elapsed=0;
                 
                 %**** USER CODE  FOR SUBCOMPONENTS GOES HERE ****
                 % incarnate atomic subcomponents; must be defined as classes in
                 % the modelbase
                 inistates = struct('phase','passive','sigma',inf,'q1',0,'q2',0);
                 %service_time = 4;
                 service_time = varargin{1};
                 am_m1 = am_proc_block('am_m1',inistates,elapsed,service_time);
                 
                 a_name = 'sub_b';
                 sub_b = am_proc_block(a_name,inistates,elapsed,service_time);
                 
                 % incarnate coupled subcomponents; must be defined as classes in
                 % the modelbase or can be directly initialized via a call of
                 % class 'coupled'
                 subc = coupled('subc',{'in1','in2', 'in3'});
                 subc2 = coupled('subkomp',{'in1','in2', 'in3'},{'out1'});
                 
                 % add all atomic and coupled subcomponents to the model
                 % Attention: subcomponents' names need to be unique
                 addcomponents(obj,{am_m1,sub_b,subc,subc2});
                 %**** END USER CODE SUBCOMPONENTS      ****
                 
                 
                 %**** USER CODE  FOR PORTS GOES HERE ****
                 % add inports, portnames must be unique on this level
                 set_x_ports(obj, {'inport1','inport2'});
                 
                 % add portnames must be unique on this level
                 set_y_ports(obj, {'outport1','out2'});
                 %**** END USER CODE PORTS      ****
                 
                 
                 %**** USER CODE  FOR COUPLINGS GOES HERE ****
                 % define the couplings in matrix Zid
                 % lines in Zid are
                 % EICs and IOCs require the portname 'parent'
                 Zid = {'parent','in2','am_m1','p1';...
                     'parent','in1','am_m1','p2';...
                     'parent','in3','am_m2','p1';...
                     'subc2','out1','subc','in3';...
                     'am_m1','p1','parent','outport1';...
                     'am_m2','p1','parent','out2'};
                 %**** END USER CODE COUPLINGS      ****
                 set_Zid(obj, Zid);
        end             
    end
end
     
     %%
     % <html>
     % <br><br>
     % <hr>
     % <br>
     % <a href="../PDEVS_home.html">DEVS Tbx Home</a>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
     % <a href="../PDEVS_examples.html">Examples</a>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
     % <a href="../PDEVS_modelbase.html">Modelbase</a>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
     % <a href="javascript:history.back()"><< Back</a>
     % </html>
     %

