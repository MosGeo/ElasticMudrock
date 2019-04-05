close all

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
phiMatrix  = .15;
aMatrix    = .1;

% Minerals
fractions = orderedCompositional(3, .05);
x = fractions*(1-phiMatrix-xKerogen);
xMinerals  = fractions;

% Frequency type
typeFrequency = 1;

% Accumulate input
nSamples = size(x,1);
ParametersNames={'xQuartz','xCalcite','xIllite','xKerogen', 'phiMatrix', 'aKerogen','roKerogen', 'aMatrix', 'typeFrequency', 'maxPhiKerogen', 'maxWtCKerogen'}; % Name of each parameter
allInputNoX = repmat([aKerogen, roKerogen, aMatrix, double(typeFrequency), maxPhiKerogen, maxWtCKerogen],[nSamples,1]);
allInput = [x, allInputNoX];

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

% Outputs
Vp = zeros(nSamples,1);
Vs = zeros(nSamples,1);
Rho = zeros(nSamples,1);

% Parameters (use VTI)
vtiIsoDem = 1;

% Not used
minAverageTypeKerogen = 100;
kerogenAlpha = 1000;

% Properties
mineralsK = Minerals{:,'K'};
mineralsG = Minerals{:,'G'};
mineralsRho = Minerals{:,'Rho'};
RoType = 'EasyDL';
minAverageTypeMatrix = 3;
fluidK     = Fluids{1,'K'};
fluidRho   = Fluids{1,'Rho'};

for i = 1:nSamples
    
    kerogenK   = Kerogens{typeKerogen,'K'};
    kerogenG   = Kerogens{typeKerogen,'G'};
    Ro         = roKerogen;
    freqType   = typeFrequency;
    phiKerogenAlpha   = aKerogen;
    maxPhi     = maxPhiKerogen;
    maxWtPerCarbonLoss = maxWtCKerogen;
    kerogenType = typeKerogen;
    initialHC = hcKerogen;
    
    fractions = xMinerals(i,:);
    phi = phiMatrix;
    phiAlphaMatrix = aMatrix; 
    kerogenPercent = xKerogen;

    % Model rock
   [kerogenK, kerogenG, kerogenRho, PhiKerogen, TR]  = modelKerogen(Ro, kerogenK, kerogenG, ...
        fluidK, fluidRho, phiKerogenAlpha, freqType, kerogenType, RoType, maxPhi, maxWtPerCarbonLoss, initialHC);
   
   [matrixK, matrixG, matrixRho] = modelMatrix(mineralsK, mineralsG, mineralsRho, fractions,...
        fluidK, fluidRho, phi, phiAlphaMatrix, freqType, minAverageTypeMatrix);

   output =  combineMatrixKerogen(matrixK, matrixG, matrixRho,kerogenK, kerogenG,...
       kerogenRho, kerogenPercent, vtiIsoDem, minAverageTypeKerogen,kerogenAlpha);

   % Store results
   Vp(i) = output(1);
   Vs(i) = output(2);
   Rho(i) = output(3);
end

%% Plotting
dataToPlot = [Vp, Vs, Rho];
names = {'Vp_{slow} (m/s)', 'Vs_{slow} (m/s)', 'Density (kg/m^3)'};
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

end

