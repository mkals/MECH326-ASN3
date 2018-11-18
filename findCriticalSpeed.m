function max_speed = findCriticalSpeed(x, y, F)
% y is deflection (m) and m is mass of element
% want first critical speed at least twice the operating speed

g = 9.81;

%% Rayleigh's Method
% this overestimates the critical speed, so less safe than Dunkerley 

critSpeed_R = sqrt(g*sum(F.*y)/sum(F.*y.^2));
max_speed = critSpeed_R / 2;

end