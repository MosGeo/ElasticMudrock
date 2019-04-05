
kerogenTypes = {'Yurchenkoa et al., 2018', 'Yurchenkoa et al., 2018', 'Masterson, 2001', 'Masterson2'};
maxT = 180;
Ti = 0;
H = 3;
dT = 1;

figure('Color', 'White', 'Units','inches', 'Position',[3 3 6 3.5],'PaperPositionMode','auto');

nColors = 3;
lineColors = gray(2*nColors);
lineColors = flipud(lineColors(1:nColors,:));

grayColor = [.5 .5 .5];

indLineWidth = 2;
% 8013.5 Phoenix
i= 1;
A = 15598000000000;
f = [0.7764, 0.026, 0.1799, 0, 0.0176]';
E = [51, 52, 53, 54, 55]';
[t, T] = linearThermalHistory(H, maxT, Ti, dT, true);
[F, TR1, Ro1]= runPyrolysis(kerogenTypes{i}, 'EasyDL', t,T, A, f, E);
%plot(T, TR, 'LineWidth', 2,  'Color', lineColors(i,:)); hold on;
h(i) = plot(TR1, Ro1, 'LineWidth', indLineWidth,  'Color', lineColors(1,:)); hold on;

% 7966.7 Phoenix
i= 2;
A = 30767000000000;
f = [.8426, 0, .1521, .0053]';
E = [52, 53, 54, 55]';
[t, T] = linearThermalHistory(H, maxT, Ti, dT, true);
[F, TR2, Ro2] = runPyrolysis(kerogenTypes{i}, 'EasyDL', t,T, A, f, E);
%plot(T, TR, 'LineWidth', 2,  'Color', lineColors(i,:)); hold on;
h(i) = plot(TR2, Ro2, 'LineWidth', indLineWidth,  'Color', lineColors(1,:)); hold on;

% Masterson Phoenix
i= 3;
A = 1.338e13;
f = [.8559, .0013, .1255, .0113, .006]';
E = [51, 52, 53, 55, 63]';
[t, T] = linearThermalHistory(H, maxT, Ti, dT, true);
[F, TR3, Ro3] = runPyrolysis(kerogenTypes{i}, 'EasyDL', t,T, A, f, E);
%plot(T, TR, 'LineWidth', 2,  'Color', lineColors(i,:)); hold on;
h(i) = plot(TR3, Ro3, 'LineWidth', indLineWidth,  'Color',lineColors(1,:)); hold on;


i=4;
TR = 0:.001:1;
Ro1Interp =interp1(TR1,Ro1,TR, 'linear', 'extrap');
Ro2Interp =interp1(TR2,Ro2,TR,  'linear', 'extrap');
Ro3Interp =interp1(TR3,Ro3,TR,  'linear', 'extrap');
Ro = (Ro1Interp+Ro2Interp+Ro3Interp)/3;
h(i)=plot(TR, Ro , 'LineWidth', 2,  'Color', 'red'); hold on;


%xlim([100,maxT])
ylim([0,1.7])
labelFontSize = 14;
tickFontSize = 12;
xlabel({'Kerogen tranformation ratio TR'}, 'FontUnits','points', 'FontWeight','normal', 'FontSize',labelFontSize, 'FontName','Times')
ylabel({'Calculated vitrinite reflectance %Ro'}, 'FontUnits','points', 'FontWeight','normal', 'FontSize',labelFontSize, 'FontName','Times')

%xlabel({'Temperature (C)'}, 'FontUnits','points', 'FontWeight','normal', 'FontSize',labelFontSize, 'FontName','Times')
legendText = {'Individual samples', 'Mean'};

legend(h(3:4), legendText, 'Location', 'SouthEast');

%% Masterson Check

kerogenTypes = {'Masterson, 2001, 0.5 C/Ma', 'Masterson, 2001, 1.0 C/Ma', 'Masterson, 2001, 3.0 C/Ma'};

