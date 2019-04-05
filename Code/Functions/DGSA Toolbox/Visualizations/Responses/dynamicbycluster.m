function dynamicbycluster(Clustering,responses,C,Labels)
% The function displays responses by clusters.
% The color corresponds to the result of MDS plot from 'DisplayMDSplot.m'
% Author: Jihoon Park (jhpark3@stanford.edu)
%
% Input:
% Clustering: Clustering results. See kmedoid.m for details
% response: (cell, # of wells x # of models) contains all reservoir responses.
% Each cell has the matrix of (# of timesteps x 2), where 2nd column has actual response. 
% Labels: Labels neede for plotting
%         Labels.xlimits: vector of min/max time
%         Labels.ylimits: vector of min/max responses  
%         Labels.xlabtxt: string of lables of x axis
%         Labels.ylabtxt: string of lables of y axis


%% Assign varariables


NbProd=size(responses,1); % # of proudcing wells.
legendtext=cell(1,length(Clustering.medoids));

figure;hold on;
for j=1:NbProd
   responses_Prod_h=responses(j,:);
   subplot(1,NbProd,j)
   title(['Prod ',num2str(NbProd)]);
   %legend_str={};
   for k=1:length(Clustering.medoids)
    %   legend_str{k}=['Cluster',num2str(k)];
       idx=find(Clustering.T==k);
       data_h=responses_Prod_h(:,idx);
       legendtext{k}=sprintf('Cluster %i',k);
       

       for i=1:length(data_h)
           
           data_h2=data_h{i};
          
           time_h=data_h2(:,1);
           dynamic_h=data_h2(:,2);
           h_h=plot(time_h,dynamic_h,'Color',C(k,:));

           hold on
       end
       h(k)=h_h;
       
   end
   
   
   

   legend(h,legendtext,'Location','northwest');
   xlim(Labels.xlimits); ylim(Labels.ylimits);

   title(['Prod ',num2str(j+1)]);
   xlabel(Labels.xlabtxt); ylabel(Labels.ylabtxt);
   hold off
    
end
