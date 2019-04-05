%% Define Well
clear all

dataFolder = 'Data - Well';
wellName = 'Alcor1';
shift = -2;

%% XRF Analysis

elementsFileName = 'Constants\Elements.csv';
[Elements] = readtable(elementsFileName, 'ReadRowNames',true);

mineralsFileName = 'Constants\Minerals.csv';
[Minerals] = readtable(mineralsFileName, 'ReadRowNames',true);

dataFileName = fullfile(dataFolder, ['XRF', '_' wellName, '.csv']);
[Data] = readtable(dataFileName, 'ReadRowNames',true);

Minerals = AnalyzeMinerals(Elements, Minerals);

mineralToUse = {'Quartz','Illite_K_Rich', 'Calcite', 'Pyrite', 'Apatite_Br_Rich'};
elementsToUse = {'Ca', 'Si', 'Al', 'P', 'K', 'Mg', 'Fe'};

[Aprime, AprimeTable] = ConstructAprimeMatrix(Minerals, elementsToUse, mineralToUse);
dataToUse = FilterData(Data,elementsToUse);
[resultsTable, inputTable] = InvertToMinerals(Aprime, dataToUse, mineralToUse);
[resultsTableVolume, resultsVolume] = MassToVolumeFraction(resultsTable, Minerals);
matrixRho = resultsVolume * Minerals(mineralToUse,:).Rho;
resultsTableVolume = [resultsTableVolume, array2table(matrixRho)];
%PlotResultsTable(resultsTableVolume)

%% Log Data 
lasFile    = fullfile(dataFolder, ['Logs', '_', wellName, '.las']);

depthCurve = 'DEPT';grCurve = 'DGRC';peCurve = 'ALPELC';ildCurve = 'R39P';
dtcCurve ='DTC';dtsCurve = 'DTS';rhoCurve = 'ALCDLC';porCurve = 'TNPS';
peCurve = 'ALPELC';

minDepth = 10575+shift ; maxDepth = 10660+shift ;

% Load Logs
[lasData, depth, lasHeader] = importLasFile(lasFile);

% Nan in missing data
lasData = standardizeMissing(lasData,-999.2500);

% Filter Depth
lasDepth = lasData.DEPT;
indexToKeep = lasDepth>= minDepth & lasDepth<=maxDepth;
lasData = lasData(indexToKeep,:);

%% Other Data
tocFile    = fullfile(dataFolder, ['TOC', '_', wellName, '.csv']);
coreGRFile = fullfile(dataFolder, ['CoreGR', '_', wellName, '.csv']);
topFile    = fullfile(dataFolder, ['Tops', '_', wellName, '.csv']);

% Load TOC Data
tocData = readtable(tocFile);
tocData = sortrows(tocData);

% Core GR
coreGRData = readtable(coreGRFile);
coreGRData = sortrows(coreGRData);

%% Shift and Aggregate Data

getLasData = @(curveName)  lasData{:,curveName};
logDepth = getLasData(depthCurve);
logGR = getLasData(grCurve);
logRho = getLasData(rhoCurve) * 1000 ;% -  getLasData('ALDCLC') *1000;
logVp = 1./getLasData(dtcCurve) * 304800; %m/s
logVs = 1./getLasData(dtsCurve) * 304800; %m/s
logIld =  getLasData(ildCurve);
logPor = getLasData(porCurve)/100;
logPe = getLasData(peCurve);

tocDataInterp= interp1(tocData{:,1} + shift,tocData{:,2},logDepth);
carbDataInterp =  interp1(tocData{:,1} + shift,tocData{:,3},logDepth);

logTable = table(logDepth, logGR, logRho, logVp, logVs, logIld, logPor, tocDataInterp);
header = cellfun(@(x) num2str(x), num2cell(logDepth), 'UniformOutput',0);
logTable.Properties.RowNames   = header;
logTable.Properties.VariableNames = {'Depth', 'GR', 'Rho', 'Vp', 'Vs', 'ILD', 'Por', 'TOC'};
%plotLogData(logTable)

%% Plotting
depthLog = logTable{:,1};
dataToPlot = logTable{:,2:end};

