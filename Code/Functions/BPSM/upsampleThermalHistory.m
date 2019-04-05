function [t, T] = upsampleThermalHistory(t, T, dT)

% Make sure that small intervals are considered 
 highResTime = [];
 highResTemp = [];
for i = 1:(numel(T)-1)
     
     if (T(i+1)>T(i))
       segmentTemp = (T(i)+dT):dT:(T(i+1)-dT);
     else
       segmentTemp = (T(i)-dT):-dT:(T(i+1)+dT);
     end
     
     segmentTime = interp1(T,t,segmentTemp);
     
     highResTemp = [highResTemp, T(i), segmentTemp];  
     highResTime = [highResTime, t(i), segmentTime];
     
end

highResTemp = [highResTemp, T(end)];  
highResTime = [highResTime, t(end)];

T = highResTemp(:);
t = highResTime(:);

end