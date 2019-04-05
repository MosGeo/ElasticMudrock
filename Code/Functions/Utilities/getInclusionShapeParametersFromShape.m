function PQs = getInclusionShapeParametersFromShape(Km, Gm, Ki,Gi, shapeType, alpha)
%getInclusionShapeParameters Returns Inclusion Shape Parameters
%   returns the inclusion shape parameters for spheres, needles, disks, and
%   penny cracks (Based on Berryman, 1995). Equations are taken from Mavko
%   et al., 2010.
%   alpha:      Crack aspect ratio, a disk is a crack of zero thickness.
%   shapeType:  Sphere, Needles, Disks, Penny cracks  
%
%   Mustafa Al Ibrahim (Mustafa.Geoscientist@outlook.com)
%   Febuary, 2017

% Default is spherical shape
if exist('shapeType', 'var') == false; shapeType = 'Sphere'; end;
if exist('alpha', 'var') == false; alpha = 1; end;

% Define the functions needed
getBeta  = @(K, G) G   .* (3*K + G )./ (3*K+4*G);
getGamma = @(K, G) G   .* (3*K + G )./ (3*K+7*G);
getZeta  = @(K, G) G/6 .* (9*K +8.*G)./ ( K +2*G);

% Calculate the needed extra parameters
BetaM  = getBeta(Km, Gm); 
GammaM = getGamma(Km, Gm);
ZetaM  = getZeta(Km, Gm); 

BetaI  = getBeta(Ki, Gi);
GammaI = getGamma(Ki, Gi);
ZetaI  = getZeta(Ki, Gi); 


% Calculate P and Q (shape parameters)
for i = 1:numel(shapeType)
    shapeKey = upper(shapeType{i}(1));
    switch shapeKey
        case 'S' % Sphere
            P(i) = (Km + 4/3*Gm)./(Ki(i)+4/3*Gm);
            Q(i) = (Gm + ZetaM)./(Gi(i)+ZetaM);
        case 'N' % Needles
            P(i) = (Km + Gm + 1/3*Gi(i))./(Ki(i) + Gm + 1/3*Gi(i));
            Q(i) = 1/5*((4*Gm)./(Gm + Gi(i))+ 2*(Gm + GammaM)./(Gi(i) + GammaM)+...
                 (Ki(i) + 4/3*Gm)./(Ki(i) + Gm + 1/3*Gi(i)));
        case 'D' % Disks
            P(i) = (Km+4./3*Gi(i))./(Ki(i)+4./3*Gi(i));
            Q(i) = (Gm + ZetaI(i)) ./(Gi(i)+ZetaI(i));
        case 'P' % Penny cracks
            P(i) = (Km + 4/3*Gi(i))./(Ki(i)+4/3*Gi(i)+pi.*alpha(i).*BetaM);
            Q(i) = 1/5*(1+ (8*Gm)./(4*Gi(i) + pi*alpha(i).*(Gm + 2*BetaM))+...
                2*(Ki(i) + 2/3*(Gi(i) + Gm))./(Ki(i) + 4/3*Gi(i) + pi*alpha(i)*BetaM));
    end
end

PQs = [P;Q];

end



