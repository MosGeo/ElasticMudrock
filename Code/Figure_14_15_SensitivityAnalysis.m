%% Monte Carlo Sampling
clear
nSamples = 5000;
rng(281)

maxPhis = [.57, .85; .29, .57; .19, .29];
maxHCLosss   = [.80, .85; .45,.6; .1, .2]; 
initialHCs = [1.59, 1.28, .9]';

% Sample proportions
nComponents = 7;
x = randCompositional(nComponents, nSamples, [1, 1, 1, .3, .3, .2 .2], false);

% Kerogen
xKerogen    = x(:,6);
aKerogen    = randInterval(nSamples, 1e-2, 1, true); 
roKerogen   = randInterval(nSamples, .4, 1.2);
typeKerogen = randCategorical(nSamples, 3);
hcKerogen   =  initialHCs(typeKerogen);

maxPhiKerogen = zeros(nSamples,1);
maxWtCKerogen = zeros(nSamples,1);
for i = 1:nSamples
    maxPhiKerogen(i) = randInterval(1, maxPhis(typeKerogen(i),1), maxPhis(typeKerogen(i),2));
    maxWtCKerogen(i) = randInterval(1, maxHCLosss(typeKerogen(i),1), maxHCLosss(typeKerogen(i),2));
end

% Matrix
xQuartz    = x(:,1);
xCalcite   = x(:,2);
xIllite    = x(:,3);
xPyrite    = x(:,4);
xApatite   = x(:,5);
xMinerals  = x(:,1:5)./sum(x(:,1:5),2);

% Matrix Pores
phiMatrix  = x(:,7);
aMatrix    = randInterval(nSamples, 1e-2, 1, true); 

% Model
typeFrequency  = randLogical(nSamples);

% clear x nComponents;
ParametersNames={'xQuartz','xCalcite','xIllite', 'xPyrite', 'xApatite','xKerogen', 'phiMatrix', 'aKerogen','roKerogen', 'aMatrix', 'typeFrequency', 'maxPhiKerogen', 'maxWtCKerogen'}; % Name of each parameter
allInput = [x, aKerogen, roKerogen, aMatrix, double(typeFrequency), maxPhiKerogen, maxWtCKerogen];

%% Mineral, kerogen, and fluid properties

% Minerals
mineralToUse = {'Quartz','Illite_K_Rich', 'Calcite', 'Pyrite', 'Apatite_Br_Rich'};
mineralsFileName = 'Constants\Minerals.csv';
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

%% Run samples

Vp = zeros(nSamples,1);
Vs = zeros(nSamples,1);
Rho = zeros(nSamples,1);

vtiIsoDem = 1;
minAverageTypeKerogen = 100; % Not used
kerogenAlpha = 1000; % Note used

mineralsK = Minerals{:,'K'};
mineralsG = Minerals{:,'G'};
mineralsRho = Minerals{:,'Rho'};
RoType = 'EasyDL';
minAverageTypeMatrix = 3;

fluidK     = Fluids{1,'K'};
fluidRho   = Fluids{1,'Rho'};

for i = 1:nSamples
    
    %disp(i)
    kerogenK   = Kerogens{typeKerogen(i),'K'};
    kerogenG   = Kerogens{typeKerogen(i),'G'};
    
    Ro         = roKerogen(i);
    freqType   = typeFrequency(i);
    phiKerogenAlpha   = aKerogen(i);
    maxPhi     = maxPhiKerogen(i);
    maxWtPerCarbonLoss = maxWtCKerogen(i);
    kerogenType = typeKerogen(i);
    initialHC = hcKerogen(i);
    
    fractions = xMinerals(i,:)';
    phi = phiMatrix(i);
    phiAlphaMatrix = aMatrix(i); 
    kerogenPercent = xKerogen(i);

   [kerogenK, kerogenG, kerogenRho, PhiKerogen, TR]  = modelKerogen(Ro, kerogenK, kerogenG, ...
        fluidK, fluidRho, phiKerogenAlpha, freqType, kerogenType, RoType, maxPhi, maxWtPerCarbonLoss, initialHC);
   
   [matrixK, matrixG, matrixRho] = modelMatrix(mineralsK, mineralsG, mineralsRho, fractions,...
        fluidK, fluidRho, phi, phiAlphaMatrix, freqType, minAverageTypeMatrix);

   output =  combineMatrixKerogen(matrixK, matrixG, matrixRho,kerogenK, kerogenG,...
       kerogenRho, kerogenPercent, vtiIsoDem, minAverageTypeKerogen,kerogenAlpha);

   Vp(i) = output(1);
   Vs(i) = output(2);
   Rho(i) = output(3);
end
%%

imagPart = imag(Vp);
badApples = imag(Vp)>0 | isnan(Vp);  
toSelect = find(~badApples);
VpUsed = real(Vp(toSelect));
VsUsed = real(Vs(toSelect));
RhoUsed = real(Rho(toSelect));
AllInputUsed = allInput(toSelect,:);

%%

PriorResponses=[VpUsed,VsUsed,RhoUsed]; 
DGSA.ParametersValues = AllInputUsed;

%DGSA.ParametersValues = DGSA.ParametersValues(1:3000,:);
%PriorResponses = PriorResponses(1:3000,:);

DGSA.D=pdist(PriorResponses);

DGSA.ParametersNames=ParametersNames;
DGSA.Nbcluster=3; % # of clusters
DGSA.MainEffects.Display.ParetoPlotbyCluster=1; % If true, display main effects by clusters
DGSA.MainEffects.Display.StandardizedSensitivity='Pareto'; 

% Perform clustering. 
DGSA.Clustering=kmedoids(DGSA.D,DGSA.Nbcluster,10); 

% Compute & Display main effects
DGSA=ComputeMainEffects(DGSA);

%%
DGSA.MainEffects.SensitivityStandardized
DGSA.ParametersNames

[mainSens, I] = sort(DGSA.MainEffects.SensitivityStandardized, 'ascend');
lables = categorical(DGSA.ParametersNames(I));
lables = reordercats(lables,DGSA.ParametersNames(I));
isSensitive = DGSA.MainEffects.H0accMain(I);

figure('Color', 'White')
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

%% Conditional
NbParams = numel(ParametersNames);
DGSA.ConditionalEffects.NbBins=3*ones(1,NbParams); % 3 bins for each parameters
DGSA.ConditionalEffects.Display.SensitivityByClusterAndBins=1; % If true, it shows Pareto plots of conditional effects by bins and clusters 
DGSA.ConditionalEffects.Display.StandardizedSensitivity='Pareto';

% Compute & display conditional effects
DGSA=ComputeConditionalEffects(DGSA);
%DisplayConditionalEffects(DGSA,DGSA.ConditionalEffects.Display.StandardizedSensitivity);
DGSA.ConditionalEffects.Names_ConditionalEffects
%% Plot matrix format

conditionalMatrix = zeros(NbParams, NbParams);
DGSA.ConditionalEffects.StandardizedSensitivity
ind = 1;
for i = 1:NbParams
   for j = 1:NbParams
       if i~=j
         conditionalMatrix(j,i) = DGSA.ConditionalEffects.StandardizedSensitivity(ind);
         ind = ind+1;
       else
           conditionalMatrix(i,j) = nan;
       end
   end
end

figure('Color', 'White')
h = heatmap(ParametersNames,ParametersNames,conditionalMatrix); %, 'Colormap', flipud(gray));
set(gca,'FontName','Times')
xlabel('Conditioned paramter')
ylabel('Conditioning paramter')


