%% Coupled Object with Coordinator Functionalities
%  stored in DEVS_PATH/00-simulator/coupled.p
%
% Is provided as p-code.

%%
% <html>
% <table border=0><tr><td>Based on modified parallel DEVS algorithms (Zeigler, Schwatinski).</td></tr>
% <tr><td>User defined coupled models can be created as instances of this class directly or can
% be derived from it alternatively.
% For initialization, the modeler has to define input and output portnames.
% Components and coupling information are defined after instantiation via the methods *addcomponents(obj,comps)* and *set_Zid(obj,Zid)*.</td></tr>
% <tr><td>C. Deatcu 2016</td></tr></table>
% </html>
% 
%%

classdef coupled < devs
    %% Description
    % Class definition file for a coupled DEVS model and it's *associated
    % coordinator*
    %
    % constructor call:  |obj =
    % coupled(name,xportnames,yportnames)|, where xportnames and yportnames
    % are optional
    %
    %
    %% Superclass
    % |devs|
    %
    %% Inherited properties
    %
    % * |sub_of|    : string, name of the superordinate model --> for debugging purposes
    % * |tnext|     : float, time of next event
    % * |tlast|     : float, time of last event
    % * |name|      : string, (unique) name of this model --> for debugging purposes
    %                 max. 12 characters for "nice" debug-look ;-)
    % * |x|         : structure, set of inport name/input value (cell array) pairs
    % * |y|         : structure, set of outport name/output value (cell array) pairs
    % * |debug_flag|: 0|1|2|3, no messages|messages|steps|visualize x, y, and s of atomic subcomponents (default 0)
    % * |observe_flag|: 0|1, log states of atomic subcomponents or not (default 0)
    %
    %% Properties
    %
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
    %% Class methods
    % *Simulation Messages*
    %
    % * |i_msg(obj,gt)|   : initialization message -
    %                       sets tlast and tnext at all subcomponents and 
    %                       sets matrix |eventlist|
    % * |s_msg(obj,gt,flag)|: star message - called when coupled is
    %                         imminent, sets |tlast| and |tnext|
    % * |x_msg(obj,gt)|  : x message - called, if external event
    %                      arrives 
    % * |y_msg(obj,gt)|  : inperpellation y message
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
    % * |set_debug(obj,debug_flag)|: set debug flag to 0|1|2
    % * |set_observe(obj,observe_flag)|: set observe flag to 0|1 (for tracking states of atomic subcomponents)
   
    % * some methods for getting information on the object (see below
    %   section _Functions for Displaying the Coupled Objects_)
    %
    
    properties (SetAccess = private, GetAccess = public) 
        Da      %//type: cell array of strings    //names of atomic subcomponents
        Dc      %//type: cell array of strings    //names of coupled subcomponents
        Zid     %//type: cell array of strings  //"i-to-d-matrix"
                % (if Da, Dc or Zid are empty: please type [] )        
        eventlist
    end
    
    properties 
     components  %//type: array of objects (subcomponents)
     % public to allow set access from everywhere to subcomponents states
     % or user-defined properties
    end
       
    methods
        % constructor
        function obj = coupled(name,xportnames,yportnames)
            obj = obj@devs(); % create an empty DEVS
            if nargin < 1
                  warning('constructor of class coupled called without a name (less input parameters)');
            else            
                obj.name = name;
                obj.Da = {};
                obj.Dc = {};
                if nargin > 1
                    x =  xportnames;
                    set_x_ports(obj, x);
                else
                    set_x_ports(obj, {});
                end
                if nargin > 2
                    y =  yportnames;
                    set_y_ports(obj, y);
                else
                    set_y_ports(obj, {});
                end
                if nargin > 3
                    warning(['constructor of class coupled <<',name,'>> called with too many input parameters)']);
                end
                obj.eventlist = []; % create an empty evenlist
            end  
        end
        
