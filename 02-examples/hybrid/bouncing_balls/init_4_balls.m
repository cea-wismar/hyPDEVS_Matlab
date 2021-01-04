%% Initialize Bouncing Ball
% initialization script for the simple hybrid model "Bouncing Ball"
%%
% basic models are found in folder DEVSPATH/Vers00-hybrid/01-atomic-modelbase/bouncing_ball

%% Preparation
close all;
clear all;
clear classes;

%clc;
global SIMUSTOP % to stop simulation by condition
SIMUSTOP = 0;

global HYBRID
HYBRID = 1; % it's a hybrid model

elapsed = 0;

%% Create the modelbase
% Variable to store patterns of models is MODELBASE.
% Atomic models' patterns necessarily have to start with type of atomic model and the
% model name. Following parameters depend on type of atomic models and must
% match the according constructor method. Coupled models' patterns
% necessarily have to start with keyword 'coupled' followed by the model's
% name,x,y,Da,Dc,Zid
% and furthermore c_x,c_y,CZid,c_states if this is a hybrid model
%global MODELBASE
% fields in MODELBASE must correspond to component names

heigth = 0;
velocity = 20;

%a_type = 'am_bball';
%a_name = 'the_ball_1';
%x_d = [];
%y_d = struct('p1',[]);
c_states = [heigth; velocity];
%c_x = [];
%c_y = struct('c_p1',[]);
s_d = struct('sigma',4,'active',1,'bounce_start',[],'bounce_end',[]);
attenuation = 0.95;
%    MODELBASE.the_ball_1 = {a_type,a_name,x_d,y_d,c_states,c_x,c_y,s_d,elapsed,attenuation};
the_ball_1 = am_bball('the_ball_1',s_d,c_states,elapsed,attenuation);

    
% a_type = 'am_bball';
% a_name = 'the_ball_2';
% x_d = struct('p1',[]);
% y_d = struct('p1',[]);
c_states = [heigth; velocity];
% c_x = [];
% c_y = struct('c_p1',[]);
s_d = struct('sigma',inf,'active',1,'bounce_start',[],'bounce_end',[]);
attenuation = 0.90; 
%    MODELBASE.the_ball_2 = {a_type,a_name,x_d,y_d,c_states,c_x,c_y,s_d,elapsed,attenuation};
the_ball_2 = am_bball('the_ball_2',s_d,c_states,elapsed,attenuation);
    
% a_type = 'am_bball';
% a_name = 'the_ball_3';
% x_d = struct('p1',[]);
% y_d = struct('p1',[]);
c_states = [heigth; velocity];
% c_x = [];
% c_y = struct('c_p1',[]);
s_d = struct('sigma',inf,'active',0,'bounce_start',[],'bounce_end',[]);
attenuation = 0.8; 
%    MODELBASE.the_ball_3 = {a_type,a_name,x_d,y_d,c_states,c_x,c_y,s_d,elapsed,attenuation}; 
the_ball_3 = am_bball('the_ball_3',s_d,c_states,elapsed,attenuation);
    
% coupled subcomponent    
    
% 4th ball just as dummy in a coupled submodel
% a_type = 'am_bball';
% a_name = 'the_ball_4';
% x_d = struct('p1',[]);
% y_d = struct('p1',[]);
c_states = [heigth; velocity];
% c_x = [];
% c_y = struct('c_p1',[]);
s_d = struct('sigma',inf,'active',1,'bounce_start',[],'bounce_end',[]);
attenuation = 0.99; 
%    MODELBASE.the_ball_4 = {a_type,a_name,x_d,y_d,c_states,c_x,c_y,s_d,elapsed,attenuation};
the_ball_4 = am_bball('the_ball_4',s_d,c_states,elapsed,attenuation);


%%        
% Create pattern for root_model
y_root = {};
x_root = {};
root_model = hybridcoupled('root_model',x_root,y_root);
addcomponents(root_model,{the_ball_1,the_ball_2,the_ball_3,the_ball_4});
Zid_model = {'the_ball_1','p1','the_ball_2','p1';...
             'the_ball_2','p1','the_ball_3','p1';...
             'the_ball_3','p1','the_ball_4','p1'};
set_Zid(root_model, Zid_model);
CZid_model = {};
%set_CZid(root_model, CZid_model); 
showall(root_model);
Check(root_model);
%%        
% The root_model is stored in MODELBASE for documentation purposes only    
%       MODELBASE.root_model ={'coupled','root_model',[],[],[],[],[],Da_model,Dc_model,Zid_model,CZid_model};%not necessary
%%
% Display the modelbase
%disp(MODELBASE);
        
%% Incarnate the entire model
% Constructor method of coupled reads recursively the patterns from
% MODELBASE and incarnates the subcomponents based on this information
% constructor of coupled models: function obj = coupled(name,x,y,Da,Dc,Zid)

%root_model = coupled('root_model',[],[],[],[],[],Da_model,Dc_model,Zid_model,CZid_model);
        

%% Finally
%  Done!
%  Now the root_coordinator can be called to simulate the model:
%  root_model = r_c(root_model,0,30)
%  und auch da frisst es sich fest ;-)