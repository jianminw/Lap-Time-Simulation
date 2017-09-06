function v = getMaxTurningVelocity(radius, mass, A, Cd, mu)
    g = 9.8; % gravitational accelleration
    rho = 1.225; % density of air

    if radius > 0
        normalForce = mass * g;
        temp = ( (mass / radius)^2 + ( rho * A * Cd / 2)^2 );
        temp = ( (mu * normalForce )^2 ) / temp;
        v = temp^(1/4);
    else
        v = 0;
    end
end