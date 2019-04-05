function DataStruct=ProcessInputParameters(FileName,DataStruct)
% The function proceses Monte Carlo results of Parameters to use in DGSA
%
% Author: Jihoon Park (jhpark3@stanford.edu)
% Date: 12 May 2016

% Input :
%
% FileName: (string) Name of the file that contains name of parameters and values from Monte Carlo simulations.
% DataStruct: Data structure containing results of DGSA.


% Output:
% DataStruct: Data structure containing results of DGSA.
%   .ParametersNames: (cell, length=# of parameters) contains the names of parameters
%   .ParametersValues: (matrix, # of models x # of parameters) contains values of each parameter from Monte Carlo sampling.
%   .N:(scalar) # of models (sample size)

%% 1. Import data
DataImported=importdata(FileName);

%% 2. Save data at DataStruct
DataStruct.ParametersNames=DataImported.textdata(1,2:end); % Names of parameters
DataStruct.ParametersValues=DataImported.data; % Values of Parameters
DataStruct.N=size(DataStruct.ParametersValues,1); % Sample size

end