dataToPlot = [logGR, logRho/1000, logVp, logVs, logIld, logPe, logPor, tocDataInterp*100]
nCols = size(dataToPlot,2);
logIndex = 1:nCols;
spacing = [0, 0 , 0, 0, 0, 0,0, 0, 0, 0 ,0,0,0];
width = .11;
styles = repmat({'k'}, [nCols,1]);
titles =  {'GR (API)', 'Rho (g/cc)', 'Vp (ft/s)', 'Vs (ft/s)', 'ILD', 'Pe', '\phi (%)', 'TOC (wt%)'};
[figureHandle, axisHandles] = plotWellLogs(dataToPlot, depthLog,titles, logIndex, [5], styles, spacing, width);

%% Interpolate between XRF and meausurments (XRF POINTS)
xrfDepth = resultsTableVolume.Properties.RowNames;
xrfDepth = arrayfun(@(x) str2double(x), xrfDepth);
xrfDepth = xrfDepth + shift;
xrfData = table2array(resultsTableVolume(:,:)) ;

bottomCut = 25;
xrfData = xrfData(1:end-bottomCut,:);
xrfDepth = xrfDepth(1:end-bottomCut,:);

xrfDataUsed = xrfData;
xrfDataUsedTable = array2table([xrfDepth, xrfDataUsed]);

header = cellfun(@(x) num2str(x), num2cell(xrfDepth), 'UniformOutput',0);
xrfDataUsedTable.Properties.RowNames   = header ;
xrfDataUsedTable.Properties.VariableNames = ['Depth', mineralToUse, 'MatrixRho'];
%plotLogData(xrfDataUsedTable);

% Interp to XRF Points
logXRFInterp = interp1(logDepth, logTable{:,:}, xrfDepth);
logTable = array2table(logXRFInterp) ;
logTable.Properties.RowNames   = header;
logTable.Properties.VariableNames = {'Depth', 'GR', 'Rho', 'Vp', 'Vs', 'ILD', 'Por', 'TOC'};
logDepth = xrfDepth;

% Now we accumulate both XRF and Other Data together
allData = horzcat(logTable, xrfDataUsedTable(:,2:end));
%plotLogData(allData);

%% Interpolate between XRF and meausurments (Log Points)
% xrfDepth = resultsTableVolume.Properties.RowNames;
% xrfDepth = arrayfun(@(x) str2double(x), xrfDepth);
% xrfDepth = xrfDepth + shift;
% xrfData = table2array(resultsTableVolume(:,:)) ;
% 
% xrfDataUsed = interp1(xrfDepth, xrfData, logDepth);
% xrfDataUsedTable = array2table([logDepth, xrfDataUsed]);
% 
% header = cellfun(@(x) num2str(x), num2cell(logDepth), 'UniformOutput',0);
% xrfDataUsedTable.Properties.RowNames   = header;
% xrfDataUsedTable.Properties.VariableNames = ['Depth', mineralToUse, 'MatrixRho'];
% %plotLogData(xrfDataUsedTable);
% 
% allData = horzcat(logTable, xrfDataUsedTable(:,2:end));
% 
% bottomCut = 10;
% allData = allData(1:end-bottomCut,:);
% logDepth = logDepth(1:end-bottomCut,:);

%%
% Minerals
mineralToUse = {'Quartz','Illite_K_Rich', 'Calcite', 'Pyrite', 'Apatite_Br_Rich'};
mineralsFileName = 'Constants\Minerals.csv';
[Minerals] = readtable(mineralsFileName, 'ReadRowNames',true);
parameterNames      =  {'K', 'G', 'Rho'};
mineralsValues = Minerals{mineralToUse, {'K', 'G','Rho'}};
Minerals = array2table(mineralsValues, 'RowNames', mineralToUse, 'VariableNames', parameterNames);
nMinerals = numel(mineralToUse);

% Kerogen
kerogenNames = {'I', 'II', 'III'};
parameterNames ={'K', 'G', 'alpha', 'beta', 'maxPhi'};
kerogenValues(1,:) = [5.5, 3.2, 1.357, 0.58, .71];
kerogenValues(2,:) = [5.5, 3.2, 1.293, 0.20, .43];
kerogenValues(3,:) = [5.5, 3.2, 1.725, 0.10, .12];
Kerogens = array2table(kerogenValues, 'RowNames', kerogenNames, 'VariableNames', parameterNames);
nKerogens = 1;