%$$$$$$$$$$$$$$$$$$$$$$$ COORDINATOR FUNCTIONS $$$$$$$$$$$$$$$$$$$$$$$$$$$$
    %% i_MSG  
    %  function i_msg(obj,gt)
    %%
    % WHAT HAPPENS IN I_MSG?
    %%
    % * set times |tlast| and |tnext| at all objects
    % * set matrix |eventlist|
    %
    %  eventlist = [a,b,c;...]
    %  a - time for next transition
    %  b - {1,2} | 1 if atomic DEVS, 2 if coupled DEVS
    %  c - index for eventlist (position in Da or Dc)
    %
    % |eventlist| is NOT sorted by smallest tnext        
    function i_msg(obj,gt)
        obj.debug_obj.dbprint(gt,1,obj,[]); % begin i-msg debug-message
        % for atomic submodels
        if ~isempty(obj.Da)
            for i = 1:length(obj.Da) % for all atomic subcomponents
                a_name = obj.Da{i};% get name of atomic subcomponent from Da
                a_obj = obj.components.(a_name);% get the atomic object itself
                obj.debug_obj.dbprint(gt,2,obj,a_obj); % send i-msg to atomic subcomponent debug-message
                i_msg(a_obj,gt);%send the atomic object an i_msg
                if i==1
                    obj.tlast = a_obj.tlast; % set last event time to last event time of first atomic subcomponent
                    obj.tnext = a_obj.tnext;% set next event time to last event time of first atomic subcomponent
                    obj.eventlist(1,:)= [a_obj.tnext,1,1];% initialize eventlist (first position)
                else
                    if obj.tlast < a_obj.tlast % test for following atomic subcomponents
                        obj.tlast = a_obj.tlast;% set to smaller tlast
                    end
                    obj.eventlist(i,:) = [a_obj.tnext,1,i]; % add subcomponent to eventlist
                    if obj.tnext > obj.eventlist(i,1)
                        obj.tnext = obj.eventlist(i,1);% set tnext to smallest t of atomic subobj in eventlist
                    end
                end
            end
        end % end atomic
        
        % for coupled submodels
        if ~isempty(obj.Dc)
            for j = 1:length(obj.Dc) % for all coupled subcomponents
                c_name = obj.Dc{j};% get name of coupled subcomponent from Dc
                c_obj = obj.components.(c_name);% get the coupled object itself
                obj.debug_obj.dbprint(gt,2,obj,c_obj); % send i-msg to coupled subcomponent debug-message
                i_msg(c_obj,gt); %send the coupled object an i_msg
                if j==1 && isempty(obj.eventlist)
                    i = 0;% counter of atomic subcomponents already in eventlist --> none
                    obj.tlast = c_obj.tlast;% set last event time to last event time of first coupled subcomponent
                    obj.tnext = c_obj.tnext;% set next event time to next event time of first coupled subcomponent
                    obj.eventlist(1,:) = [c_obj.tnext,2,1];% initialize eventlist (first position)
                else
                    if obj.tlast < c_obj.tlast
                        obj.tlast = c_obj.tlast;
                    end
                    obj.eventlist(i+j,:) = [c_obj.tnext,2,j];% add subcomponent to eventlist
                    if obj.tnext > obj.eventlist(i+j,1)
                        obj.tnext = obj.eventlist(i+j,1);%set tnext to smallest t of subobjects in eventlist
                    end
                end
            end
        end % end coupled
        
        obj.debug_obj.dbprint(gt,3,obj,[]); % end of i-msg debug-message
    end
    % #####################################################################
    
    %% S_MSG  
    %  function s_msg(obj,gt,flag)
    %%
    % WHAT HAPPENS IN S_MSG?
    %%
    % * copy all elements from matrix |eventlist| which are imminent to
    %   local matrix |imminents| (same structure like |eventlist|)
    % * delete all copied rows (look at step before) in |eventlist|
    % * carry out interpellation y-message (only for imminents) -> set all relevant
    %     output ports to input ports
    % * transmit relevant input ports from parent to all children -> delete
    %     all input ports from parent
    % * carry out x-message of relevant (all which have inputs) elements in matrix |eventlist| and
    %     delete the input ports
    % * carry out s-message or x-message (if there are also inputs) for relevant elements in
    %     matrix |imminents| and then delete the input ports
    % * set times |tlast| an |tnext| at THIS coupled and build a new matrix eventlist
    %
    % |flag == 1| --> s_msg from ROOT, |flag == 0| --> s_msg from other
    %
    function s_msg(obj,gt,flag)% flag to distinguish between s_msg from root (1) and other s-messages (0)
        
        if flag ==1
            obj.debug_obj.dbprint(gt,4,obj,[]); % begin s-msg from root debug-message
        else
            obj.debug_obj.dbprint(gt,5,obj,[]); %  begin s-msg from superordinate debug-message
        end
        
        % if obj.tnext~=gt
        if abs(obj.tnext - gt) > obj.epsi
            disp(['error: bad synchronization at coupled coordinator <',obj.name,'> in s_msg']);
            disp(['Values are: tnext = ',num2str(obj.tnext), ' and current time = ',num2str(gt)]);
            showall(obj);
            showeventlist(obj);
            %pause;
        end
        
        % set matrix imminents
        imminents = obj.eventlist(find(abs(obj.eventlist(:,1)-gt)< obj.epsi),:); %#ok<*FNDSB>
        if size(imminents)>1
            obj.debug_obj.dbprint(gt,9,obj,''); %  simultaneous internal events debug-message
        end
        obj.eventlist = obj.eventlist(find(abs(obj.eventlist(:,1)-gt)>= obj.epsi),:);
        
        if flag == 1 % only when *-msg from root-coordinator
            % carry y-message out, set and delete output/input ports
            for i=1:size(imminents,1) % for all imminent submodels
                % atomic models
                if imminents(i,2) == 1 % filter out atomics
                    a_name = obj.Da{imminents(i,3)}; % get name of imminent atomic subcomponent from Da % {} NEW
                    a_obj = obj.components.(a_name);% get the atomic object itself
                    obj.debug_obj.dbprint(gt,6,obj,a_obj); % send interp. y-msg to atomic subcomp. debug-message
                    y_msg(a_obj,gt); % send the atomic object an y_msg
                    obj.debug_obj.dbprint(gt,8,obj,a_obj); % collect output of atomic subcomponents debug-message
                    y = a_obj.y; %#ok<*PROP> % copy output from atomic subcomponent to local variable;
                    obj.debug_obj.dbprintout(gt,1,obj,a_obj);% print output of atomic debug-message
                    % y consists of port/output pairs !!!!
                    % y is to be filled with output from all subcomponents and will be later on copied to obj.y
                    for m=1:size(obj.Zid,1)% for all subcomponents with couplings
                        if strcmp(obj.Zid{m,1},a_name)% lines, where this atomic component influences other components
                            if ~strcmp(obj.Zid{m,3},'parent')% if it are couplings to other components (== ICs or EICs)
                                inf_name = obj.Zid{m,3}; % get name of influenced component
                                inf_obj = obj.components.(inf_name); % get the influenced object itself
                                x = inf_obj.x; % get the current input of influenced component into bag
                                % x consists of port/input pairs !!!!
                                % x is to be filled with input from all subcomponents and will be later on copied to inf_obj.x
                                % in Zid(m,4) are the destination ports, in Zid(m,2) are the origin ports
                                x.(obj.Zid{m,4}) = [x.(obj.Zid{m,4}),y.(obj.Zid{m,2})];% for this line in Zid copy ouput from relevant atomic subcomponent to input matrix BAG
                                obj.components.(inf_name).x = x; % set inputs of this influenced object to updated x
                            end
                        end
                    end
                    try
                        names = fieldnames(y); % get portnames
                        for k=1:length(names) % for all ports
                            y.(names{k}) = {}; % delete output in local variable
                        end
                    catch
                    end
                    obj.components.(a_name).y = y; %  set outputs of current atomic subcomponent to empty (copy from local variable to model)
                    % end atomic imminents
                    
                    % coupled imminents
                else
                    c_name = obj.Dc{imminents(i,3)};% get name of imminent coupled subcomponent from Dc
                    c_obj = obj.components.(c_name);% get the coupled object itself
                    obj.debug_obj.dbprint(gt,6,obj,c_obj); % send interp. y-msg to coupled subcomp. debug-message
                    y_msg(c_obj,gt); % send an interpellation y-message to subcomponent
                    obj.debug_obj.dbprint(gt,8,obj,c_obj); % collect output of coupled subcomponents debug-message
                    y = c_obj.y; % copy output from coupled subcomponent to local variable;
                    obj.debug_obj.dbprintout(gt,1,obj,c_obj);% print output of coupled subcomp. debug-message
                    
                    for m=1:size(obj.Zid,1) % for all subcomponents with couplings
                        if strcmp(obj.Zid{m,1},c_name) % lines, where this coupled component influences others
                            if ~strcmp(obj.Zid{m,3},'parent') % if it are couplings to other components (== ICs or EICs)
                                inf_name = obj.Zid{m,3}; % get name of influenced component
                                inf_obj = obj.components.(inf_name); % get the influenced object itself
                                inf_obj.x.(obj.Zid{m,4}) = [inf_obj.x.(obj.Zid{m,4}), y.(obj.Zid{m,2})]; % for this line in Zid copy ouput from relevant coupled subcomponent to input matrix BAG
                            end
                        end
                    end
                    
                    % delete outputs and save coupled DEVS
                    names = fieldnames(y); % get portnames
                    for k=1:length(names) % for all ports
                        y.(names{k}) = {}; % delete output in local variable
                    end
                    obj.components.(c_name).y = y; %  set outputs of current coupled subcomponent to empty (copy from local variable to model)
                end % end coupled imminents
            end % end all imminents
        end % end for s_messages fromm root-coordinator

  % until here just, if *-message came from root coordinator 
  % #######################################################################
  % following code for all *-messages
  
   % transmit relevant input ports from parent to its children -> delete all
   % input ports from parent
       new_x = obj.x; % save structure of x for deleting inputs later on
       for i=1:size(obj.Zid,1) % for all couplings
           if strcmp(obj.Zid{i,1},'parent') % just for the EICs
               inf_name = obj.Zid{i,3}; % get name of influenced component
               inf_obj = obj.components.(inf_name); % get the influenced object itself
               x = inf_obj.x; % get the current input of influenced component into bag
               x.(obj.Zid{i,4}) = [x.(obj.Zid{i,4}), obj.x.(obj.Zid{i,2})]; % transmit input from parent to ports in x (local variable) BAG
               new_x.(obj.Zid{i,2}) = {}; % delete input at this port in parent, first in local variable - set obj.x later, outside of loop!!!
               obj.components.(inf_name).x = x; % set inputs of the influenced subcomponent
           end
       end
       obj.x = new_x; % set the deleted ports (delete all transmitted inputs of parent)
       % carry x-message out from relevant elements in matrix eventlist and
       % delete the input ports
       % just for subcomponents, which are not imminent!!!
       for i=1:size(obj.eventlist,1) % for all rows = all entries in eventlist
           % atomic DEVS
           if obj.eventlist(i,2) == 1 % if it is atomic
               a_name = obj.Da{obj.eventlist(i,3)}; % name of atomic subcomponent
               x = obj.components.(a_name).x; % get input values of this subcomponent into local variable
               if ~isempty(x) % if there are ports
                   names = fieldnames(x); % get portnames
                   for l=1:length(names) % for all ports, get out of this loop with break
                       if ~isempty(x.(names{l})) % if there is an input at this port
                           a_obj = obj.components.(a_name); % get the object
                           
                           obj.debug_obj.dbprint(gt,10,obj,a_obj);% send x-msg to atomic subcomp. debug-message                           
                           x_msg(a_obj,gt);% send an x-message
                           
                           for k=l:length(names)
                               x.(names{k})= {}; % delete all inputs in local variable
                           end
                           obj.components.(a_name).x = x; % delete all inputs at atomic subcomponent
                           break; % x-message is to be carried just once for each atomic which has at least
                           % one port with input
                       end
                   end
               end
               %coupled DEVS
           else
               c_name = obj.Dc{obj.eventlist(i,3)}; % name of coupled subcomponent
               x = obj.components.(c_name).x; % get input values of this subcomponent
               if ~isempty(x)% if there are ports
                   names=fieldnames(x);% get portnames
                   for l=1:length(names)% for all ports
                       if ~isempty(x.(names{l}))% if there is an input at this port
                           c_obj = obj.components.(c_name);
                           
                           obj.debug_obj.dbprint(gt,10,obj,c_obj);% send x-msg to coupled subcomp. debug-message                           
                           x_msg(c_obj,gt);
                           
                           for k=l:length(names)
                               x.(names{k})= {}; % delete all inputs in local variable
                           end
                           obj.components.(c_name).x = x; % delete all inputs at coupled subcomponent
                           break;
                       end
                   end
               end
           end
       end
       % branches for atomic and coupled could be programmed as one!
       
       % carry s-message or confluent-function out for relevant elements in
       % matrix imminents and delete the input ports
       for i=1:size(imminents,1)
           %atomic DEVS
           if imminents(i,2)==1
               deltaconf=0;% set flag deltaconf of this atomic imminent to 0 --> confluent function does not need to be carried out, because there is no known input
               a_name = obj.Da{imminents(i,3)}; % name of atomic subcomponent
               a_obj = obj.components.(a_name);% get the atomic object itself
               x = a_obj.x; % get input values of this subcomponent into local variable
               if ~isempty(x)
                   names=fieldnames(x);% get portnames
                   for k=1:length(names)% for all ports
                       if ~isempty(x.(names{k}))% if there is an input at this port
                           deltaconf=1;% if there is an input at this port, confluent function needs to be carried out later --> set deltanconf-flag
                           break;
                       end
                   end
               end
               switch deltaconf
                   % carry out s-message
                   case 0 % no inputs for this imminent subcomponent, so just s-message necessary!
                       obj.debug_obj.dbprint(gt,11,obj,a_obj);% send s-msg to atomic subcomp. debug-message                       
                       s_msg(a_obj, gt, 0); % send s_msg with flag = 0, because it is s-message from upper component, not from root coordinator
                       
                       % carry out confluent-function
                   case 1 % if there are inputs for this imminent subcomponent, confluent function needs to be carried out
                       obj.debug_obj.dbprint(gt,12,obj,a_obj);% simultaneuous external and internal events debug-message
                       
                       obj.debug_obj.dbprint(gt,10,obj,a_obj);% send x-msg to atomic subcomp. debug-message                       
                       x_msg(a_obj,gt);% call the x_msg, which then desides, if to call deltaconf or not
                       
                       for l=k:length(names)
                           x.(names{l})= {}; % delete all inputs in local variable
                       end
                       obj.components.(a_name).x = x; % delete all inputs at atomic subcomponent
               end
               % coupled DEVS
           else
               c_name = obj.Dc{imminents(i,3)}; % name of coupled subcomponent
               c_obj = obj.components.(c_name);% get the coupled object itself
               
               obj.debug_obj.dbprint(gt,11,obj,c_obj);% send s-msg to coupled subcomp. debug-message
               s_msg(c_obj,gt,0);
               
           end
       end
       
    % set times tlast and tnext at parent and build a new matrix eventlist
    obj.eventlist = [];
    
    % atomic-models
    if ~isempty(obj.Da)
        for i=1:length(obj.Da)
            a_name = obj.Da{i}; % name of atomic subcomponent
            a_obj = obj.components.(a_name);% get the atomic object itself
            if i==1
                obj.tlast = a_obj.tlast; % initialize tlast with tlast of first atomic subcomponent
                obj.tnext = a_obj.tnext; % initialize tnext with tnext of first atomic subcomponent
                obj.eventlist(i,:)= [a_obj.tnext,1,i];% create first entry in eventlist
            else
                if obj.tlast < a_obj.tlast
                    obj.tlast = a_obj.tlast; % set tlast to highest tlast
                end
                obj.eventlist(i,:) = [a_obj.tnext,1,i]; % add entry to eventlist
                if obj.tnext > obj.eventlist(i,1)
                    obj.tnext = obj.eventlist(i,1); % set tnext to smaller value of subcomponent, if there's one
                end
            end
        end
    end
    
    % coupled models
    if ~isempty(obj.Dc)
        for j=1:length(obj.Dc)
            c_name = obj.Dc{j}; % name of coupled subcomponent
            c_obj = obj.components.(c_name); % get the coupled object itself
            if j==1 && isempty(obj.eventlist) % for first coupled subcomponent, if there was no atomic subcomponent
                obj.tlast = c_obj.tlast; % initialize tlast with tlast of first coupled subcomponent
                obj.tnext = c_obj.tnext; % initialize tnext with tnext of first coupled subcomponent
                obj.eventlist(j,:)= [obj.tnext,2,j]; % create first entry in eventlist
                i=0; % initialize i, if there were atomic subcomponents, i has an value already
            else
                if obj.tlast < c_obj.tlast
                    obj.tlast = c_obj.tlast;
                end
                obj.eventlist(i+j,:) = [c_obj.tnext,2,j];% add an entry to eventlist, i for offset, if there are already atomic subcomponents in it
                if obj.tnext > obj.eventlist(i+j,1)
                    obj.tnext = obj.eventlist(i+j,1); %set tnext to smaller value of subcomponent, if there's one
                end
            end
        end
    end
    obj.debug_obj.dbprint(gt,7,obj,[]);% end s-msg debug message
    end
   % ######################################################################
   %% Y_MSG
   %  function y_msg(obj,gt)
   %
   %  it is an interpellation y_msg
   %%
   % WHAT HAPPENS IN Y_MSG?
   %%
   % * copy all elements from matrix |eventlist| which are imminent to 
   %     local matrix |imminents| (same structure like eventlist)
   % * carry y-message out for all elements in |imminents| 
   %     -> set relevant input/output ports
   %
   function y_msg(obj,gt)
       obj.debug_obj.dbprint(gt,13,obj,[]);% begin interp. y-msg debug message
       % set matrix imminents
       imminents = obj.eventlist(find(abs(obj.eventlist(:,1)-gt)< obj.epsi),:);
       for i=1:size(imminents,1)
           % atomic DEVS
           if imminents(i,2)==1
               a_name = obj.Da{imminents(i,3)}; % get name of imminent atomic subcomponent from Da
               a_obj = obj.components.(a_name);% get the atomic object itself
               
               obj.debug_obj.dbprint(gt,6,obj,a_obj); % send interp. y-msg to atomic subcomp. debug-message               
               y_msg(a_obj,gt);% send the atomic object an y_msg
               % this was an interpellation message!
               obj.debug_obj.dbprint(gt,8,obj,a_obj); % collect output of atomic subcomponent debug message
               
               %y = a_obj.y; % copy output from atomic subcomponent to local variable;
               obj.debug_obj.dbprintout(gt,1,obj,a_obj);% print output of atomic debug-message
               
               for m=1:size(obj.Zid,1)%for all subcomponents with couplings
                   if strcmp(obj.Zid{m,1},a_name) % lines, where this atomic component influences other components or parent
                       if strcmp(obj.Zid{m,3},'parent') % if this atomic component influences its parent == EOC
                           obj.y.(obj.Zid{m,4}) = [obj.y.(obj.Zid{m,4}), a_obj.y.(obj.Zid{m,2})]; % for this line in Zid copy ouput from relevant atomic subcomponent to output matrix BAG
                       else
                           inf_name = obj.Zid{m,3}; % get name of influenced component
                           inf_obj = obj.components.(inf_name); % get the influenced object itself
                           x = inf_obj.x; % get the current input of influenced component into bag
                           x.(obj.Zid{m,4}) = [x.(obj.Zid{m,4}), a_obj.y.(obj.Zid{m,2})]; % for this line in Zid copy ouput from relevant atomic subcomponent to input matrix BAG
                           obj.components.(inf_name).x = x; % set inputs of this influenced object to updated x
                       end
                   end
               end
               names=fieldnames(a_obj.y); % delete outputs and save atomic DEVS
               for k=1:length(names)
                   a_obj.y.(names{k}) = {};
               end
               
               % coupled DEVS
           else
               c_name = obj.Dc{imminents(i,3)}; % get name of imminent coupled subcomponent from Dc
               c_obj = obj.components.(c_name);% get the coupled object itself
               
               obj.debug_obj.dbprint(gt,6,obj,c_obj); % send interp. y-msg to coupled subcomp. debug-message     
               y_msg(c_obj,gt);% send the coupled object an y_msg
               
               obj.debug_obj.dbprint(gt,8,obj,c_obj); % collect output of coupled subcomponent debug message
               %y = c_obj.y;% copy output from coupled subcomponent to local variable;
               
               obj.debug_obj.dbprintout(gt,1,obj,c_obj);% print output of coupled debug-message
               
               for l=1:size(obj.Zid,1)
                   if strcmp(obj.Zid{l,1},c_name)% lines, where this coupled component influences other components or parent
                       if strcmp(obj.Zid{l,3},'parent')
                           obj.y.(obj.Zid{l,4}) = [obj.y.(obj.Zid{l,4}), c_obj.y.(obj.Zid{l,2})]; % for this line in Zid copy ouput from relevant coupled subcomponent to output matrix BAG
                       else
                           inf_name = obj.Zid{l,3}; % get name of influenced component
                           inf_obj = obj.components.(inf_name); % get the influenced object itself
                           x = inf_obj.x; % get the current input of influenced component into bag
                           x.(obj.Zid{l,4}) = [x.(obj.Zid{l,4}), c_obj.y.(obj.Zid{l,2})];% for this line in Zid copy ouput from relevant coupled subcomponent to input matrix BAG
                           obj.components.(inf_name).x = x; % set inputs of this influenced object to updated x
                       end
                   end
               end
               names=fieldnames(c_obj.y);%delete outputs and save coupled DEVS
               for k=1:length(names)
                   c_obj.y.(names{k}) = {};
               end
           end
       end
       obj.debug_obj.dbprint(gt,14,obj,[]); % end interp. y-msg debug message
   end
   % ######################################################################
   %% X_MSG
   %  function x_msg(obj,gt)
   %%
   % WHAT HAPPENS IN X_MSG?
   %%
   % * transmit relevant input ports from parent to all children -> delete
   %   all input ports from parent
   % * carry out x-message of influenced subcomponents
   % * set times |tlast| and |tnext| at parent and build a new matrix
   %     |eventlist|
   function x_msg(obj,gt)
       
    obj.debug_obj.dbprint(gt,15,obj,[]); % begin x-msg debug message    
    obj.debug_obj.dbprintout(gt,2,obj,[])% print x-ports debug-message
    % transmit relevant input ports from parent to its children -> delete all
    % input ports from parent
    parentx = obj.x;
    new_parentx = obj.x;
    for i=1:size(obj.Zid,1)
        if strcmp(obj.Zid{i,1},'parent')% if the parent influences a subcomponent
            inf_name = obj.Zid{i,3};% get name of influenced subcomponent
            inf_obj = obj.components.(inf_name); % get the influenced object itself
            x = inf_obj.x; % get the current input of influenced component into bag
            x.(obj.Zid{i,4}) = [x.(obj.Zid{i,4}), parentx.(obj.Zid{i,2})];% transmit input from parent to influenced subcomponent BAG
            new_parentx.(obj.Zid{i,2}) = {};% delete input at this port of parent
            obj.components.(inf_name).x = x; % set inputs of this influenced object to updated x
        end
    end
    obj.x = new_parentx;% update x of parent --> delete all inputs
    
    %carry x-message out
    for i=1:size(obj.eventlist,1)  %external transitions from eventlist
        %disp(obj.name);
        %disp(obj.eventlist);
        %atomic DEVS
        if obj.eventlist(i,2)==1% for all atomics in eventlist
            a_name = obj.Da{obj.eventlist(i,3)};% get name of atomic subcomponent
            a_obj = obj.components.(a_name);% get the atomic object itself
            x = a_obj.x;% current input of atomic into local variable x
            if ~isempty(x)% if there are some input ports
                names=fieldnames(x);
                for l=1:length(names)% for all ports
                    if ~isempty(x.(names{l}))% if there is an input at this port
                        obj.debug_obj.dbprint(gt,10,obj,a_obj); % send x-msg to subcomponent debug message                          
                        x_msg(a_obj,gt); % send the atomic object an x_msg
                        
                        for k=l:length(names)
                            x.(names{k}) = {};
                        end
                        obj.components.(a_name).x = x; % delete all inputs at atomic subcomponent
                        break;
                    end
                end
            end
            
            %coupled DEVS
        else
            c_name = obj.Dc{obj.eventlist(i,3)};% get name of coupled subcomponent
            c_obj = obj.components.(c_name);% get the coupled object itself
            x = c_obj.x;% current input of x into local variable
            if ~isempty(x)% if there is some input
                names=fieldnames(x);% for all ports
                for l=1:length(names)
                    if ~isempty(x.(names{l}))% if there is an input at this port
                        obj.debug_obj.dbprint(gt,10,obj,c_obj); % send x-msg to subcomponent debug message  
                        x_msg(c_obj,gt);% send the coupled object an x_msg
                        
                        for k=l:length(names)
                            x.(names{k}) = {};
                        end
                        obj.components.(c_name).x = x; % delete all inputs at coupled subcomponent
                        break;
                    end
                end
            end
        end
    end
    % set times tlast and tnext at parent and build a new matrix eventlist
    obj.eventlist=[]; % delete old eventlist
    
    % atomic models
    if ~isempty(obj.Da) % if there are atomic subcomponents
        for i=1:length(obj.Da )% for all atomic subcomponents
            a_obj = obj.components.(obj.Da{i}); % get the atomic subcomponent
            if i==1 %if it is the first one
                obj.tlast = a_obj.tlast; % initialize tlast
                obj.tnext = a_obj.tnext; % initialize tnext
                obj.eventlist(i,:) = [obj.tnext,1,i]; % initialize eventlist with first entry
            else
                if obj.tlast < a_obj.tlast
                    obj.tlast = a_obj.tlast; % set parent's tlast to biggest of atomic subcomponents
                end
                obj.eventlist(i,:) = [a_obj.tnext,1,i]; % add atomic subcomponent to eventlist
                if obj.tnext > obj.eventlist(i,1) % if tnext in eventlist is smaller
                    obj.tnext = obj.eventlist(i,1); % set to smaller tnext of atomic subcomponent
                end
            end
        end
    end
    
    % coupled models
    if ~isempty(obj.Dc) % if there are coupled subcomponents
        for j=1:length(obj.Dc) % for all coupled subcomponents
            c_obj = obj.components.(obj.Dc{j}); % get the coupled subcomponent
            if j==1 && isempty(obj.eventlist) % if it is the first one AND no atomics --> eventlist was still empty
                obj.tlast = c_obj.tlast; % initialize tlast
                obj.tnext = c_obj.tnext; % initialize tnext
                obj.eventlist(j,:) = [obj.tnext,2,j]; % initialize eventlist with first entry
                i = 0; % set offset for atomics in eventlist to 0, because ther are no
            else
                if obj.tlast < c_obj.tlast
                    obj.tlast = c_obj.tlast; % set parent's tlast to biggest of coupled subcomponents
                end
                obj.eventlist(i+j,:) = [c_obj.tnext,2,j]; % add coupled subcomponent to eventlist at position i+j, where i is offset from atomics
                if obj.tnext > obj.eventlist(i+j,1) % if tnext in eventlist is smaller
                    obj.tnext = obj.eventlist(i+j,1); % set to smaller tnext of coupled subcomponent
                end
            end
        end
    end
    obj.debug_obj.dbprint(gt,16,obj,[]); % end x-msg debug message  
    
   end
   
