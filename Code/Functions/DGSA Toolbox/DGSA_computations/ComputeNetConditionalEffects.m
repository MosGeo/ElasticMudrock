function [NetConditionalEffects,Bin_MaxNetConditional]=ComputeNetConditionalEffects...
    (ParameterSpecified, DGSA,YTicktxt)
% This functions compute net interactions and visualizae in bar graphs
% Author: Jihoon Park (jhpark3@stanford.edu)
% Date: 16 May 2016
%
%Input: 
% ParameterSpecified: string, a name of parameter that wants to see net conditioanl effects
% DGSA: Datastructure contains results of DGSA.
% YTicktxt: Labels of y-axis of horizontal bar graph.

%Output:

% NetConditionalEffects:matrix (NbBins x (# of Parameters-1)): contains net conditional effects of the specified parameter.
% Bin_MaxNetConditional: scalar, the index of bin that has the highest conditional effects.

    

%% Assgin varaiables

ParametersNames=DGSA.ParametersNames;
IdxParametersSpecified=find(ismember(ParametersNames,ParameterSpecified));
NamesConditionalEffects=DGSA.ConditionalEffects.Names_ConditionalEffects;
ParametersNames=DGSA.ParametersNames;
ConditionalEffects_by_bins_clusters=DGSA.ConditionalEffects.SensitivityByClusterandBins;
if isempty(IdxParametersSpecified)
    error('Enter Right name of the parameter')
end


%% 
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
    set(gca,'YTickLabel', YTicktxt);
    
end




xlabel(ParametersNames(IdxParametersSpecified));
ylabel('Net conditional effects');

legend(NamesConditionalEffects((NbParams-1)*(IdxParametersSpecified-1)+1:(NbParams-1)*IdxParametersSpecified),'Location','EastOutside');        

[~,Bin_MaxNetConditional]=max(sum(NetConditionalEffects,2));


end
