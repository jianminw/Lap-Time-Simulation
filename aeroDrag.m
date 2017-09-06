function d = aeroDrag(speed, Cd)
    rho = 1.225; % kilograms per meter cubed
    A = 1.22; % meters squared 

    d = (rho * A * Cd / 2 * speed^2);
end