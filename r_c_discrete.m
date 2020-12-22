%% PDEVS Root Coordinator for Pure Discrete Models
%  stored in DEVS_PATH/r_c_discrete.p
%
% Is provided as p-code.


%% Description
% Discrete DEVS root coordinator for parallel DEVS with ports.
%
% *Call:* |model = r_c_discrete(model,tstart,tend)|
%
% *Input arguments:*
%
% |model| : type is coupled object
%
% |tstart| : type is double, start time for simulation
%
% |tend| : type is double, end time for simulation
%
% *Variables used in simulator:*
%
% |gt| : type is double, current simulation time
%

% BEGIN pure discrete root coordinator
function root_model=r_c_discrete(root_model,tstart,tend)

%% Preparation
%
global HYBRID
if isempty(HYBRID)
    HYBRID = false;
end
% HYBRID = 1 --> hybrid simulation  
% HYBRID = 0 --> discrete-only simulation
% set in initialization script of model
if HYBRID
    error('You called the root coordinator for pure discrete DEVS to simulate a hybrid model');
end

global SIMUSTOP
if isempty(SIMUSTOP)
    SIMUSTOP = false;
end
% to stop simulation by condition
% SIMUSTOP = 0 --> simulate
% SIMUSTOP = 1 --> stop simulation
% set to 0 in initialization script of model
% can be manipulated in any part of the model

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
    debug_m = db_empty; % nothing will be displayed
end


%% Initialize the Model
%
% Send initialization message to all children
debug_m.dbprintroot(tstart,1,root_model); % print a STARTUP message, if debug is activated         
i_msg(root_model,tstart);

if debug_flag == 2
        pause;
end
gt = root_model.tnext;

%% Simulation Loop
%
% Send recursive *-messages
while (gt <= tend) && (~SIMUSTOP)
   
    debug_m.dbprintroot(gt,2,root_model);  % print a STEP message, if debug is activated 
            
    s_msg(root_model,gt,1);% flag = 1 for s-messages from root coordinator

    if debug_flag == 2
        pause;
    end
    
    gt = root_model.tnext;
    if gt == inf
        break
    end

end
            
debug_m.dbprintroot(gt,3,root_model); % print an END message, if debug is activated           
end
% END pure discrete root coordinator

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