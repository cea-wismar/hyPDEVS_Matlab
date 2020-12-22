% Welcome to Matlab DEVS toolbox
% Vers. 2.0
% August 2016
% 
% **************************************************************
% * Files and directory structure of hybrid PDEVS for Matlab   *
% * Christina Deatcu 2016                                      *
% * Contact: christina.deatcu@hs-wismar.de                     *
% **************************************************************
% 
% INSTALLATION
%
% Copy the directory MatlabDEVSTbx to a place of your choice and add to Matlab-Path (including all subdirectories) --> done!
% Open 'Supplemental Software' Tab in Matlab's help browser and browse help files to get started. 
%
% Alternatively install as Matlab's App:
% goto Tab APPS --> install Apps --> choose MatlabDEVS.mlappinstall -->
% done ;-)

% 
%
% FILES
%
% * my_odeplot.p --> adopted plot function for continuous variables (used as 'Outputfcn' via odeset)
% * ode_wrapper.p --> acts as model function and event function for ODE-solver
% * r_c_discrete.p --> root coordinator solely for simulation of pure discrete models
% * r_c_hybrid.p --> root coordinator for simulation of hybrid as well as pure discrete models (experimental status!)
%  
% 
% DIRECTORIES
% 
% 00-simulator
% ********************
% - contains class definitions for the base class 'devs', atomic PDEVS simulator 'atomic' and coupled PDEVS coordinator and models 'coupled'
% - class definitions for hybrid atomic PDEVS simulator 'hybridatomic' and hybrid coupled PDEVS coordinator and models 'hybridcoupled'
% - all files provided as p-code
% 
% 01-modelbase
% ********************
% - contains class definitions for user defined atomic and coupled models; sortet by application examples, where those models are used
% - modeler should store own model definitions (derived from class 'atomic', 'hybridatomic', 'coupled' or 'hybridcoupled') to this folder
% - templates for user defined atomic models 'am_discrete_template.m' and 'am_hybrid_template.m' are provided
% - templates for user defined coupled models 'cm_discrete_template.m' and 'cm_hybrid_template.m' are provided
% 
% 
% 02-examples
% ********************
% - some example models, sorted by application examples
% - minimum per example: each with a script for model's definition and initialization
% - some examples come with scripts for plotting and/or analyzing simulation results
% 
% 03-rand
% ********************
% -  a set of random number generators for use with models (interarrival times etc.)
% 
% doc
% ********************
% HTML documentation. Start with ./doc/html/PDEVS_home.html.
