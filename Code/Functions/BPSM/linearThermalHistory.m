function [t, T] = linearThermalHistory(heatingRate, maxT, Ti, dT, isInputInMa)
% LINEARTHERMALHISTORY    Linear thermal history profile
%
% 
%
% Mustafa Al Ibrahim @ 2018
% Mustafa.Geoscientist@outlook.com

%% Preprocessing

% Defaults
if ~exist('isInputInMa', 'var'); isInputInMa = false; end

%% Main

T = Ti:dT:maxT;
dt = dT/heatingRate;
t = 0:dt:(numel(T)*dt-dt);

if (isInputInMa)
    t = millionYearsToSeconds(t);
end

t = t(:);
T = T(:);

end