function a = getMaxBrakeAccel(maxAY, maxAX, currSideAccel)
% braking should probably be limited by the least grippy tire, since
% there is only one pedal controlling all 4 brakes. That is, unless ABS
% makes this significantly better. 

a = sqrt(1 - (currSideAccel / maxAY)^2) * maxAX;
end