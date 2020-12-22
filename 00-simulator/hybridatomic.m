%% Hybrid Atomic Object with Simulator Functionalities
%  stored in DEVS_PATH/00-simulator/hybridatomic.p
%
% Is provided as p-code.


%%
% <html>
% <table border=0><tr><td>Based on modified parallel DEVS
% algorithms (Zeigler, Schwatinski) and wrapper extension (Deatcu).</td></tr>
% <tr><td>All hybrid user defined atomic models have to be derived from class
% hybridatomic.</td></tr>
% <tr><td>C. Deatcu 2016</td></tr></table>
% </html>
%
%% 
classdef hybridatomic < atomic
    %% Description
    % Class definition file for an *associated simulator* for
    % hybrid atomic DEVS models. Extends the discrete associated simulator. 
    %
    % constructor call:  |obj =
    % hybridatomic(name,x,y,s,c_states,elapsed,sysparams)|
    %
    %
    %% Superclass
    % |atomic|
    %
    %% Inherited properties
    %
    % *inherited from devs:*
    %
    % * |sub_of|    : string, name of the superordinate model --> for debugging purposes
    % * |tnext|     : float, time of next event
    % * |tlast|     : float, time of last event
    % * |name|      : string, (unique) name of this model --> for debugging purposes
    %                 max. 12 characters for "nice" debug-look ;-)
    % * |x|         : structure, set of inport name/input value (cell array) pairs
    % * |y|         : structure, set of outport name/output value (cell array) pairs
    % * |debug_flag|: 0|1|2|3, no messages|messages|steps|visualize x, y, and s (default 0)
    % * |observe_flag|: 0|1, log states of atomic subcomponents or not (default 0)
    %
    % *inherited from atomic:*
    %
    % * |s|         : structure, set of states
    % * |elapsed|   : float, time elapsed since last 
    %                 transition (only for initialization)
    % * |sysparams| : structure, set of system parameters, can be set only once at instantiation
    % * |observed|  : cell array including time stamps and a copy of s (structure of states)
    %
    %% Properties
    %
    % * |c_states|  : vector of continuous state variables
    % * |mealy|     : 1 if it is of Mealy type, 0 if it is of Moore type
    %                 needs to be set by the modeler in constructor method
    % * |num_c_state_events| : number of cont. state events
    % * |event_offset|    : offset in global event location vector
    % * |state_offset|    : offset in global state vector
    % * |output_offset|   : offset in global output vector
    % * |output_length|   : length of output-vector returned by lamda_c    
    % * |input_offset|     : input offsets in global x vector
    % * |input_length|     : length of input from global x vector
    %
    %% Class methods
    %
    % *inherited from atomic:*
    %
    % *Simulation Messages*
    %
    % * |i_msg(obj,gt)|   : initialization message -
    %   sets tlast and calls tafun() of model to calculate tnext
    % * |s_msg(obj,gt,flag)|: star message - called when atomic is
    %   imminent, calls deltaint() and tafun() of model, sets tlast and
    %   tnext
    % * |x_msg(obj,gt)|  : x message - called, if external event
    %   arrives, calls deltaconffun() or deltaextfun() of model    
    % * |y_msg(obj,gt)|  : inperpellation y message - calls lambdafun
    %   of model
    %
    % *Set Methods for Flags*
    %
    % * |set_debug(obj, debug_flag)|: set flag for debug messages to
    % 0|1|2|3
    % * |set_observe(obj, observe_flag)|: set flag for tracking discrete states to 0|1
    %
    % *Set Methods for States*
    %
    % * |set_states(obj, statenames)|: initializes the structure obj.s. with fields defined in statenames
    % * |set.s(obj,svalues)|:          safe setting of state values in s
    %
    % --------------------------------------------------------------------
    %
    % *Additional methods for hybrid simulation:*
    %
    % * |[obj,gstatvec,gevveclen,outoffs] = z_msg(obj,gt,soff,eoff)| :
    %   z message - vector configuration of hybrid atomics
    % * |obj = z2_msg(obj,gt,ioffs)| : z2 message - second run vector
    %   configuration of hybrid atomics (setting the index of local input
    %   variables)
    % * |[obj,event_flag] = se_msg(obj,te,ye,ie)| : state event message - 
    %   is called when a state event occurred somewhere in entire model
    %   (for hybrid simulation only);
    %   if state event occured in THIS model, set event_flag and calculate tnext
    %
    % * |showall(obj)|                 : display the object 
    %
    
    properties (Access = public) 
        % HYBRID PROPERTIES
        c_states = []; % vector of continuous state variables
        
        mealy
        num_c_state_events = [];
        event_offset = NaN;     
        state_offset = NaN;         
        output_offset = NaN;    
        output_length = NaN;         
        input_offset = [];
        input_length = [];
        % END HYBRID PROPERTIES        
    end
      
    methods
        function obj = hybridatomic(name,x,y,s,c_states,mealy,elapsed,sysparams) %#ok<INUSL>
            
            if nargin < 8
                error('constructor of base class <<hybridatomic>> failed');
            end
            obj = obj@atomic(name,x,y,s,elapsed,sysparams);% incarnate the associated discrete simulator
            obj.mealy = mealy;        
         end
        
       
        

        %% Z_MSG
        %  function [obj,gstatvec,gevveclen,outoffs]=z_msg(obj,gt,soff,eoff)
        %%
        %  WHAT HAPPENS IN Z_MSG?
        %%
        %
        % * message for vector configuration (for hybrid simulation only)
        %
       function [obj,gstatvec,gevveclen,outoffs]=z_msg(obj,gt,soff,eoff)
            % gt: current time
            % soff: state offset --> will be set
            % eoff: event offset --> will be set
            % gstatvec: local state vector for building global state vector
            % gevveclen: number of local state events for calculating
            %            offset in global state event vector
            % outoffs: indexes of continuous output variables in global
            %          state vector
             
            obj.debug_obj.dbprint(gt,110,obj,'');% begin z-msg debug-message
            obj.state_offset = soff;% safe the offset in global state vector HERE LOCALLY
            obj.event_offset = eoff;% safe the offset in global event vector HERE LOCALLY
            
            obj.debug_obj.dbprintcall(gt,6,obj); % call csefunc. debug-message
            ret = cse(obj,-1,0);% call state event condition function with just one input argument
                           % to determine number of possible events
                           % function ret = cse(obj,gt,y)
                         
            %obj.num_c_state_events = length(ret(1));% set number of state events HERE LOCALLY
            %ret(:,1);
            if ~isempty(ret)
            obj.num_c_state_events = length(ret(:,1));% set number of state events HERE LOCALLY
            else
                obj.num_c_state_events = 0;
            end
            
            
            gstatvec = obj.c_states;% return continuous states
            gevveclen = obj.num_c_state_events;% return number of state events
            
            outoffs = (soff+1):(soff+length(gstatvec));% calculate indexes in output vector
                                                       % shift one to the
                                                       % right??????
            obj.debug_obj.dbprint(gt,111,obj,'');% end z-msg debug-message
                                                       
       end
        %% Z2_MSG
        %  function obj=z2_msg(obj,gt,ioffs)
        %%
        %  WHAT HAPPENS IN Z2_MSG?
        %%
        %
        % * message for vector configuration (for hybrid simulation only)
        % * second run for setting the index of local input variables
        %
        function obj = z2_msg(obj,gt,ioffs)
            % gt: current time
            % ioffs: index of first local input variable in global state
            % vector
            obj.debug_obj.dbprint(gt,112,obj,'');% begin z2-msg debug-message
            obj.input_offset = ioffs; % safe the offset HERE LOCALLY
            obj.debug_obj.dbprint(gt,113,obj,'');% end z2-msg debug-message
        end
    
        %% SE_MSG
        %  function [obj,event_flag]=se_msg(obj,te,ye,ie)
        %%
        % WHAT HAPPENS IN SE_MSG?
        %%
        %
        % * state event message
        % * is called when an state event occurred somewhere in entire model (for hybrid simulation only)
        % * if state event occured in THIS model, set event_flag and calculate t_next 
        %  
        function [obj,event_flag]=se_msg(obj,te,ye,ie)
             
            obj.debug_obj.dbprint(te,114,obj,'');% begin se-msg debug-message
            event_flag = 0; % initialize
            if ~isempty (obj.c_states)% if this is a HYBRID atomic
            
            
