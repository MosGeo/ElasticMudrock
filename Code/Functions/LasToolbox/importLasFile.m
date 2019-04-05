function [dataTable, depth, lasHeader , isSuccess] = importLasFile(fullFileName, curvesToUse)


%% Load the File

% Open The Text File and Read it
fileID = fopen(fullFileName,'r');
formatSpec = '%s';
selectedData = textscan(fileID, formatSpec,  'Delimiter', '\n');
fclose(fileID);

clear fileID formatSpec;
%% Check the validity of the file
% Check if something is loaded and terminate if nothing found in the file
if isempty(selectedData) == false
    selectedData = selectedData{1};
else
    curvesData = [];
    curvesNames =[];
    lasHeader = [];
    isSuccess = false;
    return
end

%% Clean-up

cleanedData = selectedData;
% Remove Comment Lines in the LAS file
commentIndex =  findLines('#', cleanedData);
cleanedData(commentIndex) =[];

clear expression nChar commentIndex

%% Get the Location of the Sections

% Get the location of the section blocks and add the end of the file
sectionIndex =  findLines('~', cleanedData);
sectionNames = cleanedData(sectionIndex);
sectionChar = cellfun(@(x) x(2), sectionNames, 'UniformOutput', false);
sectionIndex(end+1) = size(cleanedData,1)+1;

clear sectionNames
%% Get Headers
lasHeader.version = extractSection('V', sectionChar, sectionIndex, cleanedData);
lasHeader.well = extractSection('W', sectionChar, sectionIndex, cleanedData);
lasHeader.parameter = extractSection('P', sectionChar, sectionIndex, cleanedData);
lasHeader.other = extractSection('O', sectionChar, sectionIndex, cleanedData);
lasHeader.curves = extractSection('C', sectionChar, sectionIndex, cleanedData);

%% Check for Wrapping

wrapIndex = find(ismember (lasHeader.version.variables, 'WRAP'),1, 'first');

if (strcmp(upper(lasHeader.version.values{wrapIndex}),'YES'))
    isWrapped = true;
else
    isWrapped = false;
end

%% Extract Data
curvesNames = lasHeader.curves.variables ;
curvesData = extractSection('A', sectionChar, sectionIndex, cleanedData, isWrapped);

depth = curvesData(:,1);
dataTable = array2table(curvesData);
curvesNames = arrayfun(@(x) regexprep(x,'[\[\]]','_'),curvesNames);
curvesNames = arrayfun(@(x) regexprep(x,'-','_'),curvesNames);
dataTable.Properties.VariableNames = curvesNames;

if(exist('curvesToUse','var') == true)
    dataTable = dataTable(:,curvesToUse);
else
    dataTable = dataTable(:,1:end);
end
    
%% Final things in the function
isSuccess = true;

end
