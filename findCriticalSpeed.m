function max_speed = findCriticalSpeed(x, y, w)
% y is deflection (m) and m is mass of element
% want first critical speed at least twice the operating speed

g = 9.81;

%% Rayleigh's Method
% this overestimates the critical speed, so less safe than Dunkerley 

critSpeed_R = sqrt(abs(g*sum(w.*y)/sum(w.*y.^2)));
max_speed = critSpeed_R / 2;

end