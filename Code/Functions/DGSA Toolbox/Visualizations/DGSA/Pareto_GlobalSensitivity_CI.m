function Pareto_GlobalSensitivity_CI(StandardizedSensitivity, H0accMain, ParametersNames,ColorType)
% The function dispalys standardized main effects with confidence
% intervals.
% Author: Jihoon Park (jhpark3@stanford.edu)
% Date: 14 May 2016

% Input:
%
% StandardizedSensitivity: (array, # of Parameters x 1 x 3) : Main effects standardized by averaging over clusters
% H0accMain (logical, length=# of Parameters): If 1, H0 is rejected (sensitive), otherwise accepted (insensitive)
% ParametersNames (cell, length=# of parameters) Names of Parameters
% ColorType: (string) Specifies how a Pareto plot is colored.
%   If 'RB', red/blue scheme is used (default)
%   If 'jet', a bar is colored by 'jet' from matlab


StandardizedSensitivity0=StandardizedSensitivity(:,:,1); % This is the sensitivity corresponding the first value of alpha. This will be taken as the sensitivities.

%%% StandardizedSensitivity1 and StandardizedSensitivity2 corresponds to
%%% the second and third values of alpha. This is used to compute the
%%% confidence intervals.

StandardizedSensitivity1=StandardizedSensitivity(:,:,2); 
StandardizedSensitivity2=StandardizedSensitivity(:,:,3);

[~, SortedSA] = sort(StandardizedSensitivity0,'ascend'); 

% Sort the variables according to the rank of sensitivity

StandardizedSensitivity0=StandardizedSensitivity0(SortedSA);
StandardizedSensitivity1=StandardizedSensitivity1(SortedSA);
StandardizedSensitivity2=StandardizedSensitivity2(SortedSA);
H0accMain=H0accMain(SortedSA);
ParametersNames=ParametersNames(SortedSA);
IsSensitive=H0accMain;

NbParams = length(StandardizedSensitivity0);

if NbParams > 10
    TextSize = 10;
else
    TextSize = 12;
end



%% Define Color

switch ColorType
    
    case 'jet'
        
        C=jet;
        nC=size(C,1);
        C=flipud(C);
        
    case 'RB'
        
        C2=jet(64);C=C2*0; % Initialize
        
        C(:,1)=linspace(0,1,size(C,1))'; % Blue
        C(:,3)=linspace(1,0,size(C,1))'; % Red
        
        nC=size(C,1);
        
        
    otherwise
        error('Enter correct types of colors')
        
end
%%  Visualization

    figure
    axes('FontSize',TextSize,'fontweight','b');  hold on;
    for i = 1:NbParams
        delta_n=StandardizedSensitivity1(i)-StandardizedSensitivity2(i); % define delta_n
        if StandardizedSensitivity0(i)<1-delta_n/2
            ColorVector=C(1,:); % Blue
        elseif StandardizedSensitivity0(i)>1+delta_n/2
            ColorVector=C(end,:); % Red
        else
            higher=1+delta_n/2;
            lower=1-delta_n/2;
            ratio_pvalue=(StandardizedSensitivity0(i)-lower)/(higher-lower);
            ColorVector=C(floor(nC*ratio_pvalue)+1,:);
            
        end
        
        colormap(C);
        if IsSensitive(i) == 1
            h1 = barh(i,StandardizedSensitivity0(i),'FaceColor',ColorVector,'BarWidth',0.8,'LineStyle','-','LineWidth',2);
          
        else
            h2 = barh(i,StandardizedSensitivity0(i),'FaceColor',ColorVector,'BarWidth',0.8,'LineStyle','-.','LineWidth',2);
            
        end
        herrorbar(1,i,delta_n/2); % Add confidence intervals
        
    end
    set(gca,'YTick',1:NbParams)
    set(gca,'YTickLabel',ParametersNames)
    plot([1 1], [0 NbParams+1],'m','LineWidth',3);
    box on; ylim([0 NbParams+1]);
    h3=colorbar; caxis([0 .1]);
   
    axis_object=get(gca);
    xlim([0,axis_object.XLim(2)]);

end



