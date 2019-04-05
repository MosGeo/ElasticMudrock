function Ro = tMax2Ro(tMax)
%% TMAX2RO  Returns the estimated Vitrinite reflectance
%
% tMax:                       Temperature (C)
%
% Based on:
%   Jarvie, D. M., Claxton, B., Henk, B., and Breyer, J., 2001, Oil and 
%   shale gas from Barnett shale, Ft. Worth basin, Texas: Presented at the
%   AAPG National Convention, Denver, CO, June 3-6.
%
% Mustafa Al Ibrahim @ 2018
% Mustafa.Geoscientist@outlook.com

%% Preprocess

% Assertions
assert(isnumeric(tMax), 'tMax has be numeric')

%% Main

% See paper (not suitable for type I)
Ro = 0.0180 * tMax - 7.16;





end