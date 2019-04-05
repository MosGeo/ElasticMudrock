function PQs = getInclusionShapeParametersFromAspectRatio(Km, Gm, Ki,Gi, alpha)
%getInclusionShapeParametersFromAspectRatio Returns Inclusion Shape Parameters
%   returns the inclusion shape parameters for specific aspect ratio. 
%   Equations are taken from Mavko et al., 2010.
%
%   alpha:      Crack aspect ratio, a disk is a crack of zero thickness.
%   shapeType:  Sphere, Needles, Disks, Penny cracks  
%
%   Mustafa Al Ibrahim (Mustafa.Geoscientist@outlook.com)
%   Febuary, 2017

% Get poisson ratio
getPoissonRatio = @(K, G) (3*K-2*G)./(2*(3*K+G));
vm = getPoissonRatio(Km,Gm);

% Calculate A,B
A = Gi/Gm - 1;
B = 1/3*(Ki/Km - Gi/Gm);

% Calculate R
R = (1-2*vm)/(2*(1-vm));

% Calculate phi
theta = zeros(size(alpha));
a1 = alpha >  1;
% Alpha > 1
theta(a1) = alpha(a1)./(alpha(a1).^2 - 1).^(3/2) .* (alpha(a1) .* (alpha(a1).^2 - 1).^(1/2)-...
    acosh(alpha(a1)));
a1 = alpha <  1;
% Alpha < 1
theta(a1) = alpha(a1)./(1-alpha(a1).^2).^(3/2)   .* (acos(alpha(a1)) - ...
    alpha(a1).*(1-alpha(a1).^2).^(1/2));

f = alpha.^2./(1-alpha.^2) .* (3 * theta -2);

% Calculate Fs
F1 = 1+A.*(3/2*(f+theta) - R*(3/2*f + 5/2*theta - 4/3));

F2 = 1+A.*(1 + 3/2*(f+theta) - 1/2*R*(3*f + 5*theta)) + B.*(3-4*R)+...
    1/2*A.*(A+3*B)*(3-4*R).*(f + theta -R*(f-theta + 2*theta.^2));

F3 = 1 + A.*(1- (f+3/2*theta) + R*(f+theta));

F4 = 1 + 1/4*A.*(f+3*theta-R*(f-theta));

F5 = A.*(-f+R*(f+theta-4/3)) + B.*theta*(3-4*R);

F6 = 1+A.*(1+f-R*(f+theta)) + B.*(1-theta)*(3-4*R);

F7 = 2 + 1/4 * A.*(3*f + 9 * theta - R*(3*f + 5*theta)) + B.*theta*(3-4*R);

F8 = A.*(1-2*R + 1/2*f*(R-1) + 1/2*theta*(5*R-3)) + B.*(1-theta)*(3-4*R);

F9 = A.*((R-1)*f- R*theta) + B.*theta*(3-4*R);


% Calculate T
Pterm = 3*F1./F2;   % Tiijj 
Qterm = 2./F3 + 1./F4 + (F4.*F5 + F6.*F7-F8.*F9)./(F2.*F4); % Tijij - 1/3Tiijj

P= 1/3*Pterm';
Q= 1/5*Qterm';

PQs = [P;Q];


end





