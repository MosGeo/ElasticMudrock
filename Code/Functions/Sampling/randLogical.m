function R = randLogical(nSamples)
%% RANDLOGICAL  Sample random true and false
%
%   nSamples:                 Number of samples    (integer >=1)
%
%   See also RAND, RANDINTERVAL, RANDCOMPOSITIONAL.

% Mustafa Al Ibrahim @ 2018
% Mustafa.Geoscientist@outlook.com

%% Preprocessing

% Defaults
if ~exist('nSamples','var');    nSamples    = 1; end

% Assertions
assert(floor(nSamples)==nSamples && isscalar(nSamples) && nSamples>=1, 'nSamples must be an integer >=1');

%% Main

R = logical(randsample(2,nSamples, true)-1);

end
