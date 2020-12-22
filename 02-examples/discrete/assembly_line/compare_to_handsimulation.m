%% Compare Results of "Assembly Line" Example to Handsimulation
% Shows the objects, x-ports, y-ports and current states (phase, sigma, queue lengths q1 and q2) of all processing blocs
% by calling the display functions for the atomic models.

%%
% Press _Enter_ after
% each processing bloc.
%
% Since simulation in standard scenario just runs from |tstart = 0| to |tend = 12|
% and model solely implements deterministic times, one can easily
% simulate it manually on a sheet of paper. This model and simulation
% scenario was developed to test improved simulator algorithms, especially regarding
% simultaneous events.
%
% Call: |compare_to_handsimulation|
%
% File: |DEVSPATH/02-examples/discrete/assembly_line/compare_to_handsimulation.m|
%

showall(root_model.components.(char('cm_c1')).components.(char('am_m1')));
pause
showall(root_model.components.(char('cm_c1')).components.(char('am_m2')));
pause
showall(root_model.components.(char('cm_c2')).components.(char('am_m1')));
pause
showall(root_model.components.(char('cm_c2')).components.(char('am_m2')));
pause
showall(root_model.components.(char('cm_c3')).components.(char('am_m1')));
pause
showall(root_model.components.(char('cm_c3')).components.(char('am_m2')));
pause

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