%             xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
%             if strcmp(obj.name,'bb_1')
%                 obj.c_states(1)=ye(1);
%                 disp('state updated');
%             else
%                 obj.c_states(1)=ye(2);
%             end
%             xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
            if isempty (ie)
               % disp('ye = ')
               % disp(ye);
                obj.c_states=ye(obj.state_offset+1:obj.state_offset+length(obj.c_states),1);
            else
                for idx=1:length(te)
                
                
%                 disp(ie);
%                 disp(obj.state_offset);
%                 disp(length(obj.c_states));
                
                obj.c_states=ye(idx,obj.state_offset+1:obj.state_offset+length(obj.c_states));
                end
                
            
  
       
            
            %disp(['event_offset = ',num2str(obj.event_offset)]);
            lower_e_idx = obj.event_offset + 1;
            %disp(['num_c_state_event = ',num2str(obj.num_c_state_events)]);
            upper_e_idx = obj.event_offset + obj.num_c_state_events;

            % put back continuous value
            % obj.c_state = ye (lower_s_idx:upper_s_idx);
            

            for idx=1:length(te)
                %disp(['ie = ', num2str(ie)]);
                
                if lower_e_idx <= ie(idx) && ie(idx) <= upper_e_idx % if event occured HERE
                   event_number_in_model = ie(idx) - lower_e_idx +1;

                %deltastatefun(asubs{k},te(i),ye(i,gstat_offset(k)+1:gstat_offset(k)+gstat_length(k)));
                %bei Aufruf aus root coordinator wie oben
                %
                obj.debug_obj.dbprintcall(te,7,obj); % call deltastatefun debug-message
                
                %disp(ye(idx,obj.state_offset+1:obj.state_offset+length(obj.c_states)));
                %disp(['event_number_in_model: ',num2str(event_number_in_model)]);
                deltastatefun(obj,te(idx),ye(idx,obj.state_offset+1:obj.state_offset+length(obj.c_states)),event_number_in_model);
