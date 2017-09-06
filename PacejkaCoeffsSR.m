function x = PacejkaCoeffsSR(pressure, camber, force, slipAngle)
load("Pacejka_Interpolation_SR.mat", "coEff");

p = zeros(1, 144);

pressure = pressure * 0.145038;
force = force / 4.4475 / 50;

for i = 1:4
    for j = 1:3
        for k = 1:4
            for l = 1:3
                temp = pressure^i * camber^j * force^k * slipAngle^l;
                index = i*3*4*3 + j*3*4 + k*3 + l + 1;
                p(index) = temp;
            end
        end
    end
end

x = coEff' * p';
end