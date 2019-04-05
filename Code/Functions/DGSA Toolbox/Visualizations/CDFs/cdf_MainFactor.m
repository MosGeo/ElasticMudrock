% This function plots the cdf of a specified parameter for each class
% 
% This function plots the cdf of each parameter for each class
 
% Author: Celine Scheidt
% Date: August 2012

% Modified by Jihoon Park (jhpark3@stanford.edu) on 14 May 2016. The user
% can specify the name of variables of parameters. If not specified, cdfs
% of all parameters will be displayed.

function cdf_MainFactor(ParametersValues,Clustering,ParametersNames, WhichParameter)

%% Input Parameters
%   - ParametersValues: matrix (NbModels x NbParams) of the parameter values
%   - ParametersNames: list containing the names of the parameters
%   - Clustering: Clustering results
%   - WhichParameter(optional): Parameters specified. If omitted, CDFs of
%   all parameters will be displayed.
if nargin<4
    WhichParameter=ParametersNames;
end

ParametersIndex=zeros(1,length(WhichParameter));
for k=1:length(WhichParameter)
    ParametersIndex_value=find(strcmp(ParametersNames,WhichParameter(k)));
    if isempty(ParametersIndex_value)
        error('Enter correct name of parameters')
    else
        ParametersIndex(k)=ParametersIndex_value;
    end
end



%nbparams = size(ParametersValues,2);
nbclusters = length(Clustering.medoids);
C = definecolor(nbclusters);


for k = 1:length(ParametersIndex) 
    i=ParametersIndex(k);
    [f_prior,x_prior] = ecdf(ParametersValues(:,i));  % prior cdf
    
    figure; axes('FontSize',12,'FontWeight','b');hold on;box on;
    stairs(x_prior,f_prior,'LineWidth',4,'Color','k');
    
    for j = 1:nbclusters
        [f_cluster,x_cluster] = ecdf(ParametersValues(Clustering.T ==j,i));  % cdf per cluster
        stairs(x_cluster,f_cluster,'LineWidth',4,'Color',C(j,:));
    end
     xlabel(ParametersNames(i),'fontsize',14,'fontweight','b');ylabel('cdf','fontsize',14,'fontweight','b');
end


end

% Define the color for each class

function C = definecolor(nbclusters)
    Cs = jet(124);
    Ds = floor(linspace(1,size(Cs,1),nbclusters));
    C = Cs(Ds,:);
end

