%% Load data
clear all

% Minerals
mineralToUse = {'Quartz','Illite_K_Rich', 'Calcite', 'Pyrite', 'Apatite_Br_Rich'};
mineralsFileName = 'C:\Users\malibrah\OneDrive\Stanford\Project Cella\Papers\Multi-Mineral Inversion of X-Ray Fluorescence Data\Code\Minerals.csv';
[Minerals] = readtable(mineralsFileName, 'ReadRowNames',true);
parameterNames      =  {'K', 'G', 'Rho'};
mineralsValues = Minerals{mineralToUse, {'K', 'G','Rho'}};
Minerals = array2table(mineralsValues, 'RowNames', mineralToUse, 'VariableNames', parameterNames);

% Kerogen
kerogenNames = {'I', 'II', 'III'};
parameterNames ={'K', 'G', 'alpha', 'beta', 'maxPhi'};
kerogenValues(1,:) = [5.5, 3.2, 1.357, 0.58, .69];
kerogenValues(2,:) = [5.5, 3.2, 1.293, 0.20, .43];
kerogenValues(3,:) = [5.5, 3.2, 1.725, 0.10, .12];
Kerogens = array2table(kerogenValues, 'RowNames', kerogenNames, 'VariableNames', parameterNames);

% Fluid
fluidNames = {'Oil'};
parameterNames ={'K', 'G', 'Rho'};
fluidValues = [1.02, 0, 800];
Fluids = array2table(fluidValues, 'RowNames', fluidNames, 'VariableNames', parameterNames);

%% Define the top layer properties


vp0Top = 4.09*1000;
vs0Top = 2.41*1000;
rhoTop = 2.37*1000;

[K1,mu1,~] = v2ku(vp0Top,vs0Top,rhoTop);


[vp0Top,vs0Top,rhoTop]=gassmnv(vp0Top,vs0Top,rhoTop,1000,2.2,800, 1.02, 37, .30)

[C1] = CSiso(K1,mu1);
[epsTop,g,deltaTop]=calc_thomsen(C1);


%% AVO and maturation

typeKerogenNames = {'I', 'II', 'III'};
maxPhis = [.71, .43, .12];
maxWtPerCarbonLosses = [.75, .45, .15];
initialHCs = [1.59, 1.28, .9];

Ros = .4:.3:1.3;
%Ros = [.4, .8, 1, 1.2]
lineStyles = {'-', '--', '-.', ':', ':'};
legendText = [];
f1 = figure('Color', 'White', 'Units','inches', 'Position',[3 3 14 6],'PaperPositionMode','auto');
locations = {'NorthEast', 'SouthWest', 'SouthWest'};
for k = 1:3
subplot(1,3,k)
for j = 1:numel(Ros)
Ro = Ros(j);
kerogenType = k;

kerogenK   = Kerogens{typeKerogenNames{kerogenType},'K'};
kerogenG   = Kerogens{typeKerogenNames{kerogenType},'G'};
fluidK     = Fluids{1,'K'};
fluidRho   = Fluids{1,'Rho'};
maxPhi     = maxPhis(kerogenType);
phiKerogenAlpha = 1;
freqType = 0;
roModel = 'EasyDL';
maxWtPerCarbonLoss = maxWtPerCarbonLosses(kerogenType);
initialHC = initialHCs(kerogenType);


mineralsK = Minerals{:,'K'};
mineralsG = Minerals{:,'G'};
mineralsRho = Minerals{:,'Rho'};
phi = .1;
phiAlphaMatrix = 0.1681;
minAverageTypeMatrix = 3;
kerogenPercent = .1;
vtiIsoDem = 1;
minAverageTypeKerogen = nan;
kerogenAlpha = nan;
fractions = [.3, 0, .7, 0 , 0];

[vp2, vs2, d2, output] = modelOrganicRichRock(Ro, kerogenK, kerogenG, ...
     fluidK, fluidRho, maxPhi, phiKerogenAlpha, freqType, roModel, kerogenType, maxWtPerCarbonLoss, initialHC,...
     mineralsK, mineralsG, mineralsRho, fractions, phi,phiAlphaMatrix, ...
     minAverageTypeMatrix,  kerogenPercent, vtiIsoDem, minAverageTypeKerogen,...
     kerogenAlpha);
 
