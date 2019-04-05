function R = randInterval(nSamples, minValue, maxValue, isLog)
%% randInterval  Uniformly sample from an interval
%
%   nSamples:                 Number of samples    (integer >=1)
%   maxValue:                 Maximum value
%   minValue:                 Minimum value
%   isLog:                    Is logrethmic?
%
%   See also RAND, RANDCOMPOSITIONAL.

% Mustafa Al Ibrahim @ 2018
% Mustafa.Geoscientist@outlook.com

%% Preprocessing

% Defaults
if ~exist('nSamples','var');    nSamples    = 1; end
if ~exist('maxValue','var');    maxValue    = 1; end
if ~exist('minValue','var');    minValue    = 0; end
if ~exist('isLog','var');       isLog       = false; end

% Assertions
assert(floor(nSamples)==nSamples && isscalar(nSamples) && nSamples>=1, 'nSamples must be an integer >=1');
assert(isscalar(maxValue), 'maxValue must be a scalar');
assert(isscalar(minValue), 'minValue must be a scalar');
assert(maxValue >= minValue, 'maxValue must be bigger than minValue');
assert(isscalar(isLog) && isa(isLog,'logical'), 'isLog must be logical'); 

%% Main

if(isLog)
    maxValue = log10(maxValue);
    minValue = log10(minValue);
end

R = (maxValue-minValue).*rand(nSamples,1) + minValue;

if(isLog)
    R = 10.^R;
end

end