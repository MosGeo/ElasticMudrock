function sectionProp =  parseSection(data)

nData = numel(data);

sectionProp.variables= cell(nData, 1);
sectionProp.units = cell(nData,1);
sectionProp.values = cell(nData, 1);
sectionProp.descriptions = cell(nData, 1);

regExpressions = {'\.', '\s', '\:'};
nRegExp = numel(regExpressions);

for i=1:nData
    
    lineSec = cell(nRegExp+1,1);
dataRow = data(i);
for k = 1:nRegExp
   expression = regExpressions{k};
   results = regexp(dataRow,expression, 'split', 'once');
   if numel(results) ==1
        results = results{1};
   end
   lineSec{k} = strtrim(results{1});
   dataRow = results{2};
end
lineSec{k+1} =  strtrim(dataRow);

sectionProp.variables{i} = lineSec{1};
sectionProp.units{i}= lineSec{2};
sectionProp.values{i}= lineSec{3};
sectionProp.descriptions{i}= lineSec{4};


end