%$$$$$$$$$$$$$$$$$$$$$$$$$$ end COORDINATOR MESSAGES $$$$$$$$$$$$$$$$$$$$$

    % Helper function for coupled models
    % builds a new matrix |eventlist| by calculating |tlast| and |tnext| of all
    % subcomponents

    function build_eventlist(obj)

        obj.eventlist = [];

        % atomic-models
        if ~isempty(obj.Da)
            for i=1:length(obj.Da)
                a_name = obj.Da{i}; % name of atomic subcomponent
                a_obj = obj.components.(a_name); % get the atomic object itself
                if i==1
                    obj.tlast = a_obj.tlast; % initialize tlast with tlast of first atomic subcomponent
                    obj.tnext = a_obj.tnext; % initialize tnext with tnext of first atomic subcomponent
                    obj.eventlist(i,:)= [a_obj.tnext,1,i]; % create first entry in eventlist
                else
                    if obj.tlast<a_obj.tlast
                        obj.tlast = a_obj.tlast; % set tlast to highest tlast
                    end
                    obj.eventlist(i,:) = [a_obj.tnext,1,i]; % add entry to eventlist
                    if obj.tnext>obj.eventlist(i,1)
                        obj.tnext = obj.eventlist(i,1); % set tnext to smaller value of subcomponent, if there's one
                    end
                end
            end
        end

        % coupled models
        if ~isempty(obj.Dc)
            for j=1:length(obj.Dc)
                c_name = obj.Dc{j}; % name of coupled subcomponent
                c_obj = obj.components.(c_name); % get the coupled object itself
                if j==1 && isempty(obj.eventlist) % for first coupled subcomponent, if there was no atomic subcomponent
                    obj.tlast = c_obj.tlast; % initialize tlast with tlast of first coupled subcomponent
                    obj.tnext = c_obj.tnext; % initialize tnext with tnext of first coupled subcomponent
                    obj.eventlist(j,:)= [obj.tnext,2,j]; % create first entry in eventlist
                    i=0; % initialize i, if there were atomic subcomponents, i has an value already
                else
                    if obj.tlast<c_obj.tlast
                        obj.tlast=c_obj.tlast;
                    end
                    obj.eventlist(i+j,:)=[c_obj.tnext,2,j]; % add an entry to eventlist, i for offset, if there are already atomic subcomponents in it
                    if obj.tnext>obj.eventlist(i+j,1)
                        obj.tnext=obj.eventlist(i+j,1); % set tnext to smaller value of subcomponent, if there's one
                    end
                end
            end
        end
    end
  %####################### end HELPER FUNCTION #######################

  % Functions for setting properties
  %
  %
  % * |function set_debug(obj,debug_flag)|: set debug flag to 0|1|2
  % * |function add_c_component(obj, comps)|: add one coupled subcomponent
  % * |function add_a_component(obj, comps)|: add one atomic subcomponent
  % * |function addcomponents(obj, comps)|: add one or more subcomponents of any kind ;-)
  % * |function set_Zid(obj, Zid)|: set Zid (one or more Lines)
  % * |function set_observe(obj,observe_flag)|: set observe flag to 0|1
  
  %
  %
  function set_debug(obj, debug_flag,descriptor)
      if ismember(debug_flag,[0, 1, 2, 3])
          obj.debug_flag=debug_flag; % set the flag for THIS coupled
          if (debug_flag == 1) || (debug_flag == 2)            
             if nargin == 3
                 obj.debug_obj = db_m(descriptor);
             else
                  obj.debug_obj = db_m(1);% std-out, if noc descriptor is specified
             end
          end
             
          if ~isempty(obj.Dc)
              for j=1:length(obj.Dc)
                  if nargin == 3
                      set_debug(obj.components.(obj.Dc{j}),debug_flag,descriptor);
                  else
                    set_debug(obj.components.(obj.Dc{j}),debug_flag);
                  end
              end
          end
          if ~isempty(obj.Da)
              for i=1:length(obj.Da)
                  if nargin == 3
                     set_debug(obj.components.(obj.Da{i}),debug_flag,descriptor); 
                  else
                    set_debug(obj.components.(obj.Da{i}),debug_flag);
                  end
              end
          end
      else
          error('debug_flag needs to be 0|1|2|3');
      end
  end
  
  function set_observe(obj, observe_flag)
      if observe_flag == 0 ||  observe_flag == 1
          obj.observe_flag=observe_flag; % set the flag for THIS coupled
          if ~isempty(obj.Dc)
              for j=1:length(obj.Dc)
                  set_observe(obj.components.(obj.Dc{j}),observe_flag);
              end
          end
          if ~isempty(obj.Da)
              for i=1:length(obj.Da)
                  set_observe(obj.components.(obj.Da{i}),observe_flag);
              end
          end
      else
          error('observe_flag needs to be 0|1');
      end
  end
  
  function [Dc] = add_c_component(obj, comp) % add one or more coupled components
      if isa(comp,'coupled')
          obj.components.(comp.name)=comp; % add to arry of component objects
          obj.components.(comp.name).sub_of = obj.name;
          obj.Dc = [obj.Dc,comp.name]; % before first call Dc must be initialized as {}
          Dc = obj.Dc;
      else
          error('This component is NOT ADDED, because it is not of class ''coupled'' or derived from it');
      end
  end
  
  
  function [Da] = add_a_component(obj, comp) % add one or more atomic components
      if isa(comp,'atomic')
          obj.components.(comp.name)=comp; % add to arry of component objects
          obj.components.(comp.name).sub_of = obj.name;
          obj.Da = [obj.Da,comp.name]; % before first call Da must be initialized as {}
          Da = obj.Da;
      else
          error('This component is NOT ADDED, because it is not an atomic model');
      end
  end
  
  function addcomponents(obj,comps) % adds components no matter if coupled or atomics
      for j=1:length(comps)
          if isa(comps{j},'atomic') || isa(comps{j},'coupled')
              if ~isempty(obj.Dc)
                  if any(strcmp(comps{j}.name,obj.Dc))
                      error(['duplicate name on this level, the name ',comps{j}.name,'  exists already in Dc']);
                  end
              end
              if ~isempty(obj.Da)
                  if any(strcmp(comps{j}.name,obj.Da))
                      error(['duplicate name on this level, the name ',comps{j}.name,' exists already in Da']);
                  end
              end
          end
          
          if isa(comps{j},'atomic')
              %disp([comps{j}.name,' is atomic']);
              add_a_component(obj, comps{j});
          elseif isa(comps{j},'coupled')
              add_c_component(obj, comps{j});
          else
              %disp(class(comps(j)));
              error(['Component no ',num2str(j),' is not a valid subcomponent because it is of class ',class(comps(j))]);
              
              %error(['Component ', comps{j}.name, 'is not a valid subcomponent']);
          end
      end
  end
  
  
  
  
  function set_Zid(obj, Zid) % Zid is one or more line of coupling definition
      % {'fromcomp','fromport','tocomp','toport';...
      %   ....}
      if iscellstr(Zid) && size(Zid,2) == 4
          for j=1:size(Zid,1)
              obj.Zid = [obj.Zid;Zid(j,:)];% add a new line to object's Zid
          end
      else
          error('Invalid value for input argument ''Zid''. Must be a cellstring with 4 entries for each row.');
      end
  end
  
  