% Fluid
fluidNames = {'Oil'};
parameterNames ={'K', 'G', 'Rho'};
fluidValues = [1.02, 0, 800];
Fluids = array2table(fluidValues, 'RowNames', fluidNames, 'VariableNames', parameterNames);
nPores = 1;

% Find Ro-TR relationship and optain a TR for an Ro of 1.2
Ro   = 1.2;
maxT = 180;
Ti = 0;
H = 3;
dT = 1;
[t, T] = linearThermalHistory(10, 300, 25, 0.5, true);
A = 15598000000000;
f = [0.7764, 0.026, 0.1799, 0, 0.0176]';
E = [51, 52, 53, 54, 55]';
[t, T] = linearThermalHistory(H, maxT, Ti, dT, true);
[F, TR1, Ro1]= runPyrolysis('Yurchenkoa et al., 2018', 'EasyDL', t,T, A, f, E);
A = 30767000000000;
f = [.8426, 0, .1521, .0053]';
E = [52, 53, 54, 55]';
[t, T] = linearThermalHistory(H, maxT, Ti, dT, true);
[F, TR2, Ro2] = runPyrolysis('Yurchenkoa et al., 2018', 'EasyDL', t,T, A, f, E);
A = 1.338e13;
f = [.8559, .0013, .1255, .0113, .006]';
E = [51, 52, 53, 55, 63]';
[t, T] = linearThermalHistory(H, maxT, Ti, dT, true);
[F, TR3, Ro3] = runPyrolysis('Masterson, 2001', 'EasyDL', t,T, A, f, E);
TR = 0:.001:1;
Ro1Interp =interp1(TR1,Ro1,TR, 'linear', 'extrap');
Ro2Interp =interp1(TR2,Ro2,TR,  'linear', 'extrap');
Ro3Interp =interp1(TR3,Ro3,TR,  'linear', 'extrap');
Ro = (Ro1Interp+Ro2Interp+Ro3Interp)/3;
[F, TRs, Ros] = runPyrolysis(2, 'EasyDL', t,T, A, f, E);
phiTR = interp1(Ro, TR, Ro);


kerogenType = 3;
maxPhi = [.71, .43, .12];
kerogenNames = {'I', 'II','III'};
[PhiKerogen] = kerogenPorosityMaxPhi(phiTR,  maxPhis(kerogenType));
[hcRatio, hcTR] = calcHcRatio(kerogenNames{kerogenType});
density = kerogenRhoFromHC(hcRatio);
rhoK = interp1(hcTR, density, phiTR)*1000;    

rhoM =  allData{:,'MatrixRho'};
rhoF = Fluids{'Oil','Rho'};
rhoB = allData{:,'Rho'};
TOC  =  allData{:,'TOC'};

wtPercKerogen = TOC/.8; % Default: .8
volKerogen = wtPercKerogen/rhoK;
volMatrix = (1-wtPercKerogen)./rhoM;
volPercKerogen = volKerogen ./(volMatrix + volKerogen);

% Second method
% rhoMatrixKerogen = rhoM.*(1-volPercKerogen) + volPercKerogen*rhoK;
% poreFractions    = (rhoB-rhoMatrixKerogen)./(rhoF-rhoMatrixKerogen);
% poreFractions(poreFractions<=0)=.001;
% kerogenFractions = (1-poreFractions).*volPercKerogen;
% matrixFractions = (1-poreFractions).*(1-volPercKerogen);
% matrixFractions = allData{:,mineralToUse} .* matrixFractions;

% First method
poreFractions = allData{:,'Por'};
kerogenFractions = volPercKerogen .* (1 - poreFractions);
nonMatrixFractions = poreFractions + kerogenFractions;
matrixFraction = 1-nonMatrixFractions;
poreFractions = poreFractions - (PhiKerogen .* kerogenFractions);
kerogenFractions = kerogenFractions + (PhiKerogen .* kerogenFractions);
matrixFractions = allData{:,mineralToUse} .* repmat((1 - nonMatrixFractions),1,nMinerals);

% Finalize
FractionsAll = [matrixFractions  kerogenFractions poreFractions]';
fractionCells = mat2cell(FractionsAll,nMinerals + nKerogens + nPores, ones(size(FractionsAll,2),1));

%% Go over Depth
close all

% Initialize output
n = size(FractionsAll,2);
vps = []; vss=[]; vpf=[];vsf=[];e=[];g=[];d=[];
CsRock = {}; rho=[];

