clear all

dataFolder = 'Data - Well';
wellName = 'Alcor1';
shift = -2;

% Load and convert
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

% Plotting
close all
depthXRF = cellfun(@str2num, inputTable.Properties.RowNames) + shift;
inputData = inputTable{:,:};
outputData = resultsTableVolume{:,1:end-1};
outputData = resultsTable{:,:};

dataToPlot1 = inputData;
dataToPlot2 = outputData;
dataToPlot = [dataToPlot1,dataToPlot2];
nCols = size(dataToPlot,2);
logIndex = 1:nCols;
spacing = [0, 0 , 0, 0, 0, 0,.05, 0, 0, 0 ,0,0,0];
width = .07;
height = .7;
styles = repmat({'k'}, [nCols,1]);
mineralToUse = {'Quartz','Illite', 'Calcite', 'Pyrite', 'Apatite'};
titles = [elementsToUse, mineralToUse];
[figureHandle, axisHandles] = plotWellLogs(dataToPlot, depthXRF,titles, logIndex, [], styles, spacing, width, height);

% Plotting XRD
dataFileName = fullfile(dataFolder, ['XRD', '_' wellName, '.csv']);
[Data] = readtable(dataFileName, 'ReadRowNames',true);
Data{:,:} = Data{:,:}./sum(Data{:,:},2);
depthXRD= cellfun(@str2num, Data.Properties.RowNames) + shift;
selectedDepth = depthXRD>= min(depthXRF) &  depthXRD<= max(depthXRF);
depthXRD = depthXRD(selectedDepth);
Data = Data(selectedDepth,:);
axisToUse = axisHandles(end-numel(mineralToUse)+1:end);
for i = 1:numel(axisToUse)
    axes(axisToUse(i)); hold on;
    s = scatter(Data{:,i}, depthXRD, 15, 'filled');
    s.MarkerFaceColor = [1, 0, 0];
end

pos = [0, .9, 1, .1];
titleAxis = subplot('Position', pos);
titleAxis.YAxis.Visible = 'off';   % remove y-axis
titleAxis.XAxis.Visible = 'off';   % remove x-axis
text(.325*pos(3), .1, 'XRF elemental proportions (%)', 'HorizontalAlignment' ,'center', 'FontSize', 16, 'FontName', 'Times')
text(.79*pos(3), .1, 'Inverted mineralogy (%)', 'HorizontalAlignment' ,'center', 'FontSize', 16, 'FontName', 'Times')