%####################### end SET FUNCTIONS #######################


%% Methods for Displaying the Coupled Objects
%%
% 
% * |showxports(obj)|: display x-ports
% * |showyports(obj)|: display y-ports
% * |showsubcomponents(obj)|: display atomic and coupled subcomponents
% * |showcouplings(obj)|: display coupling matrix
% * |showeventlist(obj)|: display eventlist
% * |showall(obj)|: display the entire object
%
% These functions *can* be called to get some information during
% or after simulation.
%
    function showxports(obj)
        disp('Set of inputs x'),disp('----------------------------------'),disp(obj.x);
        fprintf(1,'\n');
    end

    function showyports(obj)
        disp('Set of outputs y '),disp('----------------------------------'),disp(obj.y);
        fprintf(1,'\n');
    end

    function showsubcomponents(obj)
        disp('Atomic subcomponents in Da');
        disp('---------------------------');
        disp(char(obj.Da));
        fprintf(1,'\n');
        disp('Coupled subcomponents in Dc ');
        disp('---------------------------');
        disp(char(obj.Dc));
        fprintf(1,'\n');
    end
    function showcouplings(obj)
        disp('Couplings (Zid)')
        disp('from         port      to           port  ');
        disp('------------------------------------------');
        for i=1:size(obj.Zid,1)
            disp([obj.Zid{i,1},blanks(13-length(obj.Zid{i,1})),obj.Zid{i,2},blanks(6-length(obj.Zid{i,2})),' -> ',obj.Zid{i,3},blanks(13-length(obj.Zid{i,3})),obj.Zid{i,4}]);
        end
        fprintf(1,'\n');
    end

    function showeventlist(obj)
        disp('Eventlist');
        disp('tnext        a(1)/c(2)    name of subcomp.');
        disp('------------------------------------------');
        for i=1:size(obj.eventlist,1)
            if obj.eventlist(i,2) == 1
                subname = obj.Da{obj.eventlist(i,3)};
            end
            if obj.eventlist(i,2) == 2
                subname = obj.Dc{obj.eventlist(i,3)};
            end
            %disp([num2str(obj.eventlist(i,1)),blanks(13-length(num2str(obj.eventlist(i,1)))),'    ',num2str(obj.eventlist(i,2)),'           ',num2str(obj.eventlist(i,3))]);
            disp([num2str(obj.eventlist(i,1)),blanks(13-length(num2str(obj.eventlist(i,1)))),'    ',num2str(obj.eventlist(i,2)),'           ',subname]);
        end
        fprintf(1,'\n');
    end



    function showall(obj)
        disp(obj);
        showxports(obj);
        showyports(obj);
        showsubcomponents(obj);
        showcouplings(obj);
        showeventlist(obj);
    end
        %####################### end DISPLAY HELPER FUNCTIONS #######################
        
    function [flag, descriptor] = is_debug(obj,pflag,pdescriptor) % find out, if ANYWHERE in model is a debug_flag set
                                                                  % return the flag and a file descriptor, if one is set; returns the first flag found in tree!!!              
        flag = pflag;
        descriptor = pdescriptor;
        if pflag == 1 || pflag == 2
             return
        end
        if ~isempty(obj.Dc)
            for j=1:length(obj.Dc)
                if flag == 1 || flag == 2
                    return
                end
                flag = obj.components.(obj.Dc{j}).debug_flag;
                %disp([obj.components.(obj.Dc{j}).name, ' s flag is :', num2str(obj.components.(obj.Dc{j}).debug_flag)]);
                if flag == 1 || flag == 2
                    descriptor = obj.components.(obj.Dc{j}).debug_obj.out;
                    return
                end
                [flag, descriptor] = is_debug(obj.components.(obj.Dc{j}),flag,pdescriptor);
            end
        end
          if ~isempty(obj.Da)
              for i=1:length(obj.Da)
                  flag = obj.components.(obj.Da{i}).debug_flag;
                  %disp([obj.components.(obj.Da{i}).name, ' s flag is :', num2str(obj.components.(obj.Da{i}).debug_flag)]);
                  if flag == 1 || flag == 2
                      descriptor = obj.components.(obj.Da{i}).debug_obj.out;
                      return
                  end
              end
          end
    end
        
        
    end
