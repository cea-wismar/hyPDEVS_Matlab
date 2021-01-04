%% MatlabDEVS Tbx Modelbase
% Folder: |DEVSPATH/01-modelbase|
%
%% Discrete Atomic Models
%
% All discrete atomic models are derived from class |atomic| which
% implements the associated discrete atomic simulator.
%
% * <models/discrete/am_ball_starter.html am_ball_starter>
% * <models/discrete/am_dock_undock_server.html am_dock_undock_server>
% * <models/discrete/am_double_input.html am_double_input>
% * <models/discrete/am_fifo_queue.html am_fifo_queue>
% * <models/discrete/am_g_2types.html am_g_2types>
% * <models/discrete/am_generator.html am_generator>
% * <models/discrete/am_hit_counter.html am_hit_counter>
% * <models/discrete/am_proc_block.html am_proc_block>
% * <models/discrete/am_t.html am_t>
% * <models/discrete/am_transducer.html am_transducer>
% * <models/discrete/am_truck_generator.html am_truck_generator>
% * <models/discrete/am_truck_transducer.html am_truck_transducer>
% * <models/discrete/event_detect.html event_detect>
% * <models/discrete/qss1.html qss1>
% * <models/discrete/sine_qss1.html sine_qss1>
% * <models/discrete/static1.html static1>
% * <models/discrete/step_qss1.html step_qss1>
% * <models/discrete/timed_sine_qss1.html timed_sine_qss1>
%
% Template to design own atomic models is <models/am_discrete_template.html am_discrete_template>.
%
%
%% Hybrid Atomic Models
%
% All hybrid atomic models are derived from class |hybrid_atomic| which
% implements the associated hybrid atomic simulator.
%
% * <models/hybrid/am_bball.html am_bbball>
% * <models/hybrid/am_canner.html am_canner>
% * <models/hybrid/am_truck.html am_truck>
% * <models/hybrid/am_tank.html am_tank>
%
% Template to design own atomic models is <models/am_hybrid_template.html am_hybrid_template>.
%
%
%% Discrete Coupled Models
%
% All discrete coupled models are derived from class |coupled| which implements
% the associated discrete coupled coordinator.
% 
% * <models/discrete/cm_c13.html cm_c13>
% * <models/discrete/cm_c2.html cm_c2>
% * <models/discrete/cm_g.html cm_g>
%
% Note: 
% _Instead of deriving new classes from coupled, it is also possible to create models directly by invoking instances of class |coupled|
% and defining ports, components and couplings within initialization scripts._
%
%% Hybrid Coupled Models
%
% All hybrid coupled models are derived from class |hybrid_coupled| which
% implements both, the associated hybrid coupled coordinator and model. Ports,
% components,
% discrete and continuous couplings are defined in initialization scripts. 
%
%
% <html>
% <br><br>
% <hr>
% <br>
% <a href="PDEVS_home.html">DEVS Tbx Home</a>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
% <a href="PDEVS_examples.html">Examples</a>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
% <a href="javascript:history.back()"><< Back</a>
% </html>
%
%