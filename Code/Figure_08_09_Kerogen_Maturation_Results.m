close all

% Define thermal history
maxT = 500; Ti = 100; H = 10; dT = .5;
[t, T] = linearThermalHistory(H, maxT, Ti, dT, true);
RoType = 'EasyDL';

% Define transformation ratio
phiTR = 0:.5:99.999999;
phiTR(1)= .1;
phiTR = phiTR/100;

% Define kerogens
maxPhis = [.71, .43, .12];
kerogenNames = {'I', 'II','III'};
kerogenNamesTR = {'I', 'II', 'IIIN'};

% Define kerogen and oil properties
oilRho = .8;
oilK   = 1.02;
kerogenK = 5.5;
kerogenG = 3.2;
phiAlpha = 1;

% Plotting parameters
makerStyles = {'-', '--', '-.'};
lineWidth = 2.5;

% Initialize figures
f1 = figure('Color', 'White', 'Units','inches', 'Position',[3 3 14 3],'PaperPositionMode','auto');
f2 = figure('Color', 'White', 'Units','inches', 'Position',[3 3 9 3],'PaperPositionMode','auto');

results = [];
for i = 1:numel(kerogenNamesTR)

    % Run pyrolysis
    [phi] = kerogenPorosityMaxPhi(phiTR,  maxPhis(i));
    [~, roTR, Ro] = runPyrolysis(kerogenNamesTR{i}, RoType, t, T);
    [roTR,ia,ic] = unique(roTR);
    Ro = Ro(ia);
    Ro = interp1(roTR, Ro, phiTR);
    
    % Get density
    [hcRatio, hcTR] = calcHcRatio(kerogenNames{i});
    density = kerogenRhoFromHC(hcRatio);
    density = interp1(hcTR, density, phiTR);    
    wetDensity = density.*(1-phi) + phi * oilRho;
    
    % Insert fluid
    K = []; G = [];
    for j = 1:numel(phi)
        [effK,effG,~]=dem1(kerogenK,kerogenG,0,0,phiAlpha, 1,  phi(j));
        K(j)  = gassmnk(effK, 0, oilK, kerogenK, phi(j));
        G(j) = effG;
        [vp(j),vs(j)]=ku2v(K(j)*10^9,G(j)*10^9,wetDensity(j)*1000);
    end
    
    % Accumulate results
    results{i} = [phiTR', Ro', wetDensity', K', G', vp', vs'];

    % Plot results
    figure(f1)
    subplot(1,3,1)
    plot([0, Ro], [wetDensity(i), wetDensity], makerStyles{i}, 'LineWidth', lineWidth); hold on;
    xLocation = 1.3;
    yLocation = interp1(Ro, wetDensity, xLocation);
    text(xLocation,yLocation, repmat('I',[1,i]),'FontName','Times', 'BackgroundColor', 'w', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle')

    subplot(1,3,2)
    plot([0, Ro], [K(i), K], makerStyles{i}, 'LineWidth', lineWidth); hold on;
    xLocation = 1.3;
    yLocation = interp1(Ro, K, xLocation);
    text(xLocation,yLocation, repmat('I',[1,i]),'FontName','Times', 'BackgroundColor', 'w', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle')

    subplot(1,3,3)
    plot([0, Ro], [G(i), G], makerStyles{i}, 'LineWidth', lineWidth); hold on;
    xLocation = 1.3;
    yLocation = interp1(Ro, G, xLocation);
    text(xLocation,yLocation, repmat('I',[1,i]),'FontName','Times', 'BackgroundColor', 'w', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle')

    figure(f2)
    subplot(1,2,1)
    plot([0, Ro], [vp(i), vp], makerStyles{i}, 'LineWidth', lineWidth); hold on;
    xLocation = 1.3;
    yLocation = interp1(Ro, vp, xLocation);
    text(xLocation,yLocation, repmat('I',[1,i]),'FontName','Times', 'BackgroundColor', 'w', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle')

    subplot(1,2,2)
    plot([0, Ro], [vs(i), vs], makerStyles{i}, 'LineWidth', lineWidth); hold on;
    xLocation = 1.3;
    yLocation = interp1(Ro, vs, xLocation);
    text(xLocation,yLocation, repmat('I',[1,i]),'FontName','Times', 'BackgroundColor', 'w', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle')

    textToShow = ['Type ' repmat('I',[1,i])];
    legendText{i} = textToShow;
    
end


% Finalize figures
labelFontSize = 14;
tickFontSize = 12;

figure(f1)
subplot(1,3,1)
ylabel('Wet kerogen density \rho_k (g/cm^3)', 'FontUnits','points', 'FontWeight','normal', 'FontSize',labelFontSize,'FontName','Times')
xlabel('EasyDL vitrinite reflectance %Ro (%)', 'FontUnits','points', 'FontWeight','normal', 'FontSize',labelFontSize,'FontName','Times')
set(gca, 'Units','normalized', 'FontUnits','points', 'FontWeight','normal', 'FontSize',tickFontSize,'FontName','Times')
box on
ylim([.5, 1.6])
xlim([0, 1.6])
legend(legendText, 'Location', 'SouthWest')

subplot(1,3,2)
ylabel('Wet kerogen bulk modulus K (GPa)', 'FontUnits','points', 'FontWeight','normal', 'FontSize',labelFontSize,'FontName','Times')
xlabel('EasyDL vitrinite reflectance %Ro (%)', 'FontUnits','points', 'FontWeight','normal', 'FontSize',labelFontSize,'FontName','Times')
set(gca, 'Units','normalized', 'FontUnits','points', 'FontWeight','normal', 'FontSize',tickFontSize,'FontName','Times')
box on
xlim([0, 1.6])
legend(legendText, 'Location', 'SouthWest')

subplot(1,3,3)
ylabel('Wet kerogen shear modulus G (GPa)', 'FontUnits','points', 'FontWeight','normal', 'FontSize',labelFontSize,'FontName','Times')
xlabel('EasyDL vitrinite reflectance %Ro (%)', 'FontUnits','points', 'FontWeight','normal', 'FontSize',labelFontSize,'FontName','Times')
set(gca, 'Units','normalized', 'FontUnits','points', 'FontWeight','normal', 'FontSize',tickFontSize,'FontName','Times')
box on
xlim([0, 1.6])
ylim([0, 3.5])
legend(legendText, 'Location', 'SouthWest')

figure(f2)
subplot(1,2,1)
ylabel('Compressional velcoity Vp (m/s)', 'FontUnits','points', 'FontWeight','normal', 'FontSize',labelFontSize,'FontName','Times')
xlabel('EasyDL vitrinite reflectance %Ro (%)', 'FontUnits','points', 'FontWeight','normal', 'FontSize',labelFontSize,'FontName','Times')
set(gca, 'Units','normalized', 'FontUnits','points', 'FontWeight','normal', 'FontSize',tickFontSize,'FontName','Times')
box on
xlim([0, 1.6])
legend(legendText, 'Location', 'SouthWest')

subplot(1,2,2)
ylabel('Shear velcoity Vs (m/s)', 'FontUnits','points', 'FontWeight','normal', 'FontSize',labelFontSize,'FontName','Times')
xlabel('EasyDL vitrinite reflectance %Ro (%)', 'FontUnits','points', 'FontWeight','normal', 'FontSize',labelFontSize,'FontName','Times')
set(gca, 'Units','normalized', 'FontUnits','points', 'FontWeight','normal', 'FontSize',tickFontSize,'FontName','Times')
box on
xlim([0, 1.6])
ylim([0, 2000])
legend(legendText, 'Location', 'SouthWest')