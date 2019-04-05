function [effK, effG, effRho] = modelMatrix(mineralsK, mineralsG, mineralsRho, fractions,...
    fluidK, fluidRho, phi, phiAlpha, freqType, minAverageType)
% MODELKEROGEN models kerogen based on given parameters
%
% mineralsK:               Minerals bulk modulus
% mineralsG:               Minerals shear modulus
% mineralsRho:             Minerals density
% fractions:               Minerals fractions (add up to 1)
% fluidK:                  Fluid bulk modulus
% fluidRho:                fluid density
% phiAlpha:                Nano-pore aspect ratio
% freqType:                Fraquency: 1. Low, 2. High

% Mustafa Al Ibrahim @ 2018
% Mustafa.Geoscientist@outlook.com

%% Preprocessing

% Defaults
if ~exist('freqType', 'var'); freqType = 1; end
if ~exist('phiAlpha', 'var'); phiAlpha = 1; end

% Assertions


%% Data

% Minerals from file
% mineralToUse = {'Quartz','Illite_K_Rich', 'Calcite', 'Pyrite', 'Apatite_Br_Rich'};
% mineralsFileName = 'C:\Users\malibrah\OneDrive\Stanford\Project Cella\Papers\Multi-Mineral Inversion of X-Ray Fluorescence Data\Code\Minerals.csv';
% [Minerals] = readtable(mineralsFileName, 'ReadRowNames',true);
% parameterNames      =  {'K', 'G', 'Rho'};
% mineralsValues = Minerals{mineralToUse, {'K', 'G','Rho'}};
% Minerals = array2table(mineralsValues, 'RowNames', mineralToUse, 'VariableNames', parameterNames);

%% Main

minerals = [mineralsK(:), mineralsG(:), mineralsRho(:)];

fractions = fractions(:);

mineralMixture =  getVoigtReussAverages(minerals, fractions);
mineralMixture = array2table(mineralMixture, 'RowNames', {'Reuss', 'Voight', 'Hill'}, 'VariableNames', {'K', 'G', 'Rho'});

    KMatrixEmpty   =  mineralMixture{minAverageType, 'K'};
    GMatrixEmpty   =  mineralMixture{minAverageType, 'G'};
    RhoMatrixEmpty =  mineralMixture{2, 'Rho'};


xi =  phi /  (phi + sum(fractions));
if freqType == false
    [KMatrixPore, GMatrixPore] = differentialEffectiveMedium(KMatrixEmpty, GMatrixEmpty, 0,0,xi, phiAlpha);
    effK  = gassmnk(KMatrixPore,0,fluidK,KMatrixEmpty,xi);
    effG  = GMatrixPore;
else
    [effK, effG] = differentialEffectiveMedium(KMatrixEmpty, GMatrixEmpty, fluidK,0,xi, phiAlpha);
end

RhoMatrixPore = RhoMatrixEmpty * (1-xi);
effRho = RhoMatrixPore + xi* fluidRho;

end