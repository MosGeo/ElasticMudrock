function [ndim]=ploteigvalue( eigValue,threshold )
%This function plots the contribution of each eigenvector
%   Detailed explanation goes here
set(0, 'DefaultAxesFontSize', 18); 

ncomponent=length(eigValue);
percentage=cumsum(eigValue);
percentage=percentage/sum(eigValue);
%find the dimension threshold
idx=find(percentage>threshold);
ndim=min(idx);

figure;
plot(1:ncomponent,percentage,'b-','LineWidth',2);
xlabel('# of eigenvalue');
ylabel('accumulative contribution');
end

