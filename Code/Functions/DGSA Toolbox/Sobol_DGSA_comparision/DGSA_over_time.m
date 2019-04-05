function Sensitivity_with_time=DGSA_over_time(DGSA,responses,tgrid)
% The function computes main effects at each time step. 
% Author: Jihoon Park (jhpark3@stanford.edu)
% Date: 16 May 2016

% Input: 

% DGSA: Results of DGSA.
%
%   .ParametersValues: : (matrix, # of models x # of parameters) contains values of each parameter from Monte Carlo sampling.
%   .ParametersNames: (cell, length= # of parameters) Names of parameters 

% responses: (matrix, # of models x # of timesteps), time varying response 
% tgrid: (vector, length=# of timesteps): Grid for time.

% Output
%
% Sensitivity_with_time: (matrix, # of models x # of timesteps), Main effects over time.

%% Assign variables
ParametersValues=DGSA.ParametersValues;
ParametersNames=DGSA.ParametersNames;
NbParams=size(ParametersValues,2);
DGSA.MainEffects.Display.ParetoPlotbyCluster=0;
DGSA.MainEffects.Display.StandardizedSensitivity='None'; 
Sensitivity_with_time=zeros(NbParams,size(responses,2));

%% Run DGSA at each step

       
for i=1:size(responses,2)
 
    responses_i=responses(:,i); % Each response is univariate. 
   
    fprintf('Running DGSA at time=%3.2f...\n',tgrid(i+1));
    DGSA.D=pdist(responses_i);
    DGSA.Clustering=kmedoids(DGSA.D,DGSA.Nbcluster,10); 
    
    DGSA=ComputeMainEffects(DGSA);
    
    
    Sensitivity_with_time(:,i)=DGSA.MainEffects.SensitivityStandardized;
    
    
end
 
%% Plot the main effects over time

LineSeries={'b','r','k','m','--b','--r','--k','--m',':b',':r',':k',':m'};
figure
for k=1:NbParams
    plot(tgrid, [0,Sensitivity_with_time(k,:)],LineSeries{k},'LineWidth',3); hold on
    
end
legend(ParametersNames,'Location','EastOutside');
xlim([0 tgrid(end)]);ylim([0 6]);xlabel('Time(Day)','Fontsize',12,'Fontweight','bold'); 
ylabel('Sensitivitty','Fontsize',12,'Fontweight','bold');
set(gca,'Fontsize',12,'Fontweight','bold');
hold off


end