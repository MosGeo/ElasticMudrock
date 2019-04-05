function [NetConditionalEffects,Bin_MaxNetConditional]=NetConditionalEffects...
    (ParameterSpecified, DGSA,ParameterLegend)
% This functions compute net interactions and visualizae in bar graphs
% Author: Jihoon Park (jhpark3@stanford.edu)
% Date: 16 May 2016
%
%Input: 
%
% ParameterSpecified: string, a name of parameter that wants to see net conditioanl effects
% DGSA: Data structure contains results of DGSA.
%   .ParameterNames: (cell, length= # of parameters) Names of parameters. 
%   .ConditioanlEffects.Names_ConditionalEffects: (cell, length=(# of parameters) x (# of parameters-1)) Contains names of conditional effects.
%   .ConditionalEffects.SensitivityByClusterandBins:
%        (4D array, (# of parameters) x (# of parameters-1) x (# of clusters) x (maximum value of bins))
%        Element (i,j,c,l)  corresponds to conditional effect of  i-th parameter conditioned to  l-th bin of  j-th parameter from class c.  

% ParameterLegend: Legend of parameters. If omitted, {'Low','Med', 'High'} or {'Low','High'} are given as default for three and two parameters, respectively


%Output:
% NetConditionalEffects: matrix, # of parameters x # of bins of specified parameter, contains values of net conditional effects
% Bin_MaxNetConditiona: scalar, an index of bin that shows highest value of net conditional effects.
%                      This bin will be chosen to decrease uncertainty of model parameters later.
%% 

%% Assgin varaiables


ParametersNames=DGSA.ParametersNames;
IdxParametersSpecified=find(ismember(ParametersNames,ParameterSpecified));
NamesConditionalEffects=DGSA.ConditionalEffects.Names_ConditionalEffects;

ConditionalEffects_by_bins_clusters=DGSA.ConditionalEffects.SensitivityByClusterandBins;
if isempty(IdxParametersSpecified)
    error('Enter Right name of the parameter')
end


%% Compute net conditional effects
NbParams=length(ParametersNames);

SensitivityInteractionOverClass=nanmean(ConditionalEffects_by_bins_clusters, 3); % Average over cluster
NetConditionalEffects_temp=SensitivityInteractionOverClass(IdxParametersSpecified,:,:,:); % Take according to varable specified.

[~,NumConditionalPerParams,~,NbBins_Parameters]=size(NetConditionalEffects_temp);

% Transform the form of variable NetConditionalEffects_temp

NetConditionalEffects=zeros(NbBins_Parameters,NumConditionalPerParams); % Initialize

for k=1:NbBins_Parameters
    NetConditionalEffects(k,:)=NetConditionalEffects_temp(:,:,:,k);
end

%% Visualization
figure;
barh(NetConditionalEffects,'stacked');
if nargin<3
   
    
    if NbBins_Parameters==3
        set(gca,'YTickLabel', {'Low','Med','High'});
    end
    if NbBins_Parameters==2
        set(gca,'YTickLabel', {'Low','High'});
    end
else
    set(gca,'YTickLabel', ParameterLegend);
end


xlabel(ParametersNames(IdxParametersSpecified));
ylabel('Net conditional effects');

legend(NamesConditionalEffects((NbParams-1)*(IdxParametersSpecified-1)+1:(NbParams-1)*IdxParametersSpecified),'Location','EastOutside');        

[~,Bin_MaxNetConditional]=max(sum(NetConditionalEffects,2));


end
