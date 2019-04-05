function density = kerogenDensity(Ro, alpha, beta, isPlot)
%% kerogenDensity  Returns estimated kerogen density.
%
% Ro:                       Vitrinite reflectance %Ro
%
% Based on:
%   Alfred, D., and Vernik, L., 2012, A new petrophysical model for organic
%   shales: Petrophysics, v. 54, no. 3, p. 1-15.
%
% Mustafa Al Ibrahim @ 2018
% Mustafa.Geoscientist@outlook.com

%% Preprocess

% Defaults
if ~exist('Ro', 'var');     Ro = .4:.05:2.5; end
if ~exist('alpha', 'var');  alpha = 1.293; end
if ~exist('beta', 'var');   beta = .2; end
if ~exist('isPlot', 'var'); isPlot = false; end

% Assertions
assert(all(isnumeric(Ro)) && all(Ro>=0), 'Ro should be bigger than 0');
assert(isa(isPlot, 'logical'), 'isPlot should be a boolean');
assert(isscalar(alpha) || numel(Ro) == numel(alpha) , 'alpha must be a scalar');
assert(isscalar(beta) || numel(Ro) == numel(beta) , 'beta must be a scalar');
assert(numel(beta) == numel(alpha), 'Number of elements in alpha and beta must be equal');

%% Main

density = alpha .* (Ro .^ beta); 

%% Plotting

if isPlot == true
    figure('Color', 'White', 'Units','inches', 'Position',[3 3 6 3],'PaperPositionMode','auto');
    plot(Ro, density, 'k', 'LineWidth', 2)
   
    labelFontSize = 14;
    tickFontSize = 12;
    xlabel('Vitrinite reflectance %Ro (%)', 'FontUnits','points', 'FontWeight','normal', 'FontSize',labelFontSize,'FontName','Times')
    ylabel('Kerogen density \rho_k (kg/m^3)', 'FontUnits','points', 'FontWeight','normal', 'FontSize',labelFontSize, 'FontName','Times')
    set(gca, 'Units','normalized', 'FontUnits','points', 'FontWeight','normal', 'FontSize',tickFontSize,'FontName','Times')
    axis tight
end
end