close all
clear all

% Define thermal history
maxT = 500;
Ti = 100;
H = 10;
dT = .5;
[t, T] = linearThermalHistory(H, maxT, Ti, dT, true);

% Kerogen and Ro names 
RoType = 'EasyDL';
kerogenNames = {'I', 'II','III'};
kerogenNamesTR = {'I', 'II', 'IIIN'};

% Plotting parameters
lineWidth = 2.5;
makerStyles = {'-', '--', '-.'};

figure('Color', 'White', 'Units','inches', 'Position',[3 3 10 3],'PaperPositionMode','auto');
for i = 1:numel(kerogenNames)
    
    % Calculate density
    [hcRatio, hcTR, wtPerCarbonLoss] = calcHcRatio(kerogenNames{i});
    density = kerogenRhoFromHC(hcRatio);
    results = [wtPerCarbonLoss(:), hcRatio(:)];

    % Run pyrolysis
    [~, roTR, Ro] = runPyrolysis(kerogenNamesTR{i}, RoType, t, T);
    [roTR,ia,ic] = unique(roTR);
    Ro = Ro(ia);
    Ro = interp1(roTR, Ro, hcTR);

    % Plot results
    subplot(1,2,1)
    plot(wtPerCarbonLoss, hcRatio, makerStyles{i}, 'LineWidth', lineWidth); hold on;
    xLocation = .1;
    yLocation = interp1(wtPerCarbonLoss, hcRatio, xLocation);
    textToShow = ['Type ' repmat('I',[1,i])];
    text(xLocation,yLocation, repmat('I',[1,i]),'FontName','Times', 'BackgroundColor', 'w', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle')

    subplot(1,2,2)
    plot([0, Ro], [density(1), density], makerStyles{i}, 'LineWidth', lineWidth); hold on;
    xLocation = .35;
    yLocation = interp1(Ro, density, xLocation);
    textToShow = ['Type ' repmat('I',[1,i])];
    legendText{i} = textToShow;
    text(xLocation,yLocation, repmat('I',[1,i]),'FontName','Times', 'BackgroundColor', 'w', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle')

end

% Finalize figures
labelFontSize = 14;
tickFontSize = 12;

subplot(1,2,1)
xlabel('Wt.% carbon loss (fraction)', 'FontUnits','points', 'FontWeight','normal', 'FontSize',labelFontSize,'FontName','Times')
ylabel('Atomic H/C', 'FontUnits','points', 'FontWeight','normal', 'FontSize',labelFontSize,'FontName','Times')
set(gca, 'Units','normalized', 'FontUnits','points', 'FontWeight','normal', 'FontSize',tickFontSize,'FontName','Times')
box on
ylim([.4, 1.8])
xlim([0, 1])
legend(legendText, 'Location', 'NorthEast')

subplot(1,2,2)
ylabel('Kerogen density \rho_k (g/cc)', 'FontUnits','points', 'FontWeight','normal', 'FontSize',labelFontSize,'FontName','Times')
xlabel('EasyDL vitrinite reflectance %Ro (%)', 'FontUnits','points', 'FontWeight','normal', 'FontSize',labelFontSize,'FontName','Times')
set(gca, 'Units','normalized', 'FontUnits','points', 'FontWeight','normal', 'FontSize',tickFontSize,'FontName','Times')
box on
ylim([0.9, 1.6])
xlim([0, 2.5])
legend(legendText, 'Location', 'SouthEast')
