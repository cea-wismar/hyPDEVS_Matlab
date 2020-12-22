%% Hybrid Coupled Model with Coordinator Functionalities
%  stored in DEVS_PATH/00-simulator/hybridcoupled.p
%
% Is provided as p-code.

%%
% <html>
% <table border=0><tr><td>Based on modified parallel DEVS algorithms (Zeigler,
% Schwatinski) and wrapper extension (Deatcu).</td></tr>
% <tr><td>User defined coupled models can be created as instances of this class directly or can
% be derived from it alternatively.
% For initialization, the modeler has to define input and output portnames.
% Components and coupling information are defined after instantiation via the methods *addcomponents(obj,comps)*, *set_Zid(obj,Zid)* and *set_CZid(obj,CZid)*.</td></tr>
% <tr><td>C. Deatcu 2016</td></tr></table>
% </html>
% 
%%



classdef hybridcoupled < coupled
    %% Description
    % Class definition file for a hybrid coupled DEVS model and it's *associated
    % coordinator*. Extends the discrete associated coordinator and model.
    %
    % constructor call:  |obj =
    % hybridcoupled(name,xportnames,yportnames)|, where xportnames and yportnames
    % are optional
    %
    %
    %% Superclass
    % |coupled|
    %
    %% Inherited properties
    %
    % * |sub_of|    : string, name of the superordinate model --> for debugging purposes
    % * |tnext|     : float, time of next event
    % * |tlast|     : float, time of last event
    % * |name|      : string, (unique) name of this model --> for debugging purposes
    %                 max. 12 characters for "nice" debug-look ;-)
    % * |x|         : structure, set of inport name/input value pairs
    % * |y|         : structure, set of outport name/output value pairs
    % * |debug_flag|: 0|1|2|3, no messages|messages|steps|visualize x, y, and s of atomic subcomponents (default 0))
    % * |observe_flag|: 0|1, log states of atomic subcomponents or not (default 0)
    % * |Da|        : cell array of strings, names of atomic subcomponents
    % * |Dc|        : cell array of strings, names of coupled subcomponents
    % * |Zid|       : cell array of strings, "i-to-d-matrix" (couplings)
    % * |components|: array of objects, subcomponents
    % * |eventlist| : matrix with information on future events of subcomponents, eventlist = [a,b,c;...]
    %
    %  eventlist = [a,b,c;...]
    %  a - time for next transition
    %  b - {1,2} | 1 if atomic DEVS, 2 if coupled DEVS
    %  c - index for eventlist (position in Da or Dc)
    %
    %% Properties
    %
    % * |CZid|: cell array of strings, "i-to-d-matrix" (continuous couplings)
    %
    %% Class methods
    % * |i_msg(obj,gt)|   : initialization message -
    %                       sets tlast and tnext at all subcomponents and 
    %                       sets matrix |eventlist|
    % * |s_msg(obj,gt,flag)|: star message - called when coupled is
    %                         imminent, sets |tlast| and |tnext|
    % * |x_msg(obj,gt)|  : x message - called, if external event
    %                      arrives 
    % * |y_msg(obj,gt)|  : inperpellation y message
    % * |[obj,aSimObj,gstatvec,gevveclen,outoffs] = z_msg(obj,gt,soff,eoff)|:
    %   z message - vector configuration of continuous part
    % * |obj = z2_msg(obj,gt,ioffs)|: z2 message - second run of vector
    %   configuration, setting indicies
    % * |[obj,event_flag]=se_msg(obj,te,ye,ie)|: state event message -
    %   called when a state event occurred somewhere in entire model
    %    
    % *Methods to Define Components and Couplings*
    %
    % * |add_c_component(obj, comps)|: add one coupled subcomponent 
    % * |add_a_component(obj, comps)|: add one atomic subcomponent
    % * |addcomponents(obj, comps)|: add one or more subcomponents of any kind ;-)
    % * |set_Zid(obj, Zid)|: set Zid (one or more Lines)
    %
    % *Set Methods for Flags*
    %
    % * |set_debug(obj,debug_flag)|: set debug flag to 0|1|2|3
    % * |set_observe(obj,observe_flag)|: set observe flag to 0|1 (for tracking discrete states of atomic subcomponents)
   
    % * some methods for getting information on the object (see below
    %   section _Functions for Displaying the Coupled Objects_)
    %
    %
   
    properties (Access = public) 
        CZid
    end
       
    methods
        
        function obj = hybridcoupled(name,xportnames,yportnames)
            %obj = hybridcoupled(name,x,y,Da,Dc,Zid,CZid)
            obj = obj@coupled(name); % create a father object just with a name
            if nargin < 1
                error(['mistake at constructor method for class hybridcoupled <<',name,'>>']);
            else
                if nargin > 1
                    x =  xportnames;
                    set_x_ports(obj, x);
                end
                if nargin > 2
                    y =  yportnames;
                    set_y_ports(obj, y);
                end
            end
            
            %obj = obj@coupled(name,xportnames,yportnames);
           % obj.CZid = CZid;
        end
            
        

   % ######################################################################
   %% Z_MSG
   %  function [obj,aSimObj,gstatvec,gevveclen,outoffs]=z_msg(obj,gt,soff,eoff)
   %%
   % WHAT HAPPENS IN Z_MSG?
   %%
   % * message for vector configuration (for hybrid simulation only)
   % * collect references to all atomic subcomponents with continuous
   %   states in aSimObj
   % * collect continuous state variables in gstatvec
   % * collect number of events per atomic submodel in gevveclen
   % * collect indices of continuous output variables
   %
   function [obj,aSimObj,gstatvec,gevveclen,outoffs]=z_msg(obj,gt,soff,eoff)
            % gt: current time
            % soff: state offset --> will be set
            % eoff: event offset --> will be set
            % gstatvec: local state vector for building global state vector
            % gevveclen: number of local state events for calculating
            %            offset in global state event vector
            % outoffs: indexes of continuous output variables in global
            %          state vector
             
            
            obj.debug_obj.dbprint(gt,17,obj,[]); % begin z-msg debug-message
            %initialize return parameters
            aSimObj={};
            gstatvec=[];
            gevveclen=[];
            outoffs=[];           
            % atomic models
            if ~isempty(obj.Da)% if there are atomic subcomponents
               for idx=1:length(obj.Da)% for all atomic subcomponents
                    a_obj = obj.components.(char(obj.Da(idx))); % get the atomic subcomponent
                    if isa(a_obj,'hybridatomic')
                        if ~isempty(a_obj.c_states)
                        obj.debug_obj.dbprint(gt,18,obj,a_obj); % send z-msg to subcomponent debug-message   
                        [a_obj,svec,eveclen,ooffs] = z_msg(a_obj,gt,soff,eoff); % send the atomic subcomponent a z-message
                        aSimObj={aSimObj{1:end},a_obj};%add to list of hybrid atomic subcomponents
                        gstatvec=[gstatvec,svec];% add continuous state variables of this atomic subcomponent to vector
                    
                        soff=soff+length(svec);% calculate state offset for setting offset in next subcomponent
                        eoff=eoff+eveclen;% calculate number of local state events for setting offset in next subcomponent
                        gevveclen=eoff; % set number of local state events for return
                        outoffs=[outoffs,ooffs];% collect output offsets for return
                        end
                    end
               end
            end
            % coupled models
            if ~isempty(obj.Dc)% if there are coupled subcomponents
                for j=1:length(obj.Dc)% for all coupled subcomponents
                    c_obj = obj.components.(char(obj.Dc(j))); % get the coupled subcomponent
                    
                    obj.debug_obj.dbprint(gt,18,obj,c_obj); % send z-msg to subcomponent debug-message  
                    [c_obj,asubSimObj,svec,eveclen,ooffs]=z_msg(c_obj,gt,soff,eoff);
                    aSimObj={aSimObj{1:end},asubSimObj{1:end}};%add to list of hybrid atomic subcomponents
                    gstatvec=[gstatvec,svec];% add continuous state variables of this coupled subcomponent to vector
                    soff=soff+length(svec);% calculate state offset for setting offset in next subcomponent
                    eoff=eoff+eveclen;% calculate number of local state events for setting offset in next subcomponent
                    gevveclen=eoff; % set number of local state events for return
                    outoffs=[outoffs,ooffs];% collect output offsets for return
                end
            end
            obj.debug_obj.dbprint(gt,19,obj,[]); % end z-msg debug-message  
            
   end
   % ###################################################################### 
   %% Z2_MSG
   %  function obj=z2_msg(obj,gt,ioffs)
   %%
   %  WHAT HAPPENS IN Z2_MSG?
   %%
   % * message for vector configuration (for hybrid simulation only)
   % * second run for calculating and setting the index of local input variables
   %
        function obj = z2_msg(obj,gt,ioffs)
            % gt: current time
            % ioffs: input offsets
            % ioffs: index of first local input variable in global state
            % vector
             
            obj.debug_obj.dbprint(gt,20,obj,[]); % begin z2-msg debug-message
            % initialize local variables
            offset = 0;
            
            % atomic submodels
            if ~isempty(obj.Da)% if there are atomic subcomponents
               for idx=1:length(obj.Da)% for all atomic subcomponents
                   a_obj = obj.components.(char(obj.Da(idx))); % get the atomic subcomponent  
                   if isa(a_obj,'hybridatomic')
                     if ~isempty(a_obj.c_states)
                     % find in CZid, where this atomic model is influenced
                     % by others
                     ioffs=[];
                    for k=1:size(obj.CZid,1) % for all continuous couplings
                       
                        if strcmp(obj.CZid(k,3),a_obj.name) % if the atomic subcomponent is influenced