output = num2cell(output);
[vp0Bottom, vs0Bottom, rhoBottom,~,~, epsBottom, ~, deltaBottom] = output{:};

Rpp = [];
angles = 0:30;
for i = 1:numel(angles)
    %
    %Rpp(i) = rugerVTI(vp0Top, vp0Bottom, vs0Top, vs0Bottom, rhoTop, rhoBottom,...
    %deltaTop, deltaBottom, epsTop, epsBottom, angles(i), false);

    [Rpp(i), A(i), B(i), C(i)] = rugerVTI(vp0Bottom, vp0Top, vs0Bottom, vs0Top, rhoBottom, rhoTop,...
    deltaBottom, deltaTop, epsBottom, epsTop, angles(i), false);
end

subplot(2,3,k+0)
plot(angles,Rpp, lineStyles{j}, 'LineWidth', 2); hold on
legendText{j} = ['Ro = ' num2str(Ro)];


subplot(2,3,k+3)
scatter(A,B, 'filled'); hold on
end

subplot(2,3,k+0)
labelFontSize = 14;
tickFontSize = 12;
legend(legendText, 'Location', locations{k})
ylabel({'Reflectivity'}, 'FontUnits','points', 'FontWeight','normal', 'FontSize',labelFontSize,'FontName','Times')
xlabel({'Reflection angle (\circ)'}, 'FontUnits','points', 'FontWeight','normal', 'FontSize',labelFontSize, 'FontName','Times')
set(gca, 'Units','normalized', 'FontUnits','points', 'FontWeight','normal', 'FontSize',tickFontSize,'FontName','Times')
titleText = ['Type ' , repmat('I',1,k)];
ylimits = ylim;
%ylim([ylimits(1), 0])
ylimits = ylim;
xlimits = xlim;
xLocation = min(xlim) + .60*range(xlimits);
yLocation = max(ylim) - .85*range(ylimits);
text(xLocation, yLocation, titleText,'FontUnits','points', 'FontWeight','normal', 'FontSize',labelFontSize,'FontName','Times')


subplot(2,3,k+3)
legend(legendText, 'Location', 'NorthEast')
xlabel({'A'}, 'FontUnits','points', 'FontWeight','normal', 'FontSize',labelFontSize,'FontName','Times')
ylabel({'B'}, 'FontUnits','points', 'FontWeight','normal', 'FontSize',labelFontSize, 'FontName','Times')
set(gca, 'Units','normalized', 'FontUnits','points', 'FontWeight','normal', 'FontSize',tickFontSize,'FontName','Times')
ylimits = ylim;
ylim([ylimits(1)-.05, ylimits(2)+.17])
ylimits = ylim;
xlimits = xlim;
xLocation = min(xlim) + .1*range(xlimits);
yLocation = max(ylim) - .92*range(ylimits);
text(xLocation, yLocation, titleText,'FontUnits','points', 'FontWeight','normal', 'FontSize',labelFontSize,'FontName','Times')
box on


end


%% kerogenPercent

typeKerogenNames = {'I', 'II', 'III'};
maxPhis = [.71, .43, .12];
maxWtPerCarbonLosses = [.75, .45, .15];
initialHCs = [1.59, 1.28, .9];

xKer = 0:.05:.15;
lineStyles = {'-', '--', '-.', ':', '-', '--', '-.', ':', '-', '--', '-.', ':'};
legendText = [];
f1 = figure('Color', 'White', 'Units','inches', 'Position',[3 3 14 6],'PaperPositionMode','auto');
for k = 1:3

for j = 1:numel(xKer)
Ro = 1;
kerogenType = k;

kerogenK   = Kerogens{typeKerogenNames{kerogenType},'K'};
kerogenG   = Kerogens{typeKerogenNames{kerogenType},'G'};
fluidK     = Fluids{1,'K'};
fluidRho   = Fluids{1,'Rho'};
maxPhi     = maxPhis(kerogenType);
phiKerogenAlpha = 1;
freqType = 0;
roModel = 'EasyDL';
maxWtPerCarbonLoss = maxWtPerCarbonLosses(kerogenType);
initialHC = initialHCs(kerogenType);


