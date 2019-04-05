clear
close all

Ro = .25:.05:1.25;
beta = [.07, .20, .10];
alpha = [1.3395, 1.293, 1.725];

beta = [0.06, .20, .10];
alpha = [1.3395, 1.293, 1.725];


nRelations = numel(beta);
lineColors = gray(2*nRelations);
lineColors = flipud(lineColors(1:nRelations,:));

makerStyles = {'-', '--', '-.'};
figure('Color', 'White', 'Units','inches', 'Position',[3 3 6 3.5],'PaperPositionMode','auto');

iStart = 1;
for i = iStart:nRelations
    density = kerogenDensity(Ro, alpha(i), beta(i)); 
    
    RoDensityMin = .4;
    densityMin = kerogenDensity(RoDensityMin, alpha(i), beta(i));
    density(Ro<RoDensityMin) = densityMin;
    ax = gca;
    ax.ColorOrderIndex = i;
    h(i) = plot(Ro, density, 'Marker', 'none', 'LineStyle', makerStyles{i}, 'LineWidth', 3); hold on;

    xLocation = .35;
    yLocation = interp1(Ro, density, xLocation);
    textToShow = ['Type ' repmat('I',[1,i])];
    legendText{i} = textToShow;
    text(xLocation,yLocation, repmat('I',[1,i]),'FontName','Times', 'BackgroundColor', 'w', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle')
end
    
xlim([min(Ro) max(Ro)])

labelFontSize = 14;
tickFontSize = 12;
xlabel('Measured vitrinite reflectance %Ro (%)', 'FontUnits','points', 'FontWeight','normal', 'FontSize',labelFontSize,'FontName','Times')
ylabel('Kerogen density \rho_k (g/cm^3)', 'FontUnits','points', 'FontWeight','normal', 'FontSize',labelFontSize, 'FontName','Times')
set(gca, 'Units','normalized', 'FontUnits','points', 'FontWeight','normal', 'FontSize',tickFontSize,'FontName','Times')

% Type I
data = [0.72	1.31;0.75	1.31;0.83	1.395; 1.75	1.395;];
Ro = data(:,1);
density = data(:,2);
ax.ColorOrderIndex = 1;
scatter(Ro, density, 'x', 'SizeData', 100); hold on;
initialV = [1, 0.5];
fitOutput = fminsearch(@(v) objectiveFunctionRhoRo(v, [Ro, density]),initialV)

% Alfrad and Vernik 2012
data = [0.50381033, 1.1992243;0.6003387, 1.1001939;0.70491109, 1.1791855;...
    0.90558848, 1.249903;1.1024555, 1.3394958;1.3031329, 1.3701357;...
    2.0016935, 1.4998061;2.5, 1.5493213]
Ro = data(:,1);
density = data(:,2);
scatter(Ro, density, 'x', 'SizeData', 100); hold on;
initialV = [1, 0.5];
fitOutput = fminsearch(@(v) objectiveFunctionRhoRo(v, [Ro, density]),initialV)


% Type III
data =[0.43	1.59;0.45	1.65;0.6	1.59;0.7	1.71;0.99	1.71;1.15	1.71;1.96	1.73;2.1	1.79;2.57	1.985;2.57	1.985];
Ro = data(:,1);
density = data(:,2);
initialV = [1.293, 0.20];
initialV = [1, 0.5];
fitOutput = fminsearch(@(v) objectiveFunctionRhoRo(v, [Ro, density]),initialV)
scatter(Ro, density, 'x', 'SizeData', 100); hold on;

legend(h, legendText, 'Location', 'SouthEast')

%% Ward, 2010 Type II
figure('Color', 'White')
data = [0.45651562, 1.2269258; 0.64818463, 1.1950564; 0.58851675, 1.1105832; 0.97663946, 1.2618671; 1.0619195, 1.3403888; 2, 1.6690665];
Ro = data(:,1);
density = data(:,2);
scatter(Ro, density,  'filled', 'MarkerFaceColor', lineColors(1,:)); hold on;
fitOutput = fminsearch(@(v) objectiveFunctionRhoRo(v, [Ro, density]),[1.293, 0.20])

Ro = .25:.05:2;
density = kerogenDensity(Ro, fitOutput(1), fitOutput(2)); 
RoDensityMin = .4;
densityMin = kerogenDensity(RoDensityMin, fitOutput(1), fitOutput(2));
density(Ro<RoDensityMin) = densityMin;
h(i) = plot(Ro, density, 'Marker', 'none', 'LineStyle', '-',...
'Color', 'k', 'MarkerFaceColor', lineColors(i,:), 'LineWidth', 3); hold on;

%% Vandenbroucke and Largeau, 2007 Type II
figure('Color', 'White')
Ro = tMax2Ro([414, 438, 443, 479]);
density = [0.814, .99, 1.115, 1.518];
scatter(Ro, density,  'filled', 'MarkerFaceColor', lineColors(1,:)); hold on;
initialV = [1.3, .5];
fitOutput = fminsearch(@(v) objectiveFunctionRhoRo(v, [Ro, density]),initialV)

Ro = .25:.05:2;
density = kerogenDensity(Ro, fitOutput(1), fitOutput(2)); 
RoDensityMin = .4;
densityMin = kerogenDensity(RoDensityMin, fitOutput(1), fitOutput(2));
density(Ro<RoDensityMin) = densityMin;
h(i) = plot(Ro, density, 'Marker', 'none', 'LineStyle', '-',...
'Color', 'k', 'MarkerFaceColor', lineColors(i,:), 'LineWidth', 3); hold on;