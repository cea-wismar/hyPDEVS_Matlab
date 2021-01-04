%% Plot and Statistics for 3 Balls
%
% Analyses combined discrete-continuous model of three bouncing balls with
% different attenuations. Two balls bouncing from the beginning, the third
% ball is started by a discrete event after 6 seconds.

%%
% Call: |analyse_3_balls(root_model,tstart,tend,tout,yout)|
%
% File: |DEVSPATH/02-examples/hybrid/bouncing_balls/analyse_3_balls.m|
%
%%
function analyse_3_balls(root_model,tstart,tend,tout,yout)

%% Plots
%
% * Continuous trajectories of balls (from tout / yout)
% * Continuous trajectories of balls (from recorded values in ball objects)
%
% *Plot from tout/yout returned by ode45.*
%
% <<img/3balls_analyse_ode.png>>
%
%
% *Plot from trajectories recorded in atomic models of balls.*
%
% <<img/3balls_analyse_model_traj.png>>
%
% In |height_traj| of balls a time/value pair is recorded every time the
% ODE-solver calls the rate of change function |dq = f(obj,gt,x,y)| and
% asks for current derivations. The plot shows, how the event detection of
% the ODE-solver works.
% 
%
%% Statistics
%
% *From discrete variables*
%
% * Number of hits to the ground of each ball,
% * Bounce duration of balls.
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




% figure for plot of continuous variables
figure('Name','Continuous Ball Trajectories from tout / yout');
hold on;
subplot(3,1,1);
plot(tout,yout(:,1),'x');% trajectorie of first ball
legend('ball 1');
xlabel('time [sec]');
ylabel('height [m]');
subplot(3,1,2);
plot(tout,yout(:,3),'x');% trajectorie of first ball
legend('ball 2');
xlabel('time [sec]');
ylabel('height [m]');
subplot(3,1,3);
plot(tout,yout(:,5),'-x');% trajectorie of first ball
legend('ball 3');
xlabel('time [sec]');
ylabel('height [m]');
hold off;

% new figure for plots of trajectories from recorded values
figure('Name','Ball Trajectories Recorded in height_traj of Balls');
hold on;
subplot(3,1,1);
plot(root_model.components.the_ball_1.height_traj(:,1),root_model.components.the_ball_1.height_traj(:,2),'x');% trajectorie of first ball
legend('ball 1');
xlabel('time [sec]');
ylabel('height [m]');
subplot(3,1,2);
plot(root_model.components.the_ball_2.height_traj(:,1),root_model.components.the_ball_2.height_traj(:,2),'x');% trajectorie of second ball
legend('ball 2');
xlabel('time [sec]');
ylabel('height [m]');
subplot(3,1,3);
plot(root_model.components.the_ball_3.height_traj(:,1),root_model.components.the_ball_3.height_traj(:,2),'x');;% trajectorie of third ball
legend('ball 3');
xlabel('time [sec]');
ylabel('height [m]');
hold off;

fprintf('\n');
disp('Number of Hits');
disp('----------------------------------');
disp(['ball 1: ',num2str(root_model.components.hit_count.s.num_hits(1))]);
disp(['ball 2: ',num2str(root_model.components.hit_count.s.num_hits(2))]);
disp(['ball 3: ',num2str(root_model.components.hit_count.s.num_hits(3))]);
fprintf('\n');


fprintf('\n');
disp('Bouncing Duration');
disp('----------------------------------');
if ~isempty(root_model.components.the_ball_1.s.bounce_end)
    bounce_time_1 = root_model.components.the_ball_1.s.bounce_end - root_model.components.the_ball_1.s.bounce_start;
else
     bounce_time_1 = tend - root_model.components.the_ball_1.s.bounce_start;
end
disp(['ball 1: ',num2str(bounce_time_1)]);
if ~isempty(root_model.components.the_ball_2.s.bounce_end)
    bounce_time_2 = root_model.components.the_ball_2.s.bounce_end - root_model.components.the_ball_2.s.bounce_start;
else
     bounce_time_2 = tend - root_model.components.the_ball_2.s.bounce_start;
end
disp(['ball 2: ',num2str(bounce_time_2)]);
if ~isempty(root_model.components.the_ball_3.s.bounce_end)
    bounce_time_3 = root_model.components.the_ball_3.s.bounce_end - root_model.components.the_ball_3.s.bounce_start;
else
     bounce_time_3 = tend - root_model.components.the_ball_3.s.bounce_start;
end
disp(['ball 3: ',num2str(bounce_time_3)]);
fprintf('\n');





end