figure('Color', 'White', 'Units','inches', 'Position',[3 3 6 3.5],'PaperPositionMode','auto');
nColors = numel(kerogenTypes);
lineColors = gray(2*nColors);
lineColors = flipud(lineColors(1:nColors,:));

A = 1.338e13;
f = [.8559, .0013, .1255, .0113, .006]';
E = [51, 52, 53, 55, 63]';

maxT = 200;
Ti = 100;
H = .5;
dT = 1;

i= 1;
[t, T] = linearThermalHistory(H, maxT, Ti, dT, true);
[F, TR, Ro] = runPyrolysis(kerogenTypes{i}, 'EasyDL', t,T, A, f, E);
plot(T, TR, 'LineWidth', 2,  'Color', lineColors(i,:)); hold on;

i= 2;
[t, T] = linearThermalHistory(1, maxT, Ti, dT, true);
[F, TR, Ro] = runPyrolysis(kerogenTypes{i}, 'EasyDL', t,T, A, f, E);
plot(T, TR, 'LineWidth', 2,  'Color', lineColors(i,:)); hold on;

i= 3;
[t, T] = linearThermalHistory(3, maxT, Ti, dT, true);
[F, TR, Ro] = runPyrolysis(kerogenTypes{i}, 'EasyDL', t,T, A, f, E);
plot(T, TR, 'LineWidth', 2,  'Color', lineColors(i,:)); hold on;

xlim([100,maxT])
labelFontSize = 14;
tickFontSize = 12;
ylabel({'Kerogen tranformation ratio TR'}, 'FontUnits','points', 'FontWeight','normal', 'FontSize',labelFontSize, 'FontName','Times')
legend(kerogenTypes, 'Location', 'SouthEast');

%% Inessa Check


kerogenTypes = {'Yurchenkoa et al., 2018', 'Yurchenkoa et al., 2018', 'Masterson, 2001'};

figure('Color', 'White', 'Units','inches', 'Position',[3 3 6 3.5],'PaperPositionMode','auto');
nColors = numel(kerogenTypes);
lineColors = gray(2*nColors);
lineColors = flipud(lineColors(1:nColors,:));


maxT = 200;
Ti = 100;
H = 3;
dT = 1;

i= 1;
A = 15598000000000;
f = [0.7764, 0.026, 0.1799, 0, 0.0176]';
E = [51, 52, 53, 54, 55]';
[t, T] = linearThermalHistory(H, maxT, Ti, dT, true);
[F, TR, Ro] = runPyrolysis(kerogenTypes{i}, 'EasyDL', t,T, A, f, E);
plot(T, TR, 'LineWidth', 2,  'Color', lineColors(i,:)); hold on;

i= 2;
A = 30767000000000;
f = [.8426, 0, .1521, .0053]';
E = [52, 53, 54, 55]';
[t, T] = linearThermalHistory(H, maxT, Ti, dT, true);
[F, TR, Ro] = runPyrolysis(kerogenTypes{i}, 'EasyDL', t,T, A, f, E);
plot(T, TR, 'LineWidth', 2,  'Color', lineColors(i,:)); hold on;

i= 3;
A = 1.338e13;
f = [.8559, .0013, .1255, .0113, .006]';
E = [51, 52, 53, 55, 63]';
[t, T] = linearThermalHistory(H, maxT, Ti, dT, true);
[F, TR, Ro] = runPyrolysis(kerogenTypes{i}, 'EasyDL', t,T, A, f, E);
plot(T, TR, 'LineWidth', 2,  'Color', lineColors(i,:)); hold on;

xlim([100,maxT])
labelFontSize = 14;
tickFontSize = 12;
ylabel({'Kerogen tranformation ratio TR'}, 'FontUnits','points', 'FontWeight','normal', 'FontSize',labelFontSize, 'FontName','Times')
legend(kerogenTypes, 'Location', 'SouthEast');