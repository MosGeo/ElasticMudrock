close all

% NOTE: Requres the Matlab Mapping toolbox

usedProjection = 'lambert';
legendPosition = [0.68 0.23 0.1 .1];
scaleLoction  = [-.19E6, 6.9E6];

% Start figure
figure('Color', 'White', 'Units','inches', 'Position',[1 1 9 6]);
ax = usamap('Alaska');
setm(ax, 'MapProjection', usedProjection)
handles = [];

% Blue ocean
oceanColor = [.5 .7 .9];
setm(ax, 'FFaceColor', oceanColor)

% Draw earth
land = shaperead('landareas', 'UseGeoCoords', true);
geoshow(ax, land, 'FaceColor', [1 1, .5], 'LineStyle', 'none');

% Put state name
alaska = shaperead('usastatehi', 'UseGeoCoords', true,'Selector',{@(name) strcmpi(name,'Alaska'), 'Name'});
geoshow(alaska, 'FaceColor', [1 1, .5], 'LineStyle', 'none')
textm(alaska.LabelLat, alaska.LabelLon, alaska.Name, 'FontSize', 16, 'FontWeight','Bold',...
    'HorizontalAlignment', 'center', 'VerticalAlignment', 'Middle')

% Put BASINS
basins = shaperead('Data - Location\Basins', 'UseGeoCoords', true);
handles(end+1)= geoshow(basins,'EdgeColor', [.2 .2 .2], 'FaceColor', [1 1 1]*.2, 'facealpha',0, 'LineStyle', '-.');

% Put major city
cities = shaperead('Data - Location\mv_cities_pt', 'UseGeoCoords', true);
lats = extractfield(cities,'Lat');
lons = extractfield(cities,'Lon');
names = extractfield(cities,'NAME');
citiesToPlot = {'Prudhoe Bay', 'Anchorage', 'Fairbanks'};
inds = ismember(names, citiesToPlot);
lats = lats(inds);
lons = lons(inds);
names= names(inds);
handles(end+1) = geoshow(lats, lons,'DisplayType', 'point','Marker', 'o','MarkerEdgeColor', 'k','MarkerFaceColor', 'k', 'MarkerSize', 3);
textm(lats, lons, names,'HorizontalAlignment', 'left', 'VerticalAlignment', 'Bottom')

% Put wells
lats = [69.97  69.99059 70.71721944, 70.3363619425, 70.2161417335];
lons = [-148.71 -148.6781, -150.42781944, -148.962711001, -148.409394729];
names = {'Merak-1', 'Alcor-1', 'Phoenix-1', 'PBU M-07 ', ' PBU 12-03'};
color = [.6, 0, .2];

markerSize = 2;
wellFontSize = 7;

i = 2;
handles(end+1) =  geoshow(lats(i), lons(i),'DisplayType', 'point','Marker', '*','MarkerEdgeColor', color,'MarkerFaceColor', color, 'MarkerSize', 6);
textm(lats(i), lons(i), names(i),'HorizontalAlignment', 'Right', 'VerticalAlignment', 'Top', 'Color', color)

i = 3;
handles(end+1) = geoshow(lats(i), lons(i),'DisplayType', 'point','Marker', 'o','MarkerEdgeColor', color,'MarkerFaceColor', color, 'MarkerSize', markerSize)
textm(lats(i), lons(i), names(i),'HorizontalAlignment', 'right', 'VerticalAlignment', 'Bottom', 'Color', color, 'fontsize', wellFontSize)

i = 4;
geoshow(lats(i), lons(i),'DisplayType', 'point','Marker', 'o','MarkerEdgeColor', color,'MarkerFaceColor', color, 'MarkerSize', markerSize)
textm(lats(i), lons(i), names(i),'HorizontalAlignment', 'right', 'VerticalAlignment', 'Middle', 'Color', color,  'fontsize', wellFontSize)

i = 5;
geoshow(lats(i), lons(i),'DisplayType', 'point','Marker', 'o','MarkerEdgeColor', color,'MarkerFaceColor', color, 'MarkerSize', markerSize)
textm(lats(i), lons(i), names(i),'HorizontalAlignment', 'left', 'VerticalAlignment', 'Middle', 'Color', color,  'fontsize', wellFontSize)

% Finalize
tightmap

% Legend
[BL,BLicons] = legend(handles, {'Basin', 'City', 'Studied well', 'Other wells'}, 'Units', 'normalized',...
    'Position', legendPosition);
%legend boxoff              
PatchInLegend = findobj(BLicons, 'type', 'patch');
set(PatchInLegend(1), 'facea', 0*0.1);

% Arrow
northarrow('latitude', 71, 'longitude', -185, 'scaleratio', .05, 'LineWidth', .3);

% Scale
scaleruler on
setm(handlem('scaleruler1'), ...
    'XLoc',scaleLoction(1),'YLoc',scaleLoction(2),...
    'MajorTick',0:200:600,...
    'MinorTick',0:50:200,...
    'MinorTickLabel', {})