mineralsK = Minerals{:,'K'};
mineralsG = Minerals{:,'G'};
mineralsRho = Minerals{:,'Rho'};
phi = .1;
minAverageTypeMatrix = 3;
kerogenPercent = xKer(j);
vtiIsoDem = 1;
minAverageTypeKerogen = nan;
kerogenAlpha = nan;
mineralPercent = 1-kerogenPercent-phi;
fractions = [mineralPercent/2, mineralPercent/2,0, 0 , 0];

[vp2, vs2, d2, output] = modelOrganicRichRock(Ro, kerogenK, kerogenG, ...
     fluidK, fluidRho, maxPhi, phiKerogenAlpha, freqType, roModel, kerogenType, maxWtPerCarbonLoss, initialHC,...
     mineralsK, mineralsG, mineralsRho, fractions, phi,phiAlphaMatrix, ...
     minAverageTypeMatrix,  kerogenPercent, vtiIsoDem, minAverageTypeKerogen,...
     kerogenAlpha);
 
output = num2cell(output);
[vp0Bottom, vs0Bottom, rhoBottom,~,~, epsBottom, ~, deltaBottom] = output{:};
 
Rpp = [];
A = [];
B = [];
C = [];

angles = 0:30;
for i = 1:numel(angles)
    %
%     Rpp(i) = rugerVTI(vp0Top, vp0Bottom, vs0Top, vs0Bottom, rhoTop, rhoBottom,...
%     deltaTop, deltaBottom, epsTop, epsBottom, angles(i), false);

    [Rpp(i), A(i), B(i), C(i)] = rugerVTI(vp0Bottom, vp0Top, vs0Bottom, vs0Top, rhoBottom, rhoTop,...
    deltaBottom, deltaTop, epsBottom, epsTop, angles(i), false);
end
subplot(2,3,k+0)
plot(angles,Rpp, lineStyles{j}, 'LineWidth', 2); hold on
legendText{j} = ['xKerogen = ' num2str(kerogenPercent)];


subplot(2,3,k+3)
scatter(A,B, 'filled'); hold on


end

subplot(2,3,k+0)
labelFontSize = 14;
tickFontSize = 12;
legend(legendText, 'Location', 'NorthEast')
ylabel({'Reflectivity'}, 'FontUnits','points', 'FontWeight','normal', 'FontSize',labelFontSize,'FontName','Times')
xlabel({'Reflection angle (\circ)'}, 'FontUnits','points', 'FontWeight','normal', 'FontSize',labelFontSize, 'FontName','Times')
set(gca, 'Units','normalized', 'FontUnits','points', 'FontWeight','normal', 'FontSize',tickFontSize,'FontName','Times')
titleText = ['Type ' , repmat('I',1,k)];
ylimits = ylim;
ylim([ylimits(1)-.05, ylimits(2)+.17])
ylimits = ylim;
xlimits = xlim;
xLocation = min(xlim) + .1*range(xlimits);
yLocation = max(ylim) - .92*range(ylimits);
text(xLocation, yLocation, titleText,'FontUnits','points', 'FontWeight','normal', 'FontSize',labelFontSize,'FontName','Times')


subplot(2,3,k+3)
legend(legendText, 'Location', 'NorthEast')
xlabel({'A'}, 'FontUnits','points', 'FontWeight','normal', 'FontSize',labelFontSize,'FontName','Times')
ylabel({'B'}, 'FontUnits','points', 'FontWeight','normal', 'FontSize',labelFontSize, 'FontName','Times')
set(gca, 'Units','normalized', 'FontUnits','points', 'FontWeight','normal', 'FontSize',tickFontSize,'FontName','Times')
ylimits = ylim;
ylim([ylimits(1)-.05, ylimits(2)+.17])
ylimits = ylim;
xlimits = xlim;
xLocation = min(xlim) + .1*range(xlimits);
yLocation = max(ylim) - .92*range(ylimits);
text(xLocation, yLocation, titleText,'FontUnits','points', 'FontWeight','normal', 'FontSize',labelFontSize,'FontName','Times')
box on


end

