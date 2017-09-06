% pressure in kpa
% camber in degrees
% force in Newtons
% slipAngle in degrees
% slipRatio dimensionless. 

function f = TireForces(pressure, camber, force, slipAngle, slipRatio)
maxForce = 300 * 4.4475; % 300lbs in Newtons.
if force > maxForce
    force = maxForce;
end
SACoeffs = PacejkaCoeffsSA(pressure, camber, force);
SRCoeffs = PacejkaCoeffsSR(pressure, camber, force, slipAngle);

x = SACoeffs;
SAPacejka = @(xdata) x(3)*sin(x(2)*atan(x(1)*xdata - x(4)*(x(1)*xdata - atan(x(1)*xdata))));
x = SRCoeffs;
SRPacejka = @(xdata) x(3)*sin(x(2)*atan(x(1)*xdata - x(4)*(x(1)*xdata - atan(x(1)*xdata))));

f = zeros(1, 3);

f(1) = SRPacejka(slipRatio);
f(2) = SAPacejka(slipAngle);
f(3) = force;

end