%% Initialize distributed bouncing ball
% inits a bouncing ball distributet to 2 atomic devs
% call: init_dist_ball

%% Preparation
clear classes;
%clc;
global DEBUG    % 0 if no messages, 1 if some
DEBUG = 1;

global EPSI     % accuracy for comparisons
EPSI = 0.00000001;

global HYBRID
HYBRID = 1; %hybrid simulation

elapsed = 0;

%% Create the modelbase
% Variable to store patterns of models is MODELBASE.
% Atomic models' patterns necessarily have to start with type of atomic model and the
% model name. Following parameters depend on type of atomic models and must
% match the according constructor method. Coupled models' patterns
% necessarily have to start with keyword 'coupled' followed by the model's
% name,x,y,c_states,c_x,c_y,s,Da,Dc and Zid
global MODELBASE

heigth = 0;
heigth1 = 0 ;
velocity = 20;
velocity1 = 15;
% **********ball 1 **********%
a_type = 'am_bb1';
a_name = 'bb_1';
x_d = [];
y_d = struct('yd_p1',[]);
c_states = [heigth];
c_x = struct('xc_p1',[]);
c_y = [] ;
s_d = struct('sigma',inf,'active',1);
    MODELBASE.bb_1 = {a_type,a_name,x_d,y_d,c_states,c_x,c_y,s_d,elapsed};
    
a_type = 'am_bb2';
a_name = 'bb_2';
x_d = struct('xd_p1',[]);
y_d = [];
c_states = [velocity];
c_x = [];
c_y = struct('yc_p1',[]);
s_d = struct('sigma',inf,'active',1);
attenuation = 0.95;
    MODELBASE.bb_2 = {a_type,a_name,x_d,y_d,c_states,c_x,c_y,s_d,elapsed,attenuation}; 
% **********ball 2 **********%
    
a_type = 'am_bb1';
a_name = 'bb_3';
x_d = [];
y_d = struct('yd_p1',[]);
c_states = [heigth1];
c_x = struct('xc_p1',[]);
c_y = [] ;
s_d = struct('sigma',inf,'active',1);
    MODELBASE.bb_3 = {a_type,a_name,x_d,y_d,c_states,c_x,c_y,s_d,elapsed};

a_type = 'am_bb2';
a_name = 'bb_4';
x_d = struct('xd_p1',[]);
y_d = [];
c_states = [velocity1];
c_x = [];
c_y = struct('yc_p1',[]);
s_d = struct('sigma',inf,'active',1);
attenuation = 0.90;
    MODELBASE.bb_4 = {a_type,a_name,x_d,y_d,c_states,c_x,c_y,s_d,elapsed,attenuation};
    

    

    
%%        
% Create pattern for root_model

Dc_model = {};
Da_model = {'bb_1','bb_2','bb_3','bb_4'};
Zid_model = {'bb_1','yd_p1','bb_2','xd_p1';...
             'bb_3','yd_p1','bb_4','xd_p1'};% discrete couplings
CZid_model = {'bb_2',1,'bb_1',1;...
              'bb_4',1,'bb_3',1};% continuous couplings --> bb_2 outputs the velocity, which is needed by bb_1 as derivation
%%        
% The root_model is stored in MODELBASE for documentation purposes only    
       MODELBASE.root_model ={'coupled','root_model',[],[],[],[],[],Da_model,Dc_model,Zid_model,CZid_model};%not necessary
%%
% Display the modelbase
disp(MODELBASE);
        
%% Incarnate the entire model
% Constructor method of coupled reads recursively the patterns from
% MODELBASE and incarnates the subcomponents based on this information
% constructor of coupled models: function obj = coupled(name,x,y,c_states,c_x,c_y,Da,Dc,Zid)

root_model = coupled('root_model',[],[],[],[],[],Da_model,Dc_model,Zid_model,CZid_model);
        

%% Finally
%  Done!
%  Now the root_coordinator can be called to simulate the model:
%  root_model = r_c_neu(root_model,tstart,tend)

    
