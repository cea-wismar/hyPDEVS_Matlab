%% Plot and Statistics for Orange Juice Canning Hybrid Example
%
% Analyses the combined discrete-continuous example from "Introduction to
% Simulation using SIMAN", page 451.

%%
% Call: |analyse_orange_juice_canning(root_model,tstart,tend,tout,yout)|
%
% File: |DEVSPATH/02-examples/hybrid/orange_juice_canning/analyse_orange_juice_canning.m|
%
%%
function analyse_orange_juice_canning(root_model,tstart,tend,tout,yout)

%% Plots
%
% * Continuous trajectories of truck/tank/canner levels,
% * Truck generation times,
% * Truck queue
%
% <<img/discrete_statistics.png>>
% 
%
% 
% <<img/continuous_trajectories.png>>
% 
%
%% Statistics
%
% *From discrete variables*
%
% * Trucks generated, trucks emptied, truck generation times,
% * Max/min/final queue length,
% * Number of Palletes completed,
% * Uptime of canning-process.
%
% *From continuous variables*
%
% * Max/min/average truck level,
% * Standard deviation of truck level,
% * Max/min/average tank level,
% * Standard deviation of tank level,
% * Max/min/average canner level,
% * Standard deviation of canner level.
%
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
figure('Name','Continuous Trajectories');
hold on;
subplot(3,1,1);
plot(tout,yout(:,1),'x');% truck level trajectorie
legend('truck level');
xlabel('time [min]');
ylabel('level [gallons]');
subplot(3,1,2);
plot(tout,yout(:,3),'x');% tank level trajectorie
legend('tank level');
xlabel('time [min]');
ylabel('level [gallons]');
subplot(3,1,3);
plot(tout,yout(:,5),'-x');% canner level trajectorie
legend('canner level');
xlabel('time [min]');
ylabel('level [gallons]');
hold off;

% new figure for some plots of the discrete part
figure('Name','Discrete Statistics');
hold on;
subplot(2,1,1);
%plot(diff(root_model.components.t_gen.s.generation_times),1/44 *exp(-diff(root_model.components.t_gen.s.generation_times)/44),'x');
plot(root_model.components.t_gen.s.generation_times,ones(size(root_model.components.t_gen.s.generation_times)),'rx');
set(gca,'xlim',[tstart tend],'ylim',[0.5 1.5],'YTick',[]);
box on
grid on
xlabel('time [min]');
title('Truck generation times');



subplot(2,1,2);
set(gca,'xlim',[tstart tend],'ylim',[0 max(root_model.components.queue.s.queue_stats(:,2))+1],'YTick',0:1:max(root_model.components.queue.s.queue_stats(:,2)));
    box on
    grid on
    xlabel('time [min]');
    ylabel('# waiting');
    title('Truck queue');
    hold on;
stairs(root_model.components.queue.s.queue_stats(:,1),root_model.components.queue.s.queue_stats(:,2))
hold off;


fprintf('\n');
disp('trucks statistics');
disp('----------------------------------');
disp('number of trucks generated:');
disp(root_model.components.t_gen.s.number_generated);
disp('number of trucks emptied:');
disp(root_model.components.transducer.s.num_trucks);
disp('generation times of trucks:');
fprintf('%.3f \n',root_model.components.t_gen.s.generation_times);
fprintf('\n');




fprintf('\n');
disp('queue statistics');
disp('----------------------------------');
disp(['max queue length: ',num2str(max(root_model.components.queue.s.queue_stats(:,2)))]);
disp(['min queue length: ',num2str(min(root_model.components.queue.s.queue_stats(:,2)))]);
disp(['final queue length: ',num2str(root_model.components.queue.s.queue_stats(end,2))]);
disp('');
for j=1:length(root_model.components.queue.s.queue_stats)
fprintf('% 6.3f  %d \n',root_model.components.queue.s.queue_stats(j,1),root_model.components.queue.s.queue_stats(j,2));
end

fprintf('\n');
disp('pallets statistics');
disp('----------------------------------');
disp('number of pallets completed:');
disp(root_model.components.transducer.s.num_pallets);


fprintf('\n');
disp('canning statistics');
disp('----------------------------------');
disp('up-time of canning process:');
disp(root_model.components.canner.s.up_time);

fprintf('\n');
ts_truck=timeseries(yout(:,1),tout); % create a timeseries object
disp(['average truck level: ',num2str(mean(ts_truck))]);
disp(['standard deviation truck level: ',num2str(std(ts_truck))]);
disp(['max truck level: ',num2str(max(ts_truck))]);
disp(['min truck level: ',num2str(min(ts_truck))]);

fprintf('\n');
ts_tank=timeseries(yout(:,3),tout); % create a timeseries object
disp(['average tank level: ',num2str(mean(ts_tank))]);
disp(['standard deviation tank level: ',num2str(std(ts_tank))]);
disp(['max tank level: ',num2str(max(ts_tank))]);
disp(['min tank level: ',num2str(min(ts_tank))]);
disp(' ');

fprintf('\n');
ts_canner=timeseries(yout(:,5),tout); % create a timeseries object
disp(['average canner level: ',num2str(mean(ts_canner))]);
disp(['standard deviation canner level: ',num2str(std(ts_canner))]);
disp(['max tank canner: ',num2str(max(ts_canner))]);
disp(['min tank canner: ',num2str(min(ts_canner))]);
disp(' ');

end



