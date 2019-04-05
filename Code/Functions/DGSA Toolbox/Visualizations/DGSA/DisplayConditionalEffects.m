function DisplayConditionalEffects(DGSA,Type)
%%
% The function displays conditioanl effects according to the type specified by a user.
% Author: Jihoon Park(jhpark3@stanford.edu)
% Date: 15 May 2016

% Input 
%
% DGSA: Data sturcture containing results of DGSA
%   .ParametersNames:(cell, length= # of parameters) Names of parameters 
%   .ConditionalEffects.SensitivityByClusterandBins: 
%       (4D array, (# of parameters) x (# of parameters-1) x (# of clusters) x (maximum value of bins)): 
%           Element (i,j,c,l)  corresponds to conditional effect of i-th parameter conditioned to  
%           l-th bin of  j-th parameter from class c . 
%   .ConditionalEffects.Names_ConditionalEffects: (cell, length=(# of parameters) x (# of parameters-1))
%           Names of conditional effects.
%   .ConditionalEffects.NbBins: (vector, length=# of parameters) 
%           Specifies each number of bins of parameters to compute conditional effects
%   .ConditionalEffects.H0accConditional: (logical vector, length=(# of parameters) x (#  of parameters -1))
%           If it is true, corresponding conditional effect is sensitive.

% Type(string): Visualization method for standardized conditional effects
%       'Pareto (default)' : Pareto plots. If there are a lot of parameters, it is not recommended since there are 
%                            N(N-1) items to display which is not practical.

%       'Hplot': Use h-plot
%       'Bubble': Use bubble plot


%% 1. Assign variables
% Assign sensitivities to varaibles
%
% 1.1 Names of parameters
ParametersNames=DGSA.ParametersNames;

% 1.2 Clustering information
NbClusters=length(DGSA.Clustering.medoids); % # of clusters

% 1.3 Conditional effects
NormalizedInteractions=DGSA.ConditionalEffects.SensitivityByClusterandBins; % Conditional effects by clusters and bins
StandardizedSensitivityInteractions=DGSA.ConditionalEffects.StandardizedSensitivity; % Conditional effects standardized
ConditionalEffectNames=DGSA.ConditionalEffects.Names_ConditionalEffects; % Names of conditional effects
NbBins=DGSA.ConditionalEffects.NbBins; % # of bins of each parameter
H0accConditional=DGSA.ConditionalEffects.H0accConditional; % Result of hypothesis testing of conditional effects

% 1.4 Main effects

MainEffectsStandardized=DGSA.MainEffects.SensitivityStandardized; % Main effects standardized
H0accMain=DGSA.MainEffects.H0accMain; % Result of hypothesis testing of Main effcts

%% 2. Sensitivity by cluster & bins

if DGSA.ConditionalEffects.Display.SensitivityByClusterAndBins
    % If this is true, display Pareto plots to show conditional effects by bins and clusters
    ParetoInteractions(NormalizedInteractions,ConditionalEffectNames,NbClusters,NbBins);        
end

%% 3. Diplay Standardized Conditional Effects

if nargin<2
    Type='Pareto'; % Default is Pareto plot
end

switch Type
    case 'Pareto'
        
        Pareto_GlobalSensitivity(StandardizedSensitivityInteractions,ConditionalEffectNames,H0accConditional);      
        
    case 'Hplot'
                
        % Create a dialog box to receive additional information.
        
        prompt = {'Enter Scale of the bubble:','Enter Font size: '};
        dlg_title = 'Input(Hplot)';
        num_lines = 1;
        defaultans = {'30','12'};
        options.Resize='on';
        answer = inputdlg(prompt,dlg_title,num_lines,defaultans,options);      
    
        ScaleFactorHplot=str2num(answer{1}); Fontsizes=str2num(answer{2});
        
                
        DisplayHplot(StandardizedSensitivityInteractions,MainEffectsStandardized...
            ,ParametersNames, ScaleFactorHplot, Fontsizes);              

        
    case 'Bubble'
        
        prompt = {'Enter Scale of the bubble:','Enter Font size: '};
        dlg_title = 'Input(BubblePlot)';
        num_lines = 1;
        defaultans = {'5','14'};
        options.Resize='on';
        answer = inputdlg(prompt,dlg_title,num_lines,defaultans,options);
        
        ScaleFactorBubblePlot=str2num(answer{1}); Fontsizes=str2num(answer{2});
        
        BubblePlot(StandardizedSensitivityInteractions, ParametersNames, ScaleFactorBubblePlot, MainEffectsStandardized, H0accMain,Fontsizes);

        
    otherwise
        error('Enter correct names of visualization methods')
        
end
        
end

