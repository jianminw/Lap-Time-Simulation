function t = getTorque(rpm)
load('torqueCurve.mat', 'torque')
sort(torque, 1);
i = 1;
while (i <= length(torque) && torque(i, 1) <= rpm)
    i = i + 1;
end
a = i-1;
b = i;
if (a < 1)
    a = a + 1;
    b = b + 1;
end
if (b > length(torque))
    t = 0;
    return
end
m = (torque(b, 2) - torque(a, 2)) / (torque(b, 1) - torque(a, 1));
t = torque(b, 2) + m * (rpm - torque(b, 1));
end