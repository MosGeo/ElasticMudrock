function s = millionYearsToSeconds(ma)
% MILLIONYEARSTOSECONDS Million years to seconds
%
% ma:                     Million years
%
% Mustafa Al Ibrahim @ 2018
% Mustafa.Geoscientist@outlook.com

%% Preprocessing

% Assertions
assert(isnumeric(ma), 'Ma must be numeric');

% Constants
millionYearsInSeconds = 31557600000000;
% millionYearsInSeconds = 31560000000000;
%millionYearsInSeconds = 31600000000000; % To match Alan's Excel sheet

%% Main

s = ma * millionYearsInSeconds;


end