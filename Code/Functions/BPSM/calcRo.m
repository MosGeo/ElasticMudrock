function [Ro, F, TR] = calcRo(RoType, t, T, isApprox, isPlot)
% CALCRO Calculates the expected vitrinite refleactance based on on a
%        constant heating rate.
%
% TR:                       Tranformation ratio
% isPlot:                   Plot the results?

% Based on:
%   1. Sweeny, J. J., and Burnham, A. K., 1990, Evaluation of simple model 
%      of vitrinite reflectance based on chemical kinetics: AAPG Bulletin, 
%      v. 74, no. 10, p. 1559-1570.
%   2. Schenk, O., K. Bird, K. Peters, and A. Burnham, 2017, Sensitivity 
%      Analysis of Thermal Maturation of Alaska North Slope Source Rocks 
%      Based on Various Vitrinite Reflectance Models, in AAPG/SEG International 
%      Conference and Exhibition.
%   3. Nielsen, S. B., O. R. Clausen, and E. McGregor, 2017, basin%Ro: A 
%      vitrinite reflectance model derived from basin and laboratory data: 
%      Basin Research, v. 29, p. 515–536, doi:10.1111/bre.12160.
%
% Mustafa Al Ibrahim @ 2018
% Mustafa.Geoscientist@outlook.com

%% Preprocessing

% Defaults
if ~exist('isPlot', 'var'); isPlot = false; end
if ~exist('isApprox','var'); isApprox = false; end

% Assertions
assert(isa(isPlot, 'logical'), 'isPlot should be a boolean');
assert(isa(isApprox, 'logical'), 'isApprox should be a boolean');

%% Data

switch lower(RoType)
    case 'easy'
        alpha = 1.6;
        beta  = 3.7; 
        A = 1.0e13;   % Frequency Factor [/sec] 
        f = [.03, .03, .04, .04, .05, .05, .06, .04, .04, .07, .06, .06, .06, ...
            .05, .05, .04, .03, .02, .02, .01]'; 
        E = [34,36,38,40,42,44,46,48,50,52,54,56,58,60,62,64,66,68,70,72]';
    case 'easydl'
        alpha = 1.5;
        beta  = 3.7; 
        A =  2.0e14;   % Frequency Factor [/sec] 
        f = [0.02,0.03,0.04,0.05,0.04,0.04,0.03,0.04,0.07,0.1,0.09,0.07,0.06,...
            0.05,0.05,0.04,0.04,0.03,0.03,0.03]';
        E = [38,40,42,44,46,48,50,52,54,56,58,60,62,64,66,68,70,72,74,76]';
    case 'basin'
        alpha = 1.5;
        beta  = 3.7; 
        A = exp(60.9856)/(1000000*365.25*24*3600);
        f = [0.0185,0.0143,0.0569,0.0478,0.0497,0.0344,0.0344,0.0322,0.0282,...
            0.0062,0.1155,0.1041,0.1023,0.076,0.0593,0.0512,0.0477,0.0086,0.0246,0.0096]';
        E = [34,36,38,40,42,44,46,48,50,52,54,56,58,60,62,64,66,68,70,72]';
end

%% Main

if (isApprox)
    [TR, F] = arrheniusFast(t, T, A, E, f);
else
    [TR, F] = arrhenius(t, T, A, E, f);
end

Ro = exp(-alpha + beta * TR * sum(f));

%% Plotting
if isPlot == true
    figure('Color', 'White', 'Units','inches', 'Position',[3 3 10 3.5],'PaperPositionMode','auto');
    
    subplot(1,2,1)
    plot(TR, Ro, 'k', 'LineWidth', 2); hold on;
    xlabel('Vitrinite tranformation ratio');
    ylabel('Calculated vitrinite reflectance');
    
    subplot(1,2,2)
    plot(T, TR, 'k', 'LineWidth', 2)
    xlabel('Temperature (C)');
    ylabel('Calculated vitrinite reflectance');
    
end

end