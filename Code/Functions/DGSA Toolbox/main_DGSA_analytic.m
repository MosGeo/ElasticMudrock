% main_DGSA_analytic.m
%
%% Distance-Based generalized Sensitivity Analysis: Analytic example
%
% This script is written to demonstrate how to apply DGSA to obtain main/conditional effects.
% Also, it shows how to decrease uncertainty of model parameters with minimal impact on responses.
%
% References: 
%
% Fenwick et al. (2014), Quantifying Asymmetric Parameter Interactions in Sensitivity Analysis: Application to Reservoir Modeling. Mathematical Geosciences 
% Park et al. (2016), DGSA: a matlab toolbox for distance-based generalized sensitivity analysis for geoscientific computer experiments 

%This script was originally written by Celine Scheidt in August 2012
% Lastly updated by Jihoon Park (jhpark3@stanford.edu) in May 2016
% 
%   - Scripts are written to involve change of functions
%   - Net conditional effects are computed in the script.

clear all; close all; fclose('all');
%% 1. Add paths

addpath(genpath(pwd))

%% 2. Monte Carlo sampling & Compute responses

% Define three parameters 
NbSimu=500; NbParams=3; rng(12756); 
DGSA.ParametersValues=lhsdesign(NbSimu,NbParams,'criterion','correlation','iterations',50); 

% Responses Y1 and Y2, r=[Y1, Y2]=[X1,X2*(1-X3)]
Y1=DGSA.ParametersValues(:,1); Y2=abs(DGSA.ParametersValues(:,2).*(DGSA.ParametersValues(:,3)-1));
PriorResponses=[Y1,Y2]; 

% Construct distance vector
DGSA.D=pdist(PriorResponses);

%% 3. Specify inputs for DGSA

DGSA.ParametersNames={'X1','X2','X3'}; % Name of each parameter
DGSA.Nbcluster=3; % # of clusters
DGSA.MainEffects.Display.ParetoPlotbyCluster=1; % If true, display main effects by clusters
DGSA.MainEffects.Display.StandardizedSensitivity='Pareto'; 

% Perform clustering. 
DGSA.Clustering=kmedoids(DGSA.D,DGSA.Nbcluster,10); 

% Compute & Display main effects
DGSA=ComputeMainEffects(DGSA);

% Display CDFs. In this example, cdf of X1 is shown. 
% If you want every CDFs, simply omit the last variable in the following function.

cdf_MainFactor(DGSA.ParametersValues, DGSA.Clustering, DGSA.ParametersNames,{'X1'});
%% 4. Compute & Display conditional effects

%%% Enter inputs
DGSA.ConditionalEffects.NbBins=3*ones(1,NbParams); % 3 bins for each parameters
DGSA.ConditionalEffects.Display.SensitivityByClusterAndBins=1; % If true, it shows Pareto plots of conditional effects by bins and clusters 
DGSA.ConditionalEffects.Display.StandardizedSensitivity='Pareto';

% Compute & display conditional effects
DGSA=ComputeConditionalEffects(DGSA);
DisplayConditionalEffects(DGSA,DGSA.ConditionalEffects.Display.StandardizedSensitivity);

% Display CDF
cdf_ConditionalEffects('X2','X3',DGSA,1) % The example displays CDF of X2|X3, Cluster 1
%% 5. See the distribution of Y1 and Y2

% Compute net conditional effects of X3
[NetConditionalEffects,Bin_MaxNetConditional]=ComputeNetConditionalEffects...
    ('X3', DGSA, {'X3<1/3','1/3<X3<2/3','X3>2/3'}); % See net conditional effects of X3. 

% Decrease uncertainty of X3 to X3<1/3
idx=DGSA.ParametersValues(:,3)<1/3;
figure;
plot(Y1,Y2,'.','Markersize',20);hold on;
plot(Y1(idx),Y2(idx),'r*','Markersize',20);hold off;
axis('square'); xlabel('Y_1','Fontsize',12);ylabel('Y_2','Fontsize',12);
title('Uncertainty using net conditional effects','Fontsize',14);
