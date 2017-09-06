function totalTime = main()
% Lap Time Simulation
% Assumes that the track is a circuit

% all units should be mks
mu = 1.0; % dimensionless coefficient of friction
% note: using small values (<0.1m) of delta can cause problems in 
% determining turn radii of sectors. 
delta = 0.2; % meters approximate sector lengths
t = trackDef(delta);
mass = 226 + 70; % kilograms
Cd = 0.94; % dimensionless coefficient of drag
A = 1.22; % meters squared 
effectiveRadius = 0.2; % meters of wheel

maxTurningVelocities = zeros(1, length(t)); % the velocity at the points of the track
maxBrakingVelocities = zeros(1, length(t));
velocities = zeros(1, length(t));
turnRadii = zeros(1, length(t));
sectorLengths = zeros(1, length(t));
distanceArray = zeros(1, length(t));

% unused code, attempt at backtracing. Don't think it worked out that well.
%{
i = 1;

while i <= maxSteps
    disp(i)
    % getting the current, previous, and next points
    curr = mod(i, length(t));
    if curr < 1
        curr = curr + length(t);
    end
    prev = mod(i-1, length(t));
    if prev < 1
        prev = prev + length(t);
    end
    next = mod(i+1, length(t));
    if next < 1
        next = next + length(t);
    end
    currPos = t(curr, :);
    prevPos = t(prev, :);
    nextPos = t(next, :);
    
    % turn radius calculation
    % deal with zero case
    a = sqrt( (prevPos(1) - nextPos(1))^2 + (prevPos(2) - nextPos(2))^2 );
    % b is current sector length
    b = sqrt( (currPos(1) - nextPos(1))^2 + (currPos(2) - nextPos(2))^2 );
    c = sqrt( (prevPos(1) - currPos(1))^2 + (prevPos(2) - currPos(2))^2 );
    cosA = (b^2 + c^2 - a^2) / (2 * b * c);
    %disp(cosA)
    sinA = sqrt( 1 - cosA^2 );
    %disp(sinA)
    if abs(sinA) > 1e-5
        radius = a / (2 * sinA);
    else
        radius = 0;
    end
    turnRadii(curr) = radius;
    
    % find max turning speed
    if radius > 0
        normalForce = mass * g;
        temp = ( (mass / radius)^2 + ( rho * A * Cd / 2)^2 );
        temp = ( (mu * normalForce )^2 ) / temp;
        maxTurningVelocity = temp^(1/4);
    else
        maxTurningVelocity = 0;
    end
    %disp(maxTurningVelocity);
    
    % engine output
    Fa = (torque / effectiveRadius) - aeroDrag(velocities(curr), Cd);
    %disp(velocities(curr))
    %disp(aeroDrag(velocities(curr), Cd))
    %disp(Fa)
    acceleration = Fa / mass;
    %disp(acceleration)
    if maxTurningVelocity ~= 0
        % find the amount of force that remains after turning and 
        turningAccel = maxTurningVelocity^2 / radius;
        maxForwardAccel = sqrt((mu*g)^2 - turningAccel^2);
        drag = aeroDrag(velocities(curr), Cd) / mass;
        acceleration = min(maxForwardAccel - drag, acceleration);
    end
    %disp(acceleration)
    maxAccelVelocity = sqrt( velocities(curr)^2 + 2 * b * acceleration );
    %disp(maxAccelVelocity);
    
    % first check max exit velocity 
    if (velocities(next) ~= 0 && next ~= length(t))
        entry = getMaxEntrySpeed( velocities(next), b, radius, mu, mass, Cd);
        if entry >= velocities(curr)
            i = i + 1;
        else
            velocities(curr) = entry;
            i = i - 1;
        end
    % then check for turning radius restrictions
    elseif maxTurningVelocity ~= 0
        if velocities(curr) > maxTurningVelocity
            velocities(curr) = maxTurningVelocity;
            i = i - 1;
        else
            velocities(next) = min(maxTurningVelocity, maxAccelVelocity);
            i = i + 1;
        end
    else
        velocities(next) = maxAccelVelocity;
        i = i + 1;
    end
end

%disp(turnRadii)
%disp(velocities)
%}

