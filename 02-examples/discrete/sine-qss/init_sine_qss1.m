%% Initialization Script: Quantized Sine
% Inits a QSS1 model consisting of a (quantized) sine source and a qss1 integrator.

%%
% Basic models are taken from
% folder |DEVSPATH/01-modelbase/qss|.
%
% Call: |init_sine_qss1|
%
% File: |DEVSPATH/02-examples/discrete/sine-qss/init_sine_qss1.m|
%
%
% <<img/quantized_sine_example.png>>
%
% *Model Structure*
%
%% Preparation
%clear classes;
clc;

global SIMUSTOP % to stop simulation by condition
SIMUSTOP = 0;

global HYBRID
HYBRID = 0; %discrete-only simulation

elapsed = 0;

%% Create the Model
%
% Atomic models' classes:
% <../../models/discrete/sine_qss1.html sine_qss1>,
% <../../models/discrete/qss1.html qss1>.
%

% Coupled DEVS root_model
%
% Instantiate an atomic DEVS of type sine_qss1 that acts as generator for a
% quantized sine wave.
frequency = 0.5; % = 1/T
A = 3;
omega = 2*pi*frequency;
phi = 0; 
delta_u = 1;% system parameters, delta_u is quantization of sine
inistates = struct('sigma',0,'tau',phi/omega,'traj',[],'qtraj',[]);% initial values for states
sine = sine_qss1('sine',inistates,elapsed,A,omega,phi,delta_u);

% Instantiate an atomic DEVS of type qss1.
% The qss1 integrator
% integrates the sine to a (negative) cosine function.
% 
epsilon = 0.01;
dq = 0.1;% system parameters
startvalue = -A/(omega)*cos(omega*elapsed+phi);
inistates2 = struct('sigma',0,'X',startvalue,'dX',A*sin(omega*inistates.tau+phi),'q',floor(startvalue/dq)*dq,'se',0,'traj',[],'qtraj',[]);
integrator1 = qss1('integrator1',inistates2,elapsed,epsilon,dq);
   
    
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
% |plot_sine_qss1(root_model,tstart,tend)|.
%
%
% *Commands to initialize, simulate, analyze the example:*
% 
% >> |init_sine_qss1;|
%
% >> |root_model = r_c_discrete(root_model,0,20);|
%
% >> |plot_sine_qss1(root_model,0,20);|
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
    