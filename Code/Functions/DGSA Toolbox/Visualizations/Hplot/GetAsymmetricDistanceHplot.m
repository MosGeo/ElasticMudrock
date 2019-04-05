function X=GetAsymmetricDistanceHplot(A,NbPara)
%The function computes the asymmetric distance matrix to use for h-plot. 
% 
% Author : Jihoon Park
% Date: March, 2015
% This scripts returns X=[D'|D] where D is asymmetric distance amtrix 

%% Input
% A: (vector, length=(# of parameters) x (# of parameters -1)) Conditional effects averaged over bins and classes.
% NbPara : (scalar) # of Parameters. 

%% Take the inverse first.
A=1./A; 

%% Construct asymmetric distance matrix
NbInterPer=NbPara-1;                      
                     
A_reshaped=reshape(A,NbInterPer,[]);
A_augmented=zeros(NbPara);

for k=1:NbPara
   
    A_augmented(:,k)=InsertNumVec(A_reshaped(:,k),k,0);
    
end

D=A_augmented;
X=[D, D'];