% This method uses a couple of loops, some forwards, some backwards. 
% This is only compatible with lateral load shifts, and not longitudinal
% load shifts. 

% loop through first time, to find turn radii

for i = 1:length(t)
    curr = i;
    prev = i - 1;
    if prev < 1
        prev = prev + length(t);
    end
    next = i + 1;
    if next > length(t)
        next = next - length(t);
    end
    
    currPos = t(curr, :);
    prevPos = t(prev, :);
    nextPos = t(next, :);
    
    % turn radius calculation
    % deal with zero case
    a = sqrt( (prevPos(1) - nextPos(1))^2 + (prevPos(2) - nextPos(2))^2 );
    % b is current sector length
    b = sqrt( (currPos(1) - nextPos(1))^2 + (currPos(2) - nextPos(2))^2 );
    c = sqrt( (prevPos(1) - currPos(1))^2 + (prevPos(2) - currPos(2))^2 );
    cosA = (b^2 + c^2 - a^2) / (2 * b * c);
    %disp(cosA)
    sinA = sqrt( 1 - cosA^2 );
    %disp(sinA)
    if abs(sinA) > 1e-5
        radius = a / (2 * sinA);
    else
        radius = 0;
    end
    turnRadii(curr) = radius;
    sectorLengths(curr) = b;
end

% second loop through the find maxTurningVelocities
for i = 1:length(t)
    maxTurningVelocities(i) = getMaxTurningVelocity(turnRadii(i), mass, A, Cd, mu);
end

%disp(maxTurningVelocities);

% loop through three times backwards to find braking velocities
for i = 1:(length(t)*3)
    curr = length(t)*3 + 1 - i;
    while curr > length(t)
        curr = curr - length(t);
    end
    next = curr + 1;
    while next > length(t)
        next = next - length(t);
    end
    maxBrakingSpeed = getMaxEntrySpeed( maxBrakingVelocities(next), sectorLengths(curr), turnRadii(curr), mu, mass, Cd);
    
    if maxTurningVelocities(curr) ~= 0
        maxBrakingVelocities(curr) = min(maxTurningVelocities(curr), maxBrakingSpeed);
    else
        maxBrakingVelocities(curr) = maxBrakingSpeed;
    end
end

% disp(maxBrakingVelocities)

% loop through three times forward to take acceleration into account

for i = 1:(length(t)*3)
    curr = i;
    while curr > length(t)
        curr = curr - length(t);
    end
    next = curr + 1;
    while next > length(t)
        next = next - length(t);
    end
    
    maxAccelVelocity = getMaxAccelVelocity(velocities(curr), effectiveRadius, Cd, mass, turnRadii(curr), mu, sectorLengths(curr));
    
    velocities(next) = min(maxAccelVelocity, maxBrakingVelocities(next));
end

% disp(velocities)

% now that velocities have been calculated, find the total time taken.

totalTime = 0;

for i = 1:(length(t))
    curr = i;
    next = i+1;
    while next > length(t)
        next = next - length(t);
    end
    
    distance = sectorLengths(i);
    
    if curr < length(t)
        distanceArray(next) = distanceArray(curr) + distance;
    end
    
    entrySpeed = velocities(curr);
    exitSpeed = velocities(next);
    
    averageSpeed = (entrySpeed + exitSpeed) / 2;
    
    time = distance / averageSpeed;
    
    totalTime = totalTime + time;
end

%disp(velocities)

hold on
%plot(distanceArray, maxBrakingVelocities)
%plot(distanceArray, velocities)
scatter(t(:,1), t(:,2), [], velocities);

end