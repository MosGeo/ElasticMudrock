function [R, binary] = randCategorical(nSamples, nCategories, isConvertToInt)
%% RANDCATEGORICAL   Sample random categorical
%
%   nSamples:                 Number of samples    (integer >=1)
%   nCategories:              Number of categories (integer >=2)
%   isConvertToInt:           Convert samples to integers
%
%   See also RAND, RANDINTERVAL, RANDCOMPOSITIONAL.

% Mustafa Al Ibrahim @ 2018
% Mustafa.Geoscientist@outlook.com

%% Preprocessing

% Defaults
if ~exist('nSamples','var');       nSamples     = 1; end
if ~exist('nCategories','var');    nCategories  = 2; end
if ~exist('isConvertToInt','var'); isConvertToInt = false; end

% Assertions
assert(floor(nSamples)==nSamples && isscalar(nSamples) && nSamples>=1, 'nSamples must be an integer >=1');
assert(floor(nCategories)==nCategories && isscalar(nCategories) && nCategories>=2, 'nCategories must be an integer >=2');
assert(nCategories < (2^64-1), 'nCategories must be smaller than 2^64 - 1');

%% Main

% sample
R = randsample(nCategories,nSamples, true);

% Convert to integer
if isConvertToInt == true
    if (nCategories < intmax('uint8'))
        R = uint8(R);
    elseif (nCategories < intmax('uint16'))
        R = uint16(R);
    elseif (nCategories < intmax('uint32'))
        R = uint32(R);
    elseif (nCategories < intmax('uint64'))
        R = uint64(R);
    end 
end

% Binary represenattion
binary = zeros(nSamples, nCategories);
for iCategory = 1:nCategories
    binary(:,iCategory) = R==iCategory;
end

end