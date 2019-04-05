function Xd=BubblePlot(GlobalSensitivityInteractions, ParametersNames, ScaleFactor,...
    StandardizedSensitivity, IsSensitive,Fontsizes)
% The function displays bubble plot to display condtional effects. 
% Author: Jihoon Park (jhpark3@stanford.edu)
% Date: March, 2015
%
% Input:
%
% GlobalSensitivityInteractions: (vector, length=(# of parameters) x (# of parameters -1)) Conditional effects averaged over bins and classes.
% ParametersNames: (cell, length= # of parameters) Names of parameters
% ScaleFactor: (scalar) scale of the size of bubble. The size of bubble is proportional to main effects. Higher values give smaller bubble.
% StandardizedSensitivity:(vector, length=# of parameters) Main effects averaged over clusters.
% IsSensitive: (logical, length=# of parameters) Result of bootstrap hypothesis test. If true, a parameter is sensitive.
% Fontsizes: (Scalar) Fontsize at bubble plot
%
% Ouput 
% XdL (matrix, # of Parameters x 2) Coordinates of bubbles.

N=length(ParametersNames);
D=GetDistMatrixfromInterSens(GlobalSensitivityInteractions,N); % In the bubble plot, the distance between parameters are defined as the inverse of the average of conditional effects. 

% Multi-Dimensional Scaling (MDS) using distance D.
rng(123433);
Xd_ = cmdscale(D);
dims = 2;
Xd = Xd_(:,1:dims);

figure
hold on
for k=1:size(Xd,1)
    

if IsSensitive(k)==1
    colorv='r';
else
    colorv='b';
end

filledCircle(Xd(k,:),StandardizedSensitivity(k)/ScaleFactor,100,colorv);axis('equal');
alpha(.5);
    
    text(Xd(k,1),Xd(k,2),ParametersNames{k},'HorizontalAlignment','center','Fontsize',Fontsizes);

end
hold off
grid off

set(gca,'XTickLabel',{''})
set(gca,'YTickLabel',{''})
set(gcf,'color','w');box on; set(gca,'LineWidth',3);

end