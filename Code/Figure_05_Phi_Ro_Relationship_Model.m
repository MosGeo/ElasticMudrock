clear
close all

% Define thermal histroy
maxT = 500;
Ti = 100;
H = 10;
dT = .5;
[t, T] = linearThermalHistory(H, maxT, Ti, dT, true);

% Define kerogen type and calculated Ro
RoType = 'EasyDL';
kerogenNames = {'Type I', 'Type II','Type III'};
maxPhis = [.71, .43, .12];
kerogenNamesTR = {'I', 'II', 'IIIN'};

% Define TR
phiTR = 0:.5:99.999999;
phiTR(1)= .1;
phiTR = phiTR/100;
 
% Plotting parameters
makerStyles = {'-', '--', '-.'};
lineWidth = 2.5;

figure('Color', 'White', 'Units','inches', 'Position',[3 3 5 3],'PaperPositionMode','auto');
for i = 1:numel(kerogenNamesTR)

    % Get porosity
    [phi] = kerogenPorosityMaxPhi(phiTR,  maxPhis(i));
    
    % Run pyrolysis
    [~, roTR, Ro] = runPyrolysis(kerogenNamesTR{i}, RoType, t, T);
    [roTR,ia,ic] = unique(roTR);
    Ro = Ro(ia);
    Ro = interp1(roTR, Ro, phiTR);
    
    % Plot with text
    plot([0, Ro], [0, phi], makerStyles{i}, 'LineWidth', lineWidth); hold on;
    textToShow = ['Type ' repmat('I',[1,i])];
    legendText{i} = textToShow;
    xLocation = 1.3;
    yLocation = interp1(Ro, phi, xLocation);
    text(xLocation,yLocation, repmat('I',[1,i]),'FontName','Times', 'BackgroundColor', 'w', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle')
    
end

% Finalize figure
labelFontSize = 14;
tickFontSize = 12;
ylabel('Kerogen porosity \phi_k (fraction)', 'FontUnits','points', 'FontWeight','normal', 'FontSize',labelFontSize,'FontName','Times')
xlabel('EasyDL vitrinite reflectance %Ro (%)', 'FontUnits','points', 'FontWeight','normal', 'FontSize',labelFontSize,'FontName','Times')
set(gca, 'Units','normalized', 'FontUnits','points', 'FontWeight','normal', 'FontSize',tickFontSize,'FontName','Times')
box on
ylim([0, 1])
xlim([0, 1.5])
legend(legendText, 'Location', 'NorthWest')



