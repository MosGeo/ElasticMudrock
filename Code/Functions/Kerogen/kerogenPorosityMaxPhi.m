function [PhiKerogen, TR] = kerogenPorosityMaxPhi(TR, maxPhi, isPlot)
%% KEROGENPOROSITY  Returns estimated kerogen porosity.
%
% TR:                       Tranformation ratio (0-1)
% maxPhi:                   Maximum pore fraction (0-1)
%
% Based on:
%   Modica, C. J., and Lapierre, S. G., Estimation of kerogen kerogen 
%   porosity in source rocks as a function of thermal transformation: AAPG
%   Bulletin, v. 96, no. 1, p. 87-108.
%
% Mustafa Al Ibrahim @ 2018
% Mustafa.Geoscientist@outlook.com

%% Preprocessing

% Defaults based on Modica and Lapierre (2012) with Type II
if exist('TR', 'var') == false; TR = 0:.01:1; end
if exist('maxPhi', 'var') == false; maxPhi = .4; end
if exist('isPlot', 'var') == false; isPlot = false; end

% Assertions
assert(all(isnumeric(TR)) && all(TR>=0 & TR<=1), 'TR should be between 0 and 1');
assert(isscalar(maxPhi) && maxPhi>=0 && maxPhi<=1, 'maxPhi should be 0-1');
assert(isa(isPlot, 'logical'), 'isPlot should be a boolean');

%% Main

PhiKerogen =  maxPhi*TR;

%% Plotting

if isPlot == true
    figure('Color', 'White', 'Units','inches', 'Position',[3 3 6 3],'PaperPositionMode','auto');
    plot(TR, PhiKerogen, 'k', 'LineWidth', 2)
   
    labelFontSize = 14;
    tickFontSize = 12;
    xlabel({'Transformation ratio TR (%)'}, 'FontUnits','points', 'FontWeight','normal', 'FontSize',labelFontSize,'FontName','Times')
    ylabel({'Kerogen porosity (fraction)'}, 'FontUnits','points', 'FontWeight','normal', 'FontSize',labelFontSize, 'FontName','Times')
    set(gca, 'Units','normalized', 'FontUnits','points', 'FontWeight','normal', 'FontSize',tickFontSize,'FontName','Times')
end

end