clear all
% Define parameters

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

%%

% Kerogen parameters
typeKerogenNames = {'I', 'II', 'III'};
maxPhis = [.71, .43, .12];
maxWtPerCarbonLosses = [.75, .45, .15];
initialHCs = [1.59, 1.28, .9];
xKer = 0:.005:.25;

% Plotting parameters
lineStyles = {'-', '--', '-.', ':', '-', '--', '-.', ':', '-', '--', '-.', ':'};
legendText = [];


f1 = figure('Color', 'White', 'Units','inches', 'Position',[3 3 14 3],'PaperPositionMode','auto');

for k = 1:3
eps = [];
gamma = [];
delta = [];
for j = 1:numel(xKer)
    
    % Define paramters
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
    phiAlphaMatrix = .1;
    minAverageTypeMatrix = 3;
    kerogenPercent = xKer(j);
    vtiIsoDem = 1;
    minAverageTypeKerogen = nan;
    kerogenAlpha = nan;
    mineralPercent = 1-kerogenPercent-phi;
    fractions = [mineralPercent/2, mineralPercent/2, 0, 0 , 0];
    
    % Model rock
    [vp2, vs2, d2, output] = modelOrganicRichRock(Ro, kerogenK, kerogenG, ...
     fluidK, fluidRho, maxPhi, phiKerogenAlpha, freqType, roModel, kerogenType, maxWtPerCarbonLoss, initialHC,...
     mineralsK, mineralsG, mineralsRho, fractions, phi,phiAlphaMatrix, ...
     minAverageTypeMatrix,  kerogenPercent, vtiIsoDem, minAverageTypeKerogen,...
     kerogenAlpha);
     
    % store needed results
    output = num2cell(output);  % For deconstruction below
    [vps, vss, rho,vpf,vsf, eps(j), gamma(j), delta(j)] = output{:};

end

% Plot curves
subplot(1,3,1)
plot(xKer, eps, lineStyles{k}, 'LineWidth', 2); hold on

subplot(1,3,2)
plot(xKer, gamma,lineStyles{k},  'LineWidth', 2); hold on

subplot(1,3,3)
plot(xKer, delta,lineStyles{k},  'LineWidth', 2); hold on

% For legend
legendText{k} = ['Type ', kerogenNames{k}];

end

% Finalize figure
names =  {'\epsilon', '\gamma', '\delta'};
for i = 1:3
subplot(1,3,i)
labelFontSize = 14;
tickFontSize = 12;
legend(legendText, 'Location', 'Best')
ylabel(names{i}, 'FontUnits','points', 'FontWeight','normal', 'FontSize',labelFontSize,'FontName','Times')
xlabel({'Kerogen proportion (fraction)'}, 'FontUnits','points', 'FontWeight','normal', 'FontSize',labelFontSize, 'FontName','Times')
set(gca, 'Units','normalized', 'FontUnits','points', 'FontWeight','normal', 'FontSize',tickFontSize,'FontName','Times')
end