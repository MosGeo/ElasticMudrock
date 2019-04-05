function H=DisplayHplot(GlobalSensitivityInteractions,StandardizedSensitivity,ParametersNames, ScaleFactor, Fontsizes)
%%
% The function displays h-plot from conditional effects
% Author: Jihoon Park (jhpark3@stanford.edu)
% Reference: 
% Epifanio I., 2014. Mapping the asymmetrical citation relationships between journals by h-plots. Journal of the Association for Information Science and Technology, 65 (6), 1293-1298.  
% Park et al., 2016. DGSA: a matlab toolbox for distance-based generalized sensitivity analysis for geoscientific computer experiments
% 
%
% Input: 

% GlobalSensitivityInteractions:(4D array, (# of parameters) x (# of parameters-1) x (# of clusters) x (maximum value of bins)): 
%           Element (i,j,c,l)  corresponds to conditional effect of i-th parameter conditioned to  
%           l-th bin of  j-th parameter from class c . 
%
% StandardizedSensitivity: (vector, length=# of parameters) Main effects averaged over clusters.
% ParametersNames: (cell, length= # of parameters) Names of parameters
% ScaleFactor: (scalar) Value to scale the size of bubble on h-plot. Higher value decreases the size of bubbles. 
% Fontsizes: (scalar) Fontsize of names of parameters in h plot

% Output:

% H: Coordinates of each parameter at h-plot

NbParams=length(ParametersNames);
dims=2; % Dimension of h-plot. 

X=GetAsymmetricDistanceHplot(GlobalSensitivityInteractions,NbParams);
S=cov(X); % Get the covariance matrix.

[q, lambda_vec]=eig(S); lambda_extract=diag(lambda_vec); % Eigenvalue decomposition
q1=q(:,end); q2=q(:,end-dims+1); lambda1=sqrt(lambda_extract(end)); lambda2=sqrt(lambda_extract(end-1));
H=[lambda1*q1, lambda2*q2]; % Retrieve the coordinates

n=size(H,1);
figure; hold on
ColorVector=zeros(size(H,1),1);
ColorVector(1:n/2)=1;

StandardizedSensitivity=[StandardizedSensitivity;StandardizedSensitivity];
ParametersNames=[ParametersNames,ParametersNames];
for k=1:size(H,1)    
  
    if ColorVector(k)==1
        colorv='g';
    else
        colorv='m';
    end
    
    filledCircle(H(k,:),StandardizedSensitivity(k)/ScaleFactor,100,colorv);axis('equal'); % Place bubbles on h-plot
    alpha(0.5);
        
    text(H(k,1),H(k,2),ParametersNames{k},'HorizontalAlignment','center','Fontsize',Fontsizes, 'Fontweight','Bold');
    
end
hold off
grid off

set(gca,'XTickLabel',{''})
set(gca,'YTickLabel',{''})
set(gcf,'Color','w');
set(gca,'LineWidth',2);
box on; set(gca,'LineWidth',3);


lambda_extract=flipud(lambda_extract);
lambdasq_seq_sum=cumsum(lambda_extract.^2);
lamdasq_sum=lambda_extract'*lambda_extract;
lambdasq_seq_sum=lambdasq_seq_sum/lamdasq_sum;
lambdasq_seq_sum=[0;lambdasq_seq_sum];
indexi=0:length(lambdasq_seq_sum)-1;figure;
plot(indexi,lambdasq_seq_sum,'LineWidth',3);

%set(gca,'XTick',[0:length(lambdasq_seq_sum)]);
set(gca,'Fontsize',12);
set(gca,'Fontsize',12);
xlabel('Dim','Fontsize',14);
ylabel('Goodness of fit','Fontsize',14);

end
