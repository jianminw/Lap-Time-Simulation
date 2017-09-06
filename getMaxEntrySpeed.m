function v = getMaxEntrySpeed( exitSpeed, sectorLength, radius, mu, mass, Cd)
    g = 9.8; % gravitational acceleration
    % find the amount of force that remains after turning and 
    turningAccel = 0;
    if radius ~= 0
        turningAccel = exitSpeed^2 / radius;
    end
    maxReverseAccel = getMaxBrakeAccel(mu*g, mu*g, turningAccel);
    drag = aeroDrag(exitSpeed, Cd) / mass;
    acceleration = maxReverseAccel + drag;
    v = sqrt( exitSpeed^2 + 2 * sectorLength * acceleration );
end