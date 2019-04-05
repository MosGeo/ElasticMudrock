function [hcRatio, TR, wtPerCarbonLossOutput] = calcHcRatio(kerogenType, maxWtPerCarbonLossUser, hcInitialUser, hcCutoffs, hcLossRates, wtPerCarbonLoss, isPlot)
% HCRATION    Calculate atomic H/C based on loss rate 
%
%
% Mustafa Al Ibrahim @ 2018
% Mustafa.Geoscientist@outlook.com

%% Preprocessing

% Data
atomicHwt = 1.008;
atomicCwt = 12.0107;
switch kerogenType
    case 'I'
        hcInitial = 1.59;
        maxWtPerCarbonLoss = .75;
    case 'II'
        hcInitial = 1.28;
        maxWtPerCarbonLoss = .45;
    case 'III'
        hcInitial = .90;
        maxWtPerCarbonLoss = .15;       
end

hcCutoffs = [1, .75];
hcLossRates = [1.85, 3, 4];

% Defaults
if ~exist('isPlot', 'var'); isPlot = false; end

if exist('maxWtPerCarbonLossUser', 'var')== true; maxWtPerCarbonLoss = maxWtPerCarbonLossUser; end
if exist('hcInitialUser', 'var')== true; hcInitial = hcInitialUser; end
if ~exist('wtPerCarbonLoss', 'var'); wtPerCarbonLoss = 0:0.001:maxWtPerCarbonLoss; end

%% Main 1: Deterimine weight percent carbon loss cutoffs

isUsed = hcCutoffs< hcInitial;
hcCutoffsUsed = hcCutoffs(isUsed);
hcLossRatesUsed = hcLossRates([isUsed, true]);

cWtCurrent = atomicCwt;
wtPerCarbonLossCurrent = 0;
hAtomicCurrent = hcInitial;
cAtomicCurrent = 1;

wtCutoffs = zeros(1, numel(hcCutoffsUsed)+1);
for i = 1:numel(hcCutoffsUsed)
   hcCutoff   = hcCutoffsUsed(i);
   hcLossRate = hcLossRatesUsed(i);
   
   c = cAtomicCurrent;
   h = hAtomicCurrent;
   w = cWtCurrent;
   p = wtPerCarbonLossCurrent;
   l = hcLossRate;
   a = atomicCwt;

   wtCutoff = w/a + (-c*l + h + l*p - p*hcCutoff)/(l-hcCutoff);
   
   % Update the variables
   cWt     = cWtCurrent-atomicCwt*(wtCutoff-wtPerCarbonLossCurrent);
   cAtomic = cWt/atomicCwt;
   hAtomic = hAtomicCurrent - (cAtomicCurrent-cAtomic) * hcLossRate;
     
   wtPerCarbonLossCurrent = wtCutoff;
   hAtomicCurrent = hAtomic;
   cAtomicCurrent = cAtomic;
   cWtCurrent = cWt;
   
   % Store the cutoff
   wtCutoffs(i) = wtCutoff;
   
end
wtCutoffs(end) = max(wtPerCarbonLoss);

%% Main 2 : Calculate the H/C ratio

isCutoffNeeded = wtCutoffs < max(wtPerCarbonLoss);
wtPerCarbonLossWithCutoffs = sort([wtPerCarbonLoss, wtCutoffs(isCutoffNeeded)]);

cWtCurrent = atomicCwt;
wtPerCarbonLossCurrent = 0;
hAtomicCurrent = hcInitial;
cAtomicCurrent = 1;

hcRatio = zeros(size(wtPerCarbonLossWithCutoffs));
TR      = zeros(size(wtPerCarbonLossWithCutoffs));

for i=1:(sum(isCutoffNeeded)+1)
    
    wtCutoff = wtCutoffs(i);
    hcLossRate = hcLossRatesUsed(i);
    
    selection = wtPerCarbonLossWithCutoffs >= wtPerCarbonLossCurrent & wtPerCarbonLossWithCutoffs <= wtCutoff;
    
    % Carbon weight
    cWt     = cWtCurrent-atomicCwt*(wtPerCarbonLossWithCutoffs(selection)-wtPerCarbonLossCurrent);

    % Number of atoms
    cAtomic = cWt/atomicCwt;
    hAtomic = hAtomicCurrent - (cAtomicCurrent-cAtomic) * hcLossRate;

    % Hydrogen weight
    hWt = hAtomic*atomicHwt;

    % H/C ration
    hcRatio(selection) = hAtomic./cAtomic;
    hcRatio(hcRatio<0) = 0;

    % Transformation ratio
    TR(selection) = wtPerCarbonLossWithCutoffs(selection)/maxWtPerCarbonLoss;
    
    wtPerCarbonLossCurrent = wtCutoff;
    hAtomicCurrent = hAtomic(end);
    cAtomicCurrent = cAtomic(end);
    cWtCurrent = cWt(end);

end

wtPerCarbonLossOutput = wtPerCarbonLossWithCutoffs;

%% Plotting

if isPlot
    figure('Color', 'White')
    scatter(wtPerCarbonLossWithCutoffs, hcRatio)
    xlabel('Wt. % Carbon Loss')
    ylabel('Atomic H/C')
    box on
    ylim([.4, 1.8])
    xlim([0, 1])
end

end