%plot(root_model.components.integrator2.s.qtraj(:,1),root_model.components.integrator2.s.qtraj(:,2),'x')
stairs(root_model.components.integrator1.s.qtraj(:,1),root_model.components.integrator1.s.qtraj(:,2))
hold on
grid on
plot(root_model.components.integrator1.s.traj(:,1),root_model.components.integrator1.s.traj(:,2),'rx')
%pause
%plot(root_model.components.ev_det.s.traj(:,1),root_model.components.ev_det.s.traj(:,2),'g')
plot([0 5 10 20],[0 0 0 0])
title(' Timed Sine QSS2 \newline dq = 0.01','FontSize',16);
xlabel('time t');
ylabel('cos(t)');
%hleg1 = legend('q-Trajektorie','x-Trajektorie','x-Trajektorie Eventerkennung');

y=-cos(0:0.1:20);
hold on
plot(0:0.1:20,y,'k')
legend 'quantized integration' 'inputs of integrator' 'analytic -cos(t)'
hold off
