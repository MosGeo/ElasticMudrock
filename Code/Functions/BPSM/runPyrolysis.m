function [F, TR, Ro] = runPyrolysis(kerogenType, RoType, t, T, A, f, E, isApprox, isPlot)
% RUNPYROLYSIS Runs a pyrolysis simulation
%
% type:                     Kerogen type
%
% Mustafa Al Ibrahim @ 2018
% Mustafa.Geoscientist@outlook.com

%% Preprocessing

% Defaults
if ~exist('isPlot', 'var'); isPlot = false; end
if ~exist('RoType', 'var'); RoType = 'Easy'; end
if ~exist('isApprox','var'); isApprox = false; end

% Assertions
assert(isa(isPlot, 'logical'), 'isPlot should be a boolean');
assert(isa(isApprox, 'logical'), 'isApprox should be a boolean');

%% Data (Baher et al., 1997)

% Component names as defined by the paper
componentNames = {'C1', 'C2-C5', 'C6-C14', 'C15+'};
kerogenTypes = {'I', 'II', 'II-S', 'IIIM', 'IIIN'};
kerogenNames = {'Type I', 'Type II', 'Type II-S', 'Type III Mahakam', 'Type III North Sea'};

switch kerogenType
    case 'I'
        A = 7.4E13;  % A: Frequency Factor [/sec]
        f = [0,0,0,0;0,0,0,0;0,0,0,0;0,0,0,0;0.4,3.5,8.1,0;6.3,68.6,83,738.7;...
            3.1,0,0,0;2,0,0,0;1.6,0,0,0;1.3,0,0,0;1.3,0,0,0;0.4,0,0,0;...
            0,0,0,0;0,0,0,0;0,0,0,0;0,0,0,0];      
        % E: Activation energy [kcal/mole]
        E = [44, 46, 48, 50, 52, 54, 56, 58, 60, 62, 64, 66, 68, 70, 72 ,74]';
            
    case 'II'
        A = 1.6E14;
        f = [0,0,0,0;0,0.1,0.6,0.7;0.3,0.8,3.1,6.5;0.9,4.6,7.9,53.9;...
            2,12.1,14.1,157.3;2.9,12.4,20.2,250.4;2.9,11.3,7.3,7.4;...
            3.6,4.6,0.4,1.4;2.5,2,0,0;2,1.2,0,0;1.4,0.7,0,0;0.3,0.3,0,0;...
            0,0.1,0,0;0,0,0,0;0,0,0,0;0,0,0,0];
        E = [44, 46, 48, 50, 52, 54, 56, 58, 60, 62, 64, 66, 68, 70, 72 ,74]';

    case 'II-S'
        A = 2.5E13;
        f = [0.3,0.5,2.7,5.2;1.1,2.8,7.8,46;1.8,9.4,24.5,151.4;2.1,6.9,20.6,158.7;...
            2.1,11.8,23.6,39.1;3.8,8.5,3.7,6.6;4.9,2.4,0,0;4.2,1.3,0,0;....
            4.6,0.3,0,0;0.9,0,0,0;0.5,0,0,0;0.1,0,0,0;0,0,0,0;0,0,0,0;0,0,0,0;...
            0,0,0,0];
        E = [44, 46, 48, 50, 52, 54, 56, 58, 60, 62, 64, 66, 68, 70, 72 ,74]';

    case 'IIIM'
        A = 3E15;
        f = [0,0,0,0;0,0,0,0;0,0,0,0;0,0.2,0,1.6;0,0.5,0.4,3.3;0.3,1.1,1.5,7.9;...
            0.9,3,2.6,33.3;2,5.3,7.8,40.8;3.5,6.7,5.1,20.5;4.4,3.9,3.5,6.6;...
            5,1.6,1.4,2.1;5,0.9,0.7,0.4;4.8,0.4,0,0;4,0,0,0;0.7,0,0,0;0,0,0,0];
        E = [44, 46, 48, 50, 52, 54, 56, 58, 60, 62, 64, 66, 68, 70, 72 ,74]';

    case 'IIIN'
        A = 3.1E15;
        f = [0,0,0,0;0,0,0,0;0,0,0,0;0,0,0,0;0,0,0,0;0,0,0.4,0.8;0.1,0.4,1.2,24.8;...
            1,3,4.2,72.6;2.9,6.2,7.4,30.7;4,6.5,3.8,7.1;4.8,4.7,0.3,1.6;4.9,2.5,0,0;...
            4.2,1.2,0,0;4.1,1.5,0,0;3.9,0.2,0,0;1,0,0,0];
        E = [44, 46, 48, 50, 52, 54, 56, 58, 60, 62, 64, 66, 68, 70, 72 ,74]';
    otherwise
        componentNames = {};
        for i = 1:size(f,2)
            componentNames{i} = ['Comp ' num2str(i)];
        end
end

%% Main

Ro = calcRo(RoType, t, T);

if (isApprox)
    [TR, F] = arrheniusFast(t, T, A, E, f);
else
    [TR, F] = arrhenius(t, T, A, E, f);
end

%% Plotting
if isPlot == true
    
    figure('Color', 'White')
    plot(T, TR, 'LineWidth', 2)
    xlabel('Temperature (C)')
    ylabel('Transformation ratio')
    
    figure('Color', 'White')
    plot(TR, Ro, 'LineWidth', 2)
    xlabel('Tranformation ratio')
    ylabel('Calculated %Ro')
    
    figure('Color', 'White')
    %F = bsxfun(@rdivide, F, sum(F,2));
    area(TR,F)
    %ylim([0,1])
    legend(componentNames, 'Location', 'NorthWest')
    xlabel('Tranformation ratio');
    ylabel( 'Fraction generated');
    
end

end