function [TR, F] = arrhenius(t, T, A, E, f, isUpsampled, dT)


%% Preprocessing

% Defaults
if ~exist('isUpsampled', 'var'); isUpsampled = true; end
if ~exist('dT', 'var'); dT = .1; end

% Assertions
assert(isnumeric(t) && isnumeric(T), 't and T must be numeric');
assert(isnumeric(A) && isnumeric(f) && isnumeric(E), 'A, f, and E must be numeric');
assert(iscolumn(E), 'E must be a column');
assert(numel(t) == numel(T), 't and T must be the same length');
assert(size(f,1) == size(E,1), 'f and E must be the number of rows');
assert(numel(A) == 1 ||  numel(A) == numel(E), 'A must be scaler or the same length as E');
assert(numel(unique(t)) == numel(t), 't values must be unique');

% Constants
R = 1.987203611E-3;     % Gas constant [kcal K-1 mol -1]

%% Main

if (isUpsampled)
    lowResTime = t;
    [t, T] = upsampleThermalHistory(t, T, dT);
end

% Calculation
dt = diff(t);
dt = [0, dt(:)'];
%T = diff(T)/2 + T(1:end-1);

w = f;
TR = zeros(size(T));
F  = zeros(numel(T), size(f,2));
for i = 1:numel(T)
    T_K    = T(i)+ 273.16;
    k    =  A .* exp (-E./(R*T_K));
    dwdt = -w.*k;
    wNew = w + dwdt * dt(i);
    wNew(wNew<0)= 0;
    
    F(i,:) = sum(f) - sum(wNew);
    TR(i)    = 1 - sum(wNew(:)) ./ sum(f(:));
    w = wNew;
end

if (isUpsampled)
F  = interp1(t, F, lowResTime);
TR = interp1(t, TR, lowResTime);
end


end