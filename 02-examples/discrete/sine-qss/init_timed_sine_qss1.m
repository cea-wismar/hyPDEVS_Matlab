%% Initialization Script: Timed Sine
% Inits a QSS1 model consisting of a (fixed step) sine source and a qss1 integrator.
% Sine source emits a sine value every pi/100 units of time.

%%
% Basic models are taken from
% folder |DEVSPATH/01-modelbase/qss1|.
%
% Call: |init_timed_sine_qss1|
%
% File: |DEVSPATH/02-examples/discrete/sine-qss/init_timed_sine_qss1.m|
%
%
% <<img/timed_sine_example.png>>
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
% <../../models/discrete/timed_sine_qss1.html timed_sine_qss1>,
% <../../models/discrete/qss1.html qss1>.
%

% Coupled DEVS root_model
%
% Instantiate an atomic DEVS of type timed_sine_qss1 that acts as generator for a
% (fixed step) discretized sine wave.
% A timed-sine outputs a sine value every sigma interval (fixed steps).
inistates = struct('sigma',pi/100,'sine',sin(0));% initial values for states
sine = timed_sine_qss1('sine',inistates,elapsed);
    
% Instantiate an atomic DEVS of type qss1.
% The qss1 integrator
% integrates the sine to a (negative) cosine function.
% 
epsilon = 0.1;
dq = 0.1; % system parameters
sine_start = -1;
inistates = struct('sigma',0,'X',sine_start,'dX',sin(0),'q',floor(sine_start/dq)*dq,'se',0,'traj',[],'qtraj',[]);
integrator1 =  qss1('integrator1',inistates,elapsed,epsilon,dq);

        
%%    
% Instantiate the root_model
root_model = coupled('root_model');% in and output ports are always none for root model
addcomponents(root_model,{sine,integrator1});
Zid_model = {'sine','p1','integrator1','in1'};
set_Zid(root_model, Zid_model);

%% Take a look at the model

showall(root_model);
Check(root_model);

set_observe(root_model, 1);% track all state variables in s of atomics
        

%% Finally
% Done!
% Now the root_coordinator can be called to simulate the model:
%
% |root_model =  r_c_discrete(root_model,tstart,tend)|
%
% After simulation you can plot the results via
% |plot_timed_sine_qss1(root_model,tstart,tend)|.
%
%
% *Commands to initialize, simulate, analyze the example:*
% 
% >> |init_timed_sine_qss1;|
%
% >> |root_model = r_c_discrete(root_model,0,60);|
%
% >> |plot_timed_sine_qss1(root_model,0,60);|
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

    