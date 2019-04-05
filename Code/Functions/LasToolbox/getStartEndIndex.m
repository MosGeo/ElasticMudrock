function [startIndex, endIndex] = getStartEndIndex(sectionIndex, headerIndex)

startIndex = headerIndex +1;
endIndex = sectionIndex(find(sectionIndex == headerIndex)+1)-1;

end
