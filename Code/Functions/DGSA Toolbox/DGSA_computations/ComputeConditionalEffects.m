
%
% Distance-based generalized sensitivity analysis (dGSA)
% Evaluation of sensitivity of the conditioanl effects
 
% Author: Celine Scheidt
% Date: August 2013

% Updated by Jihoon Park (jhpark3@stanford.edu)
% Date: 14 May 2016
%   - Use data structures
%   - Separate computations and visualizations
%   - Display the conditioning parameter computed

function DGSA_ConditionalEffects = ...
   ComputeConditionalEffects(DGSA,alpha)%(Clustering,ParametersValues,ParametersNames,NbBins,alpha)


%% Input Parameters

% DGSA: (Stucture) Previous results of DGSA.
%
%   .Clustering: (Structure) Results of clustering
%   .ParametersValues: (matrix, # of models x # of parameters) contains values of each parameter from Monte Carlo sampling. 
%   .ConditionalEffects.NbBins: (vector, length=# of parameters) specifies each number of bins of parameters to compute conditional effects
%   .ParametersNames: (cell, 1 x # of parameters) contains the names of parameters
%
% alpha: (optional) alpha-percentile (by default, alpha = 0.95) for bootstrap percentile

%% Output Parameters 
%
% DGSA_ConditionalEffects: (Structure) Results of DGSA after computing conditional effects.
%   .ConditionalEffects.SensitivityByClusterandBins:
%        (4D array, (# of parameters) x (# of parameters-1) x (# of clusters) x (maximum value of bins))
%        Element (i,j,c,l)  corresponds to conditional effect of  i-th parameter conditioned to  l-th bin of  j-th parameter from class c.  
%
%   .ConditionalEffects.StandardizedSensitivity: (vector, length=(# of parameters) x (# of parameters -1))
%       Conditional effects averaged over bins and classes
%
%   .ConditionalEffects.H0accConditional (logical vector, length=(# of parameters) x (#  of parameters -1)) 
%       Results of bootstrap hypothesis testing. If the value is 1, corresponding conditional effect is sensitive.
%
%   .ConditionalEffects.Names_ConditionalEffects: (cell, length=(# of parameters) x (#  of parameters -1)) 
%       contains names of conditional effects

%% Assign varaibles.
DGSA_ConditionalEffects=DGSA;

Clustering=DGSA.Clustering;
ParametersValues=DGSA.ParametersValues;
NbBins=DGSA.ConditionalEffects.NbBins;
ParametersNames=DGSA.ParametersNames;


%% Computations of conditional effects.

NbParams = size(ParametersValues,2);
NbClusters = size(Clustering.medoids,2);

if nargin < 2; alpha = .95; end

% Evaluate the normalized conditionnal interaction for each parameter, each
% class and each bin
L1Interactions = NaN(NbParams,NbParams-1,NbClusters,max(NbBins));  % array containing all the Interactions 
BootInteractions = NaN(NbParams,NbParams-1,NbClusters,max(NbBins));  

for params = 1:NbParams
    fprintf('Computing sensitivity conditional to %s...\n',ParametersNames{params});
    L1InteractionsParams = L1normInteractions(ParametersValues,params,Clustering,NbBins(params));
    L1Interactions(params,:,:,1:NbBins(params)) = L1InteractionsParams(:,:,1:NbBins(params));
    BootInteractionsParams = BootstrapInteractions(ParametersValues,params,Clustering,NbBins(params),2000,alpha);
    BootInteractions(params,:,:,1:NbBins(params)) = BootInteractionsParams(:,:,1:NbBins(params));
    NormalizedInteractions = L1Interactions./BootInteractions;
end


% Measure of conditional interaction sensitivity per class
SensitivityPerClass = nanmean(NormalizedInteractions,4);

% Average measure of sensitivity over all classes 
SensitivityOverClass = nanmean(SensitivityPerClass,3);


% Hypothesis test: Ho = 1 if at least one value > 1 (per cluster and per bin)
SensitivityPerInteraction = reshape(permute(NormalizedInteractions,[2,1,4,3]),[],max(NbBins)*NbClusters);
H0accInter = any(SensitivityPerInteraction >=1,2);

StandardizedSensitivityInteractions = reshape(SensitivityOverClass',1,[]);
%% Save variables to output data structure

DGSA_ConditionalEffects.ConditionalEffects.SensitivityByClusterandBins=NormalizedInteractions;
DGSA_ConditionalEffects.ConditionalEffects.StandardizedSensitivity=StandardizedSensitivityInteractions;
DGSA_ConditionalEffects.ConditionalEffects.H0accConditional=H0accInter;
DGSA_ConditionalEffects.ConditionalEffects.Names_ConditionalEffects=CreateNames_ConditionalEffect(ParametersNames);

 
end



