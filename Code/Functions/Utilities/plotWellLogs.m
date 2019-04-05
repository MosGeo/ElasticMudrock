function [figureHandle, axisHandles, endX] = plotWellLogs(wellLogs, depth,titles, logIndex, logScale, styles, spacing, width, height)
%% PLOTWELLlOGS         Plots publishable well logs 
%
% wellLogs:                     Matrix containing well logs data
% depthLogIndex:                Log Index (depth = 0)
% logScale:                     Indecies of log scale
% logs title:                   Logs titles
% axisSeperationDistance
%
%
% Mustafa Al Ibrahim @ 2018
% Mustafa.Geoscientist@outlook.com

%% Preprocessing

% Defaults 1
if ~exist('logScale', 'var'); logScale= []; end
if ~exist('axisSeperationDistance', 'var'); axisSeperationDistance= .1; end
if ~exist('nExtraSubplots', 'var'); nExtraSubplots= 0; end
if ~exist('styles', 'var'); styles = repmat({'k'}, [size(wellLogs,2),1]); end
if ~exist('height', 'var'); height = .8; end

% Assertions 1
assert(isnumeric(wellLogs), 'wellLogs has to be numeric');
assert(isnumeric(logScale), 'logScale has to be numeric');
assert(all(mod(logScale,1)==0), 'logScale has to be integers');
assert(all(logScale<= size(wellLogs,2)), 'All values in logScale has to be smaller than the number of columns in wellLogs');
assert(isscalar(axisSeperationDistance) && axisSeperationDistance>=0, 'axisSeperationDistance has to be scaler >=0');
assert(isscalar(nExtraSubplots) && nExtraSubplots>=0, 'nExtraSubplots has to be scaler >=0');

% Defaults 2
if ~exist('logIndex', 'var'), logIndex = (1:size(wellLogs,2))'; end

% Assertions 2
assert(numel(logIndex) == size(wellLogs,2), 'logIndex has to have elements equal to the number of columns in wellLogs');
assert(all(mod(logIndex,1)==0) && all(logIndex>=0), 'logIndex has to be >=0');

%% Main


% Get number of points
nSamples = size(wellLogs,1);
nWellLogs = size(wellLogs,2);

logScale01 = zeros(size(wellLogs,2),1);
logScale01(logScale) = 1; 

% Define depth vector
if isempty(depth)
    depth = fliplr((1:nSamples)');
end

if isempty(titles)
    numbers= cellfun(@num2str, num2cell(1:max(logIndex)), 'UniformOutput', false);
    titles = cellfun(@(x) ['Var ' x], numbers, 'UniformOutput', false);
end


%% Plotting

nSubplots = max(logIndex) + nExtraSubplots;

tickFontSize = 8;
labelFontSize = 14;

startX = .08;

% Intitialize figure
figureHandle = figure('Color', 'White', 'Units','inches', 'Position',[1 1 10.2 4]);
set(gcf, 'Units', 'normalized')

axisHandles = zeros(nSubplots,1);
for iAxis = 1:nSubplots
    
    pos = [startX .15 width height];
    
    startX = startX + width + spacing(iAxis);
    
    axisHandles(iAxis) = subplot('Position', pos);
end

endX = startX;

% Plot things
for iLog = 1:nWellLogs
    index = logIndex(iLog);
    welllog = wellLogs(:,iLog);
    isLogarithmic = logScale01(iLog);
    axes(axisHandles(index))
    if ~isLogarithmic
        plot(welllog,depth, styles{iLog}, 'LineWidth', 2); hold on;
        xLimits = xlim;
        xRanage = diff(xLimits);
        xt = [xLimits(1) + xRanage/4, xLimits(2) - xRanage/4];
        xlim(xLimits)

    
    else
        semilogx(welllog,depth, styles{iLog}, 'LineWidth', 2); hold on;
        xLimits = log10(xlim);
        xRanage = diff(xLimits);
        
        xt = 10.^[xLimits(1) + xRanage/4, xLimits(2) - xRanage/4];

    end
    xticks(xt);
    xticklabels(cellfun(@num2str, num2cell(xticks), 'UniformOutput', false)) 
    
end


for iAxis = 1:nSubplots
    axes(axisHandles(iAxis));
    set(gca, 'Units','normalized', 'FontUnits','points', 'FontWeight','normal', 'FontSize',tickFontSize,'FontName','Times')
    xlabel(titles{iAxis}, 'FontWeight','normal', 'FontSize',labelFontSize, 'FontName','Times')
    if iAxis>1
       set(gca, 'yTickLabels', [])
    end
    
    
    ylim([min(depth) max(depth)])
    
    
    set(gca,'Ydir','reverse')
end

axes(axisHandles(1))

yt = yticks;
yticklabels(cellfun(@num2str, num2cell(yt), 'UniformOutput', false))

ylabel('Depth (ft)', 'FontUnits','points', 'FontWeight','normal', 'FontSize',labelFontSize, 'FontName','Times')

set(gcf, 'Color', 'White', 'Units','inches', 'Position',[1 1 9.5 4]);


end