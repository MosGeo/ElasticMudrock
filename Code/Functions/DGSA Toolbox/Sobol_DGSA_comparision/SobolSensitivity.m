function [S,S_t]=SobolSensitivity(tgrid,responses,N_unit_simul,ParametersNames)
% The function computes Sobol's first order & total effects and display over time
% Author: Jihoon Park(jhpark3@stanford.edu)
% Date: 16 May 2016
% Reference:
% Wainwright, H.M., Finsterle, S., Jung, Y., Zhou, Q., Birkholzer, J.T., 2014. Making sense of global sensitivity analyses. Computers & Geosciences 65, 84-94.

% Input
%
% tgrid: (vector, length=# of timesteps) grid for time
% responses: (matrix, # of models for Sobol's method x timesteps) Responses of each model
% N_unit_simul: (scalar, # of initial Monte Carlo samples to apply Sobol's method. 
% ParametersNamses: (cell, length=# of uncertain parameters) contains names of parameters

% Output
%
% Si: (matrix, # of uncertain parameters x # of timesteps) : containing first order effect
% Sti: (matrix, # of uncertain parameters x # of timesteps) : containing total effect

%% Retrieve n and k to apply Sobol's method
% In Sobol's method n(k+2) simulations are required where n=sample size and k is the number of parameters
NbTotalSimul=size(responses,1); % This is n.
NbParam=length(ParametersNames);  % This is k. 

%% Extract dynamic data

responses=[zeros(NbTotalSimul,1),responses];
C=responses';
C_reshaped=reshape(C, length(tgrid), N_unit_simul, NbParam+2);
%% Compute Sobol's indicies

A=C_reshaped(:,:,1); 
S=zeros(NbParam,length(tgrid));
S_t=zeros(NbParam,length(tgrid));

for k=1:length(tgrid)
    sigma_y_i=var(A(k,:)); % sigma_y_i
    mu_y_i=mean(A(k,:));
    for i=1:NbParam
        C_i=C_reshaped(k,:,i+2);
        A_i=C_reshaped(k,:,1);
        B_i=C_reshaped(k,:,2);
        S(i,k)=((A_i-mu_y_i)*(C_i-mu_y_i)')/sigma_y_i/(N_unit_simul-1);        
        S_t(i,k)=1-((C_i-mu_y_i)*(B_i-mu_y_i)')/sigma_y_i/(N_unit_simul-1);
                     
    end
      
end
%% Plotting - First order effect
S(:,1)=zeros(length(S(i,1)),1); 
LineSeries={'b','r','k','m','--b','--r','--k','--m',':b',':r',':k',':m'};

figure
for k=1:NbParam
    plot(tgrid, S(k,:),LineSeries{k},'LineWidth',3); hold on
    
end

legend(ParametersNames,'Location','EastOutside');
xlim([0 tgrid(end)]);ylim([0 1.01]);xlabel('Time (day)','Fontsize',14,'Fontweight','bold');
ylabel('First order effect','Fontsize',14,'Fontweight','bold');
set(gca,'Fontsize',12,'Fontweight','bold');
hold off


S_t(:,1)=zeros(length(S(i,1)),1); % just make it 0

%% Plotting - Total effect
figure
for k=1:NbParam
    plot(tgrid, S_t(k,:),LineSeries{k},'LineWidth',3); hold on
    
end

legend(ParametersNames,'Location','EastOutside');
xlim([0 tgrid(end)]);ylim([0 1.01]);xlabel('Time (day)','Fontsize',12,'Fontweight','bold');
ylabel('Total effect','Fontsize',14,'Fontweight','bold');
set(gca,'Fontsize',12,'Fontweight','bold');
hold off

end
