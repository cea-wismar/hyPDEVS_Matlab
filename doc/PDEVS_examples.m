%% MatlabDEVS Tbx Exampels
% All examples can be found in folder |DEVSPATH/02-examples|.
%
%% Overview
% *Discrete Examples*
%
% * Assembly Line
% * Testcase: two Outputs to one Input
% * Single Server
% * Bouncing Ball QSS
% * Sine QSS
% * Step QSS
%
% *Hybrid Examples*
%
% * Bouncing Ball
% * Orange Juice Canning
%
%% Discrete Examples
% All atomic models to compose pure discrete examples are derived from
% class |atomic| and coupled models are derived from |coupled| or are instances of this class. The root
% coordinator to simulate these models is the pure discrete root
% coordinator |root_model=r_c_discrete(root_model,tstart,tend)|.
%
% Explore the examples to learn how to model with DEVS Tbx.
%
% <html>
% <br><br>
% <table>
% <tr>
% <td><b>Example</b></td>
% <td><b>Description</b></td>
% <td><b>Associated Files</b></td>
% <td><b>Model Classes</b></td>
% </tr>
% <tr>
% <td>Assembly Line </td>
% <td>Complex model of an assembly line.<br>
% Seven generators with different intergeneration times send parts to
% processing blocks.<br>
% Processing blocks assemble two parts and send them to next processing blocks where more parts are added.
% <br>A transducer counts completed workpieces.<br>
% Folder: <tt>DEVSPATH/02-examples/discrete/assembly_line</tt></td>
% <td><ul><li><a href="examples/discrete/init_assembly_line.html">Initialization Script</a></li>
% <li><a href="examples/discrete/init_assembly_line_modelbase.html">Initialization Script with Predefined Coupled Models</a></li>
% <li><a href="examples/discrete/compare_to_handsimulation.html">Compare to Handsimulation</a></li></ul></td>
% <td><a href="models/discrete/am_generator.html">am_generator</a><br>
% <a href="models/discrete/am_proc_block.html">am_proc_block</a><br>
% <a href="models/discrete/am_transducer.html">am_transducer</a><br>
% <br>
% <a href="models/discrete/cm_c13.html">cm_c13</a><br>
% <a href="models/discrete/cm_c2.html">cm_c2</a><br>
% <a href="models/discrete/cm_g.html">cm_g</a></td>
% </tr>
% <tr>
% <td>Testcase 2 Outputs to one Input</td>
% <td>
% Two generators generate workpieces either of type1 or type2.<br>
% Processing block has one input and needs to decide of what type incoming WP is.
% Two workpieces can arrive at the same time at the same input port. A transducer counts completed workpieces.<br>
% Folder: <tt>DEVSPATH/02-examples/discrete/2-outputs-to-1-input</tt></td>
% <td><ul><li><a href="examples/discrete/init_2_out_1_in.html">Initialization Script</a></li>
% <li><a href="examples/discrete/plot_and_analyze2out1in.html">Analysis and Plotting</a></li></ul></td>
% <td><a href="models/discrete/am_g_2types.html">am_g_2types</a><br>
% <a href="models/discrete/am_double_input.html">am_double_input</a><br>
% <a href="models/discrete/am_t.html">am_t</a></td>
% </tr>
% <tr>
% <td>Single Server</td>
% <td>Simple model which uses atomic models from the <i>Assembly Line</i> example.<br>
% Two generators act as sources for parts which are then assembled by a processing block.<br>
% A transducer counts completed workpieces.<br>
% Folder: <tt>DEVSPATH/02-examples/discrete/single_server</tt></td>
% <td><ul><li><a href="examples/discrete/init_singleserver.html">Initialization Script</a></li>
% <li><a href="examples/discrete/analyse_singleserver.html">Analyse Some Results</a></li></ul></td>
% <td><a href="models/discrete/am_generator.html">am_generator</a><br>
% <a href="models/discrete/am_proc_block.html">am_proc_block</a><br>
% <a href="models/discrete/am_transducer.html">am_transducer</a></td>
% </tr>
% <tr>
% <td>Bouncing Ball QSS</td>
% <td>A simple model of a ball bouncing up and down.<br>The gravity is integrated
% by two connected QSS1 integrators to velocity and to height.<br> An event detection atomic
% model determines the points in time when the ball hits the ground and direction
% of movement has to be reversed and damped.<br>
% Folder: <tt>DEVSPATH/02-examples/discrete/bouncing_ball_qss</tt></td>
% <td><ul><li><a href="examples/discrete/init_qss1_ball_simple.html">Initialization Script</a></li>
% <li><a href="examples/discrete/plot_results_qss1_ball.html">Plot Function</a></li></td>
% <td><a href="models/discrete/static1.html">static1</a><br>
% <a href="models/discrete/qss1.html">qss1</a><br>
% <a href="models/discrete/event_detect.html">event_detect</a></td>
% </tr>
% <tr>
% <td>Sine QSS</td>
% <td>Integrates a sine function to a cosine function.<br>One example uses a quantized sine source, the other a timed sine source.<br>
% Folder: <tt>DEVSPATH/02-examples/discrete/sine_qss</tt></td>
% <td><ul><li><a href="examples/discrete/init_sine_qss1.html">Initialization Script Quantized Sine</a></li>
% <li><a href="examples/discrete/plot_sine_qss1.html">Plot Function Quantized Sine</a></li>
% <li><a href="examples/discrete/init_timed_sine_qss1.html">Initialization Script Timed Sine</a></li>
% <li><a href="examples/discrete/plot_timed_sine_qss1.html">Plot Function Timed Sine</a></li></ul></td>
% <td><a href="models/discrete/sine_qss1.html">sine_qss1</a><br>
% <a href="models/discrete/timed_sine_qss1.html">timed_sine_qss1</a><br>
% <a href="models/discrete/qss1.html">qss1</a></td>
% </tr>
% <tr>
% <td>Step QSS</td>
% <td>Integrates a step function by a QSS1 integrator. Time and values for step are customizable.<br>
% Folder: <tt>DEVSPATH/02-examples/discrete/steps-qss</tt></td>
% <td><ul><li><a href="examples/discrete/init_steptest_qss1.html">Initialization Script</a></li>
% <li><a href="examples/discrete/plot_step_qss1.html">Plot Function</a></li></ul></td>
% <td> <a href="models/discrete/step_qss1.html">step_qss1</a><br>
% <a href="models/discrete/qss1.html">qss1</a></td>
% </tr>
% </table>
% </html>
%
%% Hybrid examples
% Hybrid examples are composed from pure discrete and hybrid atomic models.
% This means that all pure discrete atomic models are derived from class
% |atomic|, all hybrid atomic models are derived from class
% |hybrid_atomic|. Coupled models are always instances of class
% |hybrid_coupled|. The root
% coordinator to simulate these models is the hybrid root
% coordinator |[root_model,tout,yout,teout,yeout,ieout] = r_c_hybrid(root_model,tstart,tend,plot_params)|.
% With help of a wrapping concept between discrete simulation steps
% Matlab(R)'s ode45 is called. Contiuous parts of model can be plotted during simualtion via Matlab(R)'s ODEPlot functionality.
%
% Hybrid PDEVS modeling and simulation is in an experimental status.  
%
% <html>
% <table>
% <tr>
% <td><b>Example</b></td>
% <td><b>Description</b></td>
% <td><b>Associated Files</b></td>
% <td><b>Atomic Models</b></td>
% </tr>
% <tr>
% <td>Bouncing Balls</td>
% <td>Models of bouncing balls which keep continuous variables for velocity and height.<br>
% Balls can be activated through a discrete port.<br>
% Continuous variables are plotted during simulation.<br>
% Folder: <tt>DEVSPATH/02-examples/hybrid/bouncing_balls</tt></td>
% <td><ul><li><a href="examples/hybrid/init_3_balls.html">Initialization Script Three Balls</a></li>
% <li><a href="examples/hybrid/analyse_3_balls.html">Plot and Analysis Function</a></li></ul></td>
% <td><b>discrete:</b><br>
% <a href="models/discrete/am_ball_starter.html">am_ball_starter</a><br>
% <a
% href="models/discrete/am_hit_counter.html">am_hit_counter</a><br><br>
% <b>hybrid:</b><br>
% <a href="models/hybrid/am_bball.html">am_bball</a></td>
% </tr>
% <tr>
% <td>Orange Juice Canning</td>
% <td>The combined discrete-continuous example &quot;Orange Juice Canning&quot; from &quot;Introduction to
% Simulation using SIMAN&quot;, page 451.<br>
% Some atomic components are pure discrete, some are hybrid.<br>
% Continuous variables are plotted during simulation.<br>
% Folder: <tt>DEVSPATH/02-examples/hybrid/orange_juice_canning</tt></td>
% <td><ul><li><a href="examples/hybrid/init_orange_juice_canning.html">Initialization Script</a></li>
% <li><a href="examples/hybrid/analyse_orange_juice_canning.html">Plot and Analysis Function</a></li></ul></td>
% <td><b>discrete:</b><br>
% <a href="models/discrete/am_truck_generator.html">am_truck_generator</a><br>
% <a href="models/discrete/am_fifo_queue.html">am_fifo_queue</a><br>
% <a href="models/discrete/am_dock_undock_server.html">am_dock_undock_server</a><br>
% <a href="models/discrete/am_truck_transducer.html">am_truck_transducer</a><br><br>
% <b>hybrid:</b><br>
% <a href="models/hybrid/am_truck.html">am_truck</a><br>
% <a href="models/hybrid/am_tank.html">am_tank</a><br>
% <a href="models/hybrid/am_canner.html">am_canner</a></td>
% </tr>
% </table>
% </html>
%
% <html>
% <br><br>
% <hr>
% <br>
% <a href="PDEVS_home.html">DEVS Tbx Home</a>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
% <a href="PDEVS_modelbase.html">Modelbase</a>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
% <a href="javascript:history.back()"><< Back</a>
% </html>
%
%