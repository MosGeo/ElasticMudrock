close all

% Define ranges
TR = 0:.5:99.999999;
TR(1)= .1;
TR = TR/100;
maxPhi = .2:.1:.8;

nRelations = numel(maxPhi);
lineColors = gray(2*nRelations);
lineColors = flipud(lineColors(1:nRelations,:));
 
figure('Color', 'White', 'Units','inches', 'Position',[3 3 6 3.5],'PaperPositionMode','auto');
for i = 1:nRelations
    % Get the porosity and plot it as a function of Ro
    [phi] = kerogenPorosityMaxPhi(TR,  maxPhi(i));
    Ro = TR2RoBordenave(TR);
    plot(Ro, phi, 'Marker', 'none', 'LineStyle', '-',...
        'Color', lineColors(i,:), 'MarkerFaceColor', lineColors(i,:), 'LineWidth', 3); hold on;      
    
    % Insert line name
    xLocation = 1.1;
    yLocation = interp1(Ro, phi, xLocation);
    textToShow = ['\phi_{max} = ' num2str(maxPhi(i))];
    legendText{i} = textToShow;
    text(xLocation,yLocation, num2str(maxPhi(i)),'FontName','Times', 'BackgroundColor', 'w', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle')
end

% Finalize figure
xlim([min(Ro) max(Ro)])
labelFontSize = 14;
tickFontSize = 12;
xlabel({'Vitrinite reflectance %Ro (%)'}, 'FontUnits','points', 'FontWeight','normal', 'FontSize',labelFontSize,'FontName','Times')
ylabel({'Kerogen porosity \phi (fraction)'}, 'FontUnits','points', 'FontWeight','normal', 'FontSize',labelFontSize, 'FontName','Times')
set(gca, 'Units','normalized', 'FontUnits','points', 'FontWeight','normal', 'FontSize',tickFontSize,'FontName','Times')
legend(legendText, 'Location', 'NorthWest')
ylim([0, .82])