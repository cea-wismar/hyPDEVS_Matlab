%% PDEVS Root Coordinator for Hybrid Models
% stored in DEVS_PATH/r_c_hybrid.p
%
% Is provided as p-code.

%% Description
% Hybrid DEVS root coordinator for parallel DEVS with ports (experimental
% status). 
%
% This root coordinator implements the *Wrapper Concept* for hybrid DEVS
% modeling and simulation. Read more about the concept e.g. in _C. Deatcu,
% T. Pawletta: A Qualitative Comparison of Two Hybrid DEVS Approaches.
% In: Simulation Notes Europe (SNE), Vol. 22(1), ARGESIM/ASIM Pub. TU Vienna, Austria, April 2012,
% Pages 15-24. (Print ISSN 2305-9974, Online ISSN 2306-0271,
% doi:10.11128/sne.22.tn.10107)_
%
% In a hybrid, modular hierarchical model, continuous model parts are typically distributed over several model components.
% To allow the deployment of advanced numerical integration methods for computation without a previous model flattening,
% these distributed continuous model parts need to be collected, united and provided in a way suitable for the chosen ODE
% solver’s interface. An ODE wrapper function supplies the closed representation of continuous model parts required by the ODE solver.
% Coevally, structure information remains available. The modular hierarchical model itself is not modified. Rather, a closed representation
% of continuous model parts is generated additionally during simulation runtime.
% 
% A discrete PDEVS root coordinator is therefore extended to operate in three different phases: i) initialization phase, ii) discrete phase, and iii) continuous phase.
%
%
%% Usage
%
% *Call:* |[root_model,tout,yout,teout,yeout,ieout]=r_c_hybrid(root_model,tstart,tend,plot_params)|
%
%
% *Input arguments:*
%
% |root_model| : type is hybridcoupled object
%
% |tstart| : type is double, start time for simulation
%
% |tend| : type is double, end time for simulation
% 
% |plot_params| : type is structure, optional parameter
%
%
% *Ouput arguments:*
%
% |root_model| : type is hybridcoupled object
%
% |tout| : vector of time values (returned by ode45)
%
% |yout| : vector of continuous values (returned by ode45)
% 
% |teout| :  vector of event time values (returned by ode45)
% 
% |yeout| : vector of continuous values at event times (returned by ode45)
%
% |ieout| : vector of indices of event functions (returned by ode45)
%
%
% *Variables used in simulator:*
%
% |gt| : type is double, current simulation time
%
% |state| : type is integer, 0 = startup state, 1 = discrete state, 2 = continuous state
%
% |gstatvec| : global state vector for continuous states (initial
% conditions)
%
%
%% Globals
% All globals are usually set in initialization script of model.
%
% * |HYBRID| : needs to be 1 for hybrid simulation
% * |SIMUSTOP| : to stop simulation by condition, |SIMUSTOP = 0| --> simulate, |SIMUSTOP = 1| --> stop simulation. Set to 0 in
% initialization script of model. Can be manipulated in any part of the model
% * |ODEPLOT| : to allow plotting of continuous variables during
% simulation,  |ODEPLOT = 0| --> no plotting, |ODEPLOT = 1| --> plotting; if plotting, plot_params need to be passed as
% optional parameter
% 
%
%% Simulation Loop
% The hybrid root coordinator operates in three different phases:
% 
% # Initialization phase,
% # Discrete phase,
% # Continuous phase.
%
% The listing below gives an impression of the simulation algorithm.
%
% <<img/rc_algorithm.png>>
%
% *Listing: Root coordinator algorithm*
%
% In addition to the well-known messages from traditional DEVS simulators, i-message, *-message, x-message, and y-message,
% we introduce a z- and a z2 message for vector configuration purposes and an se-message for handling state events of the continuous model parts.
% For exact mapping of simultaneous events we use an interpellation y-message.
% At startup of a simulation run, the initialization phase is entered and the model is initialized by an initialization message (i-message)
% sent by the root coordinator to the outermost coupled model. The initialization message is passed down the hierarchy among
% the simulation objects until it reaches the leaves of the object tree. Based on the minimum of time stamps for the next
% internal events (as they are returned by the subcomponents), the root coordinator determines whether a discrete or a continuous
% simulation phase has to be started next. If there is no imminent internal event at current simulation time, a continuous cycle/
% is initiated and starts with an update of the wrapper data structures.
% For this purpose the root coordinator sends recursive configuration messages (z- and z2-message) to the associated hybrid coordinator of the
% outermost |hybridcoupled| model. Those messages are passed down the hierarchy tree. References to all hybrid atomic simulation
% objects as well as direct references to all continuous state variables contained are returned. Furthermore,
% direct links between continuous output and input variables are established by interpreting the coupling relations.
% This linking information is written back to atomic simulation objects with the z2-message.
% 
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

