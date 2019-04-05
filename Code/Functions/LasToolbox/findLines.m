function indecies =  findLines(startingExpression, data)

nChar = numel(startingExpression);
indecies = find(strncmpi(data,startingExpression,nChar));

end