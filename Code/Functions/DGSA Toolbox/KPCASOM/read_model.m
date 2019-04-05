function [ realization ] = read_model( filename )
%this function reads in the spatial model
%   Detailed explanation goes here

fileID=fopen(filename,'r');

C=textscan(fileID,'%f', 'HeaderLines',3);
realization=C{1};



end

