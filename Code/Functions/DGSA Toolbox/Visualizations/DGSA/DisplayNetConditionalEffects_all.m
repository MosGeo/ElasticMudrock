function DisplayNetConditionalEffects_all(DGSA)
% The function displays net conditional effcts of all parameters
% Author: Jihoon Park (jhpark3@stanford.edu)
% Date 16 May 2016
% Input:
%
%   DGSA: Results of DGSA
%      .ConditionalEffects.SensitivityByClusterandBins: 
%       (4D array, (# of parameters) x (# of parameters-1) x (# of clusters) x (maximum value of bins)): 
%           Element (i,j,c,l)  corresponds to conditional effect of i-th parameter conditioned to  
%           l-th bin of  j-th parameter from class c . 
%      .MainEffects.SensitivityStandardized: (vector, length=# of parameters) Main effects averaged over clusters.
%      .ParametersNames: (cell, length= # of parameters) Names of parameters 

%% Assign parameters
  
SensitivityInteractions=DGSA.ConditionalEffects.SensitivityByClusterandBins;
GlobalSens=DGSA.MainEffects.SensitivityStandardized;
ParamsNames=DGSA.ParametersNames;

%% Compute net conditional effects

[NbParms, ~, NbClusters, NbMaxBins]=size(SensitivityInteractions);
SensitivityInteractionOverClass=nanmean(SensitivityInteractions, 3); % Average over cluster

SensitivityInteractionSumInter=sum(SensitivityInteractionOverClass,2);
MatrixSum=zeros(NbParms, NbMaxBins);


for k=1:NbMaxBins    
    MatrixSum(:,k)=SensitivityInteractionSumInter(:,:,:,k);       
end



[NbParams NbClusters] = size(MatrixSum);


[~, SortedSA] = sort(GlobalSens,'ascend');
MatrixSum = MatrixSum(SortedSA,:);
ParamsNames = ParamsNames(SortedSA);

figure;
axes('FontSize',12,'fontweight','b');  hold on;
h0 = barh(1:NbParams,MatrixSum,0.8,'group','LineWidth',1.5);

P=findobj(h0,'type','patch');
C = definecolor(NbClusters);
for n=1:length(P) 
    set(P(n),'facecolor',C(n,:),'LineWidth',1.5);
end


set(gca,'YTick',1:NbParams)
set(gca,'YTickLabel',ParamsNames)
box on

legend('Low','Med','High','Location','NorthEastOutside');
end


% This function defines the bar colors
function C = definecolor(NbClusters)
    Cs = colormap(jet(124));
    Ds = floor(linspace(1,size(Cs,1),NbClusters));
    C = Cs(Ds,:);

end