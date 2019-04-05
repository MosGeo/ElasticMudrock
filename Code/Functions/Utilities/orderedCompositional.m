function combs = orderedCompositional(nComponents, delta)

% Based on: 
% 1. https://stackoverflow.com/questions/6607355/matlab-enumerating-all-combinations-of-items-in-an-arbitrary-number-of-sets
% 2. https://www.mathworks.com/matlabcentral/fileexchange/10064-allcomb-varargin

%% Preprocessing

% Assertions
assert(mod(1/delta,1)==0, '1/delta must be an integer');

%% Main

k = nComponents-1;
values = 0:delta:1;

ip = repmat({values},k,1);
ncells=length(ip);
[nd{1:ncells}]=ndgrid(ip{:});
catted=cat(ncells,nd{1:ncells});
combs=reshape(catted,length(catted(:))/ncells,ncells);

combs = combs(sum(combs,2)<=1,:);
combs = [combs, 1-sum(combs,2)];

end
