function plotLogData(logData)

nLogs = size(logData,2)-1;


figure('Color', 'White')

for i=1:nLogs
   subplot(1,nLogs,i) 
   plot(logData{:,i+1}, logData{:,1}, 'LineWidth', 2);
   ylim([min(logData{:,1}), max(logData{:,1})]);
   set(gca,'YDir','reverse')
   title(logData.Properties.VariableNames{i+1})
   if i==1
      ylabel('Depth') 
   else
      set(gca,'yticklabel',[])
   end  
end


end