function  [Km, Gm, phis, y] = differentialEffectiveMedium(Km, Gm, Ki,Gi,xi, alpha, shapes)
 
   if exist('shapes','var') == false && alpha == 1
       shapes = {'Sphere'};
   end
   
   if (xi ==0)
        phis=0;
        y = [0, Km, Gm];
        return
   end
   
   for i = 1:numel(xi)      
        if exist('shapes','var') == false
         odeMatrix =@(t, Mm) ( ([Ki(i) Gi(i)]-Mm')./(1-t) .* ...
            getInclusionShapeParametersFromAspectRatio(Mm(1),Mm(2),Ki(i),Gi(i), alpha(i))'  )';
        else
        odeMatrix =@(t, Mm) ( ([Ki(i) Gi(i)]-Mm')./(1-t) .* ...
            getInclusionShapeParametersFromShape(Mm(1),Mm(2),Ki(i),Gi(i), shapes(i), alpha(i))'  )';
        end
        
        [phis,y] = ode45(odeMatrix,[0 xi(i)],[Km, Gm]);
        Km = y(end,1);
        Gm = y(end,2);         
   end

end