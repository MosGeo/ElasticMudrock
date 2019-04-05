function [vp, vs, rho, output] = modelOrganicRichRock(Ro, kerogenK, kerogenG, ...
     fluidK, fluidRho, maxPhi, phiKerogenAlpha, freqType, roModel, kerogenType, maxWtPerCarbonLoss, initialHC,...
     mineralsK, mineralsG, mineralsRho, fractions, phi,phiAlphaMatrix, ...
     minAverageTypeMatrix,  kerogenPercent, vtiIsoDem, minAverageTypeKerogen,...
     kerogenAlpha)

    [kerogenK, kerogenG, kerogenRho, PhiKerogen, TR]  = modelKerogen(Ro, kerogenK, kerogenG, ...
    fluidK, fluidRho, phiKerogenAlpha, freqType, kerogenType, roModel, maxPhi, maxWtPerCarbonLoss, initialHC);
   
   [matrixK, matrixG, matrixRho] = modelMatrix(mineralsK, mineralsG, mineralsRho, fractions,...
   fluidK, fluidRho, phi, phiAlphaMatrix, freqType, minAverageTypeMatrix);

   output =  combineMatrixKerogen(matrixK, matrixG, matrixRho,kerogenK, kerogenG,...
       kerogenRho, kerogenPercent, vtiIsoDem, minAverageTypeKerogen,kerogenAlpha);
  
   vp  = output(1);
   vs  = output(2);
   rho = output(3);

end