function v = getMaxAccelVelocity(velocity, effectiveRadius, Cd, mass, radius, mu, sectorLength)

% Major Problem: In steady state simulations, it is assumed that during a
% turn, the rear wheels have a slip angle of 0, while the front wheels do
% all of the turning. However, this then leads to a conclusion that during
% a turn, the driver is free to punch the gas and accelerate at will, even
% though in a RWD car, doing so would cause oversteer, meaning the rear
% tires lose grip, rather than the front tires. (The last part is from
% experience in video games such as Dirt Rally and Project Cars, and may 
% not represent reality)
    
    g = 9.8; % gravitational acceleration
    % engine output
    rps = velocity / (2 * pi * effectiveRadius);
    rpm = rps * 60;
    torque = getTorque(rpm);
    Fa = (torque / effectiveRadius) - aeroDrag(velocity, Cd);
    acceleration = Fa / mass;
    
    if radius ~= 0
        % find the amount of force that remains after turning and 
        turningAccel = velocity^2 / radius;
        maxForwardAccel = sqrt((mu*g)^2 - turningAccel^2);
        drag = aeroDrag(velocity, Cd) / mass;
        acceleration = min(maxForwardAccel - drag, acceleration);
        %disp(acceleration)
    end
    v = sqrt( velocity^2 + 2 * sectorLength * acceleration );
end
