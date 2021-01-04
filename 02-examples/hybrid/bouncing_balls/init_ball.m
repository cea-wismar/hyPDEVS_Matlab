%% Initialize Bouncing Ball
% initialization script for the simple hybrid model "Bouncing Ball"

%% Preparation
clear classes;
clc;
global DEBUG    % 0 if no messages, 1 if some
DEBUG = 0;

global EPSI     % accuracy for comparisons
EPSI = 0.00000001;

global SIMUSTOP % to stop simulation by condition
SIMUSTOP = 0;

global HYBRID
HYBRID = 1; % hybrid simulation

elapsed = 0;

%% Create the modelbase
% Variable to store patterns of models is MODELBASE.
% Atomic models' patterns necessarily have to start with type of atomic model (classname)
% and the model's name.
% Following parameters depend on type of atomic models and must
% match the according constructor method. Coupled models' patterns
% necessarily have to start with keyword 'coupled' followed by the model's
% name,x,y,Da,Dc,Zid
% and furthermore c_x,c_y,CZid,c_states if this is a hybrid model
global MODELBASE
% fields in MODELBASE must correspond to component names

heigth = 0;
velocity = 20;

a_type = 'am_bball';
a_name = 'the_ball_1';
x_d = [];
y_d = struct('p1',[]);
s_d = struct('sigma',inf);
attenuation = 0.95;
    MODELBASE.the_ball_1 = {a_type,a_name,x_d,y_d,s_d,elapsed,attenuation};
    
a_type = 'am_bball';
a_name = 'the_ball_2';
x_d = [];
y_d = struct('p1',[]);
s_d = struct('sigma',inf);
attenuation = 0.8; 
    MODELBASE.the_ball_2 = {a_type,a_name,x_d,y_d,s_d,elapsed,attenuation};
    
%%        
% Create pattern for root_model

Dc_model = [];
Da_model = {'the_ball_1','the_ball_2'};
Zid_model = [];

c_states = [];%nothing continuous
c_x = [];
c_y = [];
CZid_model = {};

%%        
% The root_model is stored in MODELBASE for documentation purposes only    
       MODELBASE.root_model ={'coupled','root_model',[],[],...
           c_states,c_x,c_y,...
           Da_model,Dc_model,Zid_model,CZid_model};%not necessary
%%
% Display the modelbase
disp(MODELBASE);
        
%% Incarnate the entire model
% Constructor method of coupled reads recursively the patterns from
% MODELBASE and incarnates the subcomponents based on this information
% constructor of coupled models: function obj = coupled(name,x,y,Da,Dc,Zid)

root_model = coupled('root_model',[],[],...
    c_states,c_x,c_y,...
    Da_model,Dc_model,Zid_model,CZid_model);
        

%% Finally
%  Done!
%  Now the root_coordinator can be called to simulate the model:
%  root_model = r_c(root_model,tstart,tend)
