function D=GetDistMatrixfromInterSens(A,NbPara)
%%
% The function computes symmetric distance matrix from conditional effects.
% Author: Jihoon Park (jhpark3@stanford.edu)
% Date: March, 2015
%
% Input:

% A: : (vector, length=(# of parameters) x (# of parameters -1)) Conditional effects averaged over bins and classes.
% NbPara: (scalar) # of parameters
% 
% Output:
% D: (matrix, # of parameters x # of parameters) Distance matrix used in bubble plot. 
%%
NbInterPer=NbPara-1; % Each parameter has one less conditional effects
A_reshaped=reshape(A,NbInterPer,[]);
A_augmented=zeros(NbPara);

for k=1:NbPara
   
    A_augmented(:,k)=InsertNumVec(A_reshaped(:,k),k,-999);
    
end

D=zeros(NbPara);
for i=1:NbPara-1
    
    for j=i+1:NbPara
        
        D(i,j)=1/((A_augmented(i,j)+A_augmented(j,i))*.5);
       
    end
end

D=D+D';