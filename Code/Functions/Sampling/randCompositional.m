function R = randCompositional(nComponents, nSamples, maxValues, isPlot, minValues)
%% RANDCOMPOSITIONAL  Uniformly sample compositional space
%
%   nComponents:              Number of components (integer >=1)
%   Lability:                 Number of samples    (integer >=1)
%
%   See also GAMRND, EXPRND, RAND.

% Based on:
%   Aitchison, J., 1986, The statistical analysis of compositional data, 
%   Chapman & Hall Ltd, Springer, 436 p. 
%
% Mustafa Al Ibrahim @ 2018
% Mustafa.Geoscientist@outlook.com

%% Preprocess

% Defaults
if ~exist('nComponents','var'); nComponents = 3; end
if ~exist('nSamples','var');    nSamples    = 1; end
if ~exist('isPlot','var');      isPlot    = false; end

% Assertions
assert(floor(nComponents)==nComponents && isscalar(nComponents), 'nComponents needs to be an integer >=1');
assert(floor(nSamples)==nSamples && isscalar(nSamples), 'nSamples needs to be an integer >= 1');
assert(rem(nComponents,1)==0, 'nComponents needs to be an integer >=1');
assert(rem(nSamples,1)==0, 'nSamples needs to be an integer >= 1');
assert(isa(isPlot, 'logical'), 'isPlot must be a boolean');

% Defaults 2
if ~exist('maxValues','var'); maxValues = ones(1,nComponents); end
if ~exist('minValues','var'); minValues = zeros(1,nComponents); end

% Assertions 2
assert(isnumeric(maxValues), 'maxValues needs to be numeric');
assert(numel(maxValues)==nComponents, 'maxValues to have nComponents elements');
assert(isnumeric(minValues), 'minValues needs to be numeric');
assert(numel(minValues)==nComponents, 'minValues to have nComponents elements');

%% Main
R = [];

% While loop because of rejection sampling for truncation
while size(R,1) < nSamples
        
    % Sample from a Dirichlet distribution with A = 1, B = 1;
    A = 1;
    B = 1;
    r = gamrnd(A,B, [nSamples, nComponents]);
    %r = exprnd(B,[nSamples, nComponents]);  % Another way is using exponential as the gamma with alpha 1 is = exponential 
    r = r./sum(r,2);

    % Truncate
    indexToKeepMax = all(r <= maxValues,2);
    indexToKeepMin = all(r >= minValues,2);
    indexToKeep = indexToKeepMax & indexToKeepMin;
    r = r(indexToKeep,:);
    R = [R;r];
end

R = R(1:nSamples,:);

%% Plotting
if isPlot == true
    colors = rand(nSamples, nComponents)*(.6-.4)+.4;
    figure('Color', 'White')
    for i = 1:min(nSamples,1000)
        plot(R(i,:), 'Color', colors(i,:), 'LineWidth', .5); hold on;
    end
    plot(mean(R,1), 'k', 'LineWidth', 2)
    xlabel('Component number');
    ylabel('Fraction')
    ylim([0 1])
    xticks(1:nComponents)
end

end