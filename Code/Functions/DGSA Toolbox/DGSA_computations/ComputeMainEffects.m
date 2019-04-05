function DataStructMainEffects=ComputeMainEffects(DataStruct,alpha,ColorType)
% This function computes/display main effects from DGSA.
% Author: Jihoon Park (jhpark3@stanford.edu) and Celine
% Scheidt(scheidtc@stanford.edu)

% Input:

% DataSturc : Data structure having inputs required for computing main effects.
%   .ParametersValues: (matrix, # of models x # of parameters) contains values of each parameter from Monte Carlo sampling.
%   .ParametersNames: (cell, 1 x # of parameters) contains the names of parameters 
%   .D: (matrix, # of models x # of models or vector, length =# of models x (# of models -1))
%       Distance matrix or vector of distances between the model.
%   .Clustering: (structure) results of clustering
%   
% 
% Inputs for Display::
%
%   .MainEffects.Display.StandardizedSensitivity: (string) specifies the method to visualize standardized main effect. 
%       'Pareto': Pareto plot
%       'CI': Add a confidence interval to the Pareto plot
%       'None': (default) do not display
%   .MainEffects.Display.ParetoPlotbyCluster: 
%
% Optional:: 
%   
%   alpha: (optional) % quantile of bootstrapped idstribution. If only Pareto plot is used to display standardized main effects, It should be scalar. The default value is 0.95 
%          If a confidence interval is displayed, it should be a vector of length 3. The value of sensitivity (length of Pareto bar) is based on the first element. 
%   ColorType: (optional, string) specifies how the Pareto plot is colored when confidence interval is dispalyed. If 'RB', the bar is colord with Red/Blue scheme (default). 
%          If 'jet', the bar is colored with 'jet' obejct from Matlab.



% Output:

% DataStructMainEffects.MainEffects: Results of Main effects are added to DataStruc
%   .SensitivitybyCluster : (matrix, # of parameters x # of clusters) contains main effects by parameters (rows) and clusters (columns)
%   .SensitivityStandardized : (vector, length=# of parameters) Main effects averaged over clusters.
%   .H0accMain: (logical, length=# of parameters) Result of bootstrap hypothesis test. If true, a parameter is sensitive.


%% Create variables
DataStructMainEffects=DataStruct;
if nargin<2
    alpha=.95;
end

    
%% 1. Check the visualization method.
if ~DataStruct.MainEffects.Display.StandardizedSensitivity
    DataStruct.MainEffects.Display.StandardizedSensitivity='None'; % Default is not to visualize sensitivities
end

switch DataStruct.MainEffects.Display.StandardizedSensitivity

    case 'CI'
        if length(alpha)~=3 
            error('In order to disply confidence interval, alpha should be a vector of length 3')
        end
        
        [~,idx]=sort(alpha);
        
        if ~all(idx==[2,1,3])
            error('In order to disply confidence interval, alpha(3)>alpha(1)>alpha(2)')
        end
        
               
        
    case 'Pareto'
        if ~isscalar(alpha)
            error('Significane level should be scalar for Parteo plot only')
        end
    case 'None'
        if ~isscalar(alpha)
            error('Significane level should be scalar when sensitivities not displayed')
        end
    otherwise
        error('Enter the right type of display method');
        
end
    

%% 2. Create variables 

ParametersValues=DataStruct.ParametersValues; % Values of Parameters
ParametersNames=DataStruct.ParametersNames;
Clustering=DataStruct.Clustering;




%% 3. Compute Main Effects

L1MainFactors = L1normMainFactors(Clustering,ParametersValues); % evaluate L1-norm
L1MainFactors=repmat(L1MainFactors,1,1,length(alpha));

BootMainFactors = BootstrapMainFactors(ParametersValues,Clustering,2000,alpha);  % bootstrap procedure

SensitivityMainFactors = L1MainFactors./BootMainFactors; % normalization 
SensitivitybyCluster=SensitivityMainFactors(:,:,1);
StandardizedSensitivity = mean(SensitivityMainFactors,2); 


%% 4. Hypothetis test: H0=1(reject, so sensitive) if at least one value > 1 (per cluster)
H0accMain = any(SensitivitybyCluster >=1,2); 



%% 5. Save Main effects to Data Structure
SensitivityStandaridzed=StandardizedSensitivity(:,:,1);
SensitivitybyCluster=SensitivityMainFactors(:,:,1);
DataStructMainEffects.MainEffects.SensitivitybyCluster=SensitivitybyCluster;
DataStructMainEffects.MainEffects.SensitivityStandardized=SensitivityStandaridzed;

DataStructMainEffects.MainEffects.H0accMain=H0accMain;

%% 6. Display main effects.

% 6.1 Sensitivity by cluster.
if DataStruct.MainEffects.Display.ParetoPlotbyCluster % display main effects by cluster  
        ParetoMainFactors(SensitivitybyCluster,ParametersNames);    
end

% 6.2 Display Standardized Sensitivity

switch DataStruct.MainEffects.Display.StandardizedSensitivity
    case 'CI'
        if nargin<3
        ColorType='RB';
        end
        Pareto_GlobalSensitivity_CI(StandardizedSensitivity, H0accMain, ParametersNames,ColorType);
        
    case 'Pareto'
        
        Pareto_GlobalSensitivity(SensitivityStandaridzed,ParametersNames,H0accMain);
  
        
end
    

end