%% Plot for QSS1 Quantized Sine Example
%
% Plots the q-trajectory of quantized sine source and the integrated sine versus
% a sine and it's integral, the
% analytically computed negative cosine function.
%
% Call: |plot_sine_qss1(root_model,tstart,tend)|
%
% File: |DEVSPATH/02-examples/discrete/sine-qss/plot_sine_qss1.m|
%
%
% <<img/sine_qss.png>>
% 
%
% 
% <<img/sine_qss_detail.png>>
% 
%%
function plot_sine_qss1(root_model,tstart,tend)
    % get the system parameters for plotting a sine wave
    A = root_model.components.sine.sysparams.A;
    omega = root_model.components.sine.sysparams.omega;
    phi = root_model.components.sine.sysparams.phi;
    % get the system parameters for figure titles
    du = root_model.components.sine.sysparams.delta_u;
    dq = root_model.components.integrator1.sysparams.dq;
    epsilon = root_model.components.integrator1.sysparams.epsilon;

%% Plot via Manually Tracked States
    figure('name','Plot sine qss1 via manually tracked states','NumberTitle','off')
    hold on
    grid on

    y=A*sin(omega*(tstart:0.001:tend)+phi);
    plot(tstart:0.001:tend,y,'r')

    stairs(root_model.components.sine.s.qtraj(:,1),root_model.components.sine.s.qtraj(:,2),'k')

    stairs(root_model.components.integrator1.s.qtraj(:,1),root_model.components.integrator1.s.qtraj(:,2))

    title(['Sine QSS1 \newline du = ',num2str(du),', dq = ',num2str(dq),', hysteresis = ',num2str(epsilon)],'FontSize',16);
    xlabel('time t');
    ylabel('sin(t) and -cos(t)');

    y=-A/(omega)*cos(omega*(tstart:0.001:tend)+phi);
    plot(tstart:0.001:tend,y,'g')
    legend 'sine' 'quantized sine' 'quantized integrated sine' 'analytically integrated sine'

    plot([tstart tend],[0 0])

    hold off

%% Plot with the Observe Functionality
% prerequisite: set observe_flag to 1 before simulation
    figure('name','Plot sine qss1 via observed states','NumberTitle','off');
    hold on
    grid on

    y=A*sin(omega*(tstart:0.001:tend)+phi);
    plot(tstart:0.001:tend,y,'r');

    sine_t_values = [root_model.components.sine.observed{:,1}];
    sine_states = [root_model.components.sine.observed{:,2}];
    sine_tau = [sine_states.tau];

    stairs(sine_t_values,sine_tau);

    integrator1_t_values = [root_model.components.integrator1.observed{:,1}];
    integrator1_states = [root_model.components.integrator1.observed{:,2}];
    integrator1_q = [integrator1_states.q];

    stairs(integrator1_t_values,integrator1_q);


    y=-A/(omega)*cos(omega*(tstart:0.001:tend)+phi);
    plot(tstart:0.001:tend,y,'g')
    legend 'sine' 's.tau' 'quantized integrated sine (s.q)' 'analytically integrated sine'

    plot([tstart tend],[0 0]);

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