function [root_model,tout,yout,teout,yeout,ieout]=r_c_hybrid(root_model,tstart,tend,plot_params)

global HYBRID
if isempty(HYBRID)
    HYBRID = true;
end
% HYBRID = 1 --> hybrid simulation  
% HYBRID = 0 --> discrete-only simulation
% set in initialization script of model

global SIMUSTOP
if isempty(SIMUSTOP)
    SIMUSTOP = false;
end
% to stop simulation by condition
% SIMUSTOP = 0 --> simulate
% SIMUSTOP = 1 --> stop simulation
% set to 0 in initialization script of model
% can be manipulated in any part of the model


global ODEPLOT
% to allow plotting of continuous variables during simulation
% ODEPLOT = 0 --> no plotting
% ODEPLOT = 1 --> plotting; if plotting, plot_params need to be passed as
% optional parameter
% set in initialization script of model


if nargin < 3
    error('To few input arguments.')
elseif nargin > 3 
    % *********************************************************************
    % BEGIN ODEPLOT initialization
    %
    if HYBRID
       if ODEPLOT % set ODE-Plot parameters
        figure('Name', plot_params.name_strg,'Toolbar', 'figure');
        set(gca,'xlim',plot_params.xlim_interv,'ylim',plot_params.ylim_interv);
        box on
        grid on
        xlabel(plot_params.xlabel_strg);
        ylabel(plot_params.ylabel_strg);
        title(plot_params.title_strg);
        hold on;
       end
    end
    % END ODEPLOT initialization
    % *********************************************************************
end

gt=tstart; % set current simulation time to tstart
state = 0; % state = 0: start, state = 1: discrete state, state = 2: continuous state

if HYBRID
    gstatvec = []; % vector of continuous states
    gstat_length = []; % array of numbers of continuous variables per hybrid subcomponent
    gstat_offset = []; % array of offsets of continuous variables in gstatvec
    
    gev_length = []; % array of numbers of events per hybrid subcomponent
    gev_offset = []; % array of offsets of events


% variables for return
        tout  = []; % vector of time
        yout  = []; % matrix of values (corresponds to times)
        teout = []; % vector of event times
        yeout = []; % matrix of values at event times
        ieout = {}; % event indices
% end display variables
end

% **********************************************************
% *                    SIMULATION START                    *
% **********************************************************  
% DEBUG modes
% debug_flag = 0 --> no debugging
% debug_flag = 1 --> show messages and function calls
% debug_flag = 2 --> show messages and function calls, steps
% debug_flag = 3 --> show x,y and s of atomics
% set in initialization script of model for entire model or parts of the
% model

[debug_flag, descriptor] = is_debug(root_model,0,0);
if debug_flag == 1 || debug_flag == 2 
    debug_m = db_m(descriptor); % create an object to display debug messages
else
    debug_m = db_empty; % nothing will bes displayed
end

