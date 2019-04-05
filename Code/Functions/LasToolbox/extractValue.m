function [value, description] =  extractValue(var, sectionProp)

index = find(ismember(sectionProp.variables,var),1);
value = sectionProp.values(index);
description = sectionProp.descriptions(index);


end