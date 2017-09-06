function t = trackDef(delta)
% around 10^-8 accuracy recommended after a lap to make sure that the last
% sector doesn't have a turn radius that is off. 

t = [];
load('track.mat', 'trackSectors')
% most simple possible circuit: a circle
%{
r = 100;
for i = 1:n
    theta = i * pi / n;
    t(i, 1) = cos(theta) * r;
    t(i, 2) = sin(theta) * r;
end
%}

% oval circuit, like Daytona
% starts at bottom right, beginning of curve
% half cirle up, then straight left, half circle down, the right
%{
l = 100;
r = 25;
d = 2*l + 2*r*pi;
for i = 1:floor(d / delta)
    p = i * delta;
    if p < pi * r
        x = l / 2 + r * cos(-pi / 2 + p / r);
        y = r * sin(-pi / 2 + p / r);
    elseif p < pi * r + l
        y = r;
        x = l / 2 - (p - pi * r);
    elseif p < 2 * pi * r + l
        x = - l / 2 + r * cos(-pi / 2 + (p - l) / r);
        y = r * sin(-pi / 2 + (p - l) / r);
    else
        y = -r;
        x = -l / 2 + p - (2 * pi * r + l);
    end
    t(i, 1) = x;
    t(i, 2) = y;
end
%}

%{
x = 0;
y = 0;
theta = 0;
sectorLength = 420 - 18.65454934539435; % adjusted, different from pdf
a = straight(x, y, theta, delta, sectorLength);
t = cat(1, t, a);
x = x + sectorLength * cos(theta * pi / 180);
y = y + sectorLength * sin(theta * pi / 180);

radius = 100;
degrees = 55;
direction = -1;
a = arc(x, y, theta, delta, radius, degrees, direction);
t = cat(1, t, a);
centerX = x + radius * cos(theta * pi / 180 + direction * pi / 2);
centerY = y + radius * sin(theta * pi / 180 + direction * pi / 2);
phi = direction * degrees * pi / 180 + (theta * pi / 180 - direction * pi / 2);
x = centerX + radius * cos(phi);
y = centerY + radius * sin(phi);
theta = theta + direction * degrees;

sectorLength = 260;
a = straight(x, y, theta, delta, sectorLength);
t = cat(1, t, a);
x = x + sectorLength * cos(theta * pi / 180);
y = y + sectorLength * sin(theta * pi / 180);

radius = 40;
degrees = 164;
direction = -1;
a = arc(x, y, theta, delta, radius, degrees, direction);
t = cat(1, t, a);
centerX = x + radius * cos(theta * pi / 180 + direction * pi / 2);
centerY = y + radius * sin(theta * pi / 180 + direction * pi / 2);
phi = direction * degrees * pi / 180 + (theta * pi / 180 - direction * pi / 2);
x = centerX + radius * cos(phi);
y = centerY + radius * sin(phi);
theta = theta + direction * degrees;

sectorLength = 171;
a = straight(x, y, theta, delta, sectorLength);
t = cat(1, t, a);
x = x + sectorLength * cos(theta * pi / 180);
y = y + sectorLength * sin(theta * pi / 180);

radius = 100;
degrees = 53;
direction = 1;
a = arc(x, y, theta, delta, radius, degrees, direction);
t = cat(1, t, a);
centerX = x + radius * cos(theta * pi / 180 + direction * pi / 2);
centerY = y + radius * sin(theta * pi / 180 + direction * pi / 2);
phi = direction * degrees * pi / 180 + (theta * pi / 180 - direction * pi / 2);
x = centerX + radius * cos(phi);
y = centerY + radius * sin(phi);
theta = theta + direction * degrees;

sectorLength = 332;
a = straight(x, y, theta, delta, sectorLength);
t = cat(1, t, a);
x = x + sectorLength * cos(theta * pi / 180);
y = y + sectorLength * sin(theta * pi / 180);

radius = 160 - 26.497152548169; % adjusted, different from pdf
degrees = 194;
direction = -1;
a = arc(x, y, theta, delta, radius, degrees, direction);
t = cat(1, t, a);
centerX = x + radius * cos(theta * pi / 180 + direction * pi / 2);
centerY = y + radius * sin(theta * pi / 180 + direction * pi / 2);
phi = direction * degrees * pi / 180 + (theta * pi / 180 - direction * pi / 2);
x = centerX + radius * cos(phi);
y = centerY + radius * sin(phi);
theta = theta + direction * degrees;
%disp(x);
%disp(y);
%disp(theta);
%}

x = 0; 
y = 0; 
theta = 0;
for i = 1:length(trackSectors)
    if trackSectors(i, 3) == 0
        sectorLength = trackSectors(i, 1);
        a = straight(x, y, theta, delta, sectorLength);
        t = cat(1, t, a);
        x = x + sectorLength * cos(theta * pi / 180);
        y = y + sectorLength * sin(theta * pi / 180);
    else
        direction = trackSectors(i, 3);
        radius = trackSectors(i, 2);
        degrees = trackSectors(i, 1) / pi * 180 / radius;
        a = arc(x, y, theta, delta, radius, degrees, direction);
        t = cat(1, t, a);
        centerX = x + radius * cos(theta * pi / 180 + direction * pi / 2);
        centerY = y + radius * sin(theta * pi / 180 + direction * pi / 2);
        phi = direction * degrees * pi / 180 + (theta * pi / 180 - direction * pi / 2);
        x = centerX + radius * cos(phi);
        y = centerY + radius * sin(phi);
        theta = theta + direction * degrees;
        %disp(theta)
    end
end
%disp(x);
%disp(y);
%disp(theta);
end

% direction is 1 for left turn and -1 for right turn
function t = arc(x, y, theta, delta, radius, degrees, direction)
theta = theta * pi / 180;
arcLength = degrees * pi / 180 * radius;
i = 0;
centerX = x + radius * cos(theta + direction * pi / 2);
centerY = y + radius * sin(theta + direction * pi / 2);
t = zeros(1, 2);
while i * delta < arcLength
    phi = direction * i * delta / radius + (theta - direction * pi / 2);
    t(i+1, 1) = centerX + radius * cos(phi);
    t(i+1, 2) = centerY + radius * sin(phi);
    i = i + 1;
end
end

function t = straight(x, y, theta, delta, sectorLength)
theta = theta * pi / 180;
i = 0;
t = zeros(1, 2);
while i * delta < sectorLength
    t(i+1, 1) = x + i * delta * cos(theta);
    t(i+1, 2) = y + i * delta * sin(theta);
    i = i + 1;
end
end