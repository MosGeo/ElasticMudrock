%
% This function applies a k-medoid algorithm for the given distance matrix
 
% Author: Celine Scheidt
% Date: April 2009
% Updated: February 2013


function Clustering = kmedoids(D,nbclusters,nbrep)

%% Input Parameters
%   - D: distance matrix to use
%   - nbclusters: number of clusters to construct
%   - nbrep: (optional). Number of kmedoid to be performed. The best cluster 
%                       configuration is returned

%% Output Parameters 
%   - Clustering: Results of the clustering, which contains:
%        - label: is a vector of length Nbmodels, which contains the cluster index that each model belongs to
%        - medoids: is a vector of length nbcluster containing the index
%                   of the medoids
%        - weights: is a vector of ength nbcluster containing the number
%                   of models in each cluster.
%


% Reference: http://en.wikipedia.org/wiki/K-medoids
%            Kaufman, L. and Rousseeuw, P.J. (1987), Clustering by means of Medoids, 
%            in Statistical Data Analysis Based on the �Norm and Related Methods, 
%            edited by Y. Dodge, North-Holland, 405�416.


if size(D,1) == 1
    D = squareform(D);
end

maxIterations = 50;
npoints = size(D,1);
minDistBest = Inf;

if nargin < 3
    nbrep = 1;
end


for iter = 1:nbrep % nbrep clustering are performed, the best is returned
    
    % 1. Initalize: randonly select nbclusters of the npoints data points as the medoids
    initMedoids = randsample(npoints,nbclusters);

    
    % 2. Associate each data point to the closest medoid
    [minDistInit, label] = min(D(initMedoids,:));

    currentMedoids = initMedoids;
    minDistCurrent = minDistInit;
    
    label_prev = NaN(1,npoints);
    nbIter = 0;
    
    while any(label ~= label_prev) && nbIter < maxIterations % while cluster configuration is changing and maxIteration not reached
              
        label_prev = label;
        
        % 3. For each medoid m
        for m = 1:nbclusters
            
            NoMedoid = setdiff(1:npoints,currentMedoids);
            NewMedoids = currentMedoids;
            
             % For each non-medoid data point o
            for o = 1:length(NoMedoid)               
                % Swap m and o and compute the cost of the configuration
                NewMedoids(m) = NoMedoid(o);
                [minDist, label] = min(D(NewMedoids,:));
                cost = sum(minDist) - sum(minDistCurrent);
                
                if cost < 0  % 4. Select the configuration with the lowest cost
                    currentMedoids(m) = NoMedoid(o);
                    [minDistCurrent, label] = min(D(currentMedoids,:));
                end
            end          
        end
        nbIter = nbIter+1;
    end
    
    currentMedoids = sort(currentMedoids);
    [minDist, label] = min(D(currentMedoids,:));

    
    % Return the best clustering configuration among the nbrep tested
     if sum(minDist) < sum(minDistBest) 
        fprintf('minDist % .2f, iter %i \n',sum(minDist),iter)
        minDistBest = minDist;
        labelBest = label;
        currentMedoidsBest = currentMedoids;
    end
end

%% Once the medoids are defined, store the outputs
weights = zeros(nbclusters,1);
for i = 1:nbclusters
    weights(i) = sum(labelBest == i);
end
    
Clustering.T = labelBest;  
Clustering.medoids = currentMedoidsBest';  
Clustering.weights = weights;

end


