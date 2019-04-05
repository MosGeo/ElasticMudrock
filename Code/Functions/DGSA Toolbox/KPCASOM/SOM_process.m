function [ classes ] = SOM_process( Y, NumNodes )
%This function runs SOM to get the spatial rank of each realization
% Y is the coordinate values (obtained from kPCA) in the NRealziations dimensions; NumNodes is
% number of nodes in the SOM, here we set it equal to number of
% realizations because we attempt to get a distinctive number for each model
% Author: Guang Yang

input_vector=Y';
%put NumNodes nodes in the first dimension
net1 = selforgmap([NumNodes 1]);

%train the SOM
net1= train(net1,input_vector);

%plot the SOM
plotsompos(net1,input_vector);


%use the som to classify the cluster
y1=net1(input_vector);

%change the matrix to a vector of classes
classes=vec2ind(y1);

end

