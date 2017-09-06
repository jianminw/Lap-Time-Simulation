function x = PacejkaCoeffsSA(pressure, camber, force)
load("Pacejka_Interpolation_SA.mat", "coEff");

p = zeros(1, 100);

pressure = pressure * 0.145038;
force = force / 4.4475 / 50;

for i = 1:4
    for j = 1:5
        for k = 1:5
            temp = pressure^i * camber^j * force^k;
            index = i * 25 + j * 5 + k + 1;
            p(index) = temp;
        end
    end
end

x = coEff' * p';

end