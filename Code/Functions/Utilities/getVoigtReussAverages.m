function results = getVoigtReussAverages(componentsInput, fractionMatrix)
%getVoigtRuessAverages Get the Voight and Ruess Averages.
%   [ReussMod, VoigtMod] = getVoigtRuessAverages(components, 
%   fractionMatrix) returns the Voigt and Reuss averages for the different
%   components of the rock given fractions.
%
%   Mustafa Al Ibrahim (Mustafa.Geoscientist@outlook.com)
%   Febuary, 2017


%% Main

% Extract data if table is provided
if isa(componentsInput, 'table') == true
    components = componentsInput{:,:};
else
    components = componentsInput;
end

nModuli = size(components,2);
nFractions = size(fractionMatrix,2);

results = zeros(3, nModuli);
for i=1:nModuli
    currentModlus = components(:,i);
    reuss = sum(fractionMatrix)./sum(fractionMatrix ./ repmat(currentModlus,1, nFractions));
    voight = sum(fractionMatrix .* repmat(currentModlus,1, nFractions))./sum(fractionMatrix);
    hill =  ( reuss + voight)./2;
    
    reuss(isnan(reuss)) = 0;
    voight(isnan(voight)) = 0;
    hill(isnan(hill)) = 0;

    results(1,i) = reuss;
    results(2,i) = voight;
    results(3,i) = hill;
end

% Return table format if table format is provided
if isa(componentsInput, 'table') == true
    results = array2table(results, 'RowNames', {'Reuss', 'Voight', 'Hill'}, 'VariableNames', componentsInput.Properties.VariableNames);
end

end

