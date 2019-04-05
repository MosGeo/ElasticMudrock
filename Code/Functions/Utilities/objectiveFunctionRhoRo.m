function b = objectiveFunctionRhoRo(v, data)

Ro = data(:,1);
Rho = data(:,2);

alpha = v(1);
beta  = v(2);

RhoModel = alpha.*(Ro.^(beta));
RhoModel(Ro<.4) = alpha.*(.4.^(beta));
b = sum((Rho-RhoModel).^2);

end