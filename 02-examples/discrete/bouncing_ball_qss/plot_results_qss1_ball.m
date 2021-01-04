%% Plot for QSS1 Bouncing Ball Example
%
% Plots the trajectories for the second integrator and the event detection
% atomics.
%
% Call: |plot_results_qss1_ball(root_model,tstart,tend)|
%
% File: |DEVSPATH/02-examples/discrete/bouncing_ball_qss/plot_results_qss1_ball.m|
%
% <<img/ball_qss.png>>
% 
%
% 
% <<img/ball_qss_detail.png>>
% 
%%
function plot_results_qss1_ball(root_model,tstart,tend)
    % get the system parameters for figure titles
    dq = root_model.components.integrator2.sysparams.dq;
    epsilon = root_model.components.integrator2.sysparams.epsilon;

%% Plot via Manually Tracked States
    figure('name','Plot bouncing ball via manually tracked states','NumberTitle','off')
    hLine = plot([tstart tend],[0 0],'y','LineWidth',2);
    set(get(get(hLine,'Annotation'),'LegendInformation'),...
        'IconDisplayStyle','off'); % exclude line from legend
    hold on
    grid on
    stairs(root_model.components.integrator2.s.qtraj(:,1),root_model.components.integrator2.s.qtraj(:,2))
    plot(root_model.components.integrator2.s.traj(:,1),root_model.components.integrator2.s.traj(:,2),'rx')
    plot(root_model.components.ev_det.s.eventtraj(:,2),root_model.components.ev_det.s.eventtraj(:,1),'gx','LineWidth',2)
    
    set(gca,'YLim',[-5,25]);
    title(['Bouncing Ball QSS1 \newline dq = ',num2str(dq),', hysteresis = ',num2str(epsilon)],'FontSize',16);
    xlabel('time t','FontSize',16);
    ylabel('high x or q','FontSize',16);
    legend('q-trajectory','X-trajectory','event detection');
    hold off

%% Plot with the Observe Functionality
% prerequisite: set observe_flag to 1 before simulation
    figure('name','Plot bouncing ball via observed states','NumberTitle','off');
    hLine2 = plot([tstart tend],[0 0],'y','LineWidth',2);
    set(get(get(hLine2,'Annotation'),'LegendInformation'),...
        'IconDisplayStyle','off'); % exclude line from legend
    hold on
    grid on
    integrator2_t_values = [root_model.components.integrator2.observed{:,1}];
    integrator2_states = [root_model.components.integrator2.observed{:,2}];
    integrator2_X = [integrator2_states.X];
    integrator2_q = [integrator2_states.q];
    stairs(integrator2_t_values,integrator2_q);
    plot(integrator2_t_values,integrator2_X,'rx');
    event_t_values = [root_model.components.ev_det.observed{:,1}];
    event_states = [root_model.components.ev_det.observed{:,2}];
    event_se = [event_states.se];
    plot(event_t_values,event_se,'gx','LineWidth',2);

    set(gca,'YLim',[-5,25]);
    title(['Bouncing Ball QSS1 \newline dq = ',num2str(dq),', hysteresis = ',num2str(epsilon)],'FontSize',16);
    xlabel('time t','FontSize',16);
    ylabel('high x or q','FontSize',16);
    legend('s.q','s.X','s.se');
    hold off

%%
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
