% objFun = @(phiAlphaMatrixUnknown) getBestMatrixAspectRatioAll(phiAlphaMatrixUnknown, allData, Kerogens,...
%      Fluids, FractionsAll, poreFractions, Minerals, kerogenFractions);
%  phiAlphaMatrix = fminbnd(objFun,.01,1);

roModel        = 'EasyDL';
kerogenK       = Kerogens{kerogenType,'K'};
kerogenG       = Kerogens{kerogenType,'G'};
kerogenAlpha   = 1; %DEM alpha for kerogen
fluidK         = Fluids{1,'K'};
fluidRho       = Fluids{1,'Rho'};
freqType       = 1;

mineralsK   = Minerals{:,'K'};
mineralsG   = Minerals{:,'G'};
mineralsRho = Minerals{:,'Rho'};

minAverageType = 3;
minAverageTypeMatrix = minAverageType;
minAverageTypeKerogen = 1;
vtiIsoDem = 1;
phiKerogenAlpha = 1;

phiAlphaMatrix  =  0.1681; % Kerogen type =3 (Objective function) Method 2
%phiAlphaMatrix  =  0.13; % Kerogen type =3 (Objective function) Method 1

for i = 1: n

    fractions = FractionsAll(1:5,i);
    fractions = fractions(:) ./ sum(fractions);
    phi = poreFractions(i);
    kerogenPercent = kerogenFractions(i);

   % find best alpha for each point
%    wellIp = allData.Vp(i) .* allData.Rho(i);
%    wellIs = allData.Vs(i) .* allData.Rho(i);
%    objFun = @(phiAlphaMatrixUnknown) getBestMatrixAspectRatio(phiAlphaMatrixUnknown, Ro, kerogenK, kerogenG,...
%    fluidK, fluidRho, alpha, beta, maxPhi, phiKerogenAlpha,freqType,roModel, mineralsK, mineralsG,...
%    mineralsRho, fractions, phi, minAverageType, kerogenPercent, vtiIsoDem, wellIp, wellIs);
%    phiAlphaMatrix = fminbnd(objFun,.01,1);
%    alphas(i) = phiAlphaMatrix;
%    phiAlphaMatrix        

    % Model rock
    [kerogenK, kerogenG, kerogenRho, PhiKerogen, TR]  =  modelKerogenShublik(Ro, kerogenK, kerogenG, ...
    fluidK, fluidRho, nan, nan, nan, phiKerogenAlpha, freqType, roModel);

    [matrixK, matrixG, matrixRho] = modelMatrix(mineralsK, mineralsG, mineralsRho, fractions,...
    fluidK, fluidRho, phi, phiAlphaMatrix, freqType, minAverageTypeMatrix);

    output =  combineMatrixKerogen(matrixK, matrixG, matrixRho,kerogenK, kerogenG,...
       kerogenRho, kerogenPercent, vtiIsoDem, minAverageTypeKerogen,kerogenAlpha);

    % Save results
    vps(i) = output(1);
    vss(i) = output(2);
    rho(i) = output(3);
    if numel(output) > 3
       vpp(i) = output(4);
       vsp(i) = output(5);
       e(i)   = output(6);
       g(i)   = output(7);
       d(i)   = output(8);
    end
   
end

% Bakus Average
win = 3;
[c,rhoB]=bkusrunavg(logDepth,vps,vss,rho,win);

% Get elastic parameters
for i = 1:numel(vps)
[vps(i),vss(i),vpf(i),vsf(i),e(i),g(i),d(i)] = cti2v(c(:,:,i),rho(i));
end


%% Plotting the results

close all

m2f = 3.2808;
dataToPlot1 = [vps*m2f; vss*m2f; rho/1000; vps.*rho/1000*m2f; vss.*rho/1000*m2f]';
dataToPlot2 = [allData.Vp*m2f, allData.Vs*m2f, allData.Rho/1000, allData.Vp.*allData.Rho/1000*m2f, allData.Vs.*allData.Rho/1000*m2f];
logIndex = [1,2,3,4,5,1,2,3,4,5];