while (gt <= tend) && (~SIMUSTOP) 
    
    switch state
        
      case 0   % start state
        debug_m.dbprintroot(tstart,4,root_model); % print a "Start of initialization phase" message, if debug is activated
        debug_m.dbprintroot(tstart,1,root_model); % print a STARTUP message, if debug is activated
        % send initialization message to all children
        i_msg(root_model,tstart);
        if debug_flag == 2
            pause;
        end
        debug_m.dbprintroot(tstart,5,root_model); % print a "End of initialization phase" message, if debug is activated
        
        pause;
        if root_model.tnext == gt
          state = 1; % start a discrete phase
        elseif root_model.tnext > gt
           if HYBRID 
               state = 2; % start a continuous phase
           else
               state = 1; % for discrete only models remain in discrete phase
               gt = root_model.tnext; % and set gt to tnext
           end
        else
          error ('sync error in state 0');
        end
        
      case 1   % 'discrete state
        if HYBRID  
           debug_m.dbprintroot(tstart,6,root_model); % print a "Start of discrete simulation phase" message, if debug is activated
        end
        
        debug_m.dbprintroot(gt,2,root_model);  % print a STEP message, if debug is activated
        s_msg(root_model,gt,1);% flag = 1 for s-messages from root coordinator
        % root_obj = i_msg (root_obj, t); % wegen moegl. Strukturwechsel !!!
        if HYBRID
            debug_m.dbprintroot(tstart,7,root_model); % print a "End of discrete simulation phase" message, if debug is activated
        end
        if debug_flag == 2
            pause;
        end
        
        %if root_model.tnext == gt
        if abs(root_model.tnext - gt) <= root_model.epsi
          state = 1;
        elseif root_model.tnext > gt
            if HYBRID
               state = 2;
            else
                gt=root_model.tnext; %set new time for next event
                state = 1;
            end
        else
          error ('sync error in state 1');
        end
        
      case 2   % 'continuous' state 
        debug_m.dbprintroot(tstart,8,root_model); % print a "Start of continuous simulation phase" message, if debug is activated
        % resolve 'continous' couplings
        % -----------------------------
        debug_m.dbprintroot(tstart,10,root_model); % print a "CONTINUOUS" message, if debug is activated                 
        [root_model,aSimObj,gstatvec]=z_msg(root_model,gt,0,0);% configure vectors, state offsets (soff) and event offsets (eoff) are 0, because z_message from root_coordinator
        debug_m.dbprintroot(tstart,11,root_model); % print a z-smg message, if debug is activated
        [root_model] = z2_msg(root_model,gt,[]); %configure vectors, 2nd step: set the input offsets (ioffs), ioffs is [], because z_message from root_coordinator
        asubs={};%initialize cellarray for handles of hybrid subcomponents
        gstat_length=[];%initialize array for number of state variables per hybrid subcomponent
        gev_length=[];  %initialize array for number of events per hybrid subcomponent
        for i=1:length(aSimObj) % for all hybrid atomic subcomponents
               gstat_length = [gstat_length, length(aSimObj{i}.c_states)];
               gev_length = [gev_length, aSimObj{i}.num_c_state_events];%save number of events per subcomponent in a vector
               if i==1
                    gstat_offset = 0; %first entry has no offset in vector
                    gev_offset=0; %first entry has no offset in vector
               else
                    gstat_offset = [gstat_offset, gstat_offset(i-1)+ length(aSimObj{i}.c_states)];
                    gev_offset=[gev_offset, gev_offset(i-1)+ gev_length(i-1)];
               end 
               asubs={asubs{1:end}, aSimObj{i}};                
        end
        
            %disp('gstatvec:'); 
            %disp(gstatvec);
            %disp('gstat_offset:');
            %disp(gstat_offset);
            %disp('gstat_length:');
            %disp(gstat_length);
            %disp('gev_length:');
            %disp(gev_length);
            %disp('gev_offset:');
            %disp(gev_offset);
       
       

       
        %for i=1:length(asubs)
            %disp(asubs{i}.name); % disp all hybrid subcomponents
        %end
       
       
        % sort the equations
        % -----------------
        % initialize arrays for subcomponents of Moore type
        moore_asubs = {};  % nicht sprungfaehig
        
        moore_soff_len = []; % array of state offsets and lengths
        moore_eoff_len = []; % array of state event offsets and lengths
        
        % initialize arrays for subcomponents of Mealy type
        mealy_asubs = {};  % sprungfaehig
        
        mealy_soff_len = [];
        mealy_eoff_len = [];
        for idx = 1:length(asubs)
          len = length(asubs{idx}.c_states);
          elen = asubs{idx}.num_c_state_events;
          if asubs{idx}.mealy
             mealy_asubs = [mealy_asubs, {asubs{idx}}];
             mealy_soff_len = [mealy_soff_len, [asubs{idx}.state_offset; len]];
             mealy_eoff_len = [mealy_eoff_len, [asubs{idx}.event_offset; elen]];
          else
             moore_asubs = [moore_asubs, {asubs{idx}}];
             moore_soff_len = [moore_soff_len, [asubs{idx}.state_offset; len]];
             moore_eoff_len = [moore_eoff_len, [asubs{idx}.event_offset; elen]];
          end
        end
        
        if ODEPLOT % with plotting during simulation
         options = odeset ('Events', @(gt,y) ode_wrapper(gt,y,0,...
                              moore_asubs, moore_soff_len, moore_eoff_len, ...
				              mealy_asubs, mealy_soff_len, mealy_eoff_len),...
                              'OutputFcn', @myodeplot,'OutputSel',plot_params.OutputSel_vec,'Refine',10,...% define here, if, how and which state variables should be plotted
                              'RelTol',1e-3,'AbsTol',1e-12);         
               
        else % without plotting
         options = odeset ('Events', @(gt,y) ode_wrapper(gt,y,0,...
                            moore_asubs, moore_soff_len, moore_eoff_len, ...
				            mealy_asubs, mealy_soff_len, mealy_eoff_len),...
                            'RelTol',1e-3,'AbsTol',1e-12);
        end

                      
        % run continous simulation step
        % -----------------------------
        %        
        debug_m.dbprintroot(tstart,12,root_model); % print a "times for next continuous cycle" message, if debug is activated  

        %if DEBUG