%                             if obj.debug_flag
%                                 disp(['internal coupling for: ',a_obj.name]);
%                                 disp(['influenced by ',char(obj.CZid(k,1)),' ,port: ',obj.CZid(k,2)]);
%                             end
                           
                             % ioffs berechenbar aus obj.state_offset und obj.num_c_state_events des Einflussnehmers
                             % erster output = obj.state_offset + 1, zweiter
                           
                           
                           ioffs=[ioffs,obj.components.(char(obj.CZid(k,1))).state_offset + obj.CZid{k,2}];%collect all input offsets of subcomponents
                           
                       end
                           
                   end
                   obj.debug_obj.dbprint(gt,21,obj,a_obj); % send z2-msg to subcomponent debug-message 
                   a_obj = z2_msg(a_obj,gt,ioffs); % send the influenced subcomponent a z2-message to set input offsets
                     end
                   end
               end
            end
            % coupled submodels
            if ~isempty(obj.Dc)% if there are coupled subcomponents
                for j=1:length(obj.Dc)% for all coupled subcomponents
                    c_obj = obj.components.(char(obj.Dc(j))); % get the coupled subcomponent
                    % find in CZid, where this coupled model is influenced
                    % by others
                    obj.debug_obj.dbprint(gt,22,obj,c_obj); % send z2-msg to subcomponent debug-message 
                end
            end
            obj.debug_obj.dbprint(gt,22,obj,[]); % end z2-msg debug-message 
                
        end     
   % ######################################################################
   %% SE_MSG
   %  function [obj,event_flag]=se_msg(obj,te,ye,ie)
   %%
   % WHAT HAPPENS IN SE_MSG?
   %%
   % * state event message
   % * is called when a state event occurred somewhere in entire model (for hybrid simulation only)
   % * send all subcomponents an se_message
   % * if state event occured in THIS model, set event_flag and calculate t_next 
   % 
   function [obj,event_flag]=se_msg(obj,te,ye,ie)
             
            obj.debug_obj.dbprint(te(1),23,obj,[]); % begin se-msg debug-message
            event_flag = 0; % standard return, if event did not happen HERE
            if ~isempty(obj.Da)% if there are atomic subcomponents
               for i=1:length(obj.Da)% for all atomic subcomponents
                    a_obj = obj.components.(char(obj.Da(i))); % get the atomic subcomponent
                    if isa(a_obj,'hybridatomic')
                        obj.debug_obj.dbprint(te(1),24,obj,a_obj); % send se-msg to subcomponent debug-message       
                        [a_obj,a_event_flag]=se_msg(a_obj,te,ye,ie); % and send an se-message
                    if a_event_flag == 1 % EVENT occured in an atomic subcomponent
                        event_flag = 1; % event occured in THIS coupled
                    end
                    
                    end
               end
            end
            if event_flag==1 % if event occurred in THIS model part
                build_eventlist(obj);% build a new matrix eventlist, set tnext and tlast
                obj.debug_obj.dbprint(te(1),25,obj,[]); % end se-msg debug-message 
            end
   end
         
