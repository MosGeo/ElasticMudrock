function Ro = TR2Ro(TR)
%Ro2TR Reflictivity Index to Tranformation Ratio
%   based on Bordenave et al., 1993.
%
% Mustafa Al Ibrahim @ 2018
TR = TR*100;
Ro = 1/(-12.068) * log((100./TR-1)/20645.5);

end
