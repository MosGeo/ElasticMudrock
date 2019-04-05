function density = kerogenRhoFromHC(hcAtomicRatio, molecularWeight, isPlot)
% KEROGENDRHOFROMHC Kerogen density (in kg/m3) from H/C
%
% hcRatio:          Hydrogen to carbon atomic ratio
% molecularWeight:  Molecular weight
%
% Mustafa Al Ibrahim @ 2018
% Mustafa.Geoscientist@outlook.com

%% Preprocessing

% Defaults
if ~exist('isPlot', 'var'); isPlot = false; end
if ~exist('molecularWeight', 'var'); molecularWeight = []; end

% Assertions
assert(exist('hcAtomicRatio', 'var')==true, 'hcAtomicRatio must be provided');
assert(isscalar(isPlot) && isa(isPlot, 'logical'), 'isPlot must be a logical scalar');
assert(isempty(molecularWeight) || numel(hcAtomicRatio)==numel(molecularWeight), 'hcAtomicRatio and molecularWeight must have the same number of elements');


%% Main

% Molecular weight term
if isempty(molecularWeight) 
    molWtTerm = 0; 
else
    molWtTerm = 23.131./(molecularWeight);
end

% Calculate density
density = 1./(0.5129+0.298*(hcAtomicRatio) + molWtTerm);

end