%% Analyse "Single Server" Example
% Shows the objects, x-ports, y-ports and current states (phase, sigma,
% queue lengths q1 and q2) of all atomic components
% by calling the display functions for the atomic models.

%%
% Press _Enter_ after each model.
%
% Call: |analyse_singleserver|
%
% File: |DEVSPATH/02-examples/discrete/single_server/analyse_singleserver.m|
%

showall(root_model.components.(char('am_g1')));
pause
showall(root_model.components.(char('am_g2')));
pause
showall(root_model.components.(char('am_server1')));
pause
showall(root_model.components.(char('am_t1')));
pause

%% Generators
tg1_values = [root_model.components.am_g1.observed{:,1}];
g1states = [root_model.components.am_g1.observed{:,2}];
g1count = [g1states.counter];

tg2_values = [root_model.components.am_g2.observed{:,1}];
g2states = [root_model.components.am_g2.observed{:,2}];
g2count = [g2states.counter];

figure('name','Single Server Example','NumberTitle','off');

subplot(3,1,1)
stairs(tg1_values,g1count);
hold on
stairs(tg2_values,g2count,'red');
title('generators 1 and 2')

%% Assembling Station with Queues
tproc_values = [root_model.components.am_server1.observed{:,1}];
procstates = [root_model.components.am_server1.observed{:,2}];
procq1 = [procstates.q1];
procq2 = [procstates.q2];

subplot(3,1,2)
stairs(tproc_values,procq1);
hold on
stairs(tproc_values,procq2,'red');
title('assembling station queues');

%% Transducer
t_values = [root_model.components.am_t1.observed{:,1}];
states = [root_model.components.am_t1.observed{:,2}];
statenames = fieldnames(states);
%disp(['Data available: ',statenames, ' acessible via ''[states.statename]'''])

q_values=[states.q];

subplot(3,1,3)
stairs(t_values,q_values);
title('transducer');


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