function x = findCriticalSpeed(x, y, m)
% y is deflection (m) and m is mass of element
% want first critical speed at least twice the operating speed

g = 9.81;

%% Rayleigh's Method
% this overestimates the critical speed, so less safe than Dunkerley 

critSpeed_R = sqrt(g*sum(m*g.*y)/sum(m*g.*y.^2))

%% Dunkerley's Equation




end