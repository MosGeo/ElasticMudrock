function [effK, effG, effRho, phi, TR] = modelKerogenShublik(RoToAnalyze, kerogenK, kerogenG, ...
    fluidK, fluidRho, alpha, beta, maxPhi, phiAlpha, freqType, roModel, t, T)

maxT = 180;
Ti = 0;
H = 3;
dT = 1;
[t, T] = linearThermalHistory(10, 300, 25, 0.5, true);
A = 15598000000000;
f = [0.7764, 0.026, 0.1799, 0, 0.0176]';
E = [51, 52, 53, 54, 55]';
[t, T] = linearThermalHistory(H, maxT, Ti, dT, true);
[F, TR1, Ro1]= runPyrolysis('Yurchenkoa et al., 2018', 'EasyDL', t,T, A, f, E);
A = 30767000000000;
f = [.8426, 0, .1521, .0053]';
E = [52, 53, 54, 55]';
[t, T] = linearThermalHistory(H, maxT, Ti, dT, true);
[F, TR2, Ro2] = runPyrolysis('Yurchenkoa et al., 2018', 'EasyDL', t,T, A, f, E);
A = 1.338e13;
f = [.8559, .0013, .1255, .0113, .006]';
E = [51, 52, 53, 55, 63]';
[t, T] = linearThermalHistory(H, maxT, Ti, dT, true);
[F, TR3, Ro3] = runPyrolysis('Masterson, 2001', 'EasyDL', t,T, A, f, E);
TR = 0:.001:1;
Ro1Interp =interp1(TR1,Ro1,TR, 'linear', 'extrap');
Ro2Interp =interp1(TR2,Ro2,TR,  'linear', 'extrap');
Ro3Interp =interp1(TR3,Ro3,TR,  'linear', 'extrap');
Ro = (Ro1Interp+Ro2Interp+Ro3Interp)/3;
[F, TRs, Ros] = runPyrolysis(2, 'EasyDL', t,T, A, f, E);
if RoToAnalyze < min(Ro) ; RoToAnalyze = min(Ro); end
phiTR = interp1(Ro, TR, RoToAnalyze);

i=3;
maxPhis = [.71, .43, .12];
kerogenNames = {'I', 'II','III'};

[phi] = kerogenPorosityMaxPhi(phiTR,  maxPhis(i));
[hcRatio, hcTR] = calcHcRatio(kerogenNames{i});
density = kerogenRhoFromHC(hcRatio);
density = interp1(hcTR, density, phiTR)*1000;    
effRho = density.*(1-phi) + phi * fluidRho;

% Insert pore and fluid
if phi > 0 
    if freqType == 0
        [effK, Gkerogen] = differentialEffectiveMedium(kerogenK, kerogenG, 0,0, phi, phiAlpha);
        effK  = gassmnk(effK, 0, fluidK, kerogenK, phi);
        effG  = Gkerogen;
    else 
        [effK, effG] = differentialEffectiveMedium(kerogenK, kerogenG, fluidK,0, phi, phiAlpha);
    end
else
    effK = kerogenK;
    effG = kerogenG;
end

end
