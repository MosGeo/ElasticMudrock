clear

% Kerogen properties
maxPhis = [.57, .85; .29, .57; .19, .29];
maxHCLosss   = [.80, .85; .45,.6; .1, .2]; 
initialHCs = [1.59, 1.28, .9]';

% Kerogen Information
xKerogen = .15;
aKerogen = 1;
roKerogen = 1.2;
typeKerogen = 2;
hcKerogen = initialHCs(typeKerogen);

maxPhiKerogen = mean(maxPhis(typeKerogen,:));
maxWtCKerogen = mean(maxHCLosss(typeKerogen,:));

% Matrix porosity
aMatrix    = .1;

% Frequency type
typeFrequency = 1;

% Accumulate input
ParametersNames={'xQuartz','xCalcite','xIllite','xKerogen', 'phiMatrix', 'aKerogen','roKerogen', 'aMatrix', 'typeFrequency', 'maxPhiKerogen', 'maxWtCKerogen'}; % Name of each parameter


%% Mineral, kerogen, and fluid properties

% Minerals
mineralToUse = {'Quartz','Illite_K_Rich', 'Calcite'};
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

fractionsOrig = orderedCompositional(3, .05);
nSamples = size(fractionsOrig,1);

Vp = zeros(nSamples,1);
Vs = zeros(nSamples,1);
Rho = zeros(nSamples,1);

vtiIsoDem = 1;

% Not used
minAverageTypeKerogen = 100;
kerogenAlpha = 1000;

mineralsK = Minerals{:,'K'};
mineralsG = Minerals{:,'G'};
mineralsRho = Minerals{:,'Rho'};
RoType = 'EasyDL';
minAverageTypeMatrix = 3;

fluidK     = Fluids{1,'K'};
fluidRho   = Fluids{1,'Rho'};

phiMatrixs = [0 .1 .2] ;

% Results
for j = 1:numel(phiMatrixs)
    
    phiMatrix  = phiMatrixs(j);

    % Minerals
    x = fractionsOrig*(1-phiMatrix-xKerogen);
    xMinerals = fractionsOrig;
    
    allInputNoX = repmat([aKerogen, roKerogen, aMatrix, double(typeFrequency), maxPhiKerogen, maxWtCKerogen],[nSamples,1]);
    allInput = [x, allInputNoX];

for i = 1:nSamples
    
    % Parameters
    kerogenK   = Kerogens{typeKerogen,'K'};
    kerogenG   = Kerogens{typeKerogen,'G'};
    Ro         = roKerogen;
    freqType   = typeFrequency;
    phiKerogenAlpha  = aKerogen;
    maxPhi     = maxPhiKerogen;
    maxWtPerCarbonLoss = maxWtCKerogen;
    kerogenType = typeKerogen;
    initialHC = hcKerogen;
    fractions = xMinerals(i,:);
    phi = phiMatrix;
    phiAlphaMatrix = aMatrix; 
    kerogenPercent = xKerogen;

    % Model kerogen
    [kerogenK, kerogenG, kerogenRho, PhiKerogen, TR]  = modelKerogen(Ro, kerogenK, kerogenG, ...
        fluidK, fluidRho, phiKerogenAlpha, freqType, kerogenType, RoType, maxPhi, maxWtPerCarbonLoss, initialHC);
   
    [matrixK, matrixG, matrixRho] = modelMatrix(mineralsK, mineralsG, mineralsRho, fractions,...
        fluidK, fluidRho, phi, phiAlphaMatrix, freqType, minAverageTypeMatrix);

    output =  combineMatrixKerogen(matrixK, matrixG, matrixRho,kerogenK, kerogenG,...
       kerogenRho, kerogenPercent, vtiIsoDem, minAverageTypeKerogen,kerogenAlpha);

    % Save outputs
    Vp(i) = output(1);
    Vs(i) = output(2);
    Rho(i) = output(3);
end

Results{j} = [Vp, Vs, Rho];

end

%% Plotting

dataToPlot = [];
for j  =1:numel(Results)
    res = Results{j};
    Vp = res(:,1);
    dataToPlot = [dataToPlot, Vp];
end
names = {'Vp_{slow} (m/s)', 'Vp_{slow} (m/s)', 'Vp_{slow} (m/s)'};
nPlots = size(dataToPlot,2);

figure('Color', 'White', 'Units','inches', 'Position',[2 2 5*nPlots 5],'PaperPositionMode','auto');
for iPlot = 1:nPlots
    
subplot(1,nPlots,iPlot)
ht = ternsurf(xMinerals(:,1), xMinerals(:,2), dataToPlot(:,iPlot));
ht.FaceColor = 'interp';
hv = vertexlabel('Illite', 'Calcite', 'Quartz', .01);
for i = 1:3
   set(hv(i), 'FontName', 'Times', 'FontSize', 13); 
end
view(0, 90);
hc = colorbar;
hc.Location = 'southoutside';
xlabel(hc,names{iPlot})
hc.FontName = 'Times';
hc.FontSize = 10;
%caxis([2750, 3200]);
title(['\phi_m= ' num2str(phiMatrixs(iPlot))])

end

