function [effK, effG, effRho, phi, TR] = modelKerogen(Ro, kerogenK, kerogenG, ...
    fluidK, fluidRho, phiAlpha, freqType, kerogenType, roModel, maxPhi, maxWtPerCarbonLoss, initialHC)
% MODELKEROGEN models kerogen based on given parameters
%
% Ro:                      Vitrinite reflectance
% kerogenK:                Kerogen bulk modulus
% kerogenG:                Kerogen shear modulus
% fluidK:                  Fluid bulk modulus
% fluidRho:                fluid density
% alpha:                   Kerogen density alpha factor (see paper)
% beta:                    Kerogen density beta factor (see paper)
% phiAlpha:                Nano-pore aspect ratio
% maxPhi:                  Maximum pore fraction
% freqType:                Fraquency: 1. Low, 2. High
% roModel:                 Vitrinite reflectance model
% t:                       time
% T:                       Temperature (C)

% Mustafa Al Ibrahim @ 2018
% Mustafa.Geoscientist@outlook.com

%% Preprocessing

% Defaults
if ~exist('roModel', 'var'); roModel = 'Easy'; end
if ~exist('t','var') || ~exist('T', 'var'); [t, T] = linearThermalHistory(10, 300, 100, 0.5, true); end
if ~exist('freqType', 'var'); freqType = 1; end
if ~exist('phiAlpha', 'var'); phiAlpha = 1; end

% Assertions
assert(exist('Ro', 'var') == true, 'Ro must be provided');
assert(exist('kerogenK', 'var') == true, 'kerogenK must be provided');
assert(exist('kerogenG', 'var') == true, 'kerogenG must be provided');
assert(exist('fluidK', 'var') == true, 'fluidK must be provided');
assert(exist('fluidRho', 'var') == true, 'fluidRho must be provided');

%% Data

% Kerogens values that can be used
% kerogenNames = {'I', 'II', 'III'};
% parameterNames ={'K', 'G', 'alpha', 'beta', 'maxPhi'};
% kerogenValues(1,:) = [5.5, 3.2, 1.357, 0.58, .69];
% kerogenValues(2,:) = [5.5, 3.2, 1.293, 0.20, .43];
% kerogenValues(3,:) = [5.5, 3.2, 1.725, 0.10, .12];
% Kerogens = array2table(kerogenValues, 'RowNames', kerogenNames, 'VariableNames', parameterNames);

% Fluid values that can be used
% fluidNames = {'Oil'};
% parameterNames ={'K', 'G', 'Rho'};
% fluidValues = [1.02, 0, 800];
% Fluids = array2table(fluidValues, 'RowNames', fluidNames, 'VariableNames', parameterNames);

%% Main

maxT = 500; Ti = 100; H = 10; dT = .5;
[t, T] = linearThermalHistory(H, maxT, Ti, dT, true);
maxPhis = [.71, .43, .12];
kerogenNamesTR = {'I', 'II', 'IIIN'};


[~, TRAll, RoAll] = runPyrolysis(kerogenNamesTR{kerogenType}, roModel, t, T);
[roTR,ia,ic] = unique(TRAll);
RoAll = RoAll(ia);
TRAll = TRAll(ia);
TR = interp1(RoAll, TRAll, Ro);

if exist('maxPhi', 'var') == false
     maxPhi = maxPhis(kerogenType);
end    

[phi] = kerogenPorosityMaxPhi(TR,  maxPhi);

kerogenNames = {'I', 'II','III'};
[hcRatio, hcTR] = calcHcRatio(kerogenNames{kerogenType}, maxWtPerCarbonLoss, initialHC);
density = kerogenRhoFromHC(hcRatio);
kerogenRhoSolid = interp1(hcTR, density, TR)*1000;    

% Insert pore and fluid
if freqType == 0
    [effK, Gkerogen] = differentialEffectiveMedium(kerogenK, kerogenG, 0,0, phi, phiAlpha);
    effK  = gassmnk(effK, 0, fluidK, kerogenK, phi);
    effG  = Gkerogen;
else 
    [effK, effG] = differentialEffectiveMedium(kerogenK, kerogenG, fluidK,0, phi, phiAlpha);
end

% Effective density
effRho =  (1-phi) .* kerogenRhoSolid + phi *  fluidRho;

end