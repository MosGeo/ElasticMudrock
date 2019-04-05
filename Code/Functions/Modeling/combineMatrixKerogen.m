function [output, C] =  combineMatrixKerogen(matrixK, matrixG, matrixRho,...
    kerogenK, kerogenG, kerogenRho, kerogenPercent, isVTI, minAverageType, phiAlpha)


%% Main

    xMatrixPore = 1-kerogenPercent;
    
    if isVTI == 1 % VTI
        [SMatrix,CMatrix] = CSiso(matrixK,matrixG);
        [SKerogen,CKerogen] = CSiso(kerogenK,kerogenG);
        [C]= aniso_bkus(CMatrix,CKerogen,xMatrixPore,kerogenPercent);
        rhoRock = kerogenRho * kerogenPercent +  xMatrixPore * matrixRho;
        [vps,vss,vpf,vsf,e,g,d] = cti2v(C*10^9,rhoRock);
        output = [vps,vss, rhoRock,vpf,vsf,e,g,d];
        
    elseif isVTI == 2 % Mineral
        f = [xMatrixPore, kerogenPercent];
        f = f/sum(f);
        k = [matrixK, kerogenK];
        u = [matrixG, kerogenG]; 
        [k_u,k_l,u_u,u_l,ka,ua]=bound(1,f,k,u);
        
        if minAverageType == 1
          kUsed = k_l;
          uUsed = u_l;
        elseif minAverageType ==2
          kUsed = k_u;
          uUsed = u_u;
        elseif minAverageType ==3
          kUsed = ka;
          uUsed = ua;
        end
        
        rhoRock = kerogenRho * kerogenPercent +  xMatrixPore * matrixRho;
        [vp,vs]=ku2v(kUsed*10^9,uUsed*10^9,rhoRock);  
        output = [vp,vs, rhoRock];
        [~,C] = CSiso(kUsed,uUsed);
        
    elseif isVTI == 3 % DEM
         [kUsed, uUsed] = differentialEffectiveMedium(matrixK, matrixG, kerogenK,kerogenG, kerogenPercent, phiAlpha);
         rhoRock = kerogenRho * kerogenPercent +  xMatrixPore * matrixRho;
         [vp,vs]=ku2v(kUsed*10^9,uUsed*10^9,rhoRock); 
         output = [vp,vs, rhoRock];
         [~,C] = CSiso(kUsed,uUsed);
    elseif isVTI == 4 % HS
       [ku,kl,uu,ul]= hashinShtrikman(matrixK,matrixG,kerogenK,kerogenG, kerogenPercent);
        if minAverageType == 1
          kUsed = kl;
          uUsed = ul;
        elseif minAverageType ==2
          kUsed = ku;
          uUsed = uu;
        elseif minAverageType ==3
          kUsed = mean([kl, ku]);
          uUsed = mean([ul, uu]);
        end
        
        rhoRock = kerogenRho * kerogenPercent +  xMatrixPore * matrixRho;
        [vp,vs]=ku2v(kUsed*10^9,uUsed*10^9,rhoRock);  
        output = [vp,vs, rhoRock];
        [~,C] = CSiso(kUsed,uUsed);

    end

end