%% Functions for displaying the coupled objects
%%
% 
% * |function showxports(obj)|: display x-ports
% * |function showyports(obj)|: display y-ports
% * |function showsubcomponents(obj)|: display atomic and coupled subcomponents
% * |function showcouplings(obj)|: display coupling matrix
% * |function showeventlist(obj)|: display eventlist
% * |function showall(obj)|: display the entire object
%
% These functions *can* be called to get some information during
% or after simulation.
%
      function showcontcouplings(obj)
            disp('Continuous couplings (CZid)')
            disp('from         var#      to           var#  ');
            disp('------------------------------------------');
            for i=1:size(obj.CZid,1)
                disp([obj.CZid{i,1},blanks(13-length(obj.CZid{i,1})),num2str(obj.CZid{i,2}),blanks(6-length(obj.CZid{i,2})),' -> ',obj.CZid{i,3},blanks(13-length(obj.CZid{i,3})),num2str(obj.CZid{i,4})]);
            end
            fprintf(1,'\n');
        end            
            
        
        function showall(obj)
            disp(obj);
            showxports(obj);
            showyports(obj);
            showsubcomponents(obj);
            showcontcouplings(obj)
            showcouplings(obj);
            showeventlist(obj);
         end
        %####################### end DISPLAY HELPER FUNCTIONS #######################
        
% Functions for setting properties
%
% * |function set_CZid(obj, CZid)|: set continuous couplings in CZid (one or more Lines)%


function set_CZid(obj, CZid) % CZid is one or more line of coupling definition
      % {'fromcomp',continuous variable #,'tocomp',continuous input #;...
      %   ....}
      if iscellstr(CZid(:,1)) && iscellstr(CZid(:,3)) && isnumeric(CZid{1,2}) && isnumeric(CZid{1,4}) && size(CZid,2) == 4
          for j=1:size(CZid,1)
              obj.CZid = [obj.CZid;CZid(j,:)];% add a new line to object's CZid
          end
      else
          error('Invalid value for input argument ''CZid''. Must be a cellstring with 4 entries for each row.');
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