%                 if obj.observe_flag % track states versus time
%                     obj.observed = [obj.observed; {te , obj.s}];
%                 end
                
	
                %obj.elapsed_time = te - obj.t_last;
                %obj = delta_state (obj, ie - lower_e_idx + 1);
                %obj.elapsed_time = 0;
                
                obj.tlast = te(idx);
                %obj.elapsed = 0;% ????????????????
                obj.debug_obj.dbprintcall(te,1,obj); % call ta-fun debug-message
                obj.tnext = obj.tlast + tafun(obj);
                event_flag = 1;   % event occured in THIS object
                end
            end
                
                %end
                
            end
            end
         obj.debug_obj.dbprint(te,115,obj,'');% end se-msg debug-message
        end
        %######################## end SIMULATOR FUNCTIONS #######################
        
        
        %######################### DISPLAY HELPER FUNCTIONS #########################
        % Functions for displaying the hybrid atomic objects
        % 
        % * |function showxports(obj)|: display x-ports
        % * |function showyports(obj)|: display y-ports
        % * |showstates(obj)|: display states in s
        % * |showcontstates(obj)|: display continuous states
        %
        % This functions *can* be called to get some information during
        % or after simulation.       

                
        function showcontstates(obj)
            disp('Vec. of cont. states c_states'),disp('------------------'),disp(obj.c_states);
        end
        
        function showall(obj)
            disp(obj);
            fprintf(1,'\n');
            showxports(obj);
            showyports(obj);
            showstates(obj);
            showcontstates(obj);
        end
        %####################### end DISPLAY HELPER FUNCTIONS #######################
        
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