spacing = [0, 0, .05, 0,0]; 
width = .16;
styles = {'k','k','k','k','k', '-.r','-.r','-.r','-.r','-.r'};
dataToPlot = [dataToPlot1,dataToPlot2];
titles = {'Vp (f/s)', 'Vs (f/s)', '\rho (g/cc)', 'Ip (f/s \cdot g/cc)', 'Is (f/s \cdot g/cc)'};
[figureHandle, axisHandles] = plotWellLogs(dataToPlot, logDepth,titles, logIndex, [], styles, spacing, width);

% VTI
spacing = [0, 0, 0, 0]; 
logIndex = [1,2,3, 4];
width = .10;
styles = {'k','k','k','k','k', '-.r','-.r','-.r','-.r','-.r'};
dataToPlot = [allData.TOC, e', g', d'];
titles = {'TOC', '\epsilon', '\delta', '\gamma'};
[figureHandle, axisHandles, endX] = plotWellLogs(dataToPlot, logDepth,titles, logIndex, [], styles, spacing, width);

dataToPlot = [ e', g', d'];
titles = {'\epsilon', '\delta', '\gamma'};
pos = [endX+.07, .15, .4, .8];
matrixHandle = subplot('Position', pos);
[S,AX,BigAx,H,HAx] = plotmatrix(dataToPlot, '.k');
for i = 1:numel(titles)
    AX(i,1).YLabel.String = titles{i};
    AX(numel(titles),i).XLabel.String =  titles{i};
    set(H(i), 'FaceColor', 'Black');
end
yticks(AX(3,1), xticks(AX(3,3)))
yticklabels(AX(3,1), get(AX(3,3), 'xticklabels'))


tickFontSize = 12;
for i = 1:numel(AX)
   set(S(i), 'MarkerSize',10)
   set(AX(i), 'Units','normalized', 'FontUnits','points', 'FontWeight','normal', 'FontSize',tickFontSize,'FontName','Times')
end

% Correlation of Ip and Is
tickFontSize = 10;
labelFontSize = 18;
percLocationR = .08;
figureHandle = figure('Color', 'White', 'Units','inches', 'Position',[1 1 9.5 4.2]);

% First Plot
subplot(1,2,1)
scatter(allData.Vp.*allData.Rho/1000*m2f, vps.*rho/1000*m2f, 'k')
box on; axis square;
R = corrcoef(allData.Vp .*allData.Rho,vps .* rho);
xlimits = get(gca, 'XLim'); xRange = diff(xlimits);
ylimits = get(gca, 'YLim'); yRange = diff(ylimits);
maxValue =  max([xlimits(2) ylimits(2)]);
minValue = min([xlimits(1) ylimits(1)]);
limits = [minValue maxValue];
xlim(limits); ylim(limits)

text(limits(1) + percLocationR* diff(limits), limits(2) - percLocationR* diff(limits) ,['R = ', num2str(R(2,1))], 'FontSize', labelFontSize,  'FontName','Times')
line(limits,limits, 'Color', 'k', 'LineWidth', 2)
set(gca, 'Units','normalized', 'FontUnits','points', 'FontWeight','normal', 'FontSize',tickFontSize,'FontName','Times')
ylabel('Modeled Ip (ft/s \cdot g/cc)', 'FontUnits','points', 'FontWeight','normal', 'FontSize',labelFontSize, 'FontName','Times')
xlabel('Measured Ip (ft/s \cdot g/cc)', 'FontUnits','points', 'FontWeight','normal', 'FontSize',labelFontSize, 'FontName','Times')
xticklabels(cellfun(@num2str, num2cell(xticks), 'UniformOutput', false))
yticklabels(cellfun(@num2str, num2cell(yticks), 'UniformOutput', false))

% Second Plot
subplot(1,2,2)
scatter(allData.Vs.*allData.Rho/1000*m2f, vss.*rho/1000*m2f, 'k')
box on; axis square;
R = corrcoef(allData.Vs .* allData.Rho,vss.* rho);
xlimits = get(gca, 'XLim'); xRange = diff(xlimits);
ylimits = get(gca, 'YLim'); yRange = diff(ylimits);

maxValue =  max([xlimits(2) ylimits(2)]);
minValue = min([xlimits(1) ylimits(1)]);
limits = [minValue maxValue];
xlim(limits); ylim(limits)

text(limits(1) + percLocationR* diff(limits), limits(2) - percLocationR* diff(limits) ,['R = ', num2str(R(2,1))], 'FontSize', labelFontSize,  'FontName','Times')
line(limits,limits, 'Color', 'k', 'LineWidth', 2)
set(gca, 'Units','normalized', 'FontUnits','points', 'FontWeight','normal', 'FontSize',tickFontSize,'FontName','Times')
ylabel('Modeled Is (ft/s \cdot g/cc)', 'FontUnits','points', 'FontWeight','normal', 'FontSize',labelFontSize, 'FontName','Times')
xlabel('Measured Is (ft/s \cdot g/cc)', 'FontUnits','points', 'FontWeight','normal', 'FontSize',labelFontSize, 'FontName','Times')

xticklabels(cellfun(@num2str, num2cell(xticks), 'UniformOutput', false))
yticklabels(cellfun(@num2str, num2cell(yticks), 'UniformOutput', false))

%% Sensitivity Analysis

PriorResponses=[allData.Vp,allData.Vs,allData.Rho]; 
DGSA.ParametersValues = allData{:,7:13};
ParametersNames = allData.Properties.VariableNames(7:13);
ParametersNames = {'Porosity', 'TOC', 'xQuartz', 'xIllite', 'xCalcite', 'xPyrite', 'xApatite'};

DGSA.D = pdist(PriorResponses);

DGSA.ParametersNames=ParametersNames;
DGSA.Nbcluster=3; % # of clusters
DGSA.MainEffects.Display.ParetoPlotbyCluster=1; % If true, display main effects by clusters
DGSA.MainEffects.Display.StandardizedSensitivity='Pareto'; 


% Perform clustering. 
DGSA.Clustering=kmedoids(DGSA.D,DGSA.Nbcluster, 10); 

% Compute & Display main effects
DGSA=ComputeMainEffects(DGSA);

%
DGSA.MainEffects.SensitivityStandardized
DGSA.ParametersNames

[mainSens, I] = sort(DGSA.MainEffects.SensitivityStandardized, 'ascend');
lables = categorical(DGSA.ParametersNames(I));
lables = reordercats(lables,DGSA.ParametersNames(I));
isSensitive = DGSA.MainEffects.H0accMain(I);


% Conditional
NbParams = numel(ParametersNames);
DGSA.ConditionalEffects.NbBins=3*ones(1,NbParams); % 3 bins for each parameters
DGSA.ConditionalEffects.Display.SensitivityByClusterAndBins=1; % If true, it shows Pareto plots of conditional effects by bins and clusters 
DGSA.ConditionalEffects.Display.StandardizedSensitivity='Pareto';

% Compute & display conditional effects
DGSA=ComputeConditionalEffects(DGSA);
%DisplayConditionalEffects(DGSA,DGSA.ConditionalEffects.Display.StandardizedSensitivity);

%
conditionalMatrix = zeros(NbParams, NbParams);

DGSA.ConditionalEffects.StandardizedSensitivity
ind = 1;
for i = 1:NbParams
   for j = 1:NbParams
       if i~=j
         conditionalMatrix(j,i) = DGSA.ConditionalEffects.StandardizedSensitivity(ind);
         ind = ind+1;
       else
           conditionalMatrix(j,i) = nan;
       end
   end
end

figure('Color', 'White','Units','inches', 'Position',[0 0 5 3],'PaperPositionMode','auto');
%subplot(1,2,1)
h1 = barh(lables(~isSensitive), mainSens(~isSensitive), 'FaceColor', [.8, .8, .8]);
hold on
h2 = barh(lables(isSensitive), mainSens(isSensitive), 'FaceColor', [7 118 191]/256);
legend([h2 h1], {'Sensitive', 'Not sensitive'}, 'Location', 'SouthEast')
legend boxoff 

labelFontSize = 12;
set(gca, 'FontUnits','points', 'FontWeight','normal', 'FontSize',labelFontSize, 'FontName','Times')

xlabel('Main effect standardized Sensitivity')
set(gca,'TickLength',[0, 0.0])
%set(gca,'yticklabel', lables)

figure('Color', 'White','Units','inches', 'Position',[0 0 5 3],'PaperPositionMode','auto');
h = heatmap(ParametersNames,ParametersNames,conditionalMatrix');
%set(h,'Colormap', flipud(gray))
set(h,'FontName','Times')
xlabel('Conditioned parameter');
ylabel('Conditioning parameter');
colorbar('off')