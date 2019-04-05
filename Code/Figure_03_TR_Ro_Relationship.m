clear

% Define thermal history
maxT = 500;
Ti = 100;
H = 10;
dT = .5;
[t, T] = linearThermalHistory(H, maxT, Ti, dT, true);

% Define kerogens
kerogenTypes = {'I', 'II', 'IIIN', 'II-S', 'IIIM'};
legendText = {'Type I', 'Type II', 'Type III North Sea', 'Type II-S', 'Type III Mahakam'};
lineStyles = {'-', '--', '-.', ':', ':'};

% Define Ploting paramters
nColors = numel(kerogenTypes);
lineColors = gray(2*nColors);
lineColors = flipud(lineColors(1:nColors,:));

% Define Calculated Ro type
RoType = 'EasyDL';

% Run analysis and plot
figure('Color', 'White', 'Units','inches', 'Position',[3 3 6 3.5],'PaperPositionMode','auto');
set(gcf, 'Name', [RoType '%Ro'], 'NumberTitle','off')
for i =1:numel(kerogenTypes)
    [F, TR, Ro] = runPyrolysis(kerogenTypes{i}, RoType, t, T);
    plot(TR, Ro, 'LineWidth', 2.5, 'lineStyle', lineStyles{i}); hold on;
end

% Finalize figure
legend(legendText, 'Location', 'NorthWest')
labelFontSize = 14;
tickFontSize = 12;
ylabel({'Calculated vitrinite reflectance %Ro (%)'}, 'FontUnits','points', 'FontWeight','normal', 'FontSize',labelFontSize,'FontName','Times')
xlabel({'Kerogen tranformation ratio TR'}, 'FontUnits','points', 'FontWeight','normal', 'FontSize',labelFontSize, 'FontName','Times')
set(gca, 'Units','normalized', 'FontUnits','points', 'FontWeight','normal', 'FontSize',tickFontSize,'FontName','Times')
ylim([0,6])