%          disp('initial conditions are:');  
%          disp(gstatvec);
%          disp('offsets in gstatvec are:');
%          disp(gstat_offset);
%          disp('length of gstats are:');
%          disp(gstat_length);
%          laenge_of_gstatvec = size(gstatvec);
        %end
        
         [t, y, te, ye, ie] = ode45(@(gt,y) ode_wrapper(gt,y,1,...
                              moore_asubs, moore_soff_len, moore_eoff_len, ...
				              mealy_asubs, mealy_soff_len, mealy_eoff_len),...
                              [gt, min(root_model.tnext, tend)],gstatvec, options);         % integrate from gt to next discrete step or end of simulation
         
            nt = length(t);           
            gt = t(nt); % set starting time for next cycle to last value in t
            
            %disp('ode45 stopped');
           
            tout = [tout; t]; % collect integration time steps
            yout  =[yout; y]; % collect values of all state variables
           
            teout = [teout; te]; % collect event times
            yeout = [yeout; ye]; % collect values at event times
            ieout = [ieout, ie]; % collect event indices
            
            %if DEBUG
                %str = fprintf('te: %.15f \n', te); % display event time
                %disp('event_idx ie = ');
                %disp(ie); % display event index
                %disp(['starting time for next cycle will be: ',num2str(gt)])
            %end
            
            % if this was the last cycle
            if gt == tend
                break;
            end
            
            %str = fprintf('starts at %.15f \n', gt);
            if isempty (ie)   % if no events occured
                t = t (end, :);
                y = y (end, :)';% put back continuous state values --> neue Anfangswerte
                % (if ie is empty, the se_msg does not call the transition function.)
                debug_m.dbprintroot(gt,13,root_model);  % print a send se-msg without events debug message, if debug is activated
                root_model = se_msg(root_model, t, y, ie);% se_msg just to put back t and y for next continuous cycle
                state = 1; % start a discrete phase next
                
                
            else %if ~isempty(ie)
                if t(end) == te(1)
                    % ODE-solver detects events at the beginning of a
                    % continuous cyle, but does NOT terminate the
                    % simulation.
                    % So, ie may not be empty, though current time is NOT te but already t(end).
                    % Events that occur simultanously with discrete events
                    % are NOT treated!!
                    % WHAT IF events after "starttime"-events?????
                debug_m.dbprintroot(gt,15,root_model); % print a "events occured" message, if debug is activated 
                debug_m.dbprintroot(gt,14,root_model);  % print a send se-msg with events debug message, if debug is activated
                root_model=se_msg(root_model,te,ye,ie); % se_msg to put back te an ye and to call deltastatefuns of affected atomics
                % remain in continuous phase
               end
            end % end no events occured
            tstart = gt;
            
            debug_m.dbprintroot(tstart,9,root_model); % print a "End of continuous simulation phase" message, if debug is activated
               
        
          if root_model.tnext == gt
           state = 1;
          elseif root_model.tnext  > gt
            state = 2;                
          else
	    error (['sync error 2, gt = ', num2str(gt),' ,root_model.tnext = ', num2str(root_model.tnext)]);
          end
     end
        %if ~isempty(ie) & length (ie) ~= 1
          %error ('terminal event must be used, see Using Matlab page 8-32');
        %end
end

% **********************************************************
% *                    SIMULATION END                    *
% **********************************************************


% *************************************************************************
% BEGIN ODEPLOT legend
%

if HYBRID
    if ODEPLOT
        legend_strg(1)={plot_params.legend1};
        for k =2:plot_params.num_legend
            legendfield=['legend',num2str(k)];
            legend_strg=[legend_strg,plot_params.(char(legendfield))];
        end
        legend(legend_strg);
        hold off
    end % end if ODEPLOT

end %end if HYBRID
% END ODEPLOT legend
% *************************************************************************

end
% END hybrid root coordinator


