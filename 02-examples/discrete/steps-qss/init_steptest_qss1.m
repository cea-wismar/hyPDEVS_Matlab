%% Initialization Script: Step Test
% 
% Inits a QSS1 model consisting of a step source and a qss1 integrator.

%%
% Basic models are taken from
% folder |DEVSPATH/01-modelbase/qss|.
%
% Call: |init_steptest_qss1|
% 
% File: |DEVSPATH/02-examples/discrete/steps-qss/init_steptest_qss1.m|
%
%
% <<img/step_qss_example.png>>
%
% *Model Structure*
%
%% Preparation
%clear classes;
clc;

global SIMUSTOP % to stop simulation by condition
SIMUSTOP = 0;

global HYBRID
HYBRID = 0; % discrete-only simulation

elapsed = 0;

%% Create the Model
%
% Atomic models' classes:
% <../../models/discrete/step_qss1.html step_qss1>,
% <../../models/discrete/qss1.html qss1>.
%

% Coupled DEVS root_model
%
% Instantiate an atomic DEVS of type step_qss
% that implements step source.

% system parameters
T = [0, 2, inf];% times for step
v =[1,3]; % values for step, 1 before step, 3 after step

inistates = struct('sigma',0,'j',1);% states
step = step_qss1('step',inistates,elapsed,T,v);
    
% Instantiate an atomic DEVS of type qss1.
% The qss1 integrator
% integrates the step to a ramp.
% 
% initial value for integrator
epsilon = 0.01;
dq = 0.1;% system parameters
startvalue = 1;
inistates = struct('sigma',0,'X',startvalue,'dX',0,'q',floor(startvalue/dq)*dq,'se',0,'traj',[],'qtraj',[]);
integrator1 = qss1('integrator1',inistates,elapsed,epsilon,dq);
   
%%    
% Instantiate the root_model
root_model = coupled('root_model');% in and output ports, always none for root model
addcomponents(root_model,{step,integrator1});
Zid_model = {'step','p1','integrator1','in1'};
set_Zid(root_model, Zid_model);

set_observe(root_model, 1);% track all state variables in s of atomics
        
%% Take a look at the model

showall(root_model);
Check(root_model);

%% Finally
% Done!
% Now the root_coordinator can be called to simulate the model:
%
% |root_model =  r_c_discrete(root_model,tstart,tend)|
%
% After simulation you can plot the results via
% |plot_step_qss1(root_model,tstart,tend)|.
%
%
% *Commands to initialize, simulate, analyze the example:*
% 
% >> |init_steptest_qss1;|
%
% >> |root_model = r_c_discrete(root_model,0,8);|
%
% >> |plot_step_qss1(root_model,0,8);|
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

    