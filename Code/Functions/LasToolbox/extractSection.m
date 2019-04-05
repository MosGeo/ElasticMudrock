function sectionPropFinal = extractSection(char, sectionChar, sectionIndex, cleanedData, isWrapped)

indexs =  sectionIndex(ismember(sectionChar, char));

if strcmp(char, 'A') == false
    sectionPropFinal.variables = [];
    sectionPropFinal.units = []; 
    sectionPropFinal.values = [];
    sectionPropFinal.descriptions = [];
else
    sectionPropFinal = [];
end

if isempty(indexs) == false
    
    for i = 1:numel(indexs)
        
        index = indexs(i);
        [indexStart, indexEnd] = getStartEndIndex(sectionIndex, index);
        sectionData = cleanedData(indexStart:indexEnd);

        if strcmp(char, 'A') == true

            if (exist('isWrapped', 'var') == false) 
                isWrapped = false;
            end

            if isWrapped == false
                sectionDataNum  = cellfun(@(x) str2num(x),sectionData, 'UniformOutput', false);
                sectionProp = cell2mat(sectionDataNum);
                sectionPropFinal = [sectionPropFinal ; sectionProp];
            else
               sectionPropC = extractSection('C', sectionChar, sectionIndex, cleanedData, isWrapped);
               nCurves = size(sectionPropC.variables,1);
               sectionDataString = strjoin(sectionData', ' ');
               sectionDataNum = str2num(sectionDataString);
               sectionPropFinal = reshape(sectionDataNum,nCurves, size(sectionDataNum,2)/nCurves);
               sectionPropFinal  = sectionPropFinal';
            end

        elseif strcmp(char, 'O') == true
            sectionPropFinal = sectionData; 
        else
            sectionProp =  parseSection(sectionData);
            sectionPropFinal.variables = [sectionPropFinal.variables ; sectionProp.variables];
            sectionPropFinal.values = [sectionPropFinal.values ; sectionProp.values];
            sectionPropFinal.descriptions = [ sectionPropFinal.descriptions ; sectionProp.descriptions];
            sectionPropFinal.units = [sectionPropFinal.units ; sectionProp.units];
        end

    end
    
end

end