end

%
 %% Example: How to Create a Coupled Model 
% 
%
%   >> newcoupled = coupled('model', {'inport1', 'inport2'}, {'outport1'});% incarnate with portnames
%
% *OR*
%
%   >> newcoupled = coupled('model'); % incarnate without portnames
%   >> set_x_ports(newcoupled, {'inport1','inport2'}); % set x and y ports
%   >> set_y_ports(newcoupled, {'outport1'});
%
% *then add subcomponents*
%
%   >> subcomponent1 = coupled('sub1', {'in1','in2'},{'out1'}); % incarnate subcomponents
%   >> set_Zid(subcomponent1,{'parent','in2','parent','out1'}); % dummy Zid
%   >> subcomponent2 = coupled('sub2', {'in1'}, {'out1'}); 
%   >> set_Zid(subcomponent2,{'parent','in1','parent','out1'}); % dummy Zid
%   >> addcomponents(newcoupled, {subcomponent1, subcomponent2}); % add components to model
%
% *then add couplings*
%
%   >> Zid = {'parent','inport2','sub1','in1';...   % define Zid
%             'parent','inport1','sub2','in1';...
%             'sub2','out1','sub1','in2';...
%             'sub2','out1','parent','outport1'};
%   >> set_Zid(newcoupled, Zid);
% 
% *check your model*
%
%   >> Check(newcoupled); % check recursively if all names and ports really exist
